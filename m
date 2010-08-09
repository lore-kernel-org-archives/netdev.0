From: Ben Greear <greearb@candelatech.com>
Subject: [net-next] net:  Use NET_XMIT_SUCCESS where possible.
Date: Mon,  9 Aug 2010 11:43:58 -0700
Message-ID: <1281379438-2709-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57605 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab0HISoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 14:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is based on work originally done by Patric McHardy.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 e114f23... 3406627... M	net/sched/sch_atm.c
:100644 100644 c657628... a5a2915... M	net/sched/sch_sfq.c
:100644 100644 0991c64... 641a30d... M	net/sched/sch_tbf.c
:100644 100644 807643b... feaabc1... M	net/sched/sch_teql.c
 net/sched/sch_atm.c  |    4 ++--
 net/sched/sch_sfq.c  |    2 +-
 net/sched/sch_tbf.c  |    4 ++--
 net/sched/sch_teql.c |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index e114f23..3406627 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -418,7 +418,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	ret = qdisc_enqueue(skb, flow->q);
-	if (ret != 0) {
+	if (ret != NET_XMIT_SUCCESS) {
 drop: __maybe_unused
 		if (net_xmit_drop_count(ret)) {
 			sch->qstats.drops++;
@@ -442,7 +442,7 @@ drop: __maybe_unused
 	 */
 	if (flow == &p->link) {
 		sch->q.qlen++;
-		return 0;
+		return NET_XMIT_SUCCESS;
 	}
 	tasklet_schedule(&p->task);
 	return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index c657628..a5a2915 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -323,7 +323,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (++sch->q.qlen <= q->limit) {
 		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
-		return 0;
+		return NET_XMIT_SUCCESS;
 	}
 
 	sfq_drop(sch);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 0991c64..641a30d 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -127,7 +127,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		return qdisc_reshape_fail(skb, sch);
 
 	ret = qdisc_enqueue(skb, q->qdisc);
-	if (ret != 0) {
+	if (ret != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret))
 			sch->qstats.drops++;
 		return ret;
@@ -136,7 +136,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	sch->q.qlen++;
 	sch->bstats.bytes += qdisc_pkt_len(skb);
 	sch->bstats.packets++;
-	return 0;
+	return NET_XMIT_SUCCESS;
 }
 
 static unsigned int tbf_drop(struct Qdisc* sch)
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 807643b..feaabc1 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -85,7 +85,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		__skb_queue_tail(&q->q, skb);
 		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
-		return 0;
+		return NET_XMIT_SUCCESS;
 	}
 
 	kfree_skb(skb);
-- 
1.6.2.5

