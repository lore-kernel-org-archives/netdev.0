From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/23] netfilter: ctnetlink: remove unnecessary inlining
Date: Fri, 22 Apr 2016 15:39:49 +0200
Message-ID: <1461332394-3994-19-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45279 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924AbcDVNkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:22 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C20304B9EE
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:20 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9F5ED9D107
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:20 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A25F9FAB5F
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:17 +0200 (CEST)
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many of these functions are called from control plane path.  Move
ctnetlink_nlmsg_size() under CONFIG_NF_CONNTRACK_EVENTS to avoid a
compilation warning when CONFIG_NF_CONNTRACK_EVENTS=n.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 117 ++++++++++++++---------------------
 1 file changed, 48 insertions(+), 69 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 355e855..caa4efe 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -58,10 +58,9 @@ MODULE_LICENSE("GPL");
 
 static char __initdata version[] = "0.93";
 
-static inline int
-ctnetlink_dump_tuples_proto(struct sk_buff *skb,
-			    const struct nf_conntrack_tuple *tuple,
-			    struct nf_conntrack_l4proto *l4proto)
+static int ctnetlink_dump_tuples_proto(struct sk_buff *skb,
+				       const struct nf_conntrack_tuple *tuple,
+				       struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 	struct nlattr *nest_parms;
@@ -83,10 +82,9 @@ nla_put_failure:
 	return -1;
 }
 
-static inline int
-ctnetlink_dump_tuples_ip(struct sk_buff *skb,
-			 const struct nf_conntrack_tuple *tuple,
-			 struct nf_conntrack_l3proto *l3proto)
+static int ctnetlink_dump_tuples_ip(struct sk_buff *skb,
+				    const struct nf_conntrack_tuple *tuple,
+				    struct nf_conntrack_l3proto *l3proto)
 {
 	int ret = 0;
 	struct nlattr *nest_parms;
@@ -106,9 +104,8 @@ nla_put_failure:
 	return -1;
 }
 
-static int
-ctnetlink_dump_tuples(struct sk_buff *skb,
-		      const struct nf_conntrack_tuple *tuple)
+static int ctnetlink_dump_tuples(struct sk_buff *skb,
+				 const struct nf_conntrack_tuple *tuple)
 {
 	int ret;
 	struct nf_conntrack_l3proto *l3proto;
@@ -127,9 +124,8 @@ ctnetlink_dump_tuples(struct sk_buff *skb,
 	return ret;
 }
 
-static inline int
-ctnetlink_dump_zone_id(struct sk_buff *skb, int attrtype,
-		       const struct nf_conntrack_zone *zone, int dir)
+static int ctnetlink_dump_zone_id(struct sk_buff *skb, int attrtype,
+				  const struct nf_conntrack_zone *zone, int dir)
 {
 	if (zone->id == NF_CT_DEFAULT_ZONE_ID || zone->dir != dir)
 		return 0;
@@ -141,8 +137,7 @@ nla_put_failure:
 	return -1;
 }
 
-static inline int
-ctnetlink_dump_status(struct sk_buff *skb, const struct nf_conn *ct)
+static int ctnetlink_dump_status(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	if (nla_put_be32(skb, CTA_STATUS, htonl(ct->status)))
 		goto nla_put_failure;
@@ -152,8 +147,7 @@ nla_put_failure:
 	return -1;
 }
 
-static inline int
-ctnetlink_dump_timeout(struct sk_buff *skb, const struct nf_conn *ct)
+static int ctnetlink_dump_timeout(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	long timeout = ((long)ct->timeout.expires - (long)jiffies) / HZ;
 
@@ -168,8 +162,7 @@ nla_put_failure:
 	return -1;
 }
 
-static inline int
-ctnetlink_dump_protoinfo(struct sk_buff *skb, struct nf_conn *ct)
+static int ctnetlink_dump_protoinfo(struct sk_buff *skb, struct nf_conn *ct)
 {
 	struct nf_conntrack_l4proto *l4proto;
 	struct nlattr *nest_proto;
@@ -193,8 +186,8 @@ nla_put_failure:
 	return -1;
 }
 
-static inline int
-ctnetlink_dump_helpinfo(struct sk_buff *skb, const struct nf_conn *ct)
+static int ctnetlink_dump_helpinfo(struct sk_buff *skb,
+				   const struct nf_conn *ct)
 {
 	struct nlattr *nest_helper;
 	const struct nf_conn_help *help = nfct_help(ct);
@@ -300,8 +293,7 @@ nla_put_failure:
 }
 
 #ifdef CONFIG_NF_CONNTRACK_MARK
-static inline int
-ctnetlink_dump_mark(struct sk_buff *skb, const struct nf_conn *ct)
+static int ctnetlink_dump_mark(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	if (nla_put_be32(skb, CTA_MARK, htonl(ct->mark)))
 		goto nla_put_failure;
@@ -315,8 +307,7 @@ nla_put_failure:
 #endif
 
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
-static inline int
-ctnetlink_dump_secctx(struct sk_buff *skb, const struct nf_conn *ct)
+static int ctnetlink_dump_secctx(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	struct nlattr *nest_secctx;
 	int len, ret;
@@ -380,8 +371,7 @@ ctnetlink_dump_labels(struct sk_buff *skb, const struct nf_conn *ct)
 
 #define master_tuple(ct) &(ct->master->tuplehash[IP_CT_DIR_ORIGINAL].tuple)
 
-static inline int
-ctnetlink_dump_master(struct sk_buff *skb, const struct nf_conn *ct)
+static int ctnetlink_dump_master(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	struct nlattr *nest_parms;
 
@@ -426,8 +416,8 @@ nla_put_failure:
 	return -1;
 }
 
-static inline int
-ctnetlink_dump_ct_seq_adj(struct sk_buff *skb, const struct nf_conn *ct)
+static int ctnetlink_dump_ct_seq_adj(struct sk_buff *skb,
+				     const struct nf_conn *ct)
 {
 	struct nf_conn_seqadj *seqadj = nfct_seqadj(ct);
 	struct nf_ct_seqadj *seq;
@@ -446,8 +436,7 @@ ctnetlink_dump_ct_seq_adj(struct sk_buff *skb, const struct nf_conn *ct)
 	return 0;
 }
 
-static inline int
-ctnetlink_dump_id(struct sk_buff *skb, const struct nf_conn *ct)
+static int ctnetlink_dump_id(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	if (nla_put_be32(skb, CTA_ID, htonl((unsigned long)ct)))
 		goto nla_put_failure;
@@ -457,8 +446,7 @@ nla_put_failure:
 	return -1;
 }
 
-static inline int
-ctnetlink_dump_use(struct sk_buff *skb, const struct nf_conn *ct)
+static int ctnetlink_dump_use(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	if (nla_put_be32(skb, CTA_USE, htonl(atomic_read(&ct->ct_general.use))))
 		goto nla_put_failure;
@@ -538,8 +526,7 @@ nla_put_failure:
 	return -1;
 }
 
-static inline size_t
-ctnetlink_proto_size(const struct nf_conn *ct)
+static size_t ctnetlink_proto_size(const struct nf_conn *ct)
 {
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
@@ -556,8 +543,7 @@ ctnetlink_proto_size(const struct nf_conn *ct)
 	return len;
 }
 
-static inline size_t
-ctnetlink_acct_size(const struct nf_conn *ct)
+static size_t ctnetlink_acct_size(const struct nf_conn *ct)
 {
 	if (!nf_ct_ext_exist(ct, NF_CT_EXT_ACCT))
 		return 0;
@@ -567,8 +553,7 @@ ctnetlink_acct_size(const struct nf_conn *ct)
 	       ;
 }
 
-static inline int
-ctnetlink_secctx_size(const struct nf_conn *ct)
+static int ctnetlink_secctx_size(const struct nf_conn *ct)
 {
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	int len, ret;
@@ -584,8 +569,7 @@ ctnetlink_secctx_size(const struct nf_conn *ct)
 #endif
 }
 
-static inline size_t
-ctnetlink_timestamp_size(const struct nf_conn *ct)
+static size_t ctnetlink_timestamp_size(const struct nf_conn *ct)
 {
 #ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
 	if (!nf_ct_ext_exist(ct, NF_CT_EXT_TSTAMP))
@@ -596,8 +580,8 @@ ctnetlink_timestamp_size(const struct nf_conn *ct)
 #endif
 }
 
-static inline size_t
-ctnetlink_nlmsg_size(const struct nf_conn *ct)
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
+static size_t ctnetlink_nlmsg_size(const struct nf_conn *ct)
 {
 	return NLMSG_ALIGN(sizeof(struct nfgenmsg))
 	       + 3 * nla_total_size(0) /* CTA_TUPLE_ORIG|REPL|MASTER */
@@ -628,7 +612,6 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 	       ;
 }
 
-#ifdef CONFIG_NF_CONNTRACK_EVENTS
 static int
 ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 {
@@ -891,8 +874,8 @@ out:
 	return skb->len;
 }
 
-static inline int
-ctnetlink_parse_tuple_ip(struct nlattr *attr, struct nf_conntrack_tuple *tuple)
+static int ctnetlink_parse_tuple_ip(struct nlattr *attr,
+				    struct nf_conntrack_tuple *tuple)
 {
 	struct nlattr *tb[CTA_IP_MAX+1];
 	struct nf_conntrack_l3proto *l3proto;
@@ -921,9 +904,8 @@ static const struct nla_policy proto_nla_policy[CTA_PROTO_MAX+1] = {
 	[CTA_PROTO_NUM]	= { .type = NLA_U8 },
 };
 
-static inline int
-ctnetlink_parse_tuple_proto(struct nlattr *attr,
-			    struct nf_conntrack_tuple *tuple)
+static int ctnetlink_parse_tuple_proto(struct nlattr *attr,
+				       struct nf_conntrack_tuple *tuple)
 {
 	struct nlattr *tb[CTA_PROTO_MAX+1];
 	struct nf_conntrack_l4proto *l4proto;
@@ -1050,9 +1032,8 @@ static const struct nla_policy help_nla_policy[CTA_HELP_MAX+1] = {
 				    .len = NF_CT_HELPER_NAME_LEN - 1 },
 };
 
-static inline int
-ctnetlink_parse_help(const struct nlattr *attr, char **helper_name,
-		     struct nlattr **helpinfo)
+static int ctnetlink_parse_help(const struct nlattr *attr, char **helper_name,
+				struct nlattr **helpinfo)
 {
 	int err;
 	struct nlattr *tb[CTA_HELP_MAX+1];
@@ -1463,8 +1444,8 @@ ctnetlink_setup_nat(struct nf_conn *ct, const struct nlattr * const cda[])
 #endif
 }
 
-static inline int
-ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
+static int ctnetlink_change_helper(struct nf_conn *ct,
+				   const struct nlattr * const cda[])
 {
 	struct nf_conntrack_helper *helper;
 	struct nf_conn_help *help = nfct_help(ct);
@@ -1524,8 +1505,8 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 	return -EOPNOTSUPP;
 }
 
-static inline int
-ctnetlink_change_timeout(struct nf_conn *ct, const struct nlattr * const cda[])
+static int ctnetlink_change_timeout(struct nf_conn *ct,
+				    const struct nlattr * const cda[])
 {
 	u_int32_t timeout = ntohl(nla_get_be32(cda[CTA_TIMEOUT]));
 
@@ -1544,8 +1525,8 @@ static const struct nla_policy protoinfo_policy[CTA_PROTOINFO_MAX+1] = {
 	[CTA_PROTOINFO_SCTP]	= { .type = NLA_NESTED },
 };
 
-static inline int
-ctnetlink_change_protoinfo(struct nf_conn *ct, const struct nlattr * const cda[])
+static int ctnetlink_change_protoinfo(struct nf_conn *ct,
+				      const struct nlattr * const cda[])
 {
 	const struct nlattr *attr = cda[CTA_PROTOINFO];
 	struct nlattr *tb[CTA_PROTOINFO_MAX+1];
@@ -1571,8 +1552,8 @@ static const struct nla_policy seqadj_policy[CTA_SEQADJ_MAX+1] = {
 	[CTA_SEQADJ_OFFSET_AFTER]	= { .type = NLA_U32 },
 };
 
-static inline int
-change_seq_adj(struct nf_ct_seqadj *seq, const struct nlattr * const attr)
+static int change_seq_adj(struct nf_ct_seqadj *seq,
+			  const struct nlattr * const attr)
 {
 	int err;
 	struct nlattr *cda[CTA_SEQADJ_MAX+1];
@@ -2405,10 +2386,9 @@ static struct nfnl_ct_hook ctnetlink_glue_hook = {
  * EXPECT
  ***********************************************************************/
 
-static inline int
-ctnetlink_exp_dump_tuple(struct sk_buff *skb,
-			 const struct nf_conntrack_tuple *tuple,
-			 enum ctattr_expect type)
+static int ctnetlink_exp_dump_tuple(struct sk_buff *skb,
+				    const struct nf_conntrack_tuple *tuple,
+				    enum ctattr_expect type)
 {
 	struct nlattr *nest_parms;
 
@@ -2425,10 +2405,9 @@ nla_put_failure:
 	return -1;
 }
 
-static inline int
-ctnetlink_exp_dump_mask(struct sk_buff *skb,
-			const struct nf_conntrack_tuple *tuple,
-			const struct nf_conntrack_tuple_mask *mask)
+static int ctnetlink_exp_dump_mask(struct sk_buff *skb,
+				   const struct nf_conntrack_tuple *tuple,
+				   const struct nf_conntrack_tuple_mask *mask)
 {
 	int ret;
 	struct nf_conntrack_l3proto *l3proto;
-- 
2.1.4
