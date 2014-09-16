From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 1/3] net: sched: fix unsued cpu variable
Date: Mon, 15 Sep 2014 19:47:33 -0700
Message-ID: <20140916024729.3010.47421.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:50966 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992AbaIPCrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 22:47:52 -0400
Received: by mail-ob0-f179.google.com with SMTP id wp18so1465671obc.10
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 19:47:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kbuild test robot reported an unused variable cpu in cls_u32.c
after the patch below. This happens when PERF and MARK config
variables are disabled

commit 459d5f626da75573e985a7197b0919c3b143146c
Author: John Fastabend <john.fastabend@gmail.com>
Date:   Fri Sep 12 20:08:47 2014 -0700

    net: sched: make cls_u32 per cpu

Fix this is to use separate variables for perf and mark
and define the cpu variable inside the ifdef logic.

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
