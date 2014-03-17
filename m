From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/38] netfilter: ipset: move registration message to init from net_init
Date: Mon, 17 Mar 2014 13:42:36 +0100
Message-ID: <1395060178-11833-17-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59412 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933127AbaCQMng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:36 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilia Mirkin <imirkin@alum.mit.edu>

Commit 1785e8f473 ("netfiler: ipset: Add net namespace for ipset") moved
the initialization print into net_init, which can get called a lot due
to namespaces. Move it back into init, reduce to pr_info.

Signed-off-by: Ilia Mirkin <imirkin@alum.mit.edu>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index c6c97b8..636cb8d 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1945,7 +1945,6 @@ ip_set_net_init(struct net *net)
 		return -ENOMEM;
 	inst->is_deleted = 0;
 	rcu_assign_pointer(inst->ip_set_list, list);
-	pr_notice("ip_set: protocol %u\n", IPSET_PROTOCOL);
 	return 0;
 }
 
@@ -1996,6 +1995,7 @@ ip_set_init(void)
 		nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
 		return ret;
 	}
+	pr_info("ip_set: protocol %u\n", IPSET_PROTOCOL);
 	return 0;
 }
 
-- 
1.7.10.4
