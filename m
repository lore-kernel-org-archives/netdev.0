From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 02/05]: Rename qdisc helpers for built-in queue
Date: Sun, 20 Jan 2008 19:28:52 +0100 (MET)
Message-ID: <20080120182851.10972.34292.sendpatchset@localhost.localdomain>
References: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64050 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702AbYATS2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 13:28:53 -0500
In-Reply-To: <20080120182848.10972.46380.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c1f4198dd24ce854b7d55d0ed23a61d36d7defc9
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 2 21:35:21 2008 +0100

    [NET_SCHED]: Rename qdisc helpers for built-in queue
    
    Rename all helper functions dealing with the built-in queue of
    struct Qdisc (sch->q) to qdisc_q_... to make the naming more
    consistent and avoid naming clashes with the next patch, which
    introduces a few simple helpers that should logically use those
    names.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 60b4b35..3ade673 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -180,8 +180,8 @@ extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
 extern void tcf_destroy(struct tcf_proto *tp);
 extern void tcf_destroy_chain(struct tcf_proto *fl);
 
-static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
-				       struct sk_buff_head *list)
+static inline int __qdisc_q_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
+					 struct sk_buff_head *list)
 {
 	__skb_queue_tail(list, skb);
 	sch->qstats.backlog += skb->len;
@@ -191,13 +191,13 @@ static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 	return NET_XMIT_SUCCESS;
 }
 
-static inline int qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch)
+static inline int qdisc_q_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch)
 {
-	return __qdisc_enqueue_tail(skb, sch, &sch->q);
+	return __qdisc_q_enqueue_tail(skb, sch, &sch->q);
 }
 
-static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
-						   struct sk_buff_head *list)
+static inline struct sk_buff *__qdisc_q_dequeue_head(struct Qdisc *sch,
+						     struct sk_buff_head *list)
 {
 	struct sk_buff *skb = __skb_dequeue(list);
 
@@ -207,13 +207,13 @@ static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
 	return skb;
 }
 
-static inline struct sk_buff *qdisc_dequeue_head(struct Qdisc *sch)
+static inline struct sk_buff *qdisc_q_dequeue_head(struct Qdisc *sch)
 {
-	return __qdisc_dequeue_head(sch, &sch->q);
+	return __qdisc_q_dequeue_head(sch, &sch->q);
 }
 
-static inline struct sk_buff *__qdisc_dequeue_tail(struct Qdisc *sch,
-						   struct sk_buff_head *list)
+static inline struct sk_buff *__qdisc_q_dequeue_tail(struct Qdisc *sch,
+						     struct sk_buff_head *list)
 {
 	struct sk_buff *skb = __skb_dequeue_tail(list);
 
@@ -223,13 +223,13 @@ static inline struct sk_buff *__qdisc_dequeue_tail(struct Qdisc *sch,
 	return skb;
 }
 
-static inline struct sk_buff *qdisc_dequeue_tail(struct Qdisc *sch)
+static inline struct sk_buff *qdisc_q_dequeue_tail(struct Qdisc *sch)
 {
-	return __qdisc_dequeue_tail(sch, &sch->q);
+	return __qdisc_q_dequeue_tail(sch, &sch->q);
 }
 
-static inline int __qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch,
-				  struct sk_buff_head *list)
+static inline int __qdisc_q_requeue(struct sk_buff *skb, struct Qdisc *sch,
+				    struct sk_buff_head *list)
 {
 	__skb_queue_head(list, skb);
 	sch->qstats.backlog += skb->len;
@@ -238,13 +238,13 @@ static inline int __qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch,
 	return NET_XMIT_SUCCESS;
 }
 
-static inline int qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch)
+static inline int qdisc_q_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	return __qdisc_requeue(skb, sch, &sch->q);
+	return __qdisc_q_requeue(skb, sch, &sch->q);
 }
 
-static inline void __qdisc_reset_queue(struct Qdisc *sch,
-				       struct sk_buff_head *list)
+static inline void __qdisc_q_reset(struct Qdisc *sch,
+				   struct sk_buff_head *list)
 {
 	/*
 	 * We do not know the backlog in bytes of this list, it
@@ -253,16 +253,16 @@ static inline void __qdisc_reset_queue(struct Qdisc *sch,
 	skb_queue_purge(list);
 }
 
-static inline void qdisc_reset_queue(struct Qdisc *sch)
+static inline void qdisc_q_reset(struct Qdisc *sch)
 {
-	__qdisc_reset_queue(sch, &sch->q);
+	__qdisc_q_reset(sch, &sch->q);
 	sch->qstats.backlog = 0;
 }
 
-static inline unsigned int __qdisc_queue_drop(struct Qdisc *sch,
-					      struct sk_buff_head *list)
+static inline unsigned int __qdisc_q_drop(struct Qdisc *sch,
+					  struct sk_buff_head *list)
 {
-	struct sk_buff *skb = __qdisc_dequeue_tail(sch, list);
+	struct sk_buff *skb = __qdisc_q_dequeue_tail(sch, list);
 
 	if (likely(skb != NULL)) {
 		unsigned int len = skb->len;
@@ -273,9 +273,9 @@ static inline unsigned int __qdisc_queue_drop(struct Qdisc *sch,
 	return 0;
 }
 
-static inline unsigned int qdisc_queue_drop(struct Qdisc *sch)
+static inline unsigned int qdisc_q_drop(struct Qdisc *sch)
 {
-	return __qdisc_queue_drop(sch, &sch->q);
+	return __qdisc_q_drop(sch, &sch->q);
 }
 
 static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index f9bf58b..e4a4dc2 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -28,7 +28,7 @@ static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
 	if (likely(sch->qstats.backlog + skb->len <= q->limit))
-		return qdisc_enqueue_tail(skb, sch);
+		return qdisc_q_enqueue_tail(skb, sch);
 
 	return qdisc_reshape_fail(skb, sch);
 }
@@ -38,7 +38,7 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
 	if (likely(skb_queue_len(&sch->q) < q->limit))
-		return qdisc_enqueue_tail(skb, sch);
+		return qdisc_q_enqueue_tail(skb, sch);
 
 	return qdisc_reshape_fail(skb, sch);
 }
@@ -82,11 +82,11 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.id		=	"pfifo",
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	pfifo_enqueue,
-	.dequeue	=	qdisc_dequeue_head,
-	.requeue	=	qdisc_requeue,
-	.drop		=	qdisc_queue_drop,
+	.dequeue	=	qdisc_q_dequeue_head,
+	.requeue	=	qdisc_q_requeue,
+	.drop		=	qdisc_q_drop,
 	.init		=	fifo_init,
-	.reset		=	qdisc_reset_queue,
+	.reset		=	qdisc_q_reset,
 	.change		=	fifo_init,
 	.dump		=	fifo_dump,
 	.owner		=	THIS_MODULE,
@@ -96,11 +96,11 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.id		=	"bfifo",
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	bfifo_enqueue,
-	.dequeue	=	qdisc_dequeue_head,
-	.requeue	=	qdisc_requeue,
-	.drop		=	qdisc_queue_drop,
+	.dequeue	=	qdisc_q_dequeue_head,
+	.requeue	=	qdisc_q_requeue,
+	.drop		=	qdisc_q_drop,
 	.init		=	fifo_init,
-	.reset		=	qdisc_reset_queue,
+	.reset		=	qdisc_q_reset,
 	.change		=	fifo_init,
 	.dump		=	fifo_dump,
 	.owner		=	THIS_MODULE,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9be2f15..6afd59e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -344,7 +344,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 
 	if (skb_queue_len(list) < qdisc->dev->tx_queue_len) {
 		qdisc->q.qlen++;
-		return __qdisc_enqueue_tail(skb, qdisc, list);
+		return __qdisc_q_enqueue_tail(skb, qdisc, list);
 	}
 
 	return qdisc_drop(skb, qdisc);
@@ -358,7 +358,7 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
 		if (!skb_queue_empty(list + prio)) {
 			qdisc->q.qlen--;
-			return __qdisc_dequeue_head(qdisc, list + prio);
+			return __qdisc_q_dequeue_head(qdisc, list + prio);
 		}
 	}
 
@@ -368,7 +368,7 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 static int pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
 	qdisc->q.qlen++;
-	return __qdisc_requeue(skb, qdisc, prio2list(skb, qdisc));
+	return __qdisc_q_requeue(skb, qdisc, prio2list(skb, qdisc));
 }
 
 static void pfifo_fast_reset(struct Qdisc* qdisc)
@@ -377,7 +377,7 @@ static void pfifo_fast_reset(struct Qdisc* qdisc)
 	struct sk_buff_head *list = qdisc_priv(qdisc);
 
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		__qdisc_reset_queue(qdisc, list + prio);
+		__qdisc_q_reset(qdisc, list + prio);
 
 	qdisc->qstats.backlog = 0;
 	qdisc->q.qlen = 0;
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index e2bcd66..d933565 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -165,7 +165,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			 * allows for DP flows to be left untouched.
 			 */
 			if (skb_queue_len(&sch->q) < sch->dev->tx_queue_len)
-				return qdisc_enqueue_tail(skb, sch);
+				return qdisc_q_enqueue_tail(skb, sch);
 			else
 				goto drop;
 		}
@@ -228,7 +228,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	if (q->backlog + skb->len <= q->limit) {
 		q->backlog += skb->len;
-		return qdisc_enqueue_tail(skb, sch);
+		return qdisc_q_enqueue_tail(skb, sch);
 	}
 
 	q->stats.pdrop++;
@@ -257,7 +257,7 @@ static int gred_requeue(struct sk_buff *skb, struct Qdisc* sch)
 		q->backlog += skb->len;
 	}
 
-	return qdisc_requeue(skb, sch);
+	return qdisc_q_requeue(skb, sch);
 }
 
 static struct sk_buff *gred_dequeue(struct Qdisc* sch)
@@ -265,7 +265,7 @@ static struct sk_buff *gred_dequeue(struct Qdisc* sch)
 	struct sk_buff *skb;
 	struct gred_sched *t = qdisc_priv(sch);
 
-	skb = qdisc_dequeue_head(sch);
+	skb = qdisc_q_dequeue_head(sch);
 
 	if (skb) {
 		struct gred_sched_data *q;
@@ -297,7 +297,7 @@ static unsigned int gred_drop(struct Qdisc* sch)
 	struct sk_buff *skb;
 	struct gred_sched *t = qdisc_priv(sch);
 
-	skb = qdisc_dequeue_tail(sch);
+	skb = qdisc_q_dequeue_tail(sch);
 	if (skb) {
 		unsigned int len = skb->len;
 		struct gred_sched_data *q;
@@ -332,7 +332,7 @@ static void gred_reset(struct Qdisc* sch)
 	int i;
 	struct gred_sched *t = qdisc_priv(sch);
 
-	qdisc_reset_queue(sch);
+	qdisc_q_reset(sch);
 
 	for (i = 0; i < t->DPs; i++) {
 		struct gred_sched_data *q = t->tab[i];
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5342a2f..3ec4a81 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -470,7 +470,7 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 		/* Optimize for add at tail */
 		if (likely(skb_queue_empty(list) || tnext >= q->oldest)) {
 			q->oldest = tnext;
-			return qdisc_enqueue_tail(nskb, sch);
+			return qdisc_q_enqueue_tail(nskb, sch);
 		}
 
 		skb_queue_reverse_walk(list, skb) {
@@ -526,11 +526,11 @@ static struct Qdisc_ops tfifo_qdisc_ops __read_mostly = {
 	.id		=	"tfifo",
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	tfifo_enqueue,
-	.dequeue	=	qdisc_dequeue_head,
-	.requeue	=	qdisc_requeue,
-	.drop		=	qdisc_queue_drop,
+	.dequeue	=	qdisc_q_dequeue_head,
+	.requeue	=	qdisc_q_requeue,
+	.drop		=	qdisc_q_drop,
 	.init		=	tfifo_init,
-	.reset		=	qdisc_reset_queue,
+	.reset		=	qdisc_q_reset,
 	.change		=	tfifo_init,
 	.dump		=	tfifo_dump,
 };
