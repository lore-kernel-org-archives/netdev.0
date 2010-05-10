From: kaber@trash.net
Subject: [PATCH 28/84] netfilter: xt extensions: use pr_<level>
Date: Mon, 10 May 2010 22:17:59 +0200
Message-ID: <1273522735-24672-29-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54508 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756580Ab0EJUTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:05 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_CONNSECMARK.c |   13 ++++++-------
 net/netfilter/xt_DSCP.c        |    4 ++--
 net/netfilter/xt_HL.c          |   10 ++++------
 net/netfilter/xt_LED.c         |   10 ++++------
 net/netfilter/xt_SECMARK.c     |   20 ++++++++++----------
 net/netfilter/xt_TCPMSS.c      |   18 +++++++++---------
 net/netfilter/xt_cluster.c     |   11 ++++++-----
 net/netfilter/xt_connbytes.c   |    5 +++--
 net/netfilter/xt_connlimit.c   |    5 +++--
 net/netfilter/xt_connmark.c    |    8 ++++----
 net/netfilter/xt_conntrack.c   |    6 +++---
 net/netfilter/xt_dscp.c        |    4 ++--
 net/netfilter/xt_hashlimit.c   |   18 ++++++++----------
 net/netfilter/xt_helper.c      |    6 +++---
 net/netfilter/xt_hl.c          |   12 ------------
 net/netfilter/xt_limit.c       |    6 +++---
 net/netfilter/xt_osf.c         |    8 ++++----
 net/netfilter/xt_physdev.c     |    8 ++++----
 net/netfilter/xt_policy.c      |   13 +++++--------
 net/netfilter/xt_recent.c      |    6 +++---
 net/netfilter/xt_state.c       |    4 ++--
 21 files changed, 88 insertions(+), 107 deletions(-)

diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index b54c375..6812865 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -15,6 +15,7 @@
  * published by the Free Software Foundation.
  *
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
@@ -22,8 +23,6 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 
-#define PFX "CONNSECMARK: "
-
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("James Morris <jmorris@redhat.com>");
 MODULE_DESCRIPTION("Xtables: target for copying between connection and security mark");
@@ -91,8 +90,8 @@ static bool connsecmark_tg_check(const struct xt_tgchk_param *par)
 
 	if (strcmp(par->table, "mangle") != 0 &&
 	    strcmp(par->table, "security") != 0) {
-		printk(KERN_INFO PFX "target only valid in the \'mangle\' "
-		       "or \'security\' tables, not \'%s\'.\n", par->table);
+		pr_info("target only valid in the \'mangle\' "
+			"or \'security\' tables, not \'%s\'.\n", par->table);
 		return false;
 	}
 
@@ -102,13 +101,13 @@ static bool connsecmark_tg_check(const struct xt_tgchk_param *par)
 		break;
 
 	default:
-		printk(KERN_INFO PFX "invalid mode: %hu\n", info->mode);
+		pr_info("invalid mode: %hu\n", info->mode);
 		return false;
 	}
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index 74ce892..bbf08a9 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -9,7 +9,7 @@
  *
  * See RFC2474 for a description of the DSCP field within the IP Header.
 */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -65,7 +65,7 @@ static bool dscp_tg_check(const struct xt_tgchk_param *par)
 	const struct xt_DSCP_info *info = par->targinfo;
 
 	if (info->dscp > XT_DSCP_MAX) {
-		printk(KERN_WARNING "DSCP: dscp %x out of range\n", info->dscp);
+		pr_info("dscp %x out of range\n", info->dscp);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
index 10e789e..7004ed2 100644
--- a/net/netfilter/xt_HL.c
+++ b/net/netfilter/xt_HL.c
@@ -9,7 +9,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -106,8 +106,7 @@ static bool ttl_tg_check(const struct xt_tgchk_param *par)
 	const struct ipt_TTL_info *info = par->targinfo;
 
 	if (info->mode > IPT_TTL_MAXMODE) {
-		printk(KERN_WARNING "ipt_TTL: invalid or unknown Mode %u\n",
-			info->mode);
+		pr_info("TTL: invalid or unknown mode %u\n", info->mode);
 		return false;
 	}
 	if (info->mode != IPT_TTL_SET && info->ttl == 0)
@@ -120,12 +119,11 @@ static bool hl_tg6_check(const struct xt_tgchk_param *par)
 	const struct ip6t_HL_info *info = par->targinfo;
 
 	if (info->mode > IP6T_HL_MAXMODE) {
-		printk(KERN_WARNING "ip6t_HL: invalid or unknown Mode %u\n",
-			info->mode);
+		pr_info("invalid or unknown mode %u\n", info->mode);
 		return false;
 	}
 	if (info->mode != IP6T_HL_SET && info->hop_limit == 0) {
-		printk(KERN_WARNING "ip6t_HL: increment/decrement doesn't "
+		pr_info("increment/decrement does not "
 			"make sense with value 0\n");
 		return false;
 	}
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index 0d6c288..f511bea 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -18,7 +18,7 @@
  * 02110-1301 USA.
  *
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
@@ -87,7 +87,7 @@ static bool led_tg_check(const struct xt_tgchk_param *par)
 	int err;
 
 	if (ledinfo->id[0] == '\0') {
-		printk(KERN_ERR KBUILD_MODNAME ": No 'id' parameter given.\n");
+		pr_info("No 'id' parameter given.\n");
 		return false;
 	}
 
@@ -99,11 +99,9 @@ static bool led_tg_check(const struct xt_tgchk_param *par)
 
 	err = led_trigger_register(&ledinternal->netfilter_led_trigger);
 	if (err) {
-		printk(KERN_CRIT KBUILD_MODNAME
-			": led_trigger_register() failed\n");
+		pr_warning("led_trigger_register() failed\n");
 		if (err == -EEXIST)
-			printk(KERN_ERR KBUILD_MODNAME
-				": Trigger name is already in use.\n");
+			pr_warning("Trigger name is already in use.\n");
 		goto exit_alloc;
 	}
 
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index 7a6f9e6..4855fd9 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -12,6 +12,7 @@
  * published by the Free Software Foundation.
  *
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/selinux.h>
@@ -59,20 +60,19 @@ static bool checkentry_selinux(struct xt_secmark_target_info *info)
 	err = selinux_string_to_sid(sel->selctx, &sel->selsid);
 	if (err) {
 		if (err == -EINVAL)
-			printk(KERN_INFO PFX "invalid SELinux context \'%s\'\n",
-			       sel->selctx);
+			pr_info("invalid SELinux context \'%s\'\n",
+				sel->selctx);
 		return false;
 	}
 
 	if (!sel->selsid) {
-		printk(KERN_INFO PFX "unable to map SELinux context \'%s\'\n",
-		       sel->selctx);
+		pr_info("unable to map SELinux context \'%s\'\n", sel->selctx);
 		return false;
 	}
 
 	err = selinux_secmark_relabel_packet_permission(sel->selsid);
 	if (err) {
-		printk(KERN_INFO PFX "unable to obtain relabeling permission\n");
+		pr_info("unable to obtain relabeling permission\n");
 		return false;
 	}
 
@@ -86,14 +86,14 @@ static bool secmark_tg_check(const struct xt_tgchk_param *par)
 
 	if (strcmp(par->table, "mangle") != 0 &&
 	    strcmp(par->table, "security") != 0) {
-		printk(KERN_INFO PFX "target only valid in the \'mangle\' "
-		       "or \'security\' tables, not \'%s\'.\n", par->table);
+		pr_info("target only valid in the \'mangle\' "
+			"or \'security\' tables, not \'%s\'.\n", par->table);
 		return false;
 	}
 
 	if (mode && mode != info->mode) {
-		printk(KERN_INFO PFX "mode already set to %hu cannot mix with "
-		       "rules for mode %hu\n", mode, info->mode);
+		pr_info("mode already set to %hu cannot mix with "
+			"rules for mode %hu\n", mode, info->mode);
 		return false;
 	}
 
@@ -104,7 +104,7 @@ static bool secmark_tg_check(const struct xt_tgchk_param *par)
 		break;
 
 	default:
-		printk(KERN_INFO PFX "invalid mode: %hu\n", info->mode);
+		pr_info("invalid mode: %hu\n", info->mode);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 0e357ac..2077da3 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -7,7 +7,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -67,14 +67,14 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
 		if (dst_mtu(skb_dst(skb)) <= minlen) {
 			if (net_ratelimit())
-				printk(KERN_ERR "xt_TCPMSS: "
+				pr_err("xt_TCPMSS: "
 				       "unknown or invalid path-MTU (%u)\n",
 				       dst_mtu(skb_dst(skb)));
 			return -1;
 		}
 		if (in_mtu <= minlen) {
 			if (net_ratelimit())
-				printk(KERN_ERR "xt_TCPMSS: unknown or "
+				pr_err("xt_TCPMSS: unknown or "
 				       "invalid path-MTU (%u)\n", in_mtu);
 			return -1;
 		}
@@ -245,14 +245,14 @@ static bool tcpmss_tg4_check(const struct xt_tgchk_param *par)
 	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
 			   (1 << NF_INET_LOCAL_OUT) |
 			   (1 << NF_INET_POST_ROUTING))) != 0) {
-		printk("xt_TCPMSS: path-MTU clamping only supported in "
-		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
+		pr_info("path-MTU clamping only supported in "
+			"FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
 	}
 	xt_ematch_foreach(ematch, e)
 		if (find_syn_match(ematch))
 			return true;
-	printk("xt_TCPMSS: Only works on TCP SYN packets\n");
+	pr_info("Only works on TCP SYN packets\n");
 	return false;
 }
 
@@ -267,14 +267,14 @@ static bool tcpmss_tg6_check(const struct xt_tgchk_param *par)
 	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
 			   (1 << NF_INET_LOCAL_OUT) |
 			   (1 << NF_INET_POST_ROUTING))) != 0) {
-		printk("xt_TCPMSS: path-MTU clamping only supported in "
-		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
+		pr_info("path-MTU clamping only supported in "
+			"FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
 	}
 	xt_ematch_foreach(ematch, e)
 		if (find_syn_match(ematch))
 			return true;
-	printk("xt_TCPMSS: Only works on TCP SYN packets\n");
+	pr_info("Only works on TCP SYN packets\n");
 	return false;
 }
 #endif
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 225ee3e..4c273e8 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -5,6 +5,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/jhash.h>
@@ -136,14 +137,14 @@ static bool xt_cluster_mt_checkentry(const struct xt_mtchk_param *par)
 	struct xt_cluster_match_info *info = par->matchinfo;
 
 	if (info->total_nodes > XT_CLUSTER_NODES_MAX) {
-		printk(KERN_ERR "xt_cluster: you have exceeded the maximum "
-				"number of cluster nodes (%u > %u)\n",
-				info->total_nodes, XT_CLUSTER_NODES_MAX);
+		pr_info("you have exceeded the maximum "
+			"number of cluster nodes (%u > %u)\n",
+			info->total_nodes, XT_CLUSTER_NODES_MAX);
 		return false;
 	}
 	if (info->node_mask >= (1ULL << info->total_nodes)) {
-		printk(KERN_ERR "xt_cluster: this node mask cannot be "
-				"higher than the total number of nodes\n");
+		pr_info("this node mask cannot be "
+			"higher than the total number of nodes\n");
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 955e659..edb7bbd 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -1,6 +1,7 @@
 /* Kernel module to match connection tracking byte counter.
  * GPL (C) 2002 Martin Devera (devik@cdi.cz).
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/bitops.h>
 #include <linux/skbuff.h>
@@ -107,8 +108,8 @@ static bool connbytes_mt_check(const struct xt_mtchk_param *par)
 		return false;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 9e624af..d5b26da 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -11,6 +11,7 @@
  * Kernel module to match connection tracking information.
  * GPL (C) 1999  Rusty Russell (rusty@rustcorp.com.au).
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/ip.h>
@@ -225,8 +226,8 @@ static bool connlimit_mt_check(const struct xt_mtchk_param *par)
 		connlimit_rnd_inited = true;
 	}
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
-		       "address family %u\n", par->family);
+		pr_info("cannot load conntrack support for "
+			"address family %u\n", par->family);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 97465a4..7a51ba6 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -77,8 +77,8 @@ connmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 static bool connmark_tg_check(const struct xt_tgchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
-		       "proto=%u\n", par->family);
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
 		return false;
 	}
 	return true;
@@ -106,8 +106,8 @@ connmark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 static bool connmark_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
-		       "proto=%u\n", par->family);
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index ae66305..387172b 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -9,7 +9,7 @@
  *	it under the terms of the GNU General Public License version 2 as
  *	published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <net/ipv6.h>
@@ -209,8 +209,8 @@ conntrack_mt_v2(const struct sk_buff *skb, const struct xt_match_param *par)
 static bool conntrack_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index fe58cd0..6ecedc1 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -47,7 +47,7 @@ static bool dscp_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_dscp_info *info = par->matchinfo;
 
 	if (info->dscp > XT_DSCP_MAX) {
-		printk(KERN_ERR "xt_dscp: dscp %x out of range\n", info->dscp);
+		pr_info("dscp %x out of range\n", info->dscp);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 52327c5..8f3e0c0 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -7,6 +7,7 @@
  *
  * Development of this code was funded by Astaro AG, http://www.astaro.com/
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/random.h>
@@ -166,17 +167,14 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 	if (ht->cfg.max && ht->count >= ht->cfg.max) {
 		/* FIXME: do something. question is what.. */
 		if (net_ratelimit())
-			printk(KERN_WARNING
-				"xt_hashlimit: max count of %u reached\n",
-				ht->cfg.max);
+			pr_err("max count of %u reached\n", ht->cfg.max);
 		return NULL;
 	}
 
 	ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
 	if (!ent) {
 		if (net_ratelimit())
-			printk(KERN_ERR
-				"xt_hashlimit: can't allocate dsthash_ent\n");
+			pr_err("cannot allocate dsthash_ent\n");
 		return NULL;
 	}
 	memcpy(&ent->dst, dst, sizeof(ent->dst));
@@ -681,8 +679,8 @@ static bool hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 	/* Check for overflow. */
 	if (r->cfg.burst == 0 ||
 	    user2credits(r->cfg.avg * r->cfg.burst) < user2credits(r->cfg.avg)) {
-		printk(KERN_ERR "xt_hashlimit: overflow, try lower: %u/%u\n",
-		       r->cfg.avg, r->cfg.burst);
+		pr_info("overflow, try lower: %u/%u\n",
+			r->cfg.avg, r->cfg.burst);
 		return false;
 	}
 	if (r->cfg.mode == 0 ||
@@ -718,8 +716,8 @@ static bool hashlimit_mt_check(const struct xt_mtchk_param *par)
 	if (info->cfg.burst == 0 ||
 	    user2credits(info->cfg.avg * info->cfg.burst) <
 	    user2credits(info->cfg.avg)) {
-		printk(KERN_ERR "xt_hashlimit: overflow, try lower: %u/%u\n",
-		       info->cfg.avg, info->cfg.burst);
+		pr_info("overflow, try lower: %u/%u\n",
+			info->cfg.avg, info->cfg.burst);
 		return false;
 	}
 	if (info->cfg.gc_interval == 0 || info->cfg.expire == 0)
@@ -1018,7 +1016,7 @@ static int __init hashlimit_mt_init(void)
 					    sizeof(struct dsthash_ent), 0, 0,
 					    NULL);
 	if (!hashlimit_cachep) {
-		printk(KERN_ERR "xt_hashlimit: unable to create slab cache\n");
+		pr_warning("unable to create slab cache\n");
 		goto err2;
 	}
 	return 0;
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 64fc7f2..482aff2 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter.h>
@@ -59,8 +59,8 @@ static bool helper_mt_check(const struct xt_mtchk_param *par)
 	struct xt_helper_info *info = par->matchinfo;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
 		return false;
 	}
 	info->name[29] = '\0';
diff --git a/net/netfilter/xt_hl.c b/net/netfilter/xt_hl.c
index 7726154..be53f72 100644
--- a/net/netfilter/xt_hl.c
+++ b/net/netfilter/xt_hl.c
@@ -39,10 +39,6 @@ static bool ttl_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 			return ttl < info->ttl;
 		case IPT_TTL_GT:
 			return ttl > info->ttl;
-		default:
-			printk(KERN_WARNING "ipt_ttl: unknown mode %d\n",
-				info->mode);
-			return false;
 	}
 
 	return false;
@@ -56,20 +52,12 @@ static bool hl_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 	switch (info->mode) {
 		case IP6T_HL_EQ:
 			return ip6h->hop_limit == info->hop_limit;
-			break;
 		case IP6T_HL_NE:
 			return ip6h->hop_limit != info->hop_limit;
-			break;
 		case IP6T_HL_LT:
 			return ip6h->hop_limit < info->hop_limit;
-			break;
 		case IP6T_HL_GT:
 			return ip6h->hop_limit > info->hop_limit;
-			break;
-		default:
-			printk(KERN_WARNING "ip6t_hl: unknown mode %d\n",
-				info->mode);
-			return false;
 	}
 
 	return false;
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index a0ca533..b3dfca6 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -5,7 +5,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
@@ -105,8 +105,8 @@ static bool limit_mt_check(const struct xt_mtchk_param *par)
 	/* Check for overflow. */
 	if (r->burst == 0
 	    || user2credits(r->avg * r->burst) < user2credits(r->avg)) {
-		printk("Overflow in xt_limit, try lower: %u/%u\n",
-		       r->avg, r->burst);
+		pr_info("Overflow, try lower: %u/%u\n",
+			r->avg, r->burst);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 4169e20..8dcde13 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -16,7 +16,7 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/kernel.h>
 
@@ -382,14 +382,14 @@ static int __init xt_osf_init(void)
 
 	err = nfnetlink_subsys_register(&xt_osf_nfnetlink);
 	if (err < 0) {
-		printk(KERN_ERR "Failed (%d) to register OSF nsfnetlink helper.\n", err);
+		pr_err("Failed to register OSF nsfnetlink helper (%d)\n", err);
 		goto err_out_exit;
 	}
 
 	err = xt_register_match(&xt_osf_match);
 	if (err) {
-		printk(KERN_ERR "Failed (%d) to register OS fingerprint "
-				"matching module.\n", err);
+		pr_err("Failed to register OS fingerprint "
+		       "matching module (%d)\n", err);
 		goto err_out_remove;
 	}
 
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 8d28ca5..3d42a27 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -7,7 +7,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter_bridge.h>
@@ -95,9 +95,9 @@ static bool physdev_mt_check(const struct xt_mtchk_param *par)
 	     info->invert & XT_PHYSDEV_OP_BRIDGED) &&
 	    par->hook_mask & ((1 << NF_INET_LOCAL_OUT) |
 	    (1 << NF_INET_FORWARD) | (1 << NF_INET_POST_ROUTING))) {
-		printk(KERN_WARNING "physdev match: using --physdev-out in the "
-		       "OUTPUT, FORWARD and POSTROUTING chains for non-bridged "
-		       "traffic is not supported anymore.\n");
+		pr_info("using --physdev-out in the OUTPUT, FORWARD and "
+			"POSTROUTING chains for non-bridged traffic is not "
+			"supported anymore.\n");
 		if (par->hook_mask & (1 << NF_INET_LOCAL_OUT))
 			return false;
 	}
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index cc033d2..de3aded 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -133,24 +133,21 @@ static bool policy_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_policy_info *info = par->matchinfo;
 
 	if (!(info->flags & (XT_POLICY_MATCH_IN|XT_POLICY_MATCH_OUT))) {
-		printk(KERN_ERR "xt_policy: neither incoming nor "
-				"outgoing policy selected\n");
+		pr_info("neither incoming nor outgoing policy selected\n");
 		return false;
 	}
 	if (par->hook_mask & ((1 << NF_INET_PRE_ROUTING) |
 	    (1 << NF_INET_LOCAL_IN)) && info->flags & XT_POLICY_MATCH_OUT) {
-		printk(KERN_ERR "xt_policy: output policy not valid in "
-				"PRE_ROUTING and INPUT\n");
+		pr_info("output policy not valid in PREROUTING and INPUT\n");
 		return false;
 	}
 	if (par->hook_mask & ((1 << NF_INET_POST_ROUTING) |
 	    (1 << NF_INET_LOCAL_OUT)) && info->flags & XT_POLICY_MATCH_IN) {
-		printk(KERN_ERR "xt_policy: input policy not valid in "
-				"POST_ROUTING and OUTPUT\n");
+		pr_info("input policy not valid in POSTROUTING and OUTPUT\n");
 		return false;
 	}
 	if (info->len > XT_POLICY_MAX_ELEM) {
-		printk(KERN_ERR "xt_policy: too many policy elements\n");
+		pr_info("too many policy elements\n");
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index a0ea1a2..aa9817e 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -12,6 +12,7 @@
  * Author: Stephen Frost <sfrost@snowman.net>
  * Copyright 2002-2003, Stephen Frost, 2.5.x port by laforge@netfilter.org
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/init.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
@@ -520,7 +521,7 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 		add = true;
 		break;
 	default:
-		printk(KERN_INFO KBUILD_MODNAME ": Need +ip, -ip or /\n");
+		pr_info("Need \"+ip\", \"-ip\" or \"/\"\n");
 		return -EINVAL;
 	}
 
@@ -535,8 +536,7 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 	}
 
 	if (!succ) {
-		printk(KERN_INFO KBUILD_MODNAME ": illegal address written "
-		       "to procfs\n");
+		pr_info("illegal address written to procfs\n");
 		return -EINVAL;
 	}
 
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index ef09b2e..94893be 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -40,8 +40,8 @@ state_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 static bool state_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_info("cannot load conntrack support for proto=%u\n",
+			par->family);
 		return false;
 	}
 	return true;
-- 
1.7.0.4

