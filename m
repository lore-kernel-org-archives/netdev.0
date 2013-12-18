From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 1/2] net_sched: replace pr_warning with pr_warn
Date: Wed, 18 Dec 2013 20:04:51 +0800
Message-ID: <1387368292-18120-2-git-send-email-yangyingliang@huawei.com>
References: <1387368292-18120-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32236 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443Ab3LRMFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 07:05:01 -0500
In-Reply-To: <1387368292-18120-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefer pr_warn(... to pr_warning(...

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_cbq.c    |  4 ++--
 net/sched/sch_dsmark.c |  4 ++--
 net/sched/sch_gred.c   |  4 ++--
 net/sched/sch_htb.c    | 12 +++++-------
 4 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index e251833..2f80d01 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1060,8 +1060,8 @@ static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
 			}
 			if (cl->quantum <= 0 ||
 			    cl->quantum > 32*qdisc_dev(cl->qdisc)->mtu) {
-				pr_warning("CBQ: class %08x has bad quantum==%ld, repaired.\n",
-					   cl->common.classid, cl->quantum);
+				pr_warn("CBQ: class %08x has bad quantum==%ld, repaired.\n",
+					cl->common.classid, cl->quantum);
 				cl->quantum = qdisc_dev(cl->qdisc)->mtu/2 + 1;
 			}
 		}
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 0952fd2..7cd49e5 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -303,8 +303,8 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 		 * and don't need yet another qdisc as a bypass.
 		 */
 		if (p->mask[index] != 0xff || p->value[index])
-			pr_warning("dsmark_dequeue: unsupported protocol %d\n",
-				   ntohs(skb->protocol));
+			pr_warn("dsmark_dequeue: unsupported protocol %d\n",
+				ntohs(skb->protocol));
 		break;
 	}
 
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index d42234c..fb621d2 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -370,8 +370,8 @@ static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
 
 	for (i = table->DPs; i < MAX_DPs; i++) {
 		if (table->tab[i]) {
-			pr_warning("GRED: Warning: Destroying "
-				   "shadowed VQ 0x%x\n", i);
+			pr_warn("GRED: Warning: Destroying "
+				"shadowed VQ 0x%x\n", i);
 			gred_destroy_vq(table->tab[i]);
 			table->tab[i] = NULL;
 		}
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 830c64f..5c5f01c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -712,7 +712,7 @@ static s64 htb_do_events(struct htb_sched *q, const int level,
 
 	/* too much load - let's continue after a break for scheduling */
 	if (!(q->warned & HTB_WARN_TOOMANYEVENTS)) {
-		pr_warning("htb: too many events!\n");
+		pr_warn("htb: too many events!\n");
 		q->warned |= HTB_WARN_TOOMANYEVENTS;
 	}
 
@@ -1477,15 +1477,13 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	if (!cl->level) {
 		cl->quantum = hopt->rate.rate / q->rate2quantum;
 		if (!hopt->quantum && cl->quantum < 1000) {
-			pr_warning(
-			       "HTB: quantum of class %X is small. Consider r2q change.\n",
-			       cl->common.classid);
+			pr_warn("HTB: quantum of class %X is small. Consider r2q change.\n",
+				cl->common.classid);
 			cl->quantum = 1000;
 		}
 		if (!hopt->quantum && cl->quantum > 200000) {
-			pr_warning(
-			       "HTB: quantum of class %X is big. Consider r2q change.\n",
-			       cl->common.classid);
+			pr_warn("HTB: quantum of class %X is big. Consider r2q change.\n",
+				cl->common.classid);
 			cl->quantum = 200000;
 		}
 		if (hopt->quantum)
-- 
1.8.0
