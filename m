From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next/iproute 1/5] tc: bash-completion: Add the _from variant to _tc_one* funcs
Date: Mon,  6 Feb 2017 15:19:20 +0200
Message-ID: <1486387164-40404-2-git-send-email-yotamg@mellanox.com>
References: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        eladr@mellanox.com, idosch@mellanox.com, jiri@mellanox.com,
        jhs@mojatatu.com, mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51768 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751321AbdBFNQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 08:16:50 -0500
In-Reply-To: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The _tc_one_of_list and _tc_once_attr functions simplfy the bash
completion task by validating each attr exist only once on the command
line.

For example, for the command line:

$ a b c d e

and the call to _tc_once_attr with "a f g", the function will suggest
"f g" as "a" existed in the command line in args 0.

Add the _from variant to those functions, which allows having the command
line option once from a specified index. In the previous example, calling
_tc_once_attr with 4 and "a f g" will suggest "a f g".

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 bash-completion/tc | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/bash-completion/tc b/bash-completion/tc
index ed2796d..04f969e 100644
--- a/bash-completion/tc
+++ b/bash-completion/tc
@@ -20,6 +20,26 @@ _tc_once_attr()
     done
 }
 
+# Takes a list of words in argument; each one of them is added to COMPREPLY if
+# it is not already present on the command line from the provided index. Returns
+# no value.
+_tc_once_attr_from()
+{
+    local w subcword found from=$1
+    shift
+    for w in $*; do
+        found=0
+        for (( subcword=$from; subcword < ${#words[@]}-1; subcword++ )); do
+            if [[ $w == ${words[subcword]} ]]; then
+                found=1
+                break
+            fi
+        done
+        [[ $found -eq 0 ]] && \
+            COMPREPLY+=( $( compgen -W "$w" -- "$cur" ) )
+    done
+}
+
 # Takes a list of words in argument; adds them all to COMPREPLY if none of them
 # is already present on the command line. Returns no value.
 _tc_one_of_list()
@@ -33,6 +53,21 @@ _tc_one_of_list()
     COMPREPLY+=( $( compgen -W "$*" -- "$cur" ) )
 }
 
+# Takes a list of words in argument; adds them all to COMPREPLY if none of them
+# is already present on the command line from the provided index. Returns no
+# value.
+_tc_one_of_list_from()
+{
+    local w subcword from=$1
+    shift
+    for w in $*; do
+        for (( subcword=$from; subcword < ${#words[@]}-1; subcword++ )); do
+            [[ $w == ${words[subcword]} ]] && return 1
+        done
+    done
+    COMPREPLY+=( $( compgen -W "$*" -- "$cur" ) )
+}
+
 # Returns "$cur ${cur}arg1 ${cur}arg2 ..."
 _tc_expand_units()
 {
-- 
2.4.11
