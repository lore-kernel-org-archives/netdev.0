From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 07/10] Remove comments about hardcoded values.
Date: Fri, 28 Sep 2007 15:52:54 -0700
Message-ID: <11910199772144-git-send-email-bugfood-ml@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:42866 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754582AbXI1WxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 18:53:08 -0400
In-Reply-To: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
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
index b8e8fa5..341a9a1 100644
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
@@ -521,7 +510,7 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 	struct sk_buff *skb;
 	unsigned int qlen;
 	int err;
-	
+
 	/* set up tmp queue */
 	memset(&tmp, 0, sizeof(struct sfq_sched_data));
 	sfq_copy_parameters(&tmp, q);
@@ -536,7 +525,7 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 	while ((skb = sfq_q_dequeue(q)) != NULL)
 		sfq_q_enqueue(skb, &tmp, SFQ_TAIL);
-	
+
 	/* clean up the old queue */
 	sfq_q_destroy(q);
 
-- 
1.5.3

