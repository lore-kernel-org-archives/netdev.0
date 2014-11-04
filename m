From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 04/13] net_sched: rename qdisc_drop() to qdisc_drop_skb()
Date: Tue,  4 Nov 2014 09:56:27 -0800
Message-ID: <1415123796-8093-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:38790 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbaKDR4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:51 -0500
Received: by mail-pa0-f47.google.com with SMTP id kx10so14919688pab.34
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:50 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qdisc_drop() will be used by the following patch.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/codel.h       | 4 ++--
 include/net/sch_generic.h | 2 +-
 net/sched/sch_blackhole.c | 2 +-
 net/sched/sch_choke.c     | 8 ++++----
 net/sched/sch_codel.c     | 4 ++--
 net/sched/sch_dsmark.c    | 2 +-
 net/sched/sch_fq.c        | 4 ++--
 net/sched/sch_generic.c   | 2 +-
 net/sched/sch_gred.c      | 6 +++---
 net/sched/sch_htb.c       | 2 +-
 net/sched/sch_netem.c     | 2 +-
 net/sched/sch_pie.c       | 4 ++--
 net/sched/sch_red.c       | 2 +-
 net/sched/sch_sfb.c       | 2 +-
 net/sched/sch_sfq.c       | 6 +++---
 net/sched/sch_teql.c      | 2 +-
 16 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index aeee280..510d5da 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -297,7 +297,7 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 								  vars->rec_inv_sqrt);
 					goto end;
 				}
-				qdisc_drop(skb, sch);
+				qdisc_drop_skb(skb, sch);
 				stats->drop_count++;
 				skb = dequeue_func(vars, sch);
 				if (!codel_should_drop(skb, sch,
@@ -319,7 +319,7 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 		if (params->ecn && INET_ECN_set_ce(skb)) {
 			stats->ecn_mark++;
 		} else {
-			qdisc_drop(skb, sch);
+			qdisc_drop_skb(skb, sch);
 			stats->drop_count++;
 
 			skb = dequeue_func(vars, sch);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 6320c18..21df9fb 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -732,7 +732,7 @@ static inline unsigned int qdisc_queue_drop(struct Qdisc *sch)
 	return __qdisc_queue_drop(sch, &sch->q);
 }
 
-static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
+static inline int qdisc_drop_skb(struct sk_buff *skb, struct Qdisc *sch)
 {
 	kfree_skb(skb);
 	qdisc_qstats_drop(sch);
diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index 094a874..137b5d7 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -19,7 +19,7 @@
 
 static int blackhole_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	return NET_XMIT_SUCCESS;
 }
 
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index c009eb9..fac3db3 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -128,7 +128,7 @@ static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
 		choke_zap_tail_holes(q);
 
 	qdisc_qstats_backlog_dec(sch, skb);
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	qdisc_tree_decrease_qlen(sch, 1);
 	--sch->q.qlen;
 }
@@ -337,10 +337,10 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	q->stats.pdrop++;
-	return qdisc_drop(skb, sch);
+	return qdisc_drop_skb(skb, sch);
 
 congestion_drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	return NET_XMIT_CN;
 
 other_drop:
@@ -462,7 +462,7 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 				}
 				qdisc_qstats_backlog_dec(sch, skb);
 				--sch->q.qlen;
-				qdisc_drop(skb, sch);
+				qdisc_drop_skb(skb, sch);
 			}
 			qdisc_tree_decrease_qlen(sch, oqlen - sch->q.qlen);
 			q->head = 0;
diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index de28f8e..3ce45b8 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -101,7 +101,7 @@ static int codel_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 	q = qdisc_priv(sch);
 	q->drop_overlimit++;
-	return qdisc_drop(skb, sch);
+	return qdisc_drop_skb(skb, sch);
 }
 
 static const struct nla_policy codel_policy[TCA_CODEL_MAX + 1] = {
@@ -150,7 +150,7 @@ static int codel_change(struct Qdisc *sch, struct nlattr *opt)
 		struct sk_buff *skb = __skb_dequeue(&sch->q);
 
 		qdisc_qstats_backlog_dec(sch, skb);
-		qdisc_drop(skb, sch);
+		qdisc_drop_skb(skb, sch);
 	}
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 7bdf7e0..a450c53 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -267,7 +267,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 
 drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 }
 
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index cbd7e1f..34ec70c 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -360,12 +360,12 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct fq_flow *f;
 
 	if (unlikely(sch->q.qlen >= sch->limit))
-		return qdisc_drop(skb, sch);
+		return qdisc_drop_skb(skb, sch);
 
 	f = fq_classify(skb, q);
 	if (unlikely(f->qlen >= q->flow_plimit && f != &q->internal)) {
 		q->stat_flows_plimit++;
-		return qdisc_drop(skb, sch);
+		return qdisc_drop_skb(skb, sch);
 	}
 
 	f->qlen++;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9feeb5c..cd4ba53 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -489,7 +489,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
 		return __qdisc_enqueue_tail(skb, qdisc, list);
 	}
 
-	return qdisc_drop(skb, qdisc);
+	return qdisc_drop_skb(skb, qdisc);
 }
 
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index a4ca451..60da79a 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -236,10 +236,10 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	q->stats.pdrop++;
 drop:
-	return qdisc_drop(skb, sch);
+	return qdisc_drop_skb(skb, sch);
 
 congestion_drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	return NET_XMIT_CN;
 }
 
@@ -302,7 +302,7 @@ static unsigned int gred_drop(struct Qdisc *sch)
 			}
 		}
 
-		qdisc_drop(skb, sch);
+		qdisc_drop_skb(skb, sch);
 		return len;
 	}
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 28b6929..89d15e8 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -581,7 +581,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			__skb_queue_tail(&q->direct_queue, skb);
 			q->direct_pkts++;
 		} else {
-			return qdisc_drop(skb, sch);
+			return qdisc_drop_skb(skb, sch);
 		}
 #ifdef CONFIG_NET_CLS_ACT
 	} else if (!cl) {
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 179f1c8..1eb917e 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -456,7 +456,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (!(skb = skb_unshare(skb, GFP_ATOMIC)) ||
 		    (skb->ip_summed == CHECKSUM_PARTIAL &&
 		     skb_checksum_help(skb)))
-			return qdisc_drop(skb, sch);
+			return qdisc_drop_skb(skb, sch);
 
 		skb->data[prandom_u32() % skb_headlen(skb)] ^=
 			1<<(prandom_u32() % 8);
diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index b783a44..6095777 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -166,7 +166,7 @@ static int pie_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 out:
 	q->stats.dropped++;
-	return qdisc_drop(skb, sch);
+	return qdisc_drop_skb(skb, sch);
 }
 
 static const struct nla_policy pie_policy[TCA_PIE_MAX + 1] = {
@@ -233,7 +233,7 @@ static int pie_change(struct Qdisc *sch, struct nlattr *opt)
 		struct sk_buff *skb = __skb_dequeue(&sch->q);
 
 		qdisc_qstats_backlog_dec(sch, skb);
-		qdisc_drop(skb, sch);
+		qdisc_drop_skb(skb, sch);
 	}
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 8fd96ae..c19587d 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -105,7 +105,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return ret;
 
 congestion_drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	return NET_XMIT_CN;
 }
 
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 08c318e..7eea588 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -416,7 +416,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return ret;
 
 drop:
-	qdisc_drop(skb, sch);
+	qdisc_drop_skb(skb, sch);
 	return NET_XMIT_CN;
 other_drop:
 	if (ret & __NET_XMIT_BYPASS)
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b877140..6212652 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -390,7 +390,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (x == SFQ_EMPTY_SLOT) {
 		x = q->dep[0].next; /* get a free slot */
 		if (x >= SFQ_MAX_FLOWS)
-			return qdisc_drop(skb, sch);
+			return qdisc_drop_skb(skb, sch);
 		q->ht[hash] = x;
 		slot = &q->slots[x];
 		slot->hash = hash;
@@ -447,14 +447,14 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (slot->qlen >= q->maxdepth) {
 congestion_drop:
 		if (!sfq_headdrop(q))
-			return qdisc_drop(skb, sch);
+			return qdisc_drop_skb(skb, sch);
 
 		/* We know we have at least one packet in queue */
 		head = slot_dequeue_head(slot);
 		delta = qdisc_pkt_len(head) - qdisc_pkt_len(skb);
 		sch->qstats.backlog -= delta;
 		slot->backlog -= delta;
-		qdisc_drop(head, sch);
+		qdisc_drop_skb(head, sch);
 
 		slot_queue_add(slot, skb);
 		return NET_XMIT_CN;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 6ada423..fc13451 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -87,7 +87,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return NET_XMIT_SUCCESS;
 	}
 
-	return qdisc_drop(skb, sch);
+	return qdisc_drop_skb(skb, sch);
 }
 
 static struct sk_buff *
-- 
1.8.3.1
