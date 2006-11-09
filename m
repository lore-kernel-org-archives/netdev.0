From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/6] [NET] rules: Share common attribute validation policy
Date: Thu, 09 Nov 2006 12:27:40 +0100
Message-ID: <20061109113245.978740794@lsx.localdomain>
References: <20061109112735.577771022@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:9424 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965326AbWKILd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 06:33:57 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=rules_share_policy
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the attribute policy for the non-specific attributes into
net/fib_rules.h and include it in the respective protocols.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/net/fib_rules.h
===================================================================
--- net-2.6.20.orig/include/net/fib_rules.h	2006-11-08 23:32:35.000000000 +0100
+++ net-2.6.20/include/net/fib_rules.h	2006-11-08 23:33:21.000000000 +0100
@@ -59,6 +59,13 @@
 	struct module		*owner;
 };
 
+#define FRA_GENERIC_POLICY \
+	[FRA_IFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 }, \
+	[FRA_PRIORITY]	= { .type = NLA_U32 }, \
+	[FRA_FWMARK]	= { .type = NLA_U32 }, \
+	[FRA_FWMASK]	= { .type = NLA_U32 }, \
+	[FRA_TABLE]     = { .type = NLA_U32 }
+
 static inline void fib_rule_get(struct fib_rule *rule)
 {
 	atomic_inc(&rule->refcnt);
Index: net-2.6.20/net/decnet/dn_rules.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_rules.c	2006-11-08 23:32:35.000000000 +0100
+++ net-2.6.20/net/decnet/dn_rules.c	2006-11-08 23:33:21.000000000 +0100
@@ -108,13 +108,9 @@
 }
 
 static struct nla_policy dn_fib_rule_policy[FRA_MAX+1] __read_mostly = {
-	[FRA_IFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
-	[FRA_PRIORITY]	= { .type = NLA_U32 },
+	FRA_GENERIC_POLICY,
 	[FRA_SRC]	= { .type = NLA_U16 },
 	[FRA_DST]	= { .type = NLA_U16 },
-	[FRA_FWMARK]	= { .type = NLA_U32 },
-	[FRA_FWMASK]	= { .type = NLA_U32 },
-	[FRA_TABLE]     = { .type = NLA_U32 },
 };
 
 static int dn_fib_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
Index: net-2.6.20/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.20.orig/net/ipv4/fib_rules.c	2006-11-08 23:32:35.000000000 +0100
+++ net-2.6.20/net/ipv4/fib_rules.c	2006-11-08 23:33:21.000000000 +0100
@@ -170,14 +170,10 @@
 }
 
 static struct nla_policy fib4_rule_policy[FRA_MAX+1] __read_mostly = {
-	[FRA_IFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
-	[FRA_PRIORITY]	= { .type = NLA_U32 },
+	FRA_GENERIC_POLICY,
 	[FRA_SRC]	= { .type = NLA_U32 },
 	[FRA_DST]	= { .type = NLA_U32 },
-	[FRA_FWMARK]	= { .type = NLA_U32 },
-	[FRA_FWMASK]	= { .type = NLA_U32 },
 	[FRA_FLOW]	= { .type = NLA_U32 },
-	[FRA_TABLE]	= { .type = NLA_U32 },
 };
 
 static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
Index: net-2.6.20/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.20.orig/net/ipv6/fib6_rules.c	2006-11-08 23:32:35.000000000 +0100
+++ net-2.6.20/net/ipv6/fib6_rules.c	2006-11-08 23:33:21.000000000 +0100
@@ -130,13 +130,9 @@
 }
 
 static struct nla_policy fib6_rule_policy[FRA_MAX+1] __read_mostly = {
-	[FRA_IFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
-	[FRA_PRIORITY]	= { .type = NLA_U32 },
+	FRA_GENERIC_POLICY,
 	[FRA_SRC]	= { .len = sizeof(struct in6_addr) },
 	[FRA_DST]	= { .len = sizeof(struct in6_addr) },
-	[FRA_FWMARK]	= { .type = NLA_U32 },
-	[FRA_FWMASK]	= { .type = NLA_U32 },
-	[FRA_TABLE]	= { .type = NLA_U32 },
 };
 
 static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,

--

