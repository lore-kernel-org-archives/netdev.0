From: Patrick McHardy <kaber@trash.net>
Subject: x_tables 07/07: Convert printk to pr_err
Date: Sat, 13 Jun 2009 15:09:43 +0200 (MEST)
Message-ID: <20090613130943.2112.38629.sendpatchset@x2.localnet>
References: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 3dd5d7e3ba5e9b05586ff0d59ae6d700b7b7c607
Author: Joe Perches <joe@perches.com>
Date:   Sat Jun 13 12:32:39 2009 +0200

    x_tables: Convert printk to pr_err
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 46dba5f..025d1a0 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -364,14 +364,14 @@ int xt_check_match(struct xt_mtchk_param *par,
 		 * ebt_among is exempt from centralized matchsize checking
 		 * because it uses a dynamic-size data set.
 		 */
-		printk("%s_tables: %s match: invalid size %Zu != %u\n",
+		pr_err("%s_tables: %s match: invalid size %Zu != %u\n",
 		       xt_prefix[par->family], par->match->name,
 		       XT_ALIGN(par->match->matchsize), size);
 		return -EINVAL;
 	}
 	if (par->match->table != NULL &&
 	    strcmp(par->match->table, par->table) != 0) {
-		printk("%s_tables: %s match: only valid in %s table, not %s\n",
+		pr_err("%s_tables: %s match: only valid in %s table, not %s\n",
 		       xt_prefix[par->family], par->match->name,
 		       par->match->table, par->table);
 		return -EINVAL;
@@ -379,7 +379,7 @@ int xt_check_match(struct xt_mtchk_param *par,
 	if (par->match->hooks && (par->hook_mask & ~par->match->hooks) != 0) {
 		char used[64], allow[64];
 
-		printk("%s_tables: %s match: used from hooks %s, but only "
+		pr_err("%s_tables: %s match: used from hooks %s, but only "
 		       "valid from %s\n",
 		       xt_prefix[par->family], par->match->name,
 		       textify_hooks(used, sizeof(used), par->hook_mask),
@@ -387,7 +387,7 @@ int xt_check_match(struct xt_mtchk_param *par,
 		return -EINVAL;
 	}
 	if (par->match->proto && (par->match->proto != proto || inv_proto)) {
-		printk("%s_tables: %s match: only valid for protocol %u\n",
+		pr_err("%s_tables: %s match: only valid for protocol %u\n",
 		       xt_prefix[par->family], par->match->name,
 		       par->match->proto);
 		return -EINVAL;
@@ -514,14 +514,14 @@ int xt_check_target(struct xt_tgchk_param *par,
 		    unsigned int size, u_int8_t proto, bool inv_proto)
 {
 	if (XT_ALIGN(par->target->targetsize) != size) {
-		printk("%s_tables: %s target: invalid size %Zu != %u\n",
+		pr_err("%s_tables: %s target: invalid size %Zu != %u\n",
 		       xt_prefix[par->family], par->target->name,
 		       XT_ALIGN(par->target->targetsize), size);
 		return -EINVAL;
 	}
 	if (par->target->table != NULL &&
 	    strcmp(par->target->table, par->table) != 0) {
-		printk("%s_tables: %s target: only valid in %s table, not %s\n",
+		pr_err("%s_tables: %s target: only valid in %s table, not %s\n",
 		       xt_prefix[par->family], par->target->name,
 		       par->target->table, par->table);
 		return -EINVAL;
@@ -529,7 +529,7 @@ int xt_check_target(struct xt_tgchk_param *par,
 	if (par->target->hooks && (par->hook_mask & ~par->target->hooks) != 0) {
 		char used[64], allow[64];
 
-		printk("%s_tables: %s target: used from hooks %s, but only "
+		pr_err("%s_tables: %s target: used from hooks %s, but only "
 		       "usable from %s\n",
 		       xt_prefix[par->family], par->target->name,
 		       textify_hooks(used, sizeof(used), par->hook_mask),
@@ -537,7 +537,7 @@ int xt_check_target(struct xt_tgchk_param *par,
 		return -EINVAL;
 	}
 	if (par->target->proto && (par->target->proto != proto || inv_proto)) {
-		printk("%s_tables: %s target: only valid for protocol %u\n",
+		pr_err("%s_tables: %s target: only valid for protocol %u\n",
 		       xt_prefix[par->family], par->target->name,
 		       par->target->proto);
 		return -EINVAL;
