From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 4/4] netfilter: Use IS_ERR_OR_NULL().
Date: Wed, 23 Jan 2013 01:33:09 +0900
Message-ID: <50FEBF45.1000301@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51863 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754188Ab3AVQdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 11:33:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv4/netfilter/arp_tables.c |   10 +++++-----
 net/ipv4/netfilter/ip_tables.c  |   10 +++++-----
 net/ipv6/netfilter/ip6_tables.c |   10 +++++-----
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 3ea4127..7dc6a97 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -901,7 +901,7 @@ static int get_info(struct net *net, void __user *user,
 #endif
 	t = try_then_request_module(xt_find_table_lock(net, NFPROTO_ARP, name),
 				    "arptable_%s", name);
-	if (t && !IS_ERR(t)) {
+	if (!IS_ERR_OR_NULL(t)) {
 		struct arpt_getinfo info;
 		const struct xt_table_info *private = t->private;
 #ifdef CONFIG_COMPAT
@@ -958,7 +958,7 @@ static int get_entries(struct net *net, struct arpt_get_entries __user *uptr,
 	}
 
 	t = xt_find_table_lock(net, NFPROTO_ARP, get.name);
-	if (t && !IS_ERR(t)) {
+	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
 
 		duprintf("t->private->number = %u\n",
@@ -1001,7 +1001,7 @@ static int __do_replace(struct net *net, const char *name,
 
 	t = try_then_request_module(xt_find_table_lock(net, NFPROTO_ARP, name),
 				    "arptable_%s", name);
-	if (!t || IS_ERR(t)) {
+	if (IS_ERR_OR_NULL(t)) {
 		ret = t ? PTR_ERR(t) : -ENOENT;
 		goto free_newinfo_counters_untrans;
 	}
@@ -1158,7 +1158,7 @@ static int do_add_counters(struct net *net, const void __user *user,
 	}
 
 	t = xt_find_table_lock(net, NFPROTO_ARP, name);
-	if (!t || IS_ERR(t)) {
+	if (IS_ERR_OR_NULL(t)) {
 		ret = t ? PTR_ERR(t) : -ENOENT;
 		goto free;
 	}
@@ -1646,7 +1646,7 @@ static int compat_get_entries(struct net *net,
 
 	xt_compat_lock(NFPROTO_ARP);
 	t = xt_find_table_lock(net, NFPROTO_ARP, get.name);
-	if (t && !IS_ERR(t)) {
+	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 17c5e06..3efcf87 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1090,7 +1090,7 @@ static int get_info(struct net *net, void __user *user,
 #endif
 	t = try_then_request_module(xt_find_table_lock(net, AF_INET, name),
 				    "iptable_%s", name);
-	if (t && !IS_ERR(t)) {
+	if (!IS_ERR_OR_NULL(t)) {
 		struct ipt_getinfo info;
 		const struct xt_table_info *private = t->private;
 #ifdef CONFIG_COMPAT
@@ -1149,7 +1149,7 @@ get_entries(struct net *net, struct ipt_get_entries __user *uptr,
 	}
 
 	t = xt_find_table_lock(net, AF_INET, get.name);
-	if (t && !IS_ERR(t)) {
+	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
 		duprintf("t->private->number = %u\n", private->number);
 		if (get.size == private->size)
@@ -1189,7 +1189,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 
 	t = try_then_request_module(xt_find_table_lock(net, AF_INET, name),
 				    "iptable_%s", name);
-	if (!t || IS_ERR(t)) {
+	if (IS_ERR_OR_NULL(t)) {
 		ret = t ? PTR_ERR(t) : -ENOENT;
 		goto free_newinfo_counters_untrans;
 	}
@@ -1347,7 +1347,7 @@ do_add_counters(struct net *net, const void __user *user,
 	}
 
 	t = xt_find_table_lock(net, AF_INET, name);
-	if (!t || IS_ERR(t)) {
+	if (IS_ERR_OR_NULL(t)) {
 		ret = t ? PTR_ERR(t) : -ENOENT;
 		goto free;
 	}
@@ -1931,7 +1931,7 @@ compat_get_entries(struct net *net, struct compat_ipt_get_entries __user *uptr,
 
 	xt_compat_lock(AF_INET);
 	t = xt_find_table_lock(net, AF_INET, get.name);
-	if (t && !IS_ERR(t)) {
+	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
 		duprintf("t->private->number = %u\n", private->number);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 125a90d..341b54a 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1098,7 +1098,7 @@ static int get_info(struct net *net, void __user *user,
 #endif
 	t = try_then_request_module(xt_find_table_lock(net, AF_INET6, name),
 				    "ip6table_%s", name);
-	if (t && !IS_ERR(t)) {
+	if (!IS_ERR_OR_NULL(t)) {
 		struct ip6t_getinfo info;
 		const struct xt_table_info *private = t->private;
 #ifdef CONFIG_COMPAT
@@ -1157,7 +1157,7 @@ get_entries(struct net *net, struct ip6t_get_entries __user *uptr,
 	}
 
 	t = xt_find_table_lock(net, AF_INET6, get.name);
-	if (t && !IS_ERR(t)) {
+	if (!IS_ERR_OR_NULL(t)) {
 		struct xt_table_info *private = t->private;
 		duprintf("t->private->number = %u\n", private->number);
 		if (get.size == private->size)
@@ -1197,7 +1197,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 
 	t = try_then_request_module(xt_find_table_lock(net, AF_INET6, name),
 				    "ip6table_%s", name);
-	if (!t || IS_ERR(t)) {
+	if (IS_ERR_OR_NULL(t)) {
 		ret = t ? PTR_ERR(t) : -ENOENT;
 		goto free_newinfo_counters_untrans;
 	}
@@ -1355,7 +1355,7 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	}
 
 	t = xt_find_table_lock(net, AF_INET6, name);
-	if (!t || IS_ERR(t)) {
+	if (IS_ERR_OR_NULL(t)) {
 		ret = t ? PTR_ERR(t) : -ENOENT;
 		goto free;
 	}
@@ -1939,7 +1939,7 @@ compat_get_entries(struct net *net, struct compat_ip6t_get_entries __user *uptr,
 
 	xt_compat_lock(AF_INET6);
 	t = xt_find_table_lock(net, AF_INET6, get.name);
-	if (t && !IS_ERR(t)) {
+	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
 		duprintf("t->private->number = %u\n", private->number);
-- 
1.7.9.5
