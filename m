From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH net-next/iproute 2/5] tc: bash-completion: Prepare action
 autocomplete to support several actions
Date: Tue, 7 Feb 2017 05:09:38 +0000
Message-ID: <DB3PR05MB07640AEE7C65C37ACCB67A20AC430@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
        <1486387164-40404-3-git-send-email-yotamg@mellanox.com>
 <20170206141055.5c9f7610@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Elad Raz <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "mrv@mojatatu.com" <mrv@mojatatu.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40077.outbound.protection.outlook.com ([40.107.4.77]:32288
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751164AbdBGFJn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 00:09:43 -0500
In-Reply-To: <20170206141055.5c9f7610@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Stephen Hemminger [mailto:stephen@networkplumber.org]
>Sent: Tuesday, February 07, 2017 12:11 AM
>To: Yotam Gigi <yotamg@mellanox.com>
>Cc: netdev@vger.kernel.org; Elad Raz <eladr@mellanox.com>; Ido Schimmel
><idosch@mellanox.com>; Jiri Pirko <jiri@mellanox.com>; jhs@mojatatu.com;
>mrv@mojatatu.com
>Subject: Re: [PATCH net-next/iproute 2/5] tc: bash-completion: Prepare act=
ion
>autocomplete to support several actions
>
>On Mon,  6 Feb 2017 15:19:21 +0200
>Yotam Gigi <yotamg@mellanox.com> wrote:
>
>> The action autocomplete routine (_tc_action_options) currently does not
>> support several actions statements in one tc command line as it uses the
>> _tc_once_attr and _tc_one_from_list.
>>
>> For example, in that case:
>>
>> $ tc filter add dev eth0 handle ffff: u32 [...]  \
>> 	   action sample group 5 rate 12 	 \
>> 	   action sample <TAB>
>>
>> the _tc_once_attr function, when invoked with "group rate" will not
>> suggest those as they already exist on the command line.
>>
>> Fix the function to use the _from variant, thus allowing each action
>> autocomplete start from the action keyword, and not from the beginning o=
f
>> the command line.
>>
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>
>This patch does not apply cleanly to current iproute2 net-next tree.
>Please rebase and resubmit the whole series again.

Sorry for that. I will send it again.

Thanks!

>
>
>$ cat bash-completion/tc.rej
>--- bash-completion/tc
>+++ bash-completion/tc
>@@ -454,26 +454,28 @@ _tc_filter_options()
> # Returns 0 is completion should stop after running this function, 1 othe=
rwise.
> _tc_action_options()
> {
>-    case $1 in
>+    local from=3D$1
>+    local action=3D${words[from]}
>+    case $action in
>         bpf)
>             _tc_bpf_options
>             return 0
>             ;;
>         mirred)
>-            _tc_one_of_list 'ingress egress'
>-            _tc_one_of_list 'mirror redirect'
>-            _tc_once_attr 'index dev'
>+            _tc_one_of_list_from $from 'ingress egress'
>+            _tc_one_of_list_from $from 'mirror redirect'
>+            _tc_once_attr_from $from 'index dev'
>             return 0
>             ;;
>         sample)
>-            _tc_once_attr 'rate'
>-            _tc_once_attr 'trunc'
>-            _tc_once_attr 'group'
>+            _tc_once_attr_from $from 'rate'
>+            _tc_once_attr_from $from 'trunc'
>+            _tc_once_attr_from $from 'group'
>             return 0
>             ;;
>         gact)
>-            _tc_one_of_list 'reclassify drop continue pass'
>-            _tc_once_attr 'random'
>+            _tc_one_of_list_from $from 'reclassify drop continue pass'
>+            _tc_once_attr_from $from 'random'
>             return 0
>             ;;
>     esac
