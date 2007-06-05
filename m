From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NETLINK 01/09]: Mark netlink policies const
Date: Tue,  5 Jun 2007 16:12:52 +0200 (MEST)
Message-ID: <20070605141252.15650.91283.sendpatchset@localhost.localdomain>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	Patrick McHardy <kaber@trash.net>, ebiederm@xmission.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63889 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763002AbXFEOMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:12:54 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETLINK]: Mark netlink policies const

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 842f5a7aa8357f4e43b1ab8938c51f4d7ce7aba3
tree 701a1399958ff019ab6939fa0e5a96e5b148b643
parent c1a13ff57ab1ce52a0aae9984594dbfcfbaf68c0
author Patrick McHardy <kaber@trash.net> Mon, 04 Jun 2007 14:52:51 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 04 Jun 2007 14:52:51 +0200

 include/net/fib_rules.h           |    2 +-
 include/net/genetlink.h           |    2 +-
 include/net/ip_fib.h              |    2 +-
 include/net/netlink.h             |   12 ++++++------
 net/core/neighbour.c              |    4 ++--
 net/core/rtnetlink.c              |    2 +-
 net/decnet/dn_dev.c               |    2 +-
 net/decnet/dn_rules.c             |    2 +-
 net/ipv4/devinet.c                |    2 +-
 net/ipv4/fib_frontend.c           |    2 +-
 net/ipv4/fib_rules.c              |    2 +-
 net/ipv6/addrconf.c               |    2 +-
 net/ipv6/fib6_rules.c             |    2 +-
 net/ipv6/route.c                  |    2 +-
 net/netlabel/netlabel_cipso_v4.c  |    2 +-
 net/netlabel/netlabel_mgmt.c      |    2 +-
 net/netlabel/netlabel_unlabeled.c |    2 +-
 net/netlink/attr.c                |    8 ++++----
 net/netlink/genetlink.c           |    2 +-
 19 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index ed3a887..83e41dd 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -64,7 +64,7 @@ struct fib_rules_ops
 	void			(*flush_cache)(void);
 
 	int			nlgroup;
-	struct nla_policy	*policy;
+	const struct nla_policy	*policy;
 	struct list_head	*rules_list;
 	struct module		*owner;
 };
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index adff4c8..b6eaca1 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -60,7 +60,7 @@ struct genl_ops
 {
 	u8			cmd;
 	unsigned int		flags;
-	struct nla_policy	*policy;
+	const struct nla_policy	*policy;
 	int		       (*doit)(struct sk_buff *skb,
 				       struct genl_info *info);
 	int		       (*dumpit)(struct sk_buff *skb,
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 5a4a036..69252cb 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -213,7 +213,7 @@ extern void fib_select_default(const struct flowi *flp, struct fib_result *res);
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
 /* Exported by fib_frontend.c */
-extern struct nla_policy rtm_ipv4_policy[];
+extern const struct nla_policy rtm_ipv4_policy[];
 extern void		ip_fib_init(void);
 extern int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			       struct net_device *dev, __be32 *spec_dst, u32 *itag);
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 0bf325c..7b510a9 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -222,10 +222,10 @@ extern int		nlmsg_notify(struct sock *sk, struct sk_buff *skb,
 				     gfp_t flags);
 
 extern int		nla_validate(struct nlattr *head, int len, int maxtype,
-				     struct nla_policy *policy);
+				     const struct nla_policy *policy);
 extern int		nla_parse(struct nlattr *tb[], int maxtype,
 				  struct nlattr *head, int len,
-				  struct nla_policy *policy);
+				  const struct nla_policy *policy);
 extern struct nlattr *	nla_find(struct nlattr *head, int len, int attrtype);
 extern size_t		nla_strlcpy(char *dst, const struct nlattr *nla,
 				    size_t dstsize);
@@ -360,7 +360,7 @@ static inline struct nlmsghdr *nlmsg_next(struct nlmsghdr *nlh, int *remaining)
  */
 static inline int nlmsg_parse(struct nlmsghdr *nlh, int hdrlen,
 			      struct nlattr *tb[], int maxtype,
-			      struct nla_policy *policy)
+			      const struct nla_policy *policy)
 {
 	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
 		return -EINVAL;
@@ -392,7 +392,7 @@ static inline struct nlattr *nlmsg_find_attr(struct nlmsghdr *nlh,
  * @policy: validation policy
  */
 static inline int nlmsg_validate(struct nlmsghdr *nlh, int hdrlen, int maxtype,
-				 struct nla_policy *policy)
+				 const struct nla_policy *policy)
 {
 	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
 		return -EINVAL;
@@ -729,7 +729,7 @@ static inline struct nlattr *nla_find_nested(struct nlattr *nla, int attrtype)
  */
 static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
 				   struct nlattr *nla,
-				   struct nla_policy *policy)
+				   const struct nla_policy *policy)
 {
 	return nla_parse(tb, maxtype, nla_data(nla), nla_len(nla), policy);
 }
@@ -990,7 +990,7 @@ static inline int nla_nest_cancel(struct sk_buff *skb, struct nlattr *start)
  * Returns 0 on success or a negative error code.
  */
 static inline int nla_validate_nested(struct nlattr *start, int maxtype,
-				      struct nla_policy *policy)
+				      const struct nla_policy *policy)
 {
 	return nla_validate(nla_data(start), nla_len(start), maxtype, policy);
 }
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 6f3bb73..9df26a0 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1761,7 +1761,7 @@ static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
 	return NULL;
 }
 
-static struct nla_policy nl_neightbl_policy[NDTA_MAX+1] __read_mostly = {
+static const struct nla_policy nl_neightbl_policy[NDTA_MAX+1] = {
 	[NDTA_NAME]		= { .type = NLA_STRING },
 	[NDTA_THRESH1]		= { .type = NLA_U32 },
 	[NDTA_THRESH2]		= { .type = NLA_U32 },
@@ -1770,7 +1770,7 @@ static struct nla_policy nl_neightbl_policy[NDTA_MAX+1] __read_mostly = {
 	[NDTA_PARMS]		= { .type = NLA_NESTED },
 };
 
-static struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] __read_mostly = {
+static const struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] = {
 	[NDTPA_IFINDEX]			= { .type = NLA_U32 },
 	[NDTPA_QUEUE_LEN]		= { .type = NLA_U32 },
 	[NDTPA_PROXY_QLEN]		= { .type = NLA_U32 },
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 27da9cd..a8a5093 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -551,7 +551,7 @@ cont:
 	return skb->len;
 }
 
-static struct nla_policy ifla_policy[IFLA_MAX+1] __read_mostly = {
+static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_IFNAME]		= { .type = NLA_STRING, .len = IFNAMSIZ-1 },
 	[IFLA_MAP]		= { .len = sizeof(struct rtnl_link_ifmap) },
 	[IFLA_MTU]		= { .type = NLA_U32 },
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 764a56a..ab41c18 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -638,7 +638,7 @@ static struct dn_dev *dn_dev_by_index(int ifindex)
 	return dn_dev;
 }
 
-static struct nla_policy dn_ifa_policy[IFA_MAX+1] __read_mostly = {
+static const struct nla_policy dn_ifa_policy[IFA_MAX+1] = {
 	[IFA_ADDRESS]		= { .type = NLA_U16 },
 	[IFA_LOCAL]		= { .type = NLA_U16 },
 	[IFA_LABEL]		= { .type = NLA_STRING,
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 17a1932..84ff3dd 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -108,7 +108,7 @@ errout:
 	return err;
 }
 
-static struct nla_policy dn_fib_rule_policy[FRA_MAX+1] __read_mostly = {
+static const struct nla_policy dn_fib_rule_policy[FRA_MAX+1] = {
 	FRA_GENERIC_POLICY,
 };
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7f95e6e..965e35a 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -78,7 +78,7 @@ static struct ipv4_devconf ipv4_devconf_dflt = {
 	.accept_source_route = 1,
 };
 
-static struct nla_policy ifa_ipv4_policy[IFA_MAX+1] __read_mostly = {
+static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
 	[IFA_LOCAL]     	= { .type = NLA_U32 },
 	[IFA_ADDRESS]   	= { .type = NLA_U32 },
 	[IFA_BROADCAST] 	= { .type = NLA_U32 },
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 9ad1f62..311d633 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -441,7 +441,7 @@ int ip_rt_ioctl(unsigned int cmd, void __user *arg)
 	return -EINVAL;
 }
 
-struct nla_policy rtm_ipv4_policy[RTA_MAX+1] __read_mostly = {
+const struct nla_policy rtm_ipv4_policy[RTA_MAX+1] = {
 	[RTA_DST]		= { .type = NLA_U32 },
 	[RTA_SRC]		= { .type = NLA_U32 },
 	[RTA_IIF]		= { .type = NLA_U32 },
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 33083ad..2a94784 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -169,7 +169,7 @@ static struct fib_table *fib_empty_table(void)
 	return NULL;
 }
 
-static struct nla_policy fib4_rule_policy[FRA_MAX+1] __read_mostly = {
+static const struct nla_policy fib4_rule_policy[FRA_MAX+1] = {
 	FRA_GENERIC_POLICY,
 	[FRA_FLOW]	= { .type = NLA_U32 },
 };
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 329de67..5a5f8bd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2990,7 +2990,7 @@ static struct in6_addr *extract_addr(struct nlattr *addr, struct nlattr *local)
 	return pfx;
 }
 
-static struct nla_policy ifa_ipv6_policy[IFA_MAX+1] __read_mostly = {
+static const struct nla_policy ifa_ipv6_policy[IFA_MAX+1] = {
 	[IFA_ADDRESS]		= { .len = sizeof(struct in6_addr) },
 	[IFA_LOCAL]		= { .len = sizeof(struct in6_addr) },
 	[IFA_CACHEINFO]		= { .len = sizeof(struct ifa_cacheinfo) },
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index fc3882c..53b3998 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -157,7 +157,7 @@ static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 	return 1;
 }
 
-static struct nla_policy fib6_rule_policy[FRA_MAX+1] __read_mostly = {
+static const struct nla_policy fib6_rule_policy[FRA_MAX+1] = {
 	FRA_GENERIC_POLICY,
 };
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1324b06..fe8d983 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1999,7 +1999,7 @@ void rt6_mtu_change(struct net_device *dev, unsigned mtu)
 	fib6_clean_all(rt6_mtu_change_route, 0, &arg);
 }
 
-static struct nla_policy rtm_ipv6_policy[RTA_MAX+1] __read_mostly = {
+static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_GATEWAY]           = { .len = sizeof(struct in6_addr) },
 	[RTA_OIF]               = { .type = NLA_U32 },
 	[RTA_IIF]		= { .type = NLA_U32 },
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 07e47db..24b660f 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -59,7 +59,7 @@ static struct genl_family netlbl_cipsov4_gnl_family = {
 };
 
 /* NetLabel Netlink attribute policy */
-static struct nla_policy netlbl_cipsov4_genl_policy[NLBL_CIPSOV4_A_MAX + 1] = {
+static const struct nla_policy netlbl_cipsov4_genl_policy[NLBL_CIPSOV4_A_MAX + 1] = {
 	[NLBL_CIPSOV4_A_DOI] = { .type = NLA_U32 },
 	[NLBL_CIPSOV4_A_MTYPE] = { .type = NLA_U32 },
 	[NLBL_CIPSOV4_A_TAG] = { .type = NLA_U8 },
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index e8c80f3..e00fc21 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -59,7 +59,7 @@ static struct genl_family netlbl_mgmt_gnl_family = {
 };
 
 /* NetLabel Netlink attribute policy */
-static struct nla_policy netlbl_mgmt_genl_policy[NLBL_MGMT_A_MAX + 1] = {
+static const struct nla_policy netlbl_mgmt_genl_policy[NLBL_MGMT_A_MAX + 1] = {
 	[NLBL_MGMT_A_DOMAIN] = { .type = NLA_NUL_STRING },
 	[NLBL_MGMT_A_PROTOCOL] = { .type = NLA_U32 },
 	[NLBL_MGMT_A_VERSION] = { .type = NLA_U32 },
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index b931ede..5c303c6 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -61,7 +61,7 @@ static struct genl_family netlbl_unlabel_gnl_family = {
 };
 
 /* NetLabel Netlink attribute policy */
-static struct nla_policy netlbl_unlabel_genl_policy[NLBL_UNLABEL_A_MAX + 1] = {
+static const struct nla_policy netlbl_unlabel_genl_policy[NLBL_UNLABEL_A_MAX + 1] = {
 	[NLBL_UNLABEL_A_ACPTFLG] = { .type = NLA_U8 },
 };
 
diff --git a/net/netlink/attr.c b/net/netlink/attr.c
index df5f820..c591212 100644
--- a/net/netlink/attr.c
+++ b/net/netlink/attr.c
@@ -24,9 +24,9 @@ static u16 nla_attr_minlen[NLA_TYPE_MAX+1] __read_mostly = {
 };
 
 static int validate_nla(struct nlattr *nla, int maxtype,
-			struct nla_policy *policy)
+			const struct nla_policy *policy)
 {
-	struct nla_policy *pt;
+	const struct nla_policy *pt;
 	int minlen = 0, attrlen = nla_len(nla);
 
 	if (nla->nla_type <= 0 || nla->nla_type > maxtype)
@@ -99,7 +99,7 @@ static int validate_nla(struct nlattr *nla, int maxtype,
  * Returns 0 on success or a negative error code.
  */
 int nla_validate(struct nlattr *head, int len, int maxtype,
-		 struct nla_policy *policy)
+		 const struct nla_policy *policy)
 {
 	struct nlattr *nla;
 	int rem, err;
@@ -130,7 +130,7 @@ errout:
  * Returns 0 on success or a negative error code.
  */
 int nla_parse(struct nlattr *tb[], int maxtype, struct nlattr *head, int len,
-	      struct nla_policy *policy)
+	      const struct nla_policy *policy)
 {
 	struct nlattr *nla;
 	int rem, err;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 6e31234..b9ab62f 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -472,7 +472,7 @@ static struct sk_buff *ctrl_build_msg(struct genl_family *family, u32 pid,
 	return skb;
 }
 
-static struct nla_policy ctrl_policy[CTRL_ATTR_MAX+1] __read_mostly = {
+static const struct nla_policy ctrl_policy[CTRL_ATTR_MAX+1] = {
 	[CTRL_ATTR_FAMILY_ID]	= { .type = NLA_U16 },
 	[CTRL_ATTR_FAMILY_NAME]	= { .type = NLA_NUL_STRING,
 				    .len = GENL_NAMSIZ - 1 },
