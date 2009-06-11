From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] x_tables: Convert printk to pr_err
Date: Thu, 11 Jun 2009 00:40:20 -0700
Message-ID: <cf0a2bad458fe3c9f989ca6db04b5a7f8367e1a7.1244705154.git.joe@perches.com>
References: <cover.1244705154.git.joe@perches.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3301 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569AbZFKHk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 03:40:29 -0400
In-Reply-To: <cover.1244705154.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/x_tables.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

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
-- 
1.6.3.1.10.g659a0.dirty

