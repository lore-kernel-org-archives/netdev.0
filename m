From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v4 2/2] net sched: Trivial whitespace and stylistic changes
Date: Tue, 17 Jan 2017 06:11:49 -0500
Message-ID: <1484651509-27500-3-git-send-email-jhs@emojatatu.com>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35529 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdAQLNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 06:13:04 -0500
Received: by mail-qt0-f196.google.com with SMTP id f4so20684104qte.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 03:12:06 -0800 (PST)
In-Reply-To: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/act_api.h |  7 ++++---
 include/net/pkt_cls.h | 45 ++++++++++++++++++---------------------------
 net/sched/act_api.c   | 20 ++++++++------------
 3 files changed, 30 insertions(+), 42 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 0692458..b912908 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -118,7 +118,8 @@ struct tc_action_ops {
 			struct nlattr *est, struct tc_action **act, int ovr,
 			int bind);
 	int     (*walk)(struct net *, struct sk_buff *,
-			struct netlink_callback *, int, const struct tc_action_ops *);
+			struct netlink_callback *, int,
+			const struct tc_action_ops *);
 	void	(*stats_update)(struct tc_action *, u64, u32, u64);
 	int	(*get_dev)(const struct tc_action *a, struct net *net,
 			   struct net_device **mirred_dev);
@@ -162,8 +163,8 @@ int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
 		    int bind);
 int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
-		    struct tc_action **a, const struct tc_action_ops *ops, int bind,
-		    bool cpustats);
+		    struct tc_action **a, const struct tc_action_ops *ops,
+		    int bind, bool cpustats);
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
 void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a);
 
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index e0bc7e8..2a2c442 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -11,33 +11,32 @@ struct tcf_walker {
 	int	stop;
 	int	skip;
 	int	count;
-	int	(*fn)(struct tcf_proto *, unsigned long node, struct tcf_walker *);
+	int	(*fn)(struct tcf_proto *, unsigned long node,
+		      struct tcf_walker *);
 };
 
 int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
-static inline unsigned long
-__cls_set_class(unsigned long *clp, unsigned long cl)
+static inline unsigned long __cls_set_class(unsigned long *clp,
+					    unsigned long cl)
 {
 	return xchg(clp, cl);
 }
 
-static inline unsigned long
-cls_set_class(struct tcf_proto *tp, unsigned long *clp, 
+static inline unsigned long cls_set_class(struct tcf_proto *tp,
+					  unsigned long *clp,
 	unsigned long cl)
 {
 	unsigned long old_cl;
-	
 	tcf_tree_lock(tp);
 	old_cl = __cls_set_class(clp, cl);
 	tcf_tree_unlock(tp);
- 
 	return old_cl;
 }
 
-static inline void
-tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r, unsigned long base)
+static inline void tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r,
+				   unsigned long base)
 {
 	unsigned long cl;
 
@@ -47,8 +46,7 @@ struct tcf_walker {
 		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
 }
 
-static inline void
-tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
+static inline void tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
 {
 	unsigned long cl;
 
@@ -91,8 +89,7 @@ static inline int tcf_exts_init(struct tcf_exts *exts, int action, int police)
  * Returns 1 if a predicative extension is present, i.e. an extension which
  * might cause further actions and thus overrule the regular tcf_result.
  */
-static inline int
-tcf_exts_is_predicative(struct tcf_exts *exts)
+static inline int tcf_exts_is_predicative(struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	return exts->nr_actions;
@@ -107,8 +104,7 @@ static inline int tcf_exts_init(struct tcf_exts *exts, int action, int police)
  *
  * Returns 1 if at least one extension is present.
  */
-static inline int
-tcf_exts_is_available(struct tcf_exts *exts)
+static inline int tcf_exts_is_available(struct tcf_exts *exts)
 {
 	/* All non-predicative extensions must be added here. */
 	return tcf_exts_is_predicative(exts);
@@ -139,9 +135,8 @@ static inline void tcf_exts_to_list(const struct tcf_exts *exts,
  * a positive action code (TC_ACT_*) which must be returned to the
  * underlying layer.
  */
-static inline int
-tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
-	       struct tcf_result *res)
+static inline int tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
+				struct tcf_result *res)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (exts->nr_actions)
@@ -196,7 +191,7 @@ struct tcf_pkt_info {
  * @data: ematch specific data
  */
 struct tcf_ematch {
-	struct tcf_ematch_ops * ops;
+	struct tcf_ematch_ops *ops;
 	unsigned long		data;
 	unsigned int		datalen;
 	u16			matchid;
@@ -237,7 +232,6 @@ static inline int tcf_em_early_end(struct tcf_ematch *em, int result)
 
 	return 0;
 }
-	
 /**
  * struct tcf_ematch_tree - ematch tree handle
  *
@@ -246,8 +240,7 @@ static inline int tcf_em_early_end(struct tcf_ematch *em, int result)
  */
 struct tcf_ematch_tree {
 	struct tcf_ematch_tree_hdr hdr;
-	struct tcf_ematch *	matches;
-	
+	struct tcf_ematch	*matches;
 };
 
 /**
@@ -343,7 +336,7 @@ struct tcf_ematch_tree {
 
 #endif /* CONFIG_NET_EMATCH */
 
-static inline unsigned char * tcf_get_base_ptr(struct sk_buff *skb, int layer)
+static inline unsigned char *tcf_get_base_ptr(struct sk_buff *skb, int layer)
 {
 	switch (layer) {
 		case TCF_LAYER_LINK:
@@ -368,8 +361,7 @@ static inline int tcf_valid_offset(const struct sk_buff *skb,
 #ifdef CONFIG_NET_CLS_IND
 #include <net/net_namespace.h>
 
-static inline int
-tcf_change_indev(struct net *net, struct nlattr *indev_tlv)
+static inline int tcf_change_indev(struct net *net, struct nlattr *indev_tlv)
 {
 	char indev[IFNAMSIZ];
 	struct net_device *dev;
@@ -382,8 +374,7 @@ static inline int tcf_valid_offset(const struct sk_buff *skb,
 	return dev->ifindex;
 }
 
-static inline bool
-tcf_match_indev(struct sk_buff *skb, int ifindex)
+static inline bool tcf_match_indev(struct sk_buff *skb, int ifindex)
 {
 	if (!ifindex)
 		return true;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 43f1f42..37ac78d 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -739,9 +739,8 @@ static int tca_get_fill(struct sk_buff *skb, struct list_head *actions,
 	return -1;
 }
 
-static int
-act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
-	       struct list_head *actions, int event)
+static int act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
+			  struct list_head *actions, int event)
 {
 	struct sk_buff *skb;
 
@@ -864,9 +863,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	return err;
 }
 
-static int
-tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
-	       u32 portid)
+static int tcf_del_notify(struct net *net, struct nlmsghdr *n,
+			  struct list_head *actions, u32 portid)
 {
 	int ret;
 	struct sk_buff *skb;
@@ -895,9 +893,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	return ret;
 }
 
-static int
-tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
-	      u32 portid, int event)
+static int tca_action_gd(struct net *net, struct nlattr *nla,
+			 struct nlmsghdr *n, u32 portid, int event)
 {
 	int i, ret;
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
@@ -940,9 +937,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	return ret;
 }
 
-static int
-tcf_add_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
-	       u32 portid)
+static int tcf_add_notify(struct net *net, struct nlmsghdr *n,
+			  struct list_head *actions, u32 portid)
 {
 	struct sk_buff *skb;
 	int err = 0;
-- 
1.9.1
