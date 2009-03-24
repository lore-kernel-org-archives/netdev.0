From: Patrick McHardy <kaber@trash.net>
Subject: net 33/41: sysctl_net - use net_eq to compare nets
Date: Tue, 24 Mar 2009 15:03:51 +0100 (MET)
Message-ID: <20090324140346.31401.83906.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34829 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758562AbZCXODx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:53 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 81a1d3c31e3517f9939b3e04d21cf4a6b0997419
Author: Cyrill Gorcunov <gorcunov@openvz.org>
Date:   Mon Mar 16 16:23:30 2009 +0100

    net: sysctl_net - use net_eq to compare nets
    
    Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
    Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 972201c..0b15d72 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -61,7 +61,7 @@ static struct ctl_table_root net_sysctl_root = {
 static int net_ctl_ro_header_perms(struct ctl_table_root *root,
 		struct nsproxy *namespaces, struct ctl_table *table)
 {
-	if (namespaces->net_ns == &init_net)
+	if (net_eq(namespaces->net_ns, &init_net))
 		return table->mode;
 	else
 		return table->mode & ~0222;
