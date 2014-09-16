From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 1/4] net: sched: fix unsued cpu variable
Date: Mon, 15 Sep 2014 23:30:26 -0700
Message-ID: <20140916063024.2905.55403.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:44974 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735AbaIPGhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 02:37:48 -0400
Received: by mail-ob0-f179.google.com with SMTP id wp18so1617586obc.24
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 23:37:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kbuild test robot reported an unused variable cpu in cls_u32.c
after the patch below. This happens when PERF and MARK config
variables are disabled

Fix this is to use separate variables for perf and mark
and define the cpu variable inside the ifdef logic.

'commit 459d5f626da7 ("net: sched: make cls_u32 per cpu")'

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 5ed5ac4..8cffe5a 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -788,8 +788,8 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	} else {
 #ifdef CONFIG_CLS_U32_PERF
 		struct tc_u32_pcnt *gpf;
-#endif
 		int cpu;
+#endif
 
 		if (nla_put(skb, TCA_U32_SEL,
 			    sizeof(n->sel) + n->sel.nkeys*sizeof(struct tc_u32_key),
@@ -816,9 +816,10 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			struct tc_u32_mark mark = {.val = n->val,
 						   .mask = n->mask,
 						   .success = 0};
+			int cpum;
 
-			for_each_possible_cpu(cpu) {
-				__u32 cnt = *per_cpu_ptr(n->pcpu_success, cpu);
+			for_each_possible_cpu(cpum) {
+				__u32 cnt = *per_cpu_ptr(n->pcpu_success, cpum);
 
 				mark.success += cnt;
 			}
