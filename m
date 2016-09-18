From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next 1/1] net sched: stylistic cleanups
Date: Sun, 18 Sep 2016 08:45:33 -0400
Message-ID: <1474202733-14740-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34955 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754166AbcIRMpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 08:45:49 -0400
Received: by mail-it0-f68.google.com with SMTP id e20so3003855itc.2
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 05:45:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c     | 16 ++++++----------
 net/sched/act_csum.c    | 36 ++++++++++++++++++------------------
 net/sched/act_gact.c    |  3 ++-
 net/sched/act_mirred.c  |  3 ++-
 net/sched/act_police.c  | 10 ++++------
 net/sched/cls_api.c     | 18 ++++++++++--------
 net/sched/cls_bpf.c     |  6 ++++--
 net/sched/cls_flow.c    | 21 ++++++++++++++-------
 net/sched/cls_flower.c  |  3 ++-
 net/sched/cls_fw.c      | 10 +++++-----
 net/sched/cls_route.c   |  9 +++------
 net/sched/cls_tcindex.c | 12 ++++++------
 net/sched/cls_u32.c     | 30 ++++++++++++------------------
 net/sched/sch_api.c     | 41 ++++++++++++++++++++++++++---------------
 14 files changed, 114 insertions(+), 104 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d09d068..d0aceb1 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -592,9 +592,8 @@ err_out:
 	return ERR_PTR(err);
 }
 
-int tcf_action_init(struct net *net, struct nlattr *nla,
-				  struct nlattr *est, char *name, int ovr,
-				  int bind, struct list_head *actions)
+int tcf_action_init(struct net *net, struct nlattr *nla, struct nlattr *est,
+		    char *name, int ovr, int bind, struct list_head *actions)
 {
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct tc_action *act;
@@ -923,9 +922,8 @@ tcf_add_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
 	return err;
 }
 
-static int
-tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
-	       u32 portid, int ovr)
+static int tcf_action_add(struct net *net, struct nlattr *nla,
+			  struct nlmsghdr *n, u32 portid, int ovr)
 {
 	int ret = 0;
 	LIST_HEAD(actions);
@@ -988,8 +986,7 @@ replay:
 	return ret;
 }
 
-static struct nlattr *
-find_dump_kind(const struct nlmsghdr *n)
+static struct nlattr *find_dump_kind(const struct nlmsghdr *n)
 {
 	struct nlattr *tb1, *tb2[TCA_ACT_MAX + 1];
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
@@ -1016,8 +1013,7 @@ find_dump_kind(const struct nlmsghdr *n)
 	return kind;
 }
 
-static int
-tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
+static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlmsghdr *nlh;
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index b5dbf63..e0defce 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -116,8 +116,8 @@ static void *tcf_csum_skb_nextlayer(struct sk_buff *skb,
 		return (void *)(skb_network_header(skb) + ihl);
 }
 
-static int tcf_csum_ipv4_icmp(struct sk_buff *skb,
-			      unsigned int ihl, unsigned int ipl)
+static int tcf_csum_ipv4_icmp(struct sk_buff *skb, unsigned int ihl,
+			      unsigned int ipl)
 {
 	struct icmphdr *icmph;
 
@@ -152,8 +152,8 @@ static int tcf_csum_ipv4_igmp(struct sk_buff *skb,
 	return 1;
 }
 
-static int tcf_csum_ipv6_icmp(struct sk_buff *skb,
-			      unsigned int ihl, unsigned int ipl)
+static int tcf_csum_ipv6_icmp(struct sk_buff *skb, unsigned int ihl,
+			      unsigned int ipl)
 {
 	struct icmp6hdr *icmp6h;
 	const struct ipv6hdr *ip6h;
@@ -174,8 +174,8 @@ static int tcf_csum_ipv6_icmp(struct sk_buff *skb,
 	return 1;
 }
 
-static int tcf_csum_ipv4_tcp(struct sk_buff *skb,
-			     unsigned int ihl, unsigned int ipl)
+static int tcf_csum_ipv4_tcp(struct sk_buff *skb, unsigned int ihl,
+			     unsigned int ipl)
 {
 	struct tcphdr *tcph;
 	const struct iphdr *iph;
@@ -195,8 +195,8 @@ static int tcf_csum_ipv4_tcp(struct sk_buff *skb,
 	return 1;
 }
 
-static int tcf_csum_ipv6_tcp(struct sk_buff *skb,
-			     unsigned int ihl, unsigned int ipl)
+static int tcf_csum_ipv6_tcp(struct sk_buff *skb, unsigned int ihl,
+			     unsigned int ipl)
 {
 	struct tcphdr *tcph;
 	const struct ipv6hdr *ip6h;
@@ -217,8 +217,8 @@ static int tcf_csum_ipv6_tcp(struct sk_buff *skb,
 	return 1;
 }
 
-static int tcf_csum_ipv4_udp(struct sk_buff *skb,
-			     unsigned int ihl, unsigned int ipl, int udplite)
+static int tcf_csum_ipv4_udp(struct sk_buff *skb, unsigned int ihl,
+			     unsigned int ipl, int udplite)
 {
 	struct udphdr *udph;
 	const struct iphdr *iph;
@@ -270,8 +270,8 @@ ignore_obscure_skb:
 	return 1;
 }
 
-static int tcf_csum_ipv6_udp(struct sk_buff *skb,
-			     unsigned int ihl, unsigned int ipl, int udplite)
+static int tcf_csum_ipv6_udp(struct sk_buff *skb, unsigned int ihl,
+			     unsigned int ipl, int udplite)
 {
 	struct udphdr *udph;
 	const struct ipv6hdr *ip6h;
@@ -380,8 +380,8 @@ fail:
 	return 0;
 }
 
-static int tcf_csum_ipv6_hopopts(struct ipv6_opt_hdr *ip6xh,
-				 unsigned int ixhl, unsigned int *pl)
+static int tcf_csum_ipv6_hopopts(struct ipv6_opt_hdr *ip6xh, unsigned int ixhl,
+				 unsigned int *pl)
 {
 	int off, len, optlen;
 	unsigned char *xh = (void *)ip6xh;
@@ -494,8 +494,8 @@ fail:
 	return 0;
 }
 
-static int tcf_csum(struct sk_buff *skb,
-		    const struct tc_action *a, struct tcf_result *res)
+static int tcf_csum(struct sk_buff *skb, const struct tc_action *a,
+		    struct tcf_result *res)
 {
 	struct tcf_csum *p = to_tcf_csum(a);
 	int action;
@@ -531,8 +531,8 @@ drop:
 	return TC_ACT_SHOT;
 }
 
-static int tcf_csum_dump(struct sk_buff *skb,
-			 struct tc_action *a, int bind, int ref)
+static int tcf_csum_dump(struct sk_buff *skb, struct tc_action *a, int bind,
+			 int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_csum *p = to_tcf_csum(a);
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index e24a409..e0aa30f 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -156,7 +156,8 @@ static void tcf_gact_stats_update(struct tc_action *a, u64 bytes, u32 packets,
 	int action = READ_ONCE(gact->tcf_action);
 	struct tcf_t *tm = &gact->tcf_tm;
 
-	_bstats_cpu_update(this_cpu_ptr(gact->common.cpu_bstats), bytes, packets);
+	_bstats_cpu_update(this_cpu_ptr(gact->common.cpu_bstats), bytes,
+			   packets);
 	if (action == TC_ACT_SHOT)
 		this_cpu_ptr(gact->common.cpu_qstats)->drops += packets;
 
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 6038c85..1c76387 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -204,7 +204,8 @@ out:
 	return retval;
 }
 
-static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,
+			   int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_mirred *m = to_mirred(a);
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index ba7074b..d1bd248 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -263,8 +263,8 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 	return police->tcf_action;
 }
 
-static int
-tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a,
+			       int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_police *police = to_police(a);
@@ -349,14 +349,12 @@ static struct pernet_operations police_net_ops = {
 	.size = sizeof(struct tc_action_net),
 };
 
-static int __init
-police_init_module(void)
+static int __init police_init_module(void)
 {
 	return tcf_register_action(&act_police_ops, &police_net_ops);
 }
 
-static void __exit
-police_cleanup_module(void)
+static void __exit police_cleanup_module(void)
 {
 	tcf_unregister_action(&act_police_ops, &police_net_ops);
 }
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index a7c5645..11da7da 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -344,13 +344,15 @@ replay:
 			if (err == 0) {
 				struct tcf_proto *next = rtnl_dereference(tp->next);
 
-				tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
+				tfilter_notify(net, skb, n, tp, fh,
+					       RTM_DELTFILTER);
 				if (tcf_destroy(tp, false))
 					RCU_INIT_POINTER(*back, next);
 			}
 			goto errout;
 		case RTM_GETTFILTER:
-			err = tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
+			err = tfilter_notify(net, skb, n, tp, fh,
+					     RTM_NEWTFILTER);
 			goto errout;
 		default:
 			err = -EINVAL;
@@ -448,7 +450,8 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 	struct net *net = sock_net(a->skb->sk);
 
 	return tcf_fill_node(net, a->skb, tp, n, NETLINK_CB(a->cb->skb).portid,
-			     a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTFILTER);
+			     a->cb->nlh->nlmsg_seq, NLM_F_MULTI,
+			     RTM_NEWTFILTER);
 }
 
 /* called with RTNL */
@@ -552,7 +555,7 @@ void tcf_exts_destroy(struct tcf_exts *exts)
 EXPORT_SYMBOL(tcf_exts_destroy);
 
 int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
-		  struct nlattr *rate_tlv, struct tcf_exts *exts, bool ovr)
+		      struct nlattr *rate_tlv, struct tcf_exts *exts, bool ovr)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	{
@@ -560,8 +563,7 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 
 		if (exts->police && tb[exts->police]) {
 			act = tcf_action_init_1(net, tb[exts->police], rate_tlv,
-						"police", ovr,
-						TCA_ACT_BIND);
+						"police", ovr, TCA_ACT_BIND);
 			if (IS_ERR(act))
 				return PTR_ERR(act);
 
@@ -573,8 +575,8 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 			int err, i = 0;
 
 			err = tcf_action_init(net, tb[exts->action], rate_tlv,
-					      NULL, ovr,
-					      TCA_ACT_BIND, &actions);
+					      NULL, ovr, TCA_ACT_BIND,
+					      &actions);
 			if (err)
 				return err;
 			list_for_each_entry(act, &actions, list)
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 1d92d4d..c6f7a47 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -55,7 +55,8 @@ static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
 	[TCA_BPF_CLASSID]	= { .type = NLA_U32 },
 	[TCA_BPF_FLAGS]		= { .type = NLA_U32 },
 	[TCA_BPF_FD]		= { .type = NLA_U32 },
-	[TCA_BPF_NAME]		= { .type = NLA_NUL_STRING, .len = CLS_BPF_NAME_LEN },
+	[TCA_BPF_NAME]		= { .type = NLA_NUL_STRING,
+				    .len = CLS_BPF_NAME_LEN },
 	[TCA_BPF_OPS_LEN]	= { .type = NLA_U16 },
 	[TCA_BPF_OPS]		= { .type = NLA_BINARY,
 				    .len = sizeof(struct sock_filter) * BPF_MAXINSNS },
@@ -409,7 +410,8 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 	}
 
-	ret = cls_bpf_modify_existing(net, tp, prog, base, tb, tca[TCA_RATE], ovr);
+	ret = cls_bpf_modify_existing(net, tp, prog, base, tb, tca[TCA_RATE],
+				      ovr);
 	if (ret < 0)
 		goto errout;
 
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index a379bae..e396723 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -87,12 +87,14 @@ static u32 flow_get_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
 }
 
-static u32 flow_get_proto(const struct sk_buff *skb, const struct flow_keys *flow)
+static u32 flow_get_proto(const struct sk_buff *skb,
+			  const struct flow_keys *flow)
 {
 	return flow->basic.ip_proto;
 }
 
-static u32 flow_get_proto_src(const struct sk_buff *skb, const struct flow_keys *flow)
+static u32 flow_get_proto_src(const struct sk_buff *skb,
+			      const struct flow_keys *flow)
 {
 	if (flow->ports.ports)
 		return ntohs(flow->ports.src);
@@ -100,7 +102,8 @@ static u32 flow_get_proto_src(const struct sk_buff *skb, const struct flow_keys
 	return addr_fold(skb->sk);
 }
 
-static u32 flow_get_proto_dst(const struct sk_buff *skb, const struct flow_keys *flow)
+static u32 flow_get_proto_dst(const struct sk_buff *skb,
+			      const struct flow_keys *flow)
 {
 	if (flow->ports.ports)
 		return ntohs(flow->ports.dst);
@@ -149,7 +152,8 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
 })
 #endif
 
-static u32 flow_get_nfct_src(const struct sk_buff *skb, const struct flow_keys *flow)
+static u32 flow_get_nfct_src(const struct sk_buff *skb,
+			     const struct flow_keys *flow)
 {
 	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
@@ -161,7 +165,8 @@ fallback:
 	return flow_get_src(skb, flow);
 }
 
-static u32 flow_get_nfct_dst(const struct sk_buff *skb, const struct flow_keys *flow)
+static u32 flow_get_nfct_dst(const struct sk_buff *skb,
+			     const struct flow_keys *flow)
 {
 	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
@@ -173,14 +178,16 @@ fallback:
 	return flow_get_dst(skb, flow);
 }
 
-static u32 flow_get_nfct_proto_src(const struct sk_buff *skb, const struct flow_keys *flow)
+static u32 flow_get_nfct_proto_src(const struct sk_buff *skb,
+				   const struct flow_keys *flow)
 {
 	return ntohs(CTTUPLE(skb, src.u.all));
 fallback:
 	return flow_get_proto_src(skb, flow);
 }
 
-static u32 flow_get_nfct_proto_dst(const struct sk_buff *skb, const struct flow_keys *flow)
+static u32 flow_get_nfct_proto_dst(const struct sk_buff *skb,
+				   const struct flow_keys *flow)
 {
 	return ntohs(CTTUPLE(skb, dst.u.all));
 fallback:
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index a3f4c70..2af09c8 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -241,7 +241,8 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	tc.type = TC_SETUP_CLSFLOWER;
 	tc.cls_flower = &offload;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
+	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
+					    &tc);
 
 	if (tc_skip_sw(flags))
 		return err;
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index cc0bda9..9dc63d5 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -57,7 +57,7 @@ static u32 fw_hash(u32 handle)
 }
 
 static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
-			  struct tcf_result *res)
+		       struct tcf_result *res)
 {
 	struct fw_head *head = rcu_dereference_bh(tp->root);
 	struct fw_filter *f;
@@ -188,7 +188,8 @@ static const struct nla_policy fw_policy[TCA_FW_MAX + 1] = {
 
 static int
 fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
-	struct nlattr **tb, struct nlattr **tca, unsigned long base, bool ovr)
+		struct nlattr **tb, struct nlattr **tca, unsigned long base,
+		bool ovr)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
 	struct tcf_exts e;
@@ -237,9 +238,8 @@ errout:
 
 static int fw_change(struct net *net, struct sk_buff *in_skb,
 		     struct tcf_proto *tp, unsigned long base,
-		     u32 handle,
-		     struct nlattr **tca,
-		     unsigned long *arg, bool ovr)
+		     u32 handle, struct nlattr **tca, unsigned long *arg,
+		     bool ovr)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
 	struct fw_filter *f = (struct fw_filter *) *arg;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index c91e65d..a4ce39b 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -268,8 +268,7 @@ static int route4_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void
-route4_delete_filter(struct rcu_head *head)
+static void route4_delete_filter(struct rcu_head *head)
 {
 	struct route4_filter *f = container_of(head, struct route4_filter, rcu);
 
@@ -474,10 +473,8 @@ errout:
 }
 
 static int route4_change(struct net *net, struct sk_buff *in_skb,
-		       struct tcf_proto *tp, unsigned long base,
-		       u32 handle,
-		       struct nlattr **tca,
-		       unsigned long *arg, bool ovr)
+			 struct tcf_proto *tp, unsigned long base, u32 handle,
+			 struct nlattr **tca, unsigned long *arg, bool ovr)
 {
 	struct route4_head *head = rtnl_dereference(tp->root);
 	struct route4_filter __rcu **fp;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index d950070..96144bd 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -50,14 +50,13 @@ struct tcindex_data {
 	struct rcu_head rcu;
 };
 
-static inline int
-tcindex_filter_is_set(struct tcindex_filter_result *r)
+static inline int tcindex_filter_is_set(struct tcindex_filter_result *r)
 {
 	return tcf_exts_is_predicative(&r->exts) || r->res.classid;
 }
 
-static struct tcindex_filter_result *
-tcindex_lookup(struct tcindex_data *p, u16 key)
+static struct tcindex_filter_result *tcindex_lookup(struct tcindex_data *p,
+						    u16 key)
 {
 	if (p->perfect) {
 		struct tcindex_filter_result *f = p->perfect + key;
@@ -144,7 +143,8 @@ static void tcindex_destroy_rexts(struct rcu_head *head)
 
 static void tcindex_destroy_fexts(struct rcu_head *head)
 {
-	struct tcindex_filter *f = container_of(head, struct tcindex_filter, rcu);
+	struct tcindex_filter *f = container_of(head, struct tcindex_filter,
+						rcu);
 
 	tcf_exts_destroy(&f->result.exts);
 	kfree(f);
@@ -550,7 +550,7 @@ static bool tcindex_destroy(struct tcf_proto *tp, bool force)
 
 
 static int tcindex_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
-    struct sk_buff *skb, struct tcmsg *t)
+			struct sk_buff *skb, struct tcmsg *t)
 {
 	struct tcindex_data *p = rtnl_dereference(tp->root);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) fh;
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index a29263a..ae83c3ae 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -104,7 +104,8 @@ static inline unsigned int u32_hash_fold(__be32 key,
 	return h;
 }
 
-static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct tcf_result *res)
+static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+			struct tcf_result *res)
 {
 	struct {
 		struct tc_u_knode *knode;
@@ -256,8 +257,7 @@ deadloop:
 	return -1;
 }
 
-static struct tc_u_hnode *
-u32_lookup_ht(struct tc_u_common *tp_c, u32 handle)
+static struct tc_u_hnode *u32_lookup_ht(struct tc_u_common *tp_c, u32 handle)
 {
 	struct tc_u_hnode *ht;
 
@@ -270,8 +270,7 @@ u32_lookup_ht(struct tc_u_common *tp_c, u32 handle)
 	return ht;
 }
 
-static struct tc_u_knode *
-u32_lookup_key(struct tc_u_hnode *ht, u32 handle)
+static struct tc_u_knode *u32_lookup_key(struct tc_u_hnode *ht, u32 handle)
 {
 	unsigned int sel;
 	struct tc_u_knode *n = NULL;
@@ -360,8 +359,7 @@ static int u32_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static int u32_destroy_key(struct tcf_proto *tp,
-			   struct tc_u_knode *n,
+static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n,
 			   bool free_pf)
 {
 	tcf_exts_destroy(&n->exts);
@@ -448,9 +446,8 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	}
 }
 
-static int u32_replace_hw_hnode(struct tcf_proto *tp,
-				 struct tc_u_hnode *h,
-				 u32 flags)
+static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
+				u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload u32_offload = {0};
@@ -496,9 +493,8 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	}
 }
 
-static int u32_replace_hw_knode(struct tcf_proto *tp,
-				 struct tc_u_knode *n,
-				 u32 flags)
+static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
+				u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload u32_offload = {0};
@@ -763,8 +759,7 @@ errout:
 	return err;
 }
 
-static void u32_replace_knode(struct tcf_proto *tp,
-			      struct tc_u_common *tp_c,
+static void u32_replace_knode(struct tcf_proto *tp, struct tc_u_common *tp_c,
 			      struct tc_u_knode *n)
 {
 	struct tc_u_knode __rcu **ins;
@@ -845,8 +840,7 @@ static struct tc_u_knode *u32_init_knode(struct tcf_proto *tp,
 
 static int u32_change(struct net *net, struct sk_buff *in_skb,
 		      struct tcf_proto *tp, unsigned long base, u32 handle,
-		      struct nlattr **tca,
-		      unsigned long *arg, bool ovr)
+		      struct nlattr **tca, unsigned long *arg, bool ovr)
 {
 	struct tc_u_common *tp_c = tp->data;
 	struct tc_u_hnode *ht;
@@ -1088,7 +1082,7 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 }
 
 static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
-		     struct sk_buff *skb, struct tcmsg *t)
+		    struct sk_buff *skb, struct tcmsg *t)
 {
 	struct tc_u_knode *n = (struct tc_u_knode *)fh;
 	struct tc_u_hnode *ht_up, *ht_down;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d677b34..206dc24 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -389,7 +389,8 @@ static __u8 __detect_linklayer(struct tc_ratespec *r, __u32 *rtab)
 
 static struct qdisc_rate_table *qdisc_rtab_list;
 
-struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r, struct nlattr *tab)
+struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
+					struct nlattr *tab)
 {
 	struct qdisc_rate_table *rtab;
 
@@ -541,7 +542,8 @@ nla_put_failure:
 	return -1;
 }
 
-void __qdisc_calculate_pkt_len(struct sk_buff *skb, const struct qdisc_size_table *stab)
+void __qdisc_calculate_pkt_len(struct sk_buff *skb,
+			       const struct qdisc_size_table *stab)
 {
 	int pkt_len, slot;
 
@@ -888,10 +890,10 @@ static struct lock_class_key qdisc_rx_lock;
    Parameters are passed via opt.
  */
 
-static struct Qdisc *
-qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
-	     struct Qdisc *p, u32 parent, u32 handle,
-	     struct nlattr **tca, int *errp)
+static struct Qdisc *qdisc_create(struct net_device *dev,
+				  struct netdev_queue *dev_queue,
+				  struct Qdisc *p, u32 parent, u32 handle,
+				  struct nlattr **tca, int *errp)
 {
 	int err;
 	struct nlattr *kind = tca[TCA_KIND];
@@ -1073,7 +1075,8 @@ struct check_loop_arg {
 	int			depth;
 };
 
-static int check_loop_fn(struct Qdisc *q, unsigned long cl, struct qdisc_walker *w);
+static int check_loop_fn(struct Qdisc *q, unsigned long cl,
+			 struct qdisc_walker *w);
 
 static int check_loop(struct Qdisc *q, struct Qdisc *p, int depth)
 {
@@ -1450,7 +1453,8 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 	} else {
 		if (!tc_qdisc_dump_ignore(q) &&
 		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).portid,
-				  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0)
+				  cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				  RTM_NEWQDISC) <= 0)
 			goto done;
 		q_idx++;
 	}
@@ -1471,7 +1475,8 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 		}
 		if (!tc_qdisc_dump_ignore(q) &&
 		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).portid,
-				  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0)
+				  cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				  RTM_NEWQDISC) <= 0)
 			goto done;
 		q_idx++;
 	}
@@ -1505,7 +1510,8 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 			s_q_idx = 0;
 		q_idx = 0;
 
-		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx, true) < 0)
+		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx,
+				       true) < 0)
 			goto done;
 
 		dev_queue = dev_ingress_queue(dev);
@@ -1640,7 +1646,8 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
 			if (cops->delete)
 				err = cops->delete(q, cl);
 			if (err == 0)
-				tclass_notify(net, skb, n, q, cl, RTM_DELTCLASS);
+				tclass_notify(net, skb, n, q, cl,
+					      RTM_DELTCLASS);
 			goto out;
 		case RTM_GETTCLASS:
 			err = tclass_notify(net, skb, n, q, cl, RTM_NEWTCLASS);
@@ -1738,12 +1745,14 @@ struct qdisc_dump_args {
 	struct netlink_callback	*cb;
 };
 
-static int qdisc_class_dump(struct Qdisc *q, unsigned long cl, struct qdisc_walker *arg)
+static int qdisc_class_dump(struct Qdisc *q, unsigned long cl,
+			    struct qdisc_walker *arg)
 {
 	struct qdisc_dump_args *a = (struct qdisc_dump_args *)arg;
 
 	return tc_fill_tclass(a->skb, q, cl, NETLINK_CB(a->cb->skb).portid,
-			      a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTCLASS);
+			      a->cb->nlh->nlmsg_seq, NLM_F_MULTI,
+			      RTM_NEWTCLASS);
 }
 
 static int tc_dump_tclass_qdisc(struct Qdisc *q, struct sk_buff *skb,
@@ -1976,10 +1985,12 @@ static int __init pktsched_init(void)
 
 	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETQDISC, tc_get_qdisc, tc_dump_qdisc, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETQDISC, tc_get_qdisc, tc_dump_qdisc,
+		      NULL);
 	rtnl_register(PF_UNSPEC, RTM_NEWTCLASS, tc_ctl_tclass, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELTCLASS, tc_ctl_tclass, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETTCLASS, tc_ctl_tclass, tc_dump_tclass, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETTCLASS, tc_ctl_tclass, tc_dump_tclass,
+		      NULL);
 
 	return 0;
 }
-- 
1.9.1
