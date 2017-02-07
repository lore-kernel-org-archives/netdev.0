From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next/iproute v2 3/5] tc: bash-completion: Make the *_KIND variables global
Date: Tue,  7 Feb 2017 15:50:50 +0200
Message-ID: <1486475452-39214-4-git-send-email-yotamg@mellanox.com>
References: <1486475452-39214-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        eladr@mellanox.com, idosch@mellanox.com, jiri@mellanox.com,
        jhs@mojatatu.com, mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38675 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754168AbdBGNsW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 08:48:22 -0500
In-Reply-To: <1486475452-39214-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The QDISC_KIND, FILTER_KIND, ACTION_KIND variables may be used by other
routines, thus make them global variables.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 bash-completion/tc | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/bash-completion/tc b/bash-completion/tc
index c854dc0..e23f69c 100644
--- a/bash-completion/tc
+++ b/bash-completion/tc
@@ -2,6 +2,12 @@
 # Copyright 2016 6WIND S.A.
 # Copyright 2016 Quentin Monnet <quentin.monnet@6wind.com>
 
+QDISC_KIND=' choke codel bfifo pfifo pfifo_head_drop fq fq_codel gred hhf \
+            mqprio multiq netem pfifo_fast pie red rr sfb sfq tbf atm cbq drr \
+            dsmark hfsc htb prio qfq '
+FILTER_KIND=' basic bpf cgroup flow flower fw route rsvp tcindex u32 '
+ACTION_KIND=' gact mirred bpf sample '
+
 # Takes a list of words in argument; each one of them is added to COMPREPLY if
 # it is not already present on the command line. Returns no value.
 _tc_once_attr()
@@ -605,10 +611,7 @@ _tc()
                         COMPREPLY=( $( compgen -W 'dev' -- "$cur" ) )
                         return 0
                     fi
-                    local qdisc qdwd QDISC_KIND=' choke codel bfifo pfifo \
-                        pfifo_head_drop fq fq_codel gred hhf mqprio multiq \
-                        netem pfifo_fast pie red rr sfb sfq tbf atm cbq drr \
-                        dsmark hfsc htb prio qfq '
+                    local qdisc qdwd
                     for ((qdwd=$subcword; qdwd < ${#words[@]}-1; qdwd++)); do
                         if [[ $QDISC_KIND =~ ' '${words[qdwd]}' ' ]]; then
                             qdisc=${words[qdwd]}
@@ -643,10 +646,7 @@ _tc()
                         COMPREPLY=( $( compgen -W 'dev' -- "$cur" ) )
                         return 0
                     fi
-                    local qdisc qdwd QDISC_KIND=' choke codel bfifo pfifo \
-                        pfifo_head_drop fq fq_codel gred hhf mqprio multiq \
-                        netem pfifo_fast pie red rr sfb sfq tbf atm cbq drr \
-                        dsmark hfsc htb prio qfq '
+                    local qdisc qdwd
                     for ((qdwd=$subcword; qdwd < ${#words[@]}-1; qdwd++)); do
                         if [[ $QDISC_KIND =~ ' '${words[qdwd]}' ' ]]; then
                             qdisc=${words[qdwd]}
@@ -681,8 +681,7 @@ _tc()
                         COMPREPLY=( $( compgen -W 'dev' -- "$cur" ) )
                         return 0
                     fi
-                    local filter fltwd FILTER_KIND=' basic bpf cgroup flow \
-                        flower fw route rsvp tcindex u32 '
+                    local filter fltwd
                     for ((fltwd=$subcword; fltwd < ${#words[@]}-1; fltwd++));
                     do
                         if [[ $FILTER_KIND =~ ' '${words[fltwd]}' ' ]]; then
@@ -714,7 +713,7 @@ _tc()
         action)
             case $subcmd in
                 add|change|replace)
-                    local action acwd ACTION_KIND=' gact mirred bpf sample '
+                    local action acwd
                     for ((acwd=$subcword; acwd < ${#words[@]}-1; acwd++)); do
                         if [[ $ACTION_KIND =~ ' '${words[acwd]}' ' ]]; then
                             _tc_action_options $acwd && return 0
-- 
2.4.11
