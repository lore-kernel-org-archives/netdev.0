From: Patrick McHardy <kaber@trash.net>
Subject: [RFC net-sched 01/03]: use symbolic NET_XMIT constants in qdiscs
Date: Tue,  9 Jun 2009 18:17:00 +0200 (MEST)
Message-ID: <20090609161659.6730.92739.sendpatchset@x2.localnet>
References: <20090609161658.6730.59754.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33720 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756681AbZFIQQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 12:16:58 -0400
In-Reply-To: <20090609161658.6730.59754.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 49ffbac7a80175238e550479c44e1e897bc56911
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jun 9 17:55:06 2009 +0200

    net-sched: use symbolic NET_XMIT constants in qdiscs
    
    Convert the remaining spots using raw values to use the symbolic NET_XMIT constants.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 2a8b83a..15f06ce 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -431,7 +431,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	ret = qdisc_enqueue(skb, flow->q);
-	if (ret != 0) {
+	if (ret != NET_XMIT_SUCCESS) {
 drop: __maybe_unused
 		if (net_xmit_drop_count(ret)) {
 			sch->qstats.drops++;
@@ -455,7 +455,7 @@ drop: __maybe_unused
 	 */
 	if (flow == &p->link) {
 		sch->q.qlen++;
-		return 0;
+		return NET_XMIT_SUCCESS;
 	}
 	tasklet_schedule(&p->task);
 	return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8706920..b994569 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -322,7 +322,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (++sch->q.qlen <= q->limit) {
 		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
-		return 0;
+		return NET_XMIT_SUCCESS;
 	}
 
 	sfq_drop(sch);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index e22dfe8..407fa57 100644
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
index cb1cb1e..2b4f5ef 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -84,7 +84,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		__skb_queue_tail(&q->q, skb);
 		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
-		return 0;
+		return NET_XMIT_SUCCESS;
 	}
 
 	kfree_skb(skb);
