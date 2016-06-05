From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/1] net sched: indentation and other OCD stylistic fixes
Date: Sun,  5 Jun 2016 10:41:32 -0400
Message-ID: <1465137692-30959-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35743 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbcFEOlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 10:41:44 -0400
Received: by mail-io0-f193.google.com with SMTP id k19so16260487ioi.2
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 07:41:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/act_api.h          | 14 ++++++++------
 include/net/tc_act/tc_defact.h |  4 ++--
 include/uapi/linux/pkt_cls.h   |  6 +++---
 net/sched/act_api.c            | 19 +++++++++++--------
 net/sched/act_bpf.c            |  3 ++-
 net/sched/act_gact.c           |  3 ++-
 net/sched/act_ipt.c            |  6 ++++--
 net/sched/act_vlan.c           |  3 ++-
 net/sched/cls_api.c            | 11 +++++++----
 9 files changed, 41 insertions(+), 28 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 5453f52..b39f5aa 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -2,8 +2,8 @@
 #define __NET_ACT_API_H
 
 /*
- * Public police action API for classifiers/qdiscs
- */
+ * Public action API for classifiers/qdiscs
+*/
 
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
@@ -107,7 +107,8 @@ struct tc_action_ops {
 	char    kind[IFNAMSIZ];
 	__u32   type; /* TBD to match kind */
 	struct module		*owner;
-	int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
+	int     (*act)(struct sk_buff *, const struct tc_action *,
+		       struct tcf_result *);
 	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
 	void	(*cleanup)(struct tc_action *, int bind);
 	int     (*lookup)(struct net *, struct tc_action *, u32);
@@ -125,8 +126,8 @@ struct tc_action_net {
 };
 
 static inline
-int tc_action_net_init(struct tc_action_net *tn, const struct tc_action_ops *ops,
-		       unsigned int mask)
+int tc_action_net_init(struct tc_action_net *tn,
+		       const struct tc_action_ops *ops, unsigned int mask)
 {
 	int err = 0;
 
@@ -169,7 +170,8 @@ static inline int tcf_hash_release(struct tc_action *a, bool bind)
 }
 
 int tcf_register_action(struct tc_action_ops *a, struct pernet_operations *ops);
-int tcf_unregister_action(struct tc_action_ops *a, struct pernet_operations *ops);
+int tcf_unregister_action(struct tc_action_ops *a,
+			  struct pernet_operations *ops);
 int tcf_action_destroy(struct list_head *actions, int bind);
 int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
 		    struct tcf_result *res);
diff --git a/include/net/tc_act/tc_defact.h b/include/net/tc_act/tc_defact.h
index 9763dcb..ab9b5d6 100644
--- a/include/net/tc_act/tc_defact.h
+++ b/include/net/tc_act/tc_defact.h
@@ -5,8 +5,8 @@
 
 struct tcf_defact {
 	struct tcf_common	common;
-	u32     		tcfd_datalen;
-	void    		*tcfd_defdata;
+	u32		tcfd_datalen;
+	void		*tcfd_defdata;
 };
 #define to_defact(a) \
 	container_of(a->priv, struct tcf_defact, common)
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 9ba1410..5702e93 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -115,8 +115,8 @@ struct tc_police {
 	__u32			mtu;
 	struct tc_ratespec	rate;
 	struct tc_ratespec	peakrate;
-	int 			refcnt;
-	int 			bindcnt;
+	int			refcnt;
+	int			bindcnt;
 	__u32			capab;
 };
 
@@ -128,7 +128,7 @@ struct tcf_t {
 };
 
 struct tc_cnt {
-	int                   refcnt; 
+	int                   refcnt;
 	int                   bindcnt;
 };
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 5ebf6d6..719bc2e 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -504,8 +504,8 @@ nla_put_failure:
 }
 EXPORT_SYMBOL(tcf_action_dump_1);
 
-int
-tcf_action_dump(struct sk_buff *skb, struct list_head *actions, int bind, int ref)
+int tcf_action_dump(struct sk_buff *skb, struct list_head *actions,
+		    int bind, int ref)
 {
 	struct tc_action *a;
 	int err = -EINVAL;
@@ -688,9 +688,9 @@ errout:
 	return -1;
 }
 
-static int
-tca_get_fill(struct sk_buff *skb, struct list_head *actions, u32 portid, u32 seq,
-	     u16 flags, int event, int bind, int ref)
+static int tca_get_fill(struct sk_buff *skb, struct list_head *actions,
+			u32 portid, u32 seq, u16 flags, int event, int bind,
+			int ref)
 {
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
@@ -731,7 +731,8 @@ act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
 		return -ENOBUFS;
-	if (tca_get_fill(skb, actions, portid, n->nlmsg_seq, 0, event, 0, 0) <= 0) {
+	if (tca_get_fill(skb, actions, portid, n->nlmsg_seq, 0, event,
+			 0, 0) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -839,7 +840,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	if (a.ops == NULL) /*some idjot trying to flush unknown action */
 		goto err_out;
 
-	nlh = nlmsg_put(skb, portid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t), 0);
+	nlh = nlmsg_put(skb, portid, n->nlmsg_seq, RTM_DELACTION,
+			sizeof(*t), 0);
 	if (!nlh)
 		goto out_module_put;
 	t = nlmsg_data(nlh);
@@ -1002,7 +1004,8 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n)
 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
 	int ret = 0, ovr = 0;
 
-	if ((n->nlmsg_type != RTM_GETACTION) && !netlink_capable(skb, CAP_NET_ADMIN))
+	if ((n->nlmsg_type != RTM_GETACTION) &&
+	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
 	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL);
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index ae0e7cb..f7b6cf4 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -169,7 +169,8 @@ nla_put_failure:
 static const struct nla_policy act_bpf_policy[TCA_ACT_BPF_MAX + 1] = {
 	[TCA_ACT_BPF_PARMS]	= { .len = sizeof(struct tc_act_bpf) },
 	[TCA_ACT_BPF_FD]	= { .type = NLA_U32 },
-	[TCA_ACT_BPF_NAME]	= { .type = NLA_NUL_STRING, .len = ACT_BPF_NAME_LEN },
+	[TCA_ACT_BPF_NAME]	= { .type = NLA_NUL_STRING,
+				    .len = ACT_BPF_NAME_LEN },
 	[TCA_ACT_BPF_OPS_LEN]	= { .type = NLA_U16 },
 	[TCA_ACT_BPF_OPS]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct sock_filter) * BPF_MAXINSNS },
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 4c6e008..19058a7 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -162,7 +162,8 @@ static void tcf_gact_stats_update(struct tc_action *a, u64 bytes, u32 packets,
 	tm->lastuse = lastuse;
 }
 
-static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a,
+			 int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_gact *gact = a->priv;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 3fcde44..e7c0f4d 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -34,7 +34,8 @@ static int ipt_net_id;
 
 static int xt_net_id;
 
-static int ipt_init_target(struct xt_entry_target *t, char *table, unsigned int hook)
+static int ipt_init_target(struct xt_entry_target *t, char *table,
+			   unsigned int hook)
 {
 	struct xt_tgchk_param par;
 	struct xt_target *target;
@@ -250,7 +251,8 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 
 }
 
-static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind,
+			int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_ipt *ipt = a->priv;
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index f0a08a1..b075d50 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -179,7 +179,8 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
 
 	if (v->tcfv_action == TCA_VLAN_ACT_PUSH &&
 	    (nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_ID, v->tcfv_push_vid) ||
-	     nla_put_be16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL, v->tcfv_push_proto)))
+	     nla_put_be16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL,
+			  v->tcfv_push_proto)))
 		goto nla_put_failure;
 
 	tcf_tm_dump(&t, &v->tcf_tm);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index a75864d..aafa6bce 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -351,8 +351,9 @@ errout:
 	return err;
 }
 
-static int tcf_fill_node(struct net *net, struct sk_buff *skb, struct tcf_proto *tp,
-			 unsigned long fh, u32 portid, u32 seq, u16 flags, int event)
+static int tcf_fill_node(struct net *net, struct sk_buff *skb,
+			 struct tcf_proto *tp, unsigned long fh, u32 portid,
+			 u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
@@ -474,9 +475,11 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 		    TC_H_MIN(tcm->tcm_info) != tp->protocol)
 			continue;
 		if (t > s_t)
-			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
+			memset(&cb->args[1], 0,
+			       sizeof(cb->args)-sizeof(cb->args[0]));
 		if (cb->args[1] == 0) {
-			if (tcf_fill_node(net, skb, tp, 0, NETLINK_CB(cb->skb).portid,
+			if (tcf_fill_node(net, skb, tp, 0,
+					  NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					  RTM_NEWTFILTER) <= 0)
 				break;
-- 
1.9.1
