From: pablo@netfilter.org
Subject: [PATCH 06/10] netfilter: PTR_RET can be used
Date: Thu, 23 Aug 2012 01:38:42 +0200
Message-ID: <1345678726-3109-7-git-send-email-pablo@netfilter.org>
References: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wu Fengguang <fengguang.wu@intel.com>

This quiets the coccinelle warnings:

net/bridge/netfilter/ebtable_filter.c:107:1-3: WARNING: PTR_RET can be used
net/bridge/netfilter/ebtable_nat.c:107:1-3: WARNING: PTR_RET can be used
net/ipv6/netfilter/ip6table_filter.c:65:1-3: WARNING: PTR_RET can be used
net/ipv6/netfilter/ip6table_mangle.c:100:1-3: WARNING: PTR_RET can be used
net/ipv6/netfilter/ip6table_raw.c:44:1-3: WARNING: PTR_RET can be used
net/ipv6/netfilter/ip6table_security.c:62:1-3: WARNING: PTR_RET can be used
net/ipv4/netfilter/iptable_filter.c:72:1-3: WARNING: PTR_RET can be used
net/ipv4/netfilter/iptable_mangle.c:107:1-3: WARNING: PTR_RET can be used
net/ipv4/netfilter/iptable_raw.c:51:1-3: WARNING: PTR_RET can be used
net/ipv4/netfilter/iptable_security.c:70:1-3: WARNING: PTR_RET can be used

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtable_filter.c  |    4 +---
 net/bridge/netfilter/ebtable_nat.c     |    4 +---
 net/ipv4/netfilter/iptable_filter.c    |    4 +---
 net/ipv4/netfilter/iptable_mangle.c    |    4 +---
 net/ipv4/netfilter/iptable_raw.c       |    4 +---
 net/ipv4/netfilter/iptable_security.c  |    5 +----
 net/ipv6/netfilter/ip6table_filter.c   |    4 +---
 net/ipv6/netfilter/ip6table_mangle.c   |    4 +---
 net/ipv6/netfilter/ip6table_raw.c      |    4 +---
 net/ipv6/netfilter/ip6table_security.c |    5 +----
 10 files changed, 10 insertions(+), 32 deletions(-)

diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 42e6bd0..3c2e9dc 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -100,9 +100,7 @@ static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 static int __net_init frame_filter_net_init(struct net *net)
 {
 	net->xt.frame_filter = ebt_register_table(net, &frame_filter);
-	if (IS_ERR(net->xt.frame_filter))
-		return PTR_ERR(net->xt.frame_filter);
-	return 0;
+	return PTR_RET(net->xt.frame_filter);
 }
 
 static void __net_exit frame_filter_net_exit(struct net *net)
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 6dc2f87..10871bc 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -100,9 +100,7 @@ static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
 static int __net_init frame_nat_net_init(struct net *net)
 {
 	net->xt.frame_nat = ebt_register_table(net, &frame_nat);
-	if (IS_ERR(net->xt.frame_nat))
-		return PTR_ERR(net->xt.frame_nat);
-	return 0;
+	return PTR_RET(net->xt.frame_nat);
 }
 
 static void __net_exit frame_nat_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 851acec8..d20cc37 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -69,9 +69,7 @@ static int __net_init iptable_filter_net_init(struct net *net)
 	net->ipv4.iptable_filter =
 		ipt_register_table(net, &packet_filter, repl);
 	kfree(repl);
-	if (IS_ERR(net->ipv4.iptable_filter))
-		return PTR_ERR(net->ipv4.iptable_filter);
-	return 0;
+	return PTR_RET(net->ipv4.iptable_filter);
 }
 
 static void __net_exit iptable_filter_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index aef5d1f..f38b942 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -104,9 +104,7 @@ static int __net_init iptable_mangle_net_init(struct net *net)
 	net->ipv4.iptable_mangle =
 		ipt_register_table(net, &packet_mangler, repl);
 	kfree(repl);
-	if (IS_ERR(net->ipv4.iptable_mangle))
-		return PTR_ERR(net->ipv4.iptable_mangle);
-	return 0;
+	return PTR_RET(net->ipv4.iptable_mangle);
 }
 
 static void __net_exit iptable_mangle_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 07fb710..b21e219 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -48,9 +48,7 @@ static int __net_init iptable_raw_net_init(struct net *net)
 	net->ipv4.iptable_raw =
 		ipt_register_table(net, &packet_raw, repl);
 	kfree(repl);
-	if (IS_ERR(net->ipv4.iptable_raw))
-		return PTR_ERR(net->ipv4.iptable_raw);
-	return 0;
+	return PTR_RET(net->ipv4.iptable_raw);
 }
 
 static void __net_exit iptable_raw_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index be45bdc..b283d8e 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -66,10 +66,7 @@ static int __net_init iptable_security_net_init(struct net *net)
 	net->ipv4.iptable_security =
 		ipt_register_table(net, &security_table, repl);
 	kfree(repl);
-	if (IS_ERR(net->ipv4.iptable_security))
-		return PTR_ERR(net->ipv4.iptable_security);
-
-	return 0;
+	return PTR_RET(net->ipv4.iptable_security);
 }
 
 static void __net_exit iptable_security_net_exit(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 325e59a..beb5777 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -61,9 +61,7 @@ static int __net_init ip6table_filter_net_init(struct net *net)
 	net->ipv6.ip6table_filter =
 		ip6t_register_table(net, &packet_filter, repl);
 	kfree(repl);
-	if (IS_ERR(net->ipv6.ip6table_filter))
-		return PTR_ERR(net->ipv6.ip6table_filter);
-	return 0;
+	return PTR_RET(net->ipv6.ip6table_filter);
 }
 
 static void __net_exit ip6table_filter_net_exit(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 4d78240..7431121 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -97,9 +97,7 @@ static int __net_init ip6table_mangle_net_init(struct net *net)
 	net->ipv6.ip6table_mangle =
 		ip6t_register_table(net, &packet_mangler, repl);
 	kfree(repl);
-	if (IS_ERR(net->ipv6.ip6table_mangle))
-		return PTR_ERR(net->ipv6.ip6table_mangle);
-	return 0;
+	return PTR_RET(net->ipv6.ip6table_mangle);
 }
 
 static void __net_exit ip6table_mangle_net_exit(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 5b9926a..60d1bdd 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -40,9 +40,7 @@ static int __net_init ip6table_raw_net_init(struct net *net)
 	net->ipv6.ip6table_raw =
 		ip6t_register_table(net, &packet_raw, repl);
 	kfree(repl);
-	if (IS_ERR(net->ipv6.ip6table_raw))
-		return PTR_ERR(net->ipv6.ip6table_raw);
-	return 0;
+	return PTR_RET(net->ipv6.ip6table_raw);
 }
 
 static void __net_exit ip6table_raw_net_exit(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 91aa2b4..db15535 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -58,10 +58,7 @@ static int __net_init ip6table_security_net_init(struct net *net)
 	net->ipv6.ip6table_security =
 		ip6t_register_table(net, &security_table, repl);
 	kfree(repl);
-	if (IS_ERR(net->ipv6.ip6table_security))
-		return PTR_ERR(net->ipv6.ip6table_security);
-
-	return 0;
+	return PTR_RET(net->ipv6.ip6table_security);
 }
 
 static void __net_exit ip6table_security_net_exit(struct net *net)
-- 
1.7.10.4

