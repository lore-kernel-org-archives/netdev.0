From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 07/14] replace __inline__ by inline in net/sched
Date: Wed, 06 Feb 2008 10:14:12 +0100
Message-ID: <20080206092135.416431161@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:43584 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760562AbYBFJ1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:27:16 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m169RELg239836
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:14 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169REuq5058596
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:14 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169RA6d023681
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:10 GMT
Content-Disposition: inline; filename=remove-__inline__-in-sched.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/sched

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/sched/cls_fw.c    |    2 +-
 net/sched/cls_route.c |   10 +++++-----
 net/sched/cls_u32.c   |   10 +++++-----
 net/sched/sch_cbq.c   |   35 ++++++++++++++++-------------------
 net/sched/sch_sfq.c   |    2 +-
 net/sched/sch_teql.c  |    3 +--
 6 files changed, 29 insertions(+), 33 deletions(-)

Index: net-2.6/net/sched/cls_fw.c
===================================================================
--- net-2.6.orig/net/sched/cls_fw.c
+++ net-2.6/net/sched/cls_fw.c
@@ -52,7 +52,7 @@ static const struct tcf_ext_map fw_ext_m
 	.police = TCA_FW_POLICE
 };
 
-static __inline__ int fw_hash(u32 handle)
+static inline int fw_hash(u32 handle)
 {
 	if (HTSIZE == 4096)
 		return ((handle >> 24) & 0xFFF) ^
Index: net-2.6/net/sched/cls_route.c
===================================================================
--- net-2.6.orig/net/sched/cls_route.c
+++ net-2.6/net/sched/cls_route.c
@@ -67,7 +67,7 @@ static const struct tcf_ext_map route_ex
 	.action = TCA_ROUTE4_ACT
 };
 
-static __inline__ int route4_fastmap_hash(u32 id, int iif)
+static inline int route4_fastmap_hash(u32 id, int iif)
 {
 	return id&0xF;
 }
@@ -90,22 +90,22 @@ route4_set_fastmap(struct route4_head *h
 	head->fastmap[h].filter = f;
 }
 
-static __inline__ int route4_hash_to(u32 id)
+static inline int route4_hash_to(u32 id)
 {
 	return id&0xFF;
 }
 
-static __inline__ int route4_hash_from(u32 id)
+static inline int route4_hash_from(u32 id)
 {
 	return (id>>16)&0xF;
 }
 
-static __inline__ int route4_hash_iif(int iif)
+static inline int route4_hash_iif(int iif)
 {
 	return 16 + ((iif>>16)&0xF);
 }
 
-static __inline__ int route4_hash_wild(void)
+static inline int route4_hash_wild(void)
 {
 	return 32;
 }
Index: net-2.6/net/sched/cls_u32.c
===================================================================
--- net-2.6.orig/net/sched/cls_u32.c
+++ net-2.6/net/sched/cls_u32.c
@@ -89,7 +89,7 @@ static const struct tcf_ext_map u32_ext_
 
 static struct tc_u_common *u32_list;
 
-static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel *sel, u8 fshift)
+static inline unsigned u32_hash_fold(u32 key, struct tc_u32_sel *sel, u8 fshift)
 {
 	unsigned h = ntohl(key & sel->hmask)>>fshift;
 
@@ -217,8 +217,8 @@ deadloop:
 	return -1;
 }
 
-static __inline__ struct tc_u_hnode *
-u32_lookup_ht(struct tc_u_common *tp_c, u32 handle)
+static inline struct tc_u_hnode *u32_lookup_ht(struct tc_u_common *tp_c,
+					       u32 handle)
 {
 	struct tc_u_hnode *ht;
 
@@ -229,8 +229,8 @@ u32_lookup_ht(struct tc_u_common *tp_c, 
 	return ht;
 }
 
-static __inline__ struct tc_u_knode *
-u32_lookup_key(struct tc_u_hnode *ht, u32 handle)
+static inline struct tc_u_knode *u32_lookup_key(struct tc_u_hnode *ht,
+						u32 handle)
 {
 	unsigned sel;
 	struct tc_u_knode *n = NULL;
Index: net-2.6/net/sched/sch_cbq.c
===================================================================
--- net-2.6.orig/net/sched/sch_cbq.c
+++ net-2.6/net/sched/sch_cbq.c
@@ -178,15 +178,15 @@ struct cbq_sched_data
 #define L2T(cl,len)	qdisc_l2t((cl)->R_tab,len)
 
 
-static __inline__ unsigned cbq_hash(u32 h)
+static inline unsigned cbq_hash(u32 h)
 {
 	h ^= h>>8;
 	h ^= h>>4;
 	return h&0xF;
 }
 
-static __inline__ struct cbq_class *
-cbq_class_lookup(struct cbq_sched_data *q, u32 classid)
+static inline struct cbq_class *cbq_class_lookup(struct cbq_sched_data *q,
+						 u32 classid)
 {
 	struct cbq_class *cl;
 
@@ -303,7 +303,7 @@ fallback:
    of its priority band.
  */
 
-static __inline__ void cbq_activate_class(struct cbq_class *cl)
+static inline void cbq_activate_class(struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	int prio = cl->cpriority;
@@ -706,9 +706,9 @@ static int cbq_reshape_fail(struct sk_bu
    Probably, it is wrong. This question needs further investigation.
 */
 
-static __inline__ void
-cbq_update_toplevel(struct cbq_sched_data *q, struct cbq_class *cl,
-		    struct cbq_class *borrowed)
+static inline void cbq_update_toplevel(struct cbq_sched_data *q,
+				       struct cbq_class *cl,
+				       struct cbq_class *borrowed)
 {
 	if (cl && q->toplevel >= borrowed->level) {
 		if (cl->q->q.qlen > 1) {
@@ -811,8 +811,7 @@ cbq_update(struct cbq_sched_data *q)
 	cbq_update_toplevel(q, this, q->tx_borrowed);
 }
 
-static __inline__ struct cbq_class *
-cbq_under_limit(struct cbq_class *cl)
+static inline struct cbq_class *cbq_under_limit(struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	struct cbq_class *this_cl = cl;
@@ -849,8 +848,7 @@ cbq_under_limit(struct cbq_class *cl)
 	return cl;
 }
 
-static __inline__ struct sk_buff *
-cbq_dequeue_prio(struct Qdisc *sch, int prio)
+static inline struct sk_buff *cbq_dequeue_prio(struct Qdisc *sch, int prio)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl_tail, *cl_prev, *cl;
@@ -952,8 +950,7 @@ next_class:
 	return NULL;
 }
 
-static __inline__ struct sk_buff *
-cbq_dequeue_1(struct Qdisc *sch)
+static inline struct sk_buff *cbq_dequeue_1(struct Qdisc *sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
@@ -1443,7 +1440,7 @@ static int cbq_init(struct Qdisc *sch, s
 	return 0;
 }
 
-static __inline__ int cbq_dump_rate(struct sk_buff *skb, struct cbq_class *cl)
+static inline int cbq_dump_rate(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 
@@ -1455,7 +1452,7 @@ nla_put_failure:
 	return -1;
 }
 
-static __inline__ int cbq_dump_lss(struct sk_buff *skb, struct cbq_class *cl)
+static inline int cbq_dump_lss(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_lssopt opt;
@@ -1480,7 +1477,7 @@ nla_put_failure:
 	return -1;
 }
 
-static __inline__ int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
+static inline int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_wrropt opt;
@@ -1498,7 +1495,7 @@ nla_put_failure:
 	return -1;
 }
 
-static __inline__ int cbq_dump_ovl(struct sk_buff *skb, struct cbq_class *cl)
+static inline int cbq_dump_ovl(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_ovl opt;
@@ -1515,7 +1512,7 @@ nla_put_failure:
 	return -1;
 }
 
-static __inline__ int cbq_dump_fopt(struct sk_buff *skb, struct cbq_class *cl)
+static inline int cbq_dump_fopt(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_fopt opt;
@@ -1534,7 +1531,7 @@ nla_put_failure:
 }
 
 #ifdef CONFIG_NET_CLS_ACT
-static __inline__ int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
+static inline int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_police opt;
Index: net-2.6/net/sched/sch_sfq.c
===================================================================
--- net-2.6.orig/net/sched/sch_sfq.c
+++ net-2.6/net/sched/sch_sfq.c
@@ -109,7 +109,7 @@ struct sfq_sched_data
 	struct sfq_head	dep[SFQ_DEPTH*2];	/* Linked list of slots, indexed by depth */
 };
 
-static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
+static inline unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
 {
 	return jhash_2words(h, h1, q->perturbation) & (SFQ_HASH_DIVISOR - 1);
 }
Index: net-2.6/net/sched/sch_teql.c
===================================================================
--- net-2.6.orig/net/sched/sch_teql.c
+++ net-2.6/net/sched/sch_teql.c
@@ -121,8 +121,7 @@ teql_dequeue(struct Qdisc* sch)
 	return skb;
 }
 
-static __inline__ void
-teql_neigh_release(struct neighbour *n)
+static inline void teql_neigh_release(struct neighbour *n)
 {
 	if (n)
 		neigh_release(n);

-- 
