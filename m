From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 54/62: xtables: print details on size mismatch
Date: Tue, 16 Feb 2010 15:56:32 +0100 (MET)
Message-ID: <20100216145630.2796.45691.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52107 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932781Ab0BPO4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:33 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b402405d71beed8e4df354844353f66b4e18269f
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Jun 25 18:32:12 2009 +0200

    netfilter: xtables: print details on size mismatch
    
    Print which revision has been used and which size are which
    (kernel/user) for easier debugging.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 255ab06..1250319 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -366,8 +366,10 @@ int xt_check_match(struct xt_mtchk_param *par,
 		 * ebt_among is exempt from centralized matchsize checking
 		 * because it uses a dynamic-size data set.
 		 */
-		pr_err("%s_tables: %s match: invalid size %u != %u\n",
+		pr_err("%s_tables: %s.%u match: invalid size "
+		       "%u (kernel) != (user) %u\n",
 		       xt_prefix[par->family], par->match->name,
+		       par->match->revision,
 		       XT_ALIGN(par->match->matchsize), size);
 		return -EINVAL;
 	}
@@ -516,8 +518,10 @@ int xt_check_target(struct xt_tgchk_param *par,
 		    unsigned int size, u_int8_t proto, bool inv_proto)
 {
 	if (XT_ALIGN(par->target->targetsize) != size) {
-		pr_err("%s_tables: %s target: invalid size %u != %u\n",
+		pr_err("%s_tables: %s.%u target: invalid size "
+		       "%u (kernel) != (user) %u\n",
 		       xt_prefix[par->family], par->target->name,
+		       par->target->revision,
 		       XT_ALIGN(par->target->targetsize), size);
 		return -EINVAL;
 	}
