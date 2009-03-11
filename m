From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC v2 1/7] net: sysctl_net - use net_eq to compare nets
Date: Wed, 11 Mar 2009 23:57:07 +0300
Message-ID: <20090311210817.001951599@gmail.com>
References: <20090311205706.141086138@gmail.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: kaber@trash.net, davem@davemloft.net, daniel.lezcano@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.185]:62190 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbZCKVI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 17:08:26 -0400
Content-Disposition: inline; filename=net-sysctl-net-use-net_eq
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 net/sysctl_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.git/net/sysctl_net.c
===================================================================
--- linux-2.6.git.orig/net/sysctl_net.c
+++ linux-2.6.git/net/sysctl_net.c
@@ -61,7 +61,7 @@ static struct ctl_table_root net_sysctl_
 static int net_ctl_ro_header_perms(struct ctl_table_root *root,
 		struct nsproxy *namespaces, struct ctl_table *table)
 {
-	if (namespaces->net_ns == &init_net)
+	if (net_eq(namespaces->net_ns, &init_net))
 		return table->mode;
 	else
 		return table->mode & ~0222;

