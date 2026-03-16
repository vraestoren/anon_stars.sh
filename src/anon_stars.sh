#!/bin/bash

user_id=null
id_token=null
auth_token=null
unity_version="2021.3.16f1"
api="https://anon-stars.ml/api/v1"
idtk_api_key="AIzaSyB-PMkQ22u9AYKUPZKlfYF_mN8ssnP4Myk"
idtk_api="https://www.googleapis.com/identitytoolkit/v3/relyingparty"
user_agent="UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)"

function _request() {
    curl --request "$1" \
        --url "$2" \
        --user-agent "$user_agent" \
        --header "accept: application/json" \
        --header "content-type: application/json" \
        --header "x-unity-version: $unity_version" \
        ${3:+--data "$3"}
}

function _get()  {
	_request GET  "$1";
}
function _post() {
	_request POST "$1" "$2"; 
}

function _idtk() { 
	_request POST "$idtk_api/$1?key=$idtk_api_key" "$2"; 
}

function login() {
    local response
    response=$(_idtk "verifyPassword" "{\"email\":\"$1\",\"password\":\"$2\",\"returnSecureToken\":\"true\"}")
    if [ -n "$(jq -r '.idToken' <<< "$response")" ]; then
        user_id=$(jq -r '.localId' <<< "$response")
        id_token=$(jq -r '.idToken' <<< "$response")
    fi
    echo "$response"
    get_auth_token "$1" "$2"
}

function register() {
    _idtk "signupNewUser" "{\"email\":\"$1\",\"password\":\"$2\"}"
}

function get_oob_confirmation_code() {
    _idtk "getOobConfirmationCode" "{\"requestType\":\"4\",\"idToken\":\"$1\"}"
}

function get_account_info() {
    _idtk "getAccountInfo" "{\"idToken\":\"$id_token\"}"
}

function change_password() {
    _idtk "setAccountInfo" "{\"returnSecureToken\":\"true\",\"idToken\":\"$id_token\",\"password\":\"$1\"}"
}

function sign_up() {
    _post "$api/auth/signup?uid=$1&handle=$2"
}

function get_auth_token() {
    local response
    response=$(_get "$api/auth/get_token?email=$1&password=$2")
    if [ "$(jq -r '.code' <<< "$response")" == "200" ]; then
        auth_token=$(jq -r '.message' <<< "$response")
    fi
}

function get_internal_data() {
    _get "$api/data/get_internal_data?uid=$user_id&authToken=$auth_token"
}

function get_visible_data() {
    _get "$api/data/get_visible_data?uid=$user_id"
}

function change_nickname() {
    _post "$api/auth/change_handle?uid=$user_id&handle=$1&authToken=$auth_token"
}

function add_resource() {
    _post "$api/data/add_resource?uid=$user_id&authToken=$auth_token&resourceType=$1&resourceCount=$2"
}

function add_anon() {
    _post "$api/data/add_anon?uid=$user_id&authToken=$auth_token&anon=$1"
}

function set_main_anon() {
    _post "$api/data/set_main_anon?uid=$user_id&authToken=$auth_token&anon=$1"
}

function upgrade_anon() {
    _post "$api/data/upgrade_anon?uid=$user_id&authToken=$auth_token&anon=$1"
}

function change_color_code() {
    _post "$api/data/upgrade_anon?uid=$user_id&authToken=$auth_token&colorcode=$1"
}
