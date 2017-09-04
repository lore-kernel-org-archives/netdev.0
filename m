From: gfree.wind@vip.163.com
Subject: [PATCH net-next 1/1] sched: Use __qdisc_drop instead of kfree_skb in sch_prio and sch_qfq
Date: Mon,  4 Sep 2017 14:21:12 +0800
Message-ID: <1504506072-46207-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:54318 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750782AbdIDGYX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 02:24:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

The commit 520ac30f4551 ("net_sched: drop packets after root qdisc lock
is released) made a big change of tc for performance. There are two points
left in sch_prio and sch_qfq which are not changed with that commit. Now
enhance them now with __qdisc_drop.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 net/sched/sch_prio.c | 2 +-
 net/sched/sch_qfq.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index f31b28f..2dd6c68 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -80,7 +80,7 @@ struct prio_sched_data {
 
 		if (ret & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return ret;
 	}
 #endif
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index cd661a7..6ddfd49 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1215,7 +1215,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		__qdisc_drop(skb, to_free);
 		return err;
 	}
 	pr_debug("qfq_enqueue: cl = %x\n", cl->common.classid);
-- 
1.9.1
