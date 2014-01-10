From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/23] netfilter: nf_tables: constify chain type definitions and pointers
Date: Fri, 10 Jan 2014 01:35:36 +0100
Message-ID: <1389314142-17969-18-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51568 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757287AbaAJAgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:14 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h         |    6 +++---
 net/bridge/netfilter/nf_tables_bridge.c   |    2 +-
 net/ipv4/netfilter/nf_tables_arp.c        |    2 +-
 net/ipv4/netfilter/nf_tables_ipv4.c       |    2 +-
 net/ipv4/netfilter/nft_chain_nat_ipv4.c   |    2 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c |    2 +-
 net/ipv6/netfilter/nf_tables_ipv6.c       |    2 +-
 net/ipv6/netfilter/nft_chain_nat_ipv6.c   |    2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c |    2 +-
 net/netfilter/nf_tables_api.c             |   14 +++++++-------
 net/netfilter/nf_tables_inet.c            |    2 +-
 11 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index e9b9786..d3f7053 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -436,7 +436,7 @@ struct nft_stats {
  */
 struct nft_base_chain {
 	struct nf_hook_ops		ops[NFT_HOOK_OPS_MAX];
-	struct nf_chain_type		*type;
+	const struct nf_chain_type	*type;
 	u8				policy;
 	struct nft_stats __percpu	*stats;
 	struct nft_chain		chain;
@@ -507,8 +507,8 @@ struct nf_chain_type {
 	int			family;
 };
 
-int nft_register_chain_type(struct nf_chain_type *);
-void nft_unregister_chain_type(struct nf_chain_type *);
+int nft_register_chain_type(const struct nf_chain_type *);
+void nft_unregister_chain_type(const struct nf_chain_type *);
 
 int nft_register_expr(struct nft_expr_type *);
 void nft_unregister_expr(struct nft_expr_type *);
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index f97222e..283658d 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -68,7 +68,7 @@ static struct pernet_operations nf_tables_bridge_net_ops = {
 	.exit	= nf_tables_bridge_exit_net,
 };
 
-static struct nf_chain_type filter_bridge = {
+static const struct nf_chain_type filter_bridge = {
 	.family		= NFPROTO_BRIDGE,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 228df00..8af01a5 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -68,7 +68,7 @@ static struct pernet_operations nf_tables_arp_net_ops = {
 	.exit   = nf_tables_arp_exit_net,
 };
 
-static struct nf_chain_type filter_arp = {
+static const struct nf_chain_type filter_arp = {
 	.family		= NFPROTO_ARP,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index d6fc1b4..cec7805 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -91,7 +91,7 @@ static struct pernet_operations nf_tables_ipv4_net_ops = {
 	.exit	= nf_tables_ipv4_exit_net,
 };
 
-static struct nf_chain_type filter_ipv4 = {
+static const struct nf_chain_type filter_ipv4 = {
 	.family		= NFPROTO_IPV4,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index cf2c792..9e535c2 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -164,7 +164,7 @@ static unsigned int nf_nat_output(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static struct nf_chain_type nft_chain_nat_ipv4 = {
+static const struct nf_chain_type nft_chain_nat_ipv4 = {
 	.family		= NFPROTO_IPV4,
 	.name		= "nat",
 	.type		= NFT_CHAIN_T_NAT,
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 4e6bf9a..2dd2eea 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -61,7 +61,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static struct nf_chain_type nft_chain_route_ipv4 = {
+static const struct nf_chain_type nft_chain_route_ipv4 = {
 	.family		= NFPROTO_IPV4,
 	.name		= "route",
 	.type		= NFT_CHAIN_T_ROUTE,
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index a340276..758a32b 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -90,7 +90,7 @@ static struct pernet_operations nf_tables_ipv6_net_ops = {
 	.exit	= nf_tables_ipv6_exit_net,
 };
 
-static struct nf_chain_type filter_ipv6 = {
+static const struct nf_chain_type filter_ipv6 = {
 	.family		= NFPROTO_IPV6,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index e86dcd7..efd1d57 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -170,7 +170,7 @@ static unsigned int nf_nat_ipv6_output(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static struct nf_chain_type nft_chain_nat_ipv6 = {
+static const struct nf_chain_type nft_chain_nat_ipv6 = {
 	.family		= NFPROTO_IPV6,
 	.name		= "nat",
 	.type		= NFT_CHAIN_T_NAT,
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 3fe40f0..3620f88 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -59,7 +59,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static struct nf_chain_type nft_chain_route_ipv6 = {
+static const struct nf_chain_type nft_chain_route_ipv6 = {
 	.family		= NFPROTO_IPV6,
 	.name		= "route",
 	.type		= NFT_CHAIN_T_ROUTE,
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 7d6a226..acdd9d6 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -124,9 +124,9 @@ static inline u64 nf_tables_alloc_handle(struct nft_table *table)
 	return ++table->hgenerator;
 }
 
-static struct nf_chain_type *chain_type[AF_MAX][NFT_CHAIN_T_MAX];
+static const struct nf_chain_type *chain_type[AF_MAX][NFT_CHAIN_T_MAX];
 
-static struct nf_chain_type *
+static const struct nf_chain_type *
 __nf_tables_chain_type_lookup(int family, const struct nlattr *nla)
 {
 	int i;
@@ -139,12 +139,12 @@ __nf_tables_chain_type_lookup(int family, const struct nlattr *nla)
 	return NULL;
 }
 
-static struct nf_chain_type *
+static const struct nf_chain_type *
 nf_tables_chain_type_lookup(const struct nft_af_info *afi,
 			    const struct nlattr *nla,
 			    bool autoload)
 {
-	struct nf_chain_type *type;
+	const struct nf_chain_type *type;
 
 	type = __nf_tables_chain_type_lookup(afi->family, nla);
 	if (type != NULL)
@@ -475,7 +475,7 @@ static int nf_tables_deltable(struct sock *nlsk, struct sk_buff *skb,
 	return 0;
 }
 
-int nft_register_chain_type(struct nf_chain_type *ctype)
+int nft_register_chain_type(const struct nf_chain_type *ctype)
 {
 	int err = 0;
 
@@ -491,7 +491,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(nft_register_chain_type);
 
-void nft_unregister_chain_type(struct nf_chain_type *ctype)
+void nft_unregister_chain_type(const struct nf_chain_type *ctype)
 {
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
 	chain_type[ctype->family][ctype->type] = NULL;
@@ -900,7 +900,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		return -EOVERFLOW;
 
 	if (nla[NFTA_CHAIN_HOOK]) {
-		struct nf_chain_type *type;
+		const struct nf_chain_type *type;
 		struct nf_hook_ops *ops;
 		nf_hookfn *hookfn;
 		u32 hooknum, priority;
diff --git a/net/netfilter/nf_tables_inet.c b/net/netfilter/nf_tables_inet.c
index 280d3a2..ee29ba2 100644
--- a/net/netfilter/nf_tables_inet.c
+++ b/net/netfilter/nf_tables_inet.c
@@ -66,7 +66,7 @@ static struct pernet_operations nf_tables_inet_net_ops = {
 	.exit	= nf_tables_inet_exit_net,
 };
 
-static struct nf_chain_type filter_inet = {
+static const struct nf_chain_type filter_inet = {
 	.family		= NFPROTO_INET,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
-- 
1.7.10.4
