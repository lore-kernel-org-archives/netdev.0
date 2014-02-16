From: Ilia Mirkin <imirkin@alum.mit.edu>
Subject: [PATCH] netfilter: ipset: move registration message to init from net_init
Date: Sun, 16 Feb 2014 03:01:40 -0500
Message-ID: <1392537700-7002-1-git-send-email-imirkin@alum.mit.edu>
Cc: Florian Westphal <fw@strlen.de>, Ilia Mirkin <imirkin@alum.mit.edu>
To: netdev@vger.kernel.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:61665 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbaBPIBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 03:01:46 -0500
Received: by mail-qc0-f179.google.com with SMTP id e16so22075278qcx.38
        for <netdev@vger.kernel.org>; Sun, 16 Feb 2014 00:01:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1785e8f473 ("netfiler: ipset: Add net namespace for ipset") moved
the initialization print into net_init, which can get called a lot due
to namespaces. Move it back into init, reduce to pr_info.

Signed-off-by: Ilia Mirkin <imirkin@alum.mit.edu>
---

The description is based on my meager understanding of what's going on. Feel
free to adjust it to match reality.

 net/netfilter/ipset/ip_set_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index bac7e01..0fa2d9c 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1973,7 +1973,6 @@ ip_set_net_init(struct net *net)
 		return -ENOMEM;
 	inst->is_deleted = 0;
 	rcu_assign_pointer(inst->ip_set_list, list);
-	pr_notice("ip_set: protocol %u\n", IPSET_PROTOCOL);
 	return 0;
 }
 
@@ -2024,6 +2023,7 @@ ip_set_init(void)
 		nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
 		return ret;
 	}
+	pr_info("ip_set: protocol %u\n", IPSET_PROTOCOL);
 	return 0;
 }
 
-- 
1.8.3.2
