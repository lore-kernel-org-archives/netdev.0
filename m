From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 26/31: nfnetlink: constify message attributes and headers
Date: Thu, 10 Sep 2009 18:12:20 +0200 (MEST)
Message-ID: <20090910161215.31179.30761.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64708 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbZIJQMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:12:17 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 3993832464dd4e14a4c926583a11f0fa92c1f0f0
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Aug 25 16:07:58 2009 +0200

    netfilter: nfnetlink: constify message attributes and headers
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index bff4d57..9f00da2 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -58,7 +58,8 @@ struct nfgenmsg {
 struct nfnl_callback
 {
 	int (*call)(struct sock *nl, struct sk_buff *skb, 
-		struct nlmsghdr *nlh, struct nlattr *cda[]);
+		    const struct nlmsghdr *nlh,
+		    const struct nlattr * const cda[]);
 	const struct nla_policy *policy;	/* netlink attribute policy */
 	const u_int16_t attr_count;		/* number of nlattr's */
 };
diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index 5868406..33602ab 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -31,6 +31,6 @@ struct nlattr;
 extern int
 (*nfnetlink_parse_nat_setup_hook)(struct nf_conn *ct,
 				  enum nf_nat_manip_type manip,
-				  struct nlattr *attr);
+				  const struct nlattr *attr);
 
 #endif /* _NF_NAT_CORE_H */
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index b6ddd56..68afc6e 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -620,7 +620,7 @@ static const struct nla_policy nat_nla_policy[CTA_NAT_MAX+1] = {
 };
 
 static int
-nfnetlink_parse_nat(struct nlattr *nat,
+nfnetlink_parse_nat(const struct nlattr *nat,
 		    const struct nf_conn *ct, struct nf_nat_range *range)
 {
 	struct nlattr *tb[CTA_NAT_MAX+1];
@@ -656,7 +656,7 @@ nfnetlink_parse_nat(struct nlattr *nat,
 static int
 nfnetlink_parse_nat_setup(struct nf_conn *ct,
 			  enum nf_nat_manip_type manip,
-			  struct nlattr *attr)
+			  const struct nlattr *attr)
 {
 	struct nf_nat_range range;
 
@@ -671,7 +671,7 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 static int
 nfnetlink_parse_nat_setup(struct nf_conn *ct,
 			  enum nf_nat_manip_type manip,
-			  struct nlattr *attr)
+			  const struct nlattr *attr)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index b5869b9..565c3a8 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -47,7 +47,7 @@
 
 int (*nfnetlink_parse_nat_setup_hook)(struct nf_conn *ct,
 				      enum nf_nat_manip_type manip,
-				      struct nlattr *attr) __read_mostly;
+				      const struct nlattr *attr) __read_mostly;
 EXPORT_SYMBOL_GPL(nfnetlink_parse_nat_setup_hook);
 
 DEFINE_SPINLOCK(nf_conntrack_lock);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 49479d1..59d8064 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -704,7 +704,8 @@ ctnetlink_parse_tuple_proto(struct nlattr *attr,
 }
 
 static int
-ctnetlink_parse_tuple(struct nlattr *cda[], struct nf_conntrack_tuple *tuple,
+ctnetlink_parse_tuple(const struct nlattr * const cda[],
+		      struct nf_conntrack_tuple *tuple,
 		      enum ctattr_tuple type, u_int8_t l3num)
 {
 	struct nlattr *tb[CTA_TUPLE_MAX+1];
@@ -740,7 +741,7 @@ ctnetlink_parse_tuple(struct nlattr *cda[], struct nf_conntrack_tuple *tuple,
 }
 
 static inline int
-ctnetlink_parse_help(struct nlattr *attr, char **helper_name)
+ctnetlink_parse_help(const struct nlattr *attr, char **helper_name)
 {
 	struct nlattr *tb[CTA_HELP_MAX+1];
 
@@ -764,7 +765,8 @@ static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 
 static int
 ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
-			struct nlmsghdr *nlh, struct nlattr *cda[])
+			const struct nlmsghdr *nlh,
+			const struct nlattr * const cda[])
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
@@ -823,7 +825,8 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 static int
 ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
-			struct nlmsghdr *nlh, struct nlattr *cda[])
+			const struct nlmsghdr *nlh,
+			const struct nlattr * const cda[])
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
@@ -884,7 +887,7 @@ out:
 static int
 ctnetlink_parse_nat_setup(struct nf_conn *ct,
 			  enum nf_nat_manip_type manip,
-			  struct nlattr *attr)
+			  const struct nlattr *attr)
 {
 	typeof(nfnetlink_parse_nat_setup_hook) parse_nat_setup;
 
@@ -914,7 +917,7 @@ ctnetlink_parse_nat_setup(struct nf_conn *ct,
 #endif
 
 static int
-ctnetlink_change_status(struct nf_conn *ct, struct nlattr *cda[])
+ctnetlink_change_status(struct nf_conn *ct, const struct nlattr * const cda[])
 {
 	unsigned long d;
 	unsigned int status = ntohl(nla_get_be32(cda[CTA_STATUS]));
@@ -940,7 +943,7 @@ ctnetlink_change_status(struct nf_conn *ct, struct nlattr *cda[])
 }
 
 static int
-ctnetlink_change_nat(struct nf_conn *ct, struct nlattr *cda[])
+ctnetlink_change_nat(struct nf_conn *ct, const struct nlattr * const cda[])
 {
 #ifdef CONFIG_NF_NAT_NEEDED
 	int ret;
@@ -966,7 +969,7 @@ ctnetlink_change_nat(struct nf_conn *ct, struct nlattr *cda[])
 }
 
 static inline int
-ctnetlink_change_helper(struct nf_conn *ct, struct nlattr *cda[])
+ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 {
 	struct nf_conntrack_helper *helper;
 	struct nf_conn_help *help = nfct_help(ct);
@@ -1028,7 +1031,7 @@ ctnetlink_change_helper(struct nf_conn *ct, struct nlattr *cda[])
 }
 
 static inline int
-ctnetlink_change_timeout(struct nf_conn *ct, struct nlattr *cda[])
+ctnetlink_change_timeout(struct nf_conn *ct, const struct nlattr * const cda[])
 {
 	u_int32_t timeout = ntohl(nla_get_be32(cda[CTA_TIMEOUT]));
 
@@ -1042,9 +1045,10 @@ ctnetlink_change_timeout(struct nf_conn *ct, struct nlattr *cda[])
 }
 
 static inline int
-ctnetlink_change_protoinfo(struct nf_conn *ct, struct nlattr *cda[])
+ctnetlink_change_protoinfo(struct nf_conn *ct, const struct nlattr * const cda[])
 {
-	struct nlattr *tb[CTA_PROTOINFO_MAX+1], *attr = cda[CTA_PROTOINFO];
+	const struct nlattr *attr = cda[CTA_PROTOINFO];
+	struct nlattr *tb[CTA_PROTOINFO_MAX+1];
 	struct nf_conntrack_l4proto *l4proto;
 	int err = 0;
 
@@ -1061,7 +1065,7 @@ ctnetlink_change_protoinfo(struct nf_conn *ct, struct nlattr *cda[])
 
 #ifdef CONFIG_NF_NAT_NEEDED
 static inline int
-change_nat_seq_adj(struct nf_nat_seq *natseq, struct nlattr *attr)
+change_nat_seq_adj(struct nf_nat_seq *natseq, const struct nlattr * const attr)
 {
 	struct nlattr *cda[CTA_NAT_SEQ_MAX+1];
 
@@ -1089,7 +1093,8 @@ change_nat_seq_adj(struct nf_nat_seq *natseq, struct nlattr *attr)
 }
 
 static int
-ctnetlink_change_nat_seq_adj(struct nf_conn *ct, struct nlattr *cda[])
+ctnetlink_change_nat_seq_adj(struct nf_conn *ct,
+			     const struct nlattr * const cda[])
 {
 	int ret = 0;
 	struct nf_conn_nat *nat = nfct_nat(ct);
@@ -1120,7 +1125,8 @@ ctnetlink_change_nat_seq_adj(struct nf_conn *ct, struct nlattr *cda[])
 #endif
 
 static int
-ctnetlink_change_conntrack(struct nf_conn *ct, struct nlattr *cda[])
+ctnetlink_change_conntrack(struct nf_conn *ct,
+			   const struct nlattr * const cda[])
 {
 	int err;
 
@@ -1169,7 +1175,7 @@ ctnetlink_change_conntrack(struct nf_conn *ct, struct nlattr *cda[])
 }
 
 static struct nf_conn *
-ctnetlink_create_conntrack(struct nlattr *cda[],
+ctnetlink_create_conntrack(const struct nlattr * const cda[],
 			   struct nf_conntrack_tuple *otuple,
 			   struct nf_conntrack_tuple *rtuple,
 			   u8 u3)
@@ -1304,7 +1310,8 @@ err1:
 
 static int
 ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
-			struct nlmsghdr *nlh, struct nlattr *cda[])
+			const struct nlmsghdr *nlh,
+			const struct nlattr * const cda[])
 {
 	struct nf_conntrack_tuple otuple, rtuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
@@ -1629,7 +1636,8 @@ static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
 
 static int
 ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
-		     struct nlmsghdr *nlh, struct nlattr *cda[])
+		     const struct nlmsghdr *nlh,
+		     const struct nlattr * const cda[])
 {
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
@@ -1689,7 +1697,8 @@ out:
 
 static int
 ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
-		     struct nlmsghdr *nlh, struct nlattr *cda[])
+		     const struct nlmsghdr *nlh,
+		     const struct nlattr * const cda[])
 {
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple tuple;
@@ -1767,13 +1776,15 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 	return 0;
 }
 static int
-ctnetlink_change_expect(struct nf_conntrack_expect *x, struct nlattr *cda[])
+ctnetlink_change_expect(struct nf_conntrack_expect *x,
+			const struct nlattr * const cda[])
 {
 	return -EOPNOTSUPP;
 }
 
 static int
-ctnetlink_create_expect(struct nlattr *cda[], u_int8_t u3, u32 pid, int report)
+ctnetlink_create_expect(const struct nlattr * const cda[], u_int8_t u3,
+			u32 pid, int report)
 {
 	struct nf_conntrack_tuple tuple, mask, master_tuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
@@ -1831,7 +1842,8 @@ out:
 
 static int
 ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
-		     struct nlmsghdr *nlh, struct nlattr *cda[])
+		     const struct nlmsghdr *nlh,
+		     const struct nlattr * const cda[])
 {
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 92761a9..eedc0c1 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -170,7 +170,7 @@ replay:
 		if (err < 0)
 			return err;
 
-		err = nc->call(nfnl, skb, nlh, cda);
+		err = nc->call(nfnl, skb, nlh, (const struct nlattr **)cda);
 		if (err == -EAGAIN)
 			goto replay;
 		return err;
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 66a6dd5..f900dc3 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -694,7 +694,8 @@ static struct notifier_block nfulnl_rtnl_notifier = {
 
 static int
 nfulnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
-		  struct nlmsghdr *nlh, struct nlattr *nfqa[])
+		   const struct nlmsghdr *nlh,
+		   const struct nlattr * const nfqa[])
 {
 	return -ENOTSUPP;
 }
@@ -716,7 +717,8 @@ static const struct nla_policy nfula_cfg_policy[NFULA_CFG_MAX+1] = {
 
 static int
 nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
-		   struct nlmsghdr *nlh, struct nlattr *nfula[])
+		   const struct nlmsghdr *nlh,
+		   const struct nlattr * const nfula[])
 {
 	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
 	u_int16_t group_num = ntohs(nfmsg->res_id);
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 71daa09..7a9dec9 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -608,7 +608,8 @@ static const struct nla_policy nfqa_verdict_policy[NFQA_MAX+1] = {
 
 static int
 nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
-		   struct nlmsghdr *nlh, struct nlattr *nfqa[])
+		   const struct nlmsghdr *nlh,
+		   const struct nlattr * const nfqa[])
 {
 	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
@@ -670,7 +671,8 @@ err_out_unlock:
 
 static int
 nfqnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
-		  struct nlmsghdr *nlh, struct nlattr *nfqa[])
+		  const struct nlmsghdr *nlh,
+		  const struct nlattr * const nfqa[])
 {
 	return -ENOTSUPP;
 }
@@ -687,7 +689,8 @@ static const struct nf_queue_handler nfqh = {
 
 static int
 nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
-		  struct nlmsghdr *nlh, struct nlattr *nfqa[])
+		  const struct nlmsghdr *nlh,
+		  const struct nlattr * const nfqa[])
 {
 	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 0f482e2..63e1905 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -70,7 +70,8 @@ static void xt_osf_finger_free_rcu(struct rcu_head *rcu_head)
 }
 
 static int xt_osf_add_callback(struct sock *ctnl, struct sk_buff *skb,
-			struct nlmsghdr *nlh, struct nlattr *osf_attrs[])
+			       const struct nlmsghdr *nlh,
+			       const struct nlattr * const osf_attrs[])
 {
 	struct xt_osf_user_finger *f;
 	struct xt_osf_finger *kf = NULL, *sf;
@@ -112,7 +113,8 @@ static int xt_osf_add_callback(struct sock *ctnl, struct sk_buff *skb,
 }
 
 static int xt_osf_remove_callback(struct sock *ctnl, struct sk_buff *skb,
-			struct nlmsghdr *nlh, struct nlattr *osf_attrs[])
+				  const struct nlmsghdr *nlh,
+				  const struct nlattr * const osf_attrs[])
 {
 	struct xt_osf_user_finger *f;
 	struct xt_osf_finger *sf;
