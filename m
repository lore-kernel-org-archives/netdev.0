From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 7/7] Remove comments about hardcoded values.
Date: Sun, 29 Jul 2007 17:21:16 -0700
Message-ID: <11857548781809-git-send-email-bugfood-ml@fatooh.org>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:37094 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965440AbXG3AVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 20:21:23 -0400
In-Reply-To: <11857548771998-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

None of these are true anymore (hooray!).

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 include/linux/pkt_sched.h |    8 --------
 net/sched/sch_sfq.c       |   17 +++--------------
 2 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 268c515..58a0ea6 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -148,14 +148,6 @@ struct tc_sfq_qopt
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
-/*
- *  NOTE: limit, divisor and flows are hardwired to code at the moment.
- *
- *	limit=flows=128, divisor=1024;
- *
- *	The only reason for this is efficiency, it is possible
- *	to change these parameters in compile time.
- */
 
 /* RED section */
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index e042cd0..3890452 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -61,18 +61,7 @@
 
 	We still need true WFQ for top level CSZ, but using WFQ
 	for the best effort traffic is absolutely pointless:
-	SFQ is superior for this purpose.
-
-	IMPLEMENTATION:
-	This implementation limits maximal queue length to 128;
-	maximal mtu to 2^15-1; number of hash buckets to 1024.
-	The only goal of this restrictions was that all data
-	fit into one 4K page :-). Struct sfq_sched_data is
-	organized in anti-cache manner: all the data for a bucket
-	are scattered over different locations. This is not good,
-	but it allowed me to put it into 4K.
-
-	It is easy to increase these values, but not in flight.  */
+	SFQ is superior for this purpose. */
 
 #define SFQ_DEPTH_DEFAULT	128
 #define SFQ_DIVISOR_DEFAULT	1024
@@ -491,7 +480,7 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 	struct sfq_sched_data tmp;
 	struct sk_buff *skb;
 	int err;
-	
+
 	/* set up tmp queue */
 	memset(&tmp, 0, sizeof(struct sfq_sched_data));
 	tmp.quantum = psched_mtu(sch->dev); /* default */
@@ -504,7 +493,7 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 		sfq_drop(sch);
 	while ((skb = sfq_q_dequeue(q)) != NULL)
 		sfq_q_enqueue(skb, &tmp, SFQ_TAIL);
-	
+
 	/* clean up the old queue */
 	sfq_q_destroy(q);
 
-- 
1.5.2.4

