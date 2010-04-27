From: Patrick@trash.net, McHardy@trash.net, kaber@trash.net
Subject: [PATCH 1/3] net: fib_rules: mark arguments to fib_rules_register const and __net_initdata
Date: Tue, 27 Apr 2010 15:26:23 +0200
Message-ID: <1272374785-3858-2-git-send-email-kaber@trash.net>
References: <1272374785-3858-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52161 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755697Ab0D0N02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 09:26:28 -0400
In-Reply-To: <1272374785-3858-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

fib_rules_register() duplicates the template passed to it without modification,
mark the argument as const. Additionally the templates are only needed when
instantiating a new namespace, so mark them as __net_initdata, which means
they can be discarded when CONFIG_NET_NS=n.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/fib_rules.h |    2 +-
 net/core/fib_rules.c    |    2 +-
 net/decnet/dn_rules.c   |    2 +-
 net/ipv4/fib_rules.c    |    2 +-
 net/ipv4/ipmr.c         |    2 +-
 net/ipv6/fib6_rules.c   |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 52bd9e6..e8923bc 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -104,7 +104,7 @@ static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
 	return frh->table;
 }
 
-extern struct fib_rules_ops *fib_rules_register(struct fib_rules_ops *, struct net *);
+extern struct fib_rules_ops *fib_rules_register(const struct fib_rules_ops *, struct net *);
 extern void fib_rules_unregister(struct fib_rules_ops *);
 extern void                     fib_rules_cleanup_ops(struct fib_rules_ops *);
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 1bc6659..42e84e0 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -122,7 +122,7 @@ errout:
 }
 
 struct fib_rules_ops *
-fib_rules_register(struct fib_rules_ops *tmpl, struct net *net)
+fib_rules_register(const struct fib_rules_ops *tmpl, struct net *net)
 {
 	struct fib_rules_ops *ops;
 	int err;
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index af28dcc..1226bca 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -216,7 +216,7 @@ static void dn_fib_rule_flush_cache(struct fib_rules_ops *ops)
 	dn_rt_cache_flush(-1);
 }
 
-static struct fib_rules_ops dn_fib_rules_ops_template = {
+static const struct fib_rules_ops __net_initdata dn_fib_rules_ops_template = {
 	.family		= FIB_RULES_DECNET,
 	.rule_size	= sizeof(struct dn_fib_rule),
 	.addr_size	= sizeof(u16),
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 3ec84fe..8ab62a5 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -245,7 +245,7 @@ static void fib4_rule_flush_cache(struct fib_rules_ops *ops)
 	rt_cache_flush(ops->fro_net, -1);
 }
 
-static struct fib_rules_ops fib4_rules_ops_template = {
+static const struct fib_rules_ops __net_initdata fib4_rules_ops_template = {
 	.family		= FIB_RULES_IPV4,
 	.rule_size	= sizeof(struct fib4_rule),
 	.addr_size	= sizeof(u32),
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a2df501..7d3e382 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -216,7 +216,7 @@ static int ipmr_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 	return 0;
 }
 
-static struct fib_rules_ops ipmr_rules_ops_template = {
+static const struct fib_rules_ops __net_initdata ipmr_rules_ops_template = {
 	.family		= FIB_RULES_IPMR,
 	.rule_size	= sizeof(struct ipmr_rule),
 	.addr_size	= sizeof(u32),
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 8124f16..35f6949 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -237,7 +237,7 @@ static size_t fib6_rule_nlmsg_payload(struct fib_rule *rule)
 	       + nla_total_size(16); /* src */
 }
 
-static struct fib_rules_ops fib6_rules_ops_template = {
+static const struct fib_rules_ops __net_initdata fib6_rules_ops_template = {
 	.family			= FIB_RULES_IPV6,
 	.rule_size		= sizeof(struct fib6_rule),
 	.addr_size		= sizeof(struct in6_addr),
-- 
1.7.0.4

