From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next/iproute 2/5] tc: bash-completion: Prepare
 action autocomplete to support several actions
Date: Mon, 6 Feb 2017 14:10:55 -0800
Message-ID: <20170206141055.5c9f7610@xeon-e3>
References: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
        <1486387164-40404-3-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com,
        jiri@mellanox.com, jhs@mojatatu.com, mrv@mojatatu.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34120 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751172AbdBFWLD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 17:11:03 -0500
Received: by mail-pg0-f42.google.com with SMTP id 14so31932535pgg.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 14:11:03 -0800 (PST)
In-Reply-To: <1486387164-40404-3-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  6 Feb 2017 15:19:21 +0200
Yotam Gigi <yotamg@mellanox.com> wrote:

> The action autocomplete routine (_tc_action_options) currently does not
> support several actions statements in one tc command line as it uses the
> _tc_once_attr and _tc_one_from_list.
> 
> For example, in that case:
> 
> $ tc filter add dev eth0 handle ffff: u32 [...]  \
> 	   action sample group 5 rate 12 	 \
> 	   action sample <TAB>
> 
> the _tc_once_attr function, when invoked with "group rate" will not
> suggest those as they already exist on the command line.
> 
> Fix the function to use the _from variant, thus allowing each action
> autocomplete start from the action keyword, and not from the beginning of
> the command line.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

This patch does not apply cleanly to current iproute2 net-next tree.
Please rebase and resubmit the whole series again.


$ cat bash-completion/tc.rej 
--- bash-completion/tc
+++ bash-completion/tc
@@ -454,26 +454,28 @@ _tc_filter_options()
 # Returns 0 is completion should stop after running this function, 1 otherwise.
 _tc_action_options()
 {
-    case $1 in
+    local from=$1
+    local action=${words[from]}
+    case $action in
         bpf)
             _tc_bpf_options
             return 0
             ;;
         mirred)
-            _tc_one_of_list 'ingress egress'
-            _tc_one_of_list 'mirror redirect'
-            _tc_once_attr 'index dev'
+            _tc_one_of_list_from $from 'ingress egress'
+            _tc_one_of_list_from $from 'mirror redirect'
+            _tc_once_attr_from $from 'index dev'
             return 0
             ;;
         sample)
-            _tc_once_attr 'rate'
-            _tc_once_attr 'trunc'
-            _tc_once_attr 'group'
+            _tc_once_attr_from $from 'rate'
+            _tc_once_attr_from $from 'trunc'
+            _tc_once_attr_from $from 'group'
             return 0
             ;;
         gact)
-            _tc_one_of_list 'reclassify drop continue pass'
-            _tc_once_attr 'random'
+            _tc_one_of_list_from $from 'reclassify drop continue pass'
+            _tc_once_attr_from $from 'random'
             return 0
             ;;
     esac
