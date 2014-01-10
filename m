From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/23] netfilter: nf_tables: minor nf_chain_type cleanups
Date: Fri, 10 Jan 2014 01:35:37 +0100
Message-ID: <1389314142-17969-19-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Minor nf_chain_type cleanups:

- reorder struct to plug a hoe
- rename struct module member to "owner" for consistency
- rename nf_hookfn array to "hooks" for consistency
- reorder initializers for better readability

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h         |   22 ++++++++++++++++------
 net/bridge/netfilter/nf_tables_bridge.c   |    4 ++--
 net/ipv4/netfilter/nf_tables_arp.c        |    4 ++--
 net/ipv4/netfilter/nf_tables_ipv4.c       |    4 ++--
 net/ipv4/netfilter/nft_chain_nat_ipv4.c   |    6 +++---
 net/ipv4/netfilter/nft_chain_route_ipv4.c |    6 +++---
 net/ipv6/netfilter/nf_tables_ipv6.c       |    4 ++--
 net/ipv6/netfilter/nft_chain_nat_ipv6.c   |    6 +++---
 net/ipv6/netfilter/nft_chain_route_ipv6.c |    6 +++---
 net/netfilter/nf_tables_api.c             |   12 ++++++------
 net/netfilter/nf_tables_inet.c            |    4 ++--
 11 files changed, 44 insertions(+), 34 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index d3f7053..3422365 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -498,13 +498,23 @@ struct nft_af_info {
 int nft_register_afinfo(struct net *, struct nft_af_info *);
 void nft_unregister_afinfo(struct nft_af_info *);
 
+/**
+ * 	struct nf_chain_type - nf_tables chain type info
+ *
+ * 	@name: name of the type
+ * 	@type: numeric identifier
+ * 	@family: address family
+ * 	@owner: module owner
+ * 	@hook_mask: mask of valid hooks
+ * 	@hooks: hookfn overrides
+ */
 struct nf_chain_type {
-	unsigned int		hook_mask;
-	const char		*name;
-	enum nft_chain_type	type;
-	nf_hookfn		*fn[NF_MAX_HOOKS];
-	struct module		*me;
-	int			family;
+	const char			*name;
+	enum nft_chain_type		type;
+	int				family;
+	struct module			*owner;
+	unsigned int			hook_mask;
+	nf_hookfn			*hooks[NF_MAX_HOOKS];
 };
 
 int nft_register_chain_type(const struct nf_chain_type *);
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 283658d..c83fab5 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -69,10 +69,10 @@ static struct pernet_operations nf_tables_bridge_net_ops = {
 };
 
 static const struct nf_chain_type filter_bridge = {
-	.family		= NFPROTO_BRIDGE,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
-	.me		= THIS_MODULE,
+	.family		= NFPROTO_BRIDGE,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_BR_LOCAL_IN) |
 			  (1 << NF_BR_FORWARD) |
 			  (1 << NF_BR_LOCAL_OUT),
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 8af01a5..b90d16c 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -69,10 +69,10 @@ static struct pernet_operations nf_tables_arp_net_ops = {
 };
 
 static const struct nf_chain_type filter_arp = {
-	.family		= NFPROTO_ARP,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
-	.me		= THIS_MODULE,
+	.family		= NFPROTO_ARP,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_ARP_IN) |
 			  (1 << NF_ARP_OUT) |
 			  (1 << NF_ARP_FORWARD),
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index cec7805..66679fd 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -92,10 +92,10 @@ static struct pernet_operations nf_tables_ipv4_net_ops = {
 };
 
 static const struct nf_chain_type filter_ipv4 = {
-	.family		= NFPROTO_IPV4,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
-	.me		= THIS_MODULE,
+	.family		= NFPROTO_IPV4,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_IN) |
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index 9e535c2..208d60a 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -165,20 +165,20 @@ static unsigned int nf_nat_output(const struct nf_hook_ops *ops,
 }
 
 static const struct nf_chain_type nft_chain_nat_ipv4 = {
-	.family		= NFPROTO_IPV4,
 	.name		= "nat",
 	.type		= NFT_CHAIN_T_NAT,
+	.family		= NFPROTO_IPV4,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_PRE_ROUTING) |
 			  (1 << NF_INET_POST_ROUTING) |
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_LOCAL_IN),
-	.fn		= {
+	.hooks		= {
 		[NF_INET_PRE_ROUTING]	= nf_nat_prerouting,
 		[NF_INET_POST_ROUTING]	= nf_nat_postrouting,
 		[NF_INET_LOCAL_OUT]	= nf_nat_output,
 		[NF_INET_LOCAL_IN]	= nf_nat_fn,
 	},
-	.me		= THIS_MODULE,
 };
 
 static int __init nft_chain_nat_init(void)
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 2dd2eea..67db1bb 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -62,14 +62,14 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 }
 
 static const struct nf_chain_type nft_chain_route_ipv4 = {
-	.family		= NFPROTO_IPV4,
 	.name		= "route",
 	.type		= NFT_CHAIN_T_ROUTE,
+	.family		= NFPROTO_IPV4,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_OUT),
-	.fn		= {
+	.hooks		= {
 		[NF_INET_LOCAL_OUT]	= nf_route_table_hook,
 	},
-	.me		= THIS_MODULE,
 };
 
 static int __init nft_chain_route_init(void)
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 758a32b..859fca0 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -91,10 +91,10 @@ static struct pernet_operations nf_tables_ipv6_net_ops = {
 };
 
 static const struct nf_chain_type filter_ipv6 = {
-	.family		= NFPROTO_IPV6,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
-	.me		= THIS_MODULE,
+	.family		= NFPROTO_IPV6,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_IN) |
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index efd1d57..9ed60ab 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -171,20 +171,20 @@ static unsigned int nf_nat_ipv6_output(const struct nf_hook_ops *ops,
 }
 
 static const struct nf_chain_type nft_chain_nat_ipv6 = {
-	.family		= NFPROTO_IPV6,
 	.name		= "nat",
 	.type		= NFT_CHAIN_T_NAT,
+	.family		= NFPROTO_IPV6,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_PRE_ROUTING) |
 			  (1 << NF_INET_POST_ROUTING) |
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_LOCAL_IN),
-	.fn		= {
+	.hooks		= {
 		[NF_INET_PRE_ROUTING]	= nf_nat_ipv6_prerouting,
 		[NF_INET_POST_ROUTING]	= nf_nat_ipv6_postrouting,
 		[NF_INET_LOCAL_OUT]	= nf_nat_ipv6_output,
 		[NF_INET_LOCAL_IN]	= nf_nat_ipv6_fn,
 	},
-	.me		= THIS_MODULE,
 };
 
 static int __init nft_chain_nat_ipv6_init(void)
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 3620f88..b2b7eff 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -60,14 +60,14 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 }
 
 static const struct nf_chain_type nft_chain_route_ipv6 = {
-	.family		= NFPROTO_IPV6,
 	.name		= "route",
 	.type		= NFT_CHAIN_T_ROUTE,
+	.family		= NFPROTO_IPV6,
+        .owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_OUT),
-	.fn		= {
+	.hooks		= {
                 [NF_INET_LOCAL_OUT]	= nf_route_table_hook,
         },
-        .me		= THIS_MODULE,
 };
 
 static int __init nft_chain_route_init(void)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index acdd9d6..c8ca3b8 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -929,9 +929,9 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 
 		if (!(type->hook_mask & (1 << hooknum)))
 			return -EOPNOTSUPP;
-		if (!try_module_get(type->me))
+		if (!try_module_get(type->owner))
 			return -ENOENT;
-		hookfn = type->fn[hooknum];
+		hookfn = type->hooks[hooknum];
 
 		basechain = kzalloc(sizeof(*basechain), GFP_KERNEL);
 		if (basechain == NULL)
@@ -941,7 +941,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 			err = nf_tables_counters(basechain,
 						 nla[NFTA_CHAIN_COUNTERS]);
 			if (err < 0) {
-				module_put(type->me);
+				module_put(type->owner);
 				kfree(basechain);
 				return err;
 			}
@@ -950,7 +950,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 
 			newstats = alloc_percpu(struct nft_stats);
 			if (newstats == NULL) {
-				module_put(type->me);
+				module_put(type->owner);
 				kfree(basechain);
 				return -ENOMEM;
 			}
@@ -992,7 +992,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	    chain->flags & NFT_BASE_CHAIN) {
 		err = nf_register_hooks(nft_base_chain(chain)->ops, afi->nops);
 		if (err < 0) {
-			module_put(basechain->type->me);
+			module_put(basechain->type->owner);
 			free_percpu(basechain->stats);
 			kfree(basechain);
 			return err;
@@ -1013,7 +1013,7 @@ static void nf_tables_rcu_chain_destroy(struct rcu_head *head)
 	BUG_ON(chain->use > 0);
 
 	if (chain->flags & NFT_BASE_CHAIN) {
-		module_put(nft_base_chain(chain)->type->me);
+		module_put(nft_base_chain(chain)->type->owner);
 		free_percpu(nft_base_chain(chain)->stats);
 		kfree(nft_base_chain(chain));
 	} else
diff --git a/net/netfilter/nf_tables_inet.c b/net/netfilter/nf_tables_inet.c
index ee29ba2..84478de 100644
--- a/net/netfilter/nf_tables_inet.c
+++ b/net/netfilter/nf_tables_inet.c
@@ -67,10 +67,10 @@ static struct pernet_operations nf_tables_inet_net_ops = {
 };
 
 static const struct nf_chain_type filter_inet = {
-	.family		= NFPROTO_INET,
 	.name		= "filter",
 	.type		= NFT_CHAIN_T_DEFAULT,
-	.me		= THIS_MODULE,
+	.family		= NFPROTO_INET,
+	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_INET_LOCAL_IN) |
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
-- 
1.7.10.4

