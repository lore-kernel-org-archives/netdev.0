From: kaber@trash.net
Subject: [PATCH 32/72] netfilter: xtables: resolve indirect macros 1/3
Date: Thu, 21 Oct 2010 17:19:19 +0200
Message-ID: <1287674399-31455-33-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59989 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146Ab0JUPUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:09 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Many of the used macros are just there for userspace compatibility.
Substitute the in-kernel code to directly use the terminal macro
and stuff the defines into #ifndef __KERNEL__ sections.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter_arp/arp_tables.h  |   10 ++++++----
 include/linux/netfilter_ipv4/ip_tables.h  |   10 ++++++----
 include/linux/netfilter_ipv6/ip6_tables.h |   11 ++++++-----
 net/ipv4/netfilter/arp_tables.c           |   10 +++++-----
 net/ipv4/netfilter/ip_tables.c            |   12 ++++++------
 net/ipv6/netfilter/ip6_tables.c           |   12 ++++++------
 6 files changed, 35 insertions(+), 30 deletions(-)

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index e9948c0..8193860 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -21,8 +21,10 @@
 
 #include <linux/netfilter/x_tables.h>
 
+#ifndef __KERNEL__
 #define ARPT_FUNCTION_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
 #define ARPT_TABLE_MAXNAMELEN XT_TABLE_MAXNAMELEN
+#endif
 
 #define ARPT_DEV_ADDR_LEN_MAX 16
 
@@ -134,7 +136,7 @@ struct arpt_entry
 /* The argument to ARPT_SO_GET_INFO */
 struct arpt_getinfo {
 	/* Which table: caller fills this in. */
-	char name[ARPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 
 	/* Kernel fills these in. */
 	/* Which hook entry points are valid: bitmask */
@@ -156,7 +158,7 @@ struct arpt_getinfo {
 /* The argument to ARPT_SO_SET_REPLACE. */
 struct arpt_replace {
 	/* Which table. */
-	char name[ARPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 
 	/* Which hook entry points are valid: bitmask.  You can't
            change this. */
@@ -191,7 +193,7 @@ struct arpt_replace {
 /* The argument to ARPT_SO_GET_ENTRIES. */
 struct arpt_get_entries {
 	/* Which table: user fills this in. */
-	char name[ARPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 
 	/* User fills this in: total entry size. */
 	unsigned int size;
@@ -230,7 +232,7 @@ struct arpt_standard {
 
 struct arpt_error_target {
 	struct arpt_entry_target target;
-	char errorname[ARPT_FUNCTION_MAXNAMELEN];
+	char errorname[XT_FUNCTION_MAXNAMELEN];
 };
 
 struct arpt_error {
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 704a7b6..1b7cdf1 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -27,12 +27,14 @@
 
 #include <linux/netfilter/x_tables.h>
 
+#ifndef __KERNEL__
 #define IPT_FUNCTION_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
 #define IPT_TABLE_MAXNAMELEN XT_TABLE_MAXNAMELEN
 #define ipt_match xt_match
 #define ipt_target xt_target
 #define ipt_table xt_table
 #define ipt_get_revision xt_get_revision
+#endif
 
 /* Yes, Virginia, you have to zero the padding. */
 struct ipt_ip {
@@ -146,7 +148,7 @@ struct ipt_icmp {
 /* The argument to IPT_SO_GET_INFO */
 struct ipt_getinfo {
 	/* Which table: caller fills this in. */
-	char name[IPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 
 	/* Kernel fills these in. */
 	/* Which hook entry points are valid: bitmask */
@@ -168,7 +170,7 @@ struct ipt_getinfo {
 /* The argument to IPT_SO_SET_REPLACE. */
 struct ipt_replace {
 	/* Which table. */
-	char name[IPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 
 	/* Which hook entry points are valid: bitmask.  You can't
            change this. */
@@ -202,7 +204,7 @@ struct ipt_replace {
 /* The argument to IPT_SO_GET_ENTRIES. */
 struct ipt_get_entries {
 	/* Which table: user fills this in. */
-	char name[IPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 
 	/* User fills this in: total entry size. */
 	unsigned int size;
@@ -254,7 +256,7 @@ struct ipt_standard {
 
 struct ipt_error_target {
 	struct ipt_entry_target target;
-	char errorname[IPT_FUNCTION_MAXNAMELEN];
+	char errorname[XT_FUNCTION_MAXNAMELEN];
 };
 
 struct ipt_error {
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 18442ff..abe31d0 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -27,13 +27,14 @@
 
 #include <linux/netfilter/x_tables.h>
 
+#ifndef __KERNEL__
 #define IP6T_FUNCTION_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
 #define IP6T_TABLE_MAXNAMELEN XT_TABLE_MAXNAMELEN
-
 #define ip6t_match xt_match
 #define ip6t_target xt_target
 #define ip6t_table xt_table
 #define ip6t_get_revision xt_get_revision
+#endif
 
 /* Yes, Virginia, you have to zero the padding. */
 struct ip6t_ip6 {
@@ -117,7 +118,7 @@ struct ip6t_standard {
 
 struct ip6t_error_target {
 	struct ip6t_entry_target target;
-	char errorname[IP6T_FUNCTION_MAXNAMELEN];
+	char errorname[XT_FUNCTION_MAXNAMELEN];
 };
 
 struct ip6t_error {
@@ -203,7 +204,7 @@ struct ip6t_icmp {
 /* The argument to IP6T_SO_GET_INFO */
 struct ip6t_getinfo {
 	/* Which table: caller fills this in. */
-	char name[IP6T_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 
 	/* Kernel fills these in. */
 	/* Which hook entry points are valid: bitmask */
@@ -225,7 +226,7 @@ struct ip6t_getinfo {
 /* The argument to IP6T_SO_SET_REPLACE. */
 struct ip6t_replace {
 	/* Which table. */
-	char name[IP6T_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 
 	/* Which hook entry points are valid: bitmask.  You can't
            change this. */
@@ -259,7 +260,7 @@ struct ip6t_replace {
 /* The argument to IP6T_SO_GET_ENTRIES. */
 struct ip6t_get_entries {
 	/* Which table: user fills this in. */
-	char name[IP6T_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 
 	/* User fills this in: total entry size. */
 	unsigned int size;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index e8f4f9a..e427a9e 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -895,7 +895,7 @@ static int compat_table_info(const struct xt_table_info *info,
 static int get_info(struct net *net, void __user *user,
                     const int *len, int compat)
 {
-	char name[ARPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
 	int ret;
 
@@ -908,7 +908,7 @@ static int get_info(struct net *net, void __user *user,
 	if (copy_from_user(name, user, sizeof(name)) != 0)
 		return -EFAULT;
 
-	name[ARPT_TABLE_MAXNAMELEN-1] = '\0';
+	name[XT_TABLE_MAXNAMELEN-1] = '\0';
 #ifdef CONFIG_COMPAT
 	if (compat)
 		xt_compat_lock(NFPROTO_ARP);
@@ -1474,7 +1474,7 @@ out_unlock:
 }
 
 struct compat_arpt_replace {
-	char				name[ARPT_TABLE_MAXNAMELEN];
+	char				name[XT_TABLE_MAXNAMELEN];
 	u32				valid_hooks;
 	u32				num_entries;
 	u32				size;
@@ -1628,7 +1628,7 @@ static int compat_copy_entries_to_user(unsigned int total_size,
 }
 
 struct compat_arpt_get_entries {
-	char name[ARPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 	compat_uint_t size;
 	struct compat_arpt_entry entrytable[0];
 };
@@ -1840,7 +1840,7 @@ static struct xt_target arpt_builtin_tg[] __read_mostly = {
 	{
 		.name             = ARPT_ERROR_TARGET,
 		.target           = arpt_error,
-		.targetsize       = ARPT_FUNCTION_MAXNAMELEN,
+		.targetsize       = XT_FUNCTION_MAXNAMELEN,
 		.family           = NFPROTO_ARP,
 	},
 };
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index d163f2e..2efd41b 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1092,7 +1092,7 @@ static int compat_table_info(const struct xt_table_info *info,
 static int get_info(struct net *net, void __user *user,
                     const int *len, int compat)
 {
-	char name[IPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
 	int ret;
 
@@ -1105,7 +1105,7 @@ static int get_info(struct net *net, void __user *user,
 	if (copy_from_user(name, user, sizeof(name)) != 0)
 		return -EFAULT;
 
-	name[IPT_TABLE_MAXNAMELEN-1] = '\0';
+	name[XT_TABLE_MAXNAMELEN-1] = '\0';
 #ifdef CONFIG_COMPAT
 	if (compat)
 		xt_compat_lock(AF_INET);
@@ -1400,7 +1400,7 @@ do_add_counters(struct net *net, const void __user *user,
 
 #ifdef CONFIG_COMPAT
 struct compat_ipt_replace {
-	char			name[IPT_TABLE_MAXNAMELEN];
+	char			name[XT_TABLE_MAXNAMELEN];
 	u32			valid_hooks;
 	u32			num_entries;
 	u32			size;
@@ -1884,7 +1884,7 @@ compat_do_ipt_set_ctl(struct sock *sk,	int cmd, void __user *user,
 }
 
 struct compat_ipt_get_entries {
-	char name[IPT_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 	compat_uint_t size;
 	struct compat_ipt_entry entrytable[0];
 };
@@ -2039,7 +2039,7 @@ do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 
 	case IPT_SO_GET_REVISION_MATCH:
 	case IPT_SO_GET_REVISION_TARGET: {
-		struct ipt_get_revision rev;
+		struct xt_get_revision rev;
 		int target;
 
 		if (*len != sizeof(rev)) {
@@ -2188,7 +2188,7 @@ static struct xt_target ipt_builtin_tg[] __read_mostly = {
 	{
 		.name             = IPT_ERROR_TARGET,
 		.target           = ipt_error,
-		.targetsize       = IPT_FUNCTION_MAXNAMELEN,
+		.targetsize       = XT_FUNCTION_MAXNAMELEN,
 		.family           = NFPROTO_IPV4,
 	},
 };
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 8e754be..4b973e1 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1105,7 +1105,7 @@ static int compat_table_info(const struct xt_table_info *info,
 static int get_info(struct net *net, void __user *user,
                     const int *len, int compat)
 {
-	char name[IP6T_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 	struct xt_table *t;
 	int ret;
 
@@ -1118,7 +1118,7 @@ static int get_info(struct net *net, void __user *user,
 	if (copy_from_user(name, user, sizeof(name)) != 0)
 		return -EFAULT;
 
-	name[IP6T_TABLE_MAXNAMELEN-1] = '\0';
+	name[XT_TABLE_MAXNAMELEN-1] = '\0';
 #ifdef CONFIG_COMPAT
 	if (compat)
 		xt_compat_lock(AF_INET6);
@@ -1415,7 +1415,7 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 
 #ifdef CONFIG_COMPAT
 struct compat_ip6t_replace {
-	char			name[IP6T_TABLE_MAXNAMELEN];
+	char			name[XT_TABLE_MAXNAMELEN];
 	u32			valid_hooks;
 	u32			num_entries;
 	u32			size;
@@ -1899,7 +1899,7 @@ compat_do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user,
 }
 
 struct compat_ip6t_get_entries {
-	char name[IP6T_TABLE_MAXNAMELEN];
+	char name[XT_TABLE_MAXNAMELEN];
 	compat_uint_t size;
 	struct compat_ip6t_entry entrytable[0];
 };
@@ -2054,7 +2054,7 @@ do_ip6t_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 
 	case IP6T_SO_GET_REVISION_MATCH:
 	case IP6T_SO_GET_REVISION_TARGET: {
-		struct ip6t_get_revision rev;
+		struct xt_get_revision rev;
 		int target;
 
 		if (*len != sizeof(rev)) {
@@ -2203,7 +2203,7 @@ static struct xt_target ip6t_builtin_tg[] __read_mostly = {
 	{
 		.name             = IP6T_ERROR_TARGET,
 		.target           = ip6t_error,
-		.targetsize       = IP6T_FUNCTION_MAXNAMELEN,
+		.targetsize       = XT_FUNCTION_MAXNAMELEN,
 		.family           = NFPROTO_IPV6,
 	},
 };
-- 
1.7.1

