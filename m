From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v2 2/3] net_sched: fix some checkpatch errors
Date: Thu, 7 Nov 2013 10:13:31 +0800
Message-ID: <1383790412-41944-3-git-send-email-yangyingliang@huawei.com>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <jhs@mojatatu.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:51096 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab3KGCOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 21:14:05 -0500
In-Reply-To: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some checkpatch errors, fix them.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/sched/act_api.c     |  5 +++--
 net/sched/cls_bpf.c     |  2 +-
 net/sched/cls_u32.c     |  2 +-
 net/sched/sch_cbq.c     |  3 ++-
 net/sched/sch_generic.c |  4 ++--
 net/sched/sch_htb.c     | 13 +++++++------
 net/sched/sch_netem.c   |  2 +-
 net/sched/sch_sfq.c     | 10 ++++++----
 8 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index fd70728..d92a90e9 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -191,7 +191,8 @@ u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo)
 			val = 1;
 	} while (tcf_hash_lookup(val, hinfo));
 
-	return (*idx_gen = val);
+	*idx_gen = val;
+	return *idx_gen;
 }
 EXPORT_SYMBOL(tcf_hash_new_index);
 
@@ -263,7 +264,7 @@ void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 }
 EXPORT_SYMBOL(tcf_hash_insert);
 
-static struct tc_action_ops *act_base = NULL;
+static struct tc_action_ops *act_base;
 static DEFINE_RWLOCK(act_mod_lock);
 
 int tcf_register_action(struct tc_action_ops *act)
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 1002a82..d7c72be 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -323,7 +323,7 @@ static int cls_bpf_dump(struct tcf_proto *tp, unsigned long fh,
 	if (nla == NULL)
 		goto nla_put_failure;
 
-        memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
+	memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
 
 	if (tcf_exts_dump(skb, &prog->exts, &bpf_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index eb07a1e..59e546c 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -352,7 +352,7 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 	return 0;
 }
 
-static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode* key)
+static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 {
 	struct tc_u_knode **kp;
 	struct tc_u_hnode *ht = key->ht_up;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 7a42c81..a8f40f5 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1058,7 +1058,8 @@ static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
 				cl->quantum = (cl->weight*cl->allot*q->nclasses[prio])/
 					q->quanta[prio];
 			}
-			if (cl->quantum <= 0 || cl->quantum>32*qdisc_dev(cl->qdisc)->mtu) {
+			if (cl->quantum <= 0 ||
+				cl->quantum > 32*qdisc_dev(cl->qdisc)->mtu) {
 				pr_warning("CBQ: class %08x has bad quantum==%ld, repaired.\n",
 					   cl->common.classid, cl->quantum);
 				cl->quantum = qdisc_dev(cl->qdisc)->mtu/2 + 1;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7fc899a..9421350 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -338,13 +338,13 @@ EXPORT_SYMBOL(netif_carrier_off);
    cheaper.
  */
 
-static int noop_enqueue(struct sk_buff *skb, struct Qdisc * qdisc)
+static int noop_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
 {
 	kfree_skb(skb);
 	return NET_XMIT_CN;
 }
 
-static struct sk_buff *noop_dequeue(struct Qdisc * qdisc)
+static struct sk_buff *noop_dequeue(struct Qdisc *qdisc)
 {
 	return NULL;
 }
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0e1e38b..f6e8a74 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -54,7 +54,7 @@
     one less than their parent.
 */
 
-static int htb_hysteresis __read_mostly = 0; /* whether to use mode hysteresis for speedup */
+static int htb_hysteresis __read_mostly; /* whether to use mode hysteresis for speedup */
 #define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
 
 #if HTB_VER >> 16 != TC_HTB_PROTOVER
@@ -65,7 +65,7 @@ static int htb_hysteresis __read_mostly = 0; /* whether to use mode hysteresis f
 module_param    (htb_hysteresis, int, 0640);
 MODULE_PARM_DESC(htb_hysteresis, "Hysteresis mode, less CPU load, less accurate");
 
-static int htb_rate_est = 0; /* htb classes have a default rate estimator */
+static int htb_rate_est; /* htb classes have a default rate estimator */
 module_param(htb_rate_est, int, 0640);
 MODULE_PARM_DESC(htb_rate_est, "setup a default rate estimator (4sec 16sec) for htb classes");
 
@@ -846,7 +846,7 @@ next:
 			break;
 
 		qdisc_warn_nonwc("htb", cl->un.leaf.q);
-		htb_next_rb_node(level ? &cl->parent->un.inner.clprio[prio].ptr:
+		htb_next_rb_node(level ? &cl->parent->un.inner.clprio[prio].ptr :
 					 &q->hlevel[0].hprio[prio].ptr);
 		cl = htb_lookup_leaf(hprio, prio);
 
@@ -1276,9 +1276,10 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 	struct Qdisc *new_q = NULL;
 	int last_child = 0;
 
-	// TODO: why don't allow to delete subtree ? references ? does
-	// tc subsys quarantee us that in htb_destroy it holds no class
-	// refs so that we can remove children safely there ?
+	/* TODO: why don't allow to delete subtree ? references ? does
+	 * tc subsys quarantee us that in htb_destroy it holds no class
+	 * refs so that we can remove children safely there ?
+	 */
 	if (cl->children || cl->filter_cnt)
 		return -EBUSY;
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 75c94e5..9765c3f 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -728,7 +728,7 @@ static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)
 	nla_for_each_nested(la, attr, rem) {
 		u16 type = nla_type(la);
 
-		switch(type) {
+		switch (type) {
 		case NETEM_LOSS_GI: {
 			const struct tc_netem_gimodel *gi = nla_data(la);
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d3a1bc2..76f01e0 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -237,10 +237,12 @@ static inline void sfq_link(struct sfq_sched_data *q, sfq_index x)
 }
 
 #define sfq_unlink(q, x, n, p)			\
-	n = q->slots[x].dep.next;		\
-	p = q->slots[x].dep.prev;		\
-	sfq_dep_head(q, p)->next = n;		\
-	sfq_dep_head(q, n)->prev = p
+	do {					\
+		n = q->slots[x].dep.next;	\
+		p = q->slots[x].dep.prev;	\
+		sfq_dep_head(q, p)->next = n;	\
+		sfq_dep_head(q, n)->prev = p;	\
+	} while (0)
 
 
 static inline void sfq_dec(struct sfq_sched_data *q, sfq_index x)
-- 
1.7.12
