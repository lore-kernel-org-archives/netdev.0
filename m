From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/2] net_sched: get rid of struct tcf_common
Date: Wed, 20 Jul 2016 22:23:34 -0700
Message-ID: <1469078614-13540-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1469078614-13540-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33460 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbcGUFXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 01:23:51 -0400
Received: by mail-pa0-f67.google.com with SMTP id q2so4571337pap.0
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 22:23:50 -0700 (PDT)
In-Reply-To: <1469078614-13540-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the previous patch, struct tc_action should be enough
to represent the generic tc action, tcf_common is not necessary
at more. This patch gets rid of it to make tc action code
more readable.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h            |  63 +++++++++---------
 include/net/tc_act/tc_bpf.h      |   2 +-
 include/net/tc_act/tc_connmark.h |   2 +-
 include/net/tc_act/tc_csum.h     |   2 +-
 include/net/tc_act/tc_defact.h   |   2 +-
 include/net/tc_act/tc_gact.h     |   2 +-
 include/net/tc_act/tc_ife.h      |   2 +-
 include/net/tc_act/tc_ipt.h      |   2 +-
 include/net/tc_act/tc_mirred.h   |   2 +-
 include/net/tc_act/tc_nat.h      |   2 +-
 include/net/tc_act/tc_pedit.h    |   2 +-
 include/net/tc_act/tc_skbedit.h  |   2 +-
 include/net/tc_act/tc_vlan.h     |   2 +-
 net/sched/act_api.c              | 139 +++++++++++++++++++--------------------
 net/sched/act_police.c           |  10 +--
 15 files changed, 114 insertions(+), 122 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 504e7e0..c290db8 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -22,42 +22,39 @@ struct tc_action_ops;
 
 struct tc_action {
 	const struct tc_action_ops	*ops;
-	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
-	__u32			order;
-	struct list_head	list;
-	struct tcf_hashinfo	*hinfo;
-};
-
-struct tcf_common {
-	struct tc_action		tcfc_act;
-	struct hlist_node		tcfc_head;
-	u32				tcfc_index;
-	int				tcfc_refcnt;
-	int				tcfc_bindcnt;
-	u32				tcfc_capab;
-	int				tcfc_action;
-	struct tcf_t			tcfc_tm;
-	struct gnet_stats_basic_packed	tcfc_bstats;
-	struct gnet_stats_queue		tcfc_qstats;
-	struct gnet_stats_rate_est64	tcfc_rate_est;
-	spinlock_t			tcfc_lock;
-	struct rcu_head			tcfc_rcu;
+	__u32				type; /* for backward compat(TCA_OLD_COMPAT) */
+	__u32				order;
+	struct list_head		list;
+	struct tcf_hashinfo		*hinfo;
+
+	struct hlist_node		tcfa_head;
+	u32				tcfa_index;
+	int				tcfa_refcnt;
+	int				tcfa_bindcnt;
+	u32				tcfa_capab;
+	int				tcfa_action;
+	struct tcf_t			tcfa_tm;
+	struct gnet_stats_basic_packed	tcfa_bstats;
+	struct gnet_stats_queue		tcfa_qstats;
+	struct gnet_stats_rate_est64	tcfa_rate_est;
+	spinlock_t			tcfa_lock;
+	struct rcu_head			tcfa_rcu;
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue __percpu *cpu_qstats;
 };
-#define tcf_act		common.tcfc_act
-#define tcf_head	common.tcfc_head
-#define tcf_index	common.tcfc_index
-#define tcf_refcnt	common.tcfc_refcnt
-#define tcf_bindcnt	common.tcfc_bindcnt
-#define tcf_capab	common.tcfc_capab
-#define tcf_action	common.tcfc_action
-#define tcf_tm		common.tcfc_tm
-#define tcf_bstats	common.tcfc_bstats
-#define tcf_qstats	common.tcfc_qstats
-#define tcf_rate_est	common.tcfc_rate_est
-#define tcf_lock	common.tcfc_lock
-#define tcf_rcu		common.tcfc_rcu
+#define tcf_act		common.tcfa_act
+#define tcf_head	common.tcfa_head
+#define tcf_index	common.tcfa_index
+#define tcf_refcnt	common.tcfa_refcnt
+#define tcf_bindcnt	common.tcfa_bindcnt
+#define tcf_capab	common.tcfa_capab
+#define tcf_action	common.tcfa_action
+#define tcf_tm		common.tcfa_tm
+#define tcf_bstats	common.tcfa_bstats
+#define tcf_qstats	common.tcfa_qstats
+#define tcf_rate_est	common.tcfa_rate_est
+#define tcf_lock	common.tcfa_lock
+#define tcf_rcu		common.tcfa_rcu
 
 static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
 {
diff --git a/include/net/tc_act/tc_bpf.h b/include/net/tc_act/tc_bpf.h
index 80a4d6f..2b94673 100644
--- a/include/net/tc_act/tc_bpf.h
+++ b/include/net/tc_act/tc_bpf.h
@@ -14,7 +14,7 @@
 #include <net/act_api.h>
 
 struct tcf_bpf {
-	struct tcf_common	common;
+	struct tc_action	common;
 	struct bpf_prog __rcu	*filter;
 	union {
 		u32		bpf_fd;
diff --git a/include/net/tc_act/tc_connmark.h b/include/net/tc_act/tc_connmark.h
index 8a66113..59b515d 100644
--- a/include/net/tc_act/tc_connmark.h
+++ b/include/net/tc_act/tc_connmark.h
@@ -4,7 +4,7 @@
 #include <net/act_api.h>
 
 struct tcf_connmark_info {
-	struct tcf_common common;
+	struct tc_action common;
 	struct net *net;
 	u16 zone;
 };
diff --git a/include/net/tc_act/tc_csum.h b/include/net/tc_act/tc_csum.h
index 1a9ef15..f31fb63 100644
--- a/include/net/tc_act/tc_csum.h
+++ b/include/net/tc_act/tc_csum.h
@@ -5,7 +5,7 @@
 #include <net/act_api.h>
 
 struct tcf_csum {
-	struct tcf_common common;
+	struct tc_action common;
 
 	u32 update_flags;
 };
diff --git a/include/net/tc_act/tc_defact.h b/include/net/tc_act/tc_defact.h
index e25b4eb..d47f040 100644
--- a/include/net/tc_act/tc_defact.h
+++ b/include/net/tc_act/tc_defact.h
@@ -4,7 +4,7 @@
 #include <net/act_api.h>
 
 struct tcf_defact {
-	struct tcf_common	common;
+	struct tc_action	common;
 	u32		tcfd_datalen;
 	void		*tcfd_defdata;
 };
diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 119cdb4..b6f1739 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -5,7 +5,7 @@
 #include <linux/tc_act/tc_gact.h>
 
 struct tcf_gact {
-	struct tcf_common	common;
+	struct tc_action	common;
 #ifdef CONFIG_GACT_PROB
 	u16			tcfg_ptype;
 	u16			tcfg_pval;
diff --git a/include/net/tc_act/tc_ife.h b/include/net/tc_act/tc_ife.h
index 7921abe..5164bd7 100644
--- a/include/net/tc_act/tc_ife.h
+++ b/include/net/tc_act/tc_ife.h
@@ -8,7 +8,7 @@
 
 #define IFE_METAHDRLEN 2
 struct tcf_ife_info {
-	struct tcf_common common;
+	struct tc_action common;
 	u8 eth_dst[ETH_ALEN];
 	u8 eth_src[ETH_ALEN];
 	u16 eth_type;
diff --git a/include/net/tc_act/tc_ipt.h b/include/net/tc_act/tc_ipt.h
index c22ae7a..3130976 100644
--- a/include/net/tc_act/tc_ipt.h
+++ b/include/net/tc_act/tc_ipt.h
@@ -6,7 +6,7 @@
 struct xt_entry_target;
 
 struct tcf_ipt {
-	struct tcf_common	common;
+	struct tc_action	common;
 	u32			tcfi_hook;
 	char			*tcfi_tname;
 	struct xt_entry_target	*tcfi_t;
diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index de67ca7..78d996d 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -5,7 +5,7 @@
 #include <linux/tc_act/tc_mirred.h>
 
 struct tcf_mirred {
-	struct tcf_common	common;
+	struct tc_action	common;
 	int			tcfm_eaction;
 	int			tcfm_ifindex;
 	int			tcfm_ok_push;
diff --git a/include/net/tc_act/tc_nat.h b/include/net/tc_act/tc_nat.h
index a91ad3a..56681a3 100644
--- a/include/net/tc_act/tc_nat.h
+++ b/include/net/tc_act/tc_nat.h
@@ -5,7 +5,7 @@
 #include <net/act_api.h>
 
 struct tcf_nat {
-	struct tcf_common common;
+	struct tc_action common;
 
 	__be32 old_addr;
 	__be32 new_addr;
diff --git a/include/net/tc_act/tc_pedit.h b/include/net/tc_act/tc_pedit.h
index 2cccfba..29e38d6 100644
--- a/include/net/tc_act/tc_pedit.h
+++ b/include/net/tc_act/tc_pedit.h
@@ -4,7 +4,7 @@
 #include <net/act_api.h>
 
 struct tcf_pedit {
-	struct tcf_common	common;
+	struct tc_action	common;
 	unsigned char		tcfp_nkeys;
 	unsigned char		tcfp_flags;
 	struct tc_pedit_key	*tcfp_keys;
diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index 9e05489..5767e9d 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -23,7 +23,7 @@
 #include <linux/tc_act/tc_skbedit.h>
 
 struct tcf_skbedit {
-	struct tcf_common	common;
+	struct tc_action	common;
 	u32		flags;
 	u32		priority;
 	u32		mark;
diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
index 584b807..e29f52e 100644
--- a/include/net/tc_act/tc_vlan.h
+++ b/include/net/tc_act/tc_vlan.h
@@ -16,7 +16,7 @@
 #define VLAN_F_PUSH		0x2
 
 struct tcf_vlan {
-	struct tcf_common	common;
+	struct tc_action	common;
 	int			tcfv_action;
 	u16			tcfv_push_vid;
 	__be16			tcfv_push_proto;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d97419f..e4a5f26 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -29,46 +29,43 @@
 
 static void free_tcf(struct rcu_head *head)
 {
-	struct tcf_common *p = container_of(head, struct tcf_common, tcfc_rcu);
+	struct tc_action *p = container_of(head, struct tc_action, tcfa_rcu);
 
 	free_percpu(p->cpu_bstats);
 	free_percpu(p->cpu_qstats);
 	kfree(p);
 }
 
-static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *a)
+static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *p)
 {
-	struct tcf_common *p = (struct tcf_common *)a;
-
 	spin_lock_bh(&hinfo->lock);
-	hlist_del(&p->tcfc_head);
+	hlist_del(&p->tcfa_head);
 	spin_unlock_bh(&hinfo->lock);
-	gen_kill_estimator(&p->tcfc_bstats,
-			   &p->tcfc_rate_est);
+	gen_kill_estimator(&p->tcfa_bstats,
+			   &p->tcfa_rate_est);
 	/*
-	 * gen_estimator est_timer() might access p->tcfc_lock
+	 * gen_estimator est_timer() might access p->tcfa_lock
 	 * or bstats, wait a RCU grace period before freeing p
 	 */
-	call_rcu(&p->tcfc_rcu, free_tcf);
+	call_rcu(&p->tcfa_rcu, free_tcf);
 }
 
-int __tcf_hash_release(struct tc_action *a, bool bind, bool strict)
+int __tcf_hash_release(struct tc_action *p, bool bind, bool strict)
 {
-	struct tcf_common *p = (struct tcf_common *)a;
 	int ret = 0;
 
 	if (p) {
 		if (bind)
-			p->tcfc_bindcnt--;
-		else if (strict && p->tcfc_bindcnt > 0)
+			p->tcfa_bindcnt--;
+		else if (strict && p->tcfa_bindcnt > 0)
 			return -EPERM;
 
-		p->tcfc_refcnt--;
-		if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
-			if (a->ops->cleanup)
-				a->ops->cleanup(a, bind);
-			list_del(&a->list);
-			tcf_hash_destroy(a->hinfo, a);
+		p->tcfa_refcnt--;
+		if (p->tcfa_bindcnt <= 0 && p->tcfa_refcnt <= 0) {
+			if (p->ops->cleanup)
+				p->ops->cleanup(p, bind);
+			list_del(&p->list);
+			tcf_hash_destroy(p->hinfo, p);
 			ret = ACT_P_DELETED;
 		}
 	}
@@ -89,11 +86,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
 		struct hlist_head *head;
-		struct tcf_common *p;
+		struct tc_action *p;
 
 		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
 
-		hlist_for_each_entry_rcu(p, head, tcfc_head) {
+		hlist_for_each_entry_rcu(p, head, tcfa_head) {
 			index++;
 			if (index < s_i)
 				continue;
@@ -101,7 +98,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 			nest = nla_nest_start(skb, n_i);
 			if (nest == NULL)
 				goto nla_put_failure;
-			err = tcf_action_dump_1(skb, (struct tc_action *)p, 0, 0);
+			err = tcf_action_dump_1(skb, p, 0, 0);
 			if (err < 0) {
 				index--;
 				nlmsg_trim(skb, nest);
@@ -139,13 +136,13 @@ static int tcf_del_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
 		struct hlist_head *head;
 		struct hlist_node *n;
-		struct tcf_common *p;
+		struct tc_action *p;
 
 		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
-		hlist_for_each_entry_safe(p, n, head, tcfc_head) {
-			ret = __tcf_hash_release((struct tc_action *)p, false, true);
+		hlist_for_each_entry_safe(p, n, head, tcfa_head) {
+			ret = __tcf_hash_release(p, false, true);
 			if (ret == ACT_P_DELETED) {
-				module_put(p->tcfc_act.ops->owner);
+				module_put(p->ops->owner);
 				n_i++;
 			} else if (ret < 0)
 				goto nla_put_failure;
@@ -178,15 +175,15 @@ int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(tcf_generic_walker);
 
-static struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
+static struct tc_action *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
 {
-	struct tcf_common *p = NULL;
+	struct tc_action *p = NULL;
 	struct hlist_head *head;
 
 	spin_lock_bh(&hinfo->lock);
 	head = &hinfo->htab[tcf_hash(index, hinfo->hmask)];
-	hlist_for_each_entry_rcu(p, head, tcfc_head)
-		if (p->tcfc_index == index)
+	hlist_for_each_entry_rcu(p, head, tcfa_head)
+		if (p->tcfa_index == index)
 			break;
 	spin_unlock_bh(&hinfo->lock);
 
@@ -211,10 +208,10 @@ EXPORT_SYMBOL(tcf_hash_new_index);
 int tcf_hash_search(struct tc_action_net *tn, struct tc_action **a, u32 index)
 {
 	struct tcf_hashinfo *hinfo = tn->hinfo;
-	struct tcf_common *p = tcf_hash_lookup(index, hinfo);
+	struct tc_action *p = tcf_hash_lookup(index, hinfo);
 
 	if (p) {
-		*a = &p->tcfc_act;
+		*a = p;
 		return 1;
 	}
 	return 0;
@@ -225,12 +222,13 @@ bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
 		    int bind)
 {
 	struct tcf_hashinfo *hinfo = tn->hinfo;
-	struct tcf_common *p = NULL;
+	struct tc_action *p = NULL;
+
 	if (index && (p = tcf_hash_lookup(index, hinfo)) != NULL) {
 		if (bind)
-			p->tcfc_bindcnt++;
-		p->tcfc_refcnt++;
-		*a = &p->tcfc_act;
+			p->tcfa_bindcnt++;
+		p->tcfa_refcnt++;
+		*a = p;
 		return true;
 	}
 	return false;
@@ -239,11 +237,10 @@ EXPORT_SYMBOL(tcf_hash_check);
 
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
 {
-	struct tcf_common *pc = (struct tcf_common *)a;
 	if (est)
-		gen_kill_estimator(&pc->tcfc_bstats,
-				   &pc->tcfc_rate_est);
-	call_rcu(&pc->tcfc_rcu, free_tcf);
+		gen_kill_estimator(&a->tcfa_bstats,
+				   &a->tcfa_rate_est);
+	call_rcu(&a->tcfa_rcu, free_tcf);
 }
 EXPORT_SYMBOL(tcf_hash_cleanup);
 
@@ -251,15 +248,15 @@ int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 		    struct tc_action **a, const struct tc_action_ops *ops,
 		    int bind, bool cpustats)
 {
-	struct tcf_common *p = kzalloc(ops->size, GFP_KERNEL);
+	struct tc_action *p = kzalloc(ops->size, GFP_KERNEL);
 	struct tcf_hashinfo *hinfo = tn->hinfo;
 	int err = -ENOMEM;
 
 	if (unlikely(!p))
 		return -ENOMEM;
-	p->tcfc_refcnt = 1;
+	p->tcfa_refcnt = 1;
 	if (bind)
-		p->tcfc_bindcnt = 1;
+		p->tcfa_bindcnt = 1;
 
 	if (cpustats) {
 		p->cpu_bstats = netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
@@ -275,38 +272,37 @@ int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 			goto err1;
 		}
 	}
-	spin_lock_init(&p->tcfc_lock);
-	INIT_HLIST_NODE(&p->tcfc_head);
-	p->tcfc_index = index ? index : tcf_hash_new_index(tn);
-	p->tcfc_tm.install = jiffies;
-	p->tcfc_tm.lastuse = jiffies;
-	p->tcfc_tm.firstuse = 0;
+	spin_lock_init(&p->tcfa_lock);
+	INIT_HLIST_NODE(&p->tcfa_head);
+	p->tcfa_index = index ? index : tcf_hash_new_index(tn);
+	p->tcfa_tm.install = jiffies;
+	p->tcfa_tm.lastuse = jiffies;
+	p->tcfa_tm.firstuse = 0;
 	if (est) {
-		err = gen_new_estimator(&p->tcfc_bstats, p->cpu_bstats,
-					&p->tcfc_rate_est,
-					&p->tcfc_lock, NULL, est);
+		err = gen_new_estimator(&p->tcfa_bstats, p->cpu_bstats,
+					&p->tcfa_rate_est,
+					&p->tcfa_lock, NULL, est);
 		if (err) {
 			free_percpu(p->cpu_qstats);
 			goto err2;
 		}
 	}
 
-	p->tcfc_act.hinfo = hinfo;
-	p->tcfc_act.ops = ops;
-	INIT_LIST_HEAD(&p->tcfc_act.list);
-	*a = &p->tcfc_act;
+	p->hinfo = hinfo;
+	p->ops = ops;
+	INIT_LIST_HEAD(&p->list);
+	*a = p;
 	return 0;
 }
 EXPORT_SYMBOL(tcf_hash_create);
 
 void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a)
 {
-	struct tcf_common *p = (struct tcf_common *)a;
 	struct tcf_hashinfo *hinfo = tn->hinfo;
-	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
+	unsigned int h = tcf_hash(a->tcfa_index, hinfo->hmask);
 
 	spin_lock_bh(&hinfo->lock);
-	hlist_add_head(&p->tcfc_head, &hinfo->htab[h]);
+	hlist_add_head(&a->tcfa_head, &hinfo->htab[h]);
 	spin_unlock_bh(&hinfo->lock);
 }
 EXPORT_SYMBOL(tcf_hash_insert);
@@ -317,13 +313,13 @@ void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
 	int i;
 
 	for (i = 0; i < hinfo->hmask + 1; i++) {
-		struct tcf_common *p;
+		struct tc_action *p;
 		struct hlist_node *n;
 
-		hlist_for_each_entry_safe(p, n, &hinfo->htab[i], tcfc_head) {
+		hlist_for_each_entry_safe(p, n, &hinfo->htab[i], tcfa_head) {
 			int ret;
 
-			ret = __tcf_hash_release((struct tc_action *)p, false, true);
+			ret = __tcf_hash_release(p, false, true);
 			if (ret == ACT_P_DELETED)
 				module_put(ops->owner);
 			else if (ret < 0)
@@ -625,12 +621,11 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
 	return err;
 }
 
-int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
+int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *p,
 			  int compat_mode)
 {
 	int err = 0;
 	struct gnet_dump d;
-	struct tcf_common *p = (struct tcf_common *)a;
 
 	if (p == NULL)
 		goto errout;
@@ -639,27 +634,27 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 	 * to add additional backward compatibility statistic TLVs.
 	 */
 	if (compat_mode) {
-		if (a->type == TCA_OLD_COMPAT)
+		if (p->type == TCA_OLD_COMPAT)
 			err = gnet_stats_start_copy_compat(skb, 0,
 							   TCA_STATS,
 							   TCA_XSTATS,
-							   &p->tcfc_lock, &d,
+							   &p->tcfa_lock, &d,
 							   TCA_PAD);
 		else
 			return 0;
 	} else
 		err = gnet_stats_start_copy(skb, TCA_ACT_STATS,
-					    &p->tcfc_lock, &d, TCA_ACT_PAD);
+					    &p->tcfa_lock, &d, TCA_ACT_PAD);
 
 	if (err < 0)
 		goto errout;
 
-	if (gnet_stats_copy_basic(NULL, &d, p->cpu_bstats, &p->tcfc_bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &p->tcfc_bstats,
-				     &p->tcfc_rate_est) < 0 ||
+	if (gnet_stats_copy_basic(NULL, &d, p->cpu_bstats, &p->tcfa_bstats) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &p->tcfa_bstats,
+				     &p->tcfa_rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, p->cpu_qstats,
-				  &p->tcfc_qstats,
-				  p->tcfc_qstats.qlen) < 0)
+				  &p->tcfa_qstats,
+				  p->tcfa_qstats.qlen) < 0)
 		goto errout;
 
 	if (gnet_stats_finish_copy(&d) < 0)
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 28c808d..ca9bcad 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -23,7 +23,7 @@
 #include <net/netlink.h>
 
 struct tcf_police {
-	struct tcf_common	common;
+	struct tc_action	common;
 	int			tcfp_result;
 	u32			tcfp_ewma_rate;
 	s64			tcfp_burst;
@@ -73,11 +73,11 @@ static int tcf_act_police_walker(struct net *net, struct sk_buff *skb,
 
 	for (i = 0; i < (POL_TAB_MASK + 1); i++) {
 		struct hlist_head *head;
-		struct tcf_common *p;
+		struct tc_action *p;
 
 		head = &hinfo->htab[tcf_hash(i, POL_TAB_MASK)];
 
-		hlist_for_each_entry_rcu(p, head, tcfc_head) {
+		hlist_for_each_entry_rcu(p, head, tcfa_head) {
 			index++;
 			if (index < s_i)
 				continue;
@@ -85,9 +85,9 @@ static int tcf_act_police_walker(struct net *net, struct sk_buff *skb,
 			if (nest == NULL)
 				goto nla_put_failure;
 			if (type == RTM_DELACTION)
-				err = tcf_action_dump_1(skb, (struct tc_action *)p, 0, 1);
+				err = tcf_action_dump_1(skb, p, 0, 1);
 			else
-				err = tcf_action_dump_1(skb, (struct tc_action *)p, 0, 0);
+				err = tcf_action_dump_1(skb, p, 0, 0);
 			if (err < 0) {
 				index--;
 				nla_nest_cancel(skb, nest);
-- 
2.1.0
