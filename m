From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net v2] bridge: multicast: restore router configuration on port link down/up
Date: Fri, 19 Jun 2015 01:22:57 -0700
Message-ID: <1434702177-20887-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	herbert@gondor.apana.org.au, sashok@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36214 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341AbbFSIXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 04:23:17 -0400
Received: by pdjm12 with SMTP id m12so85746566pdj.3
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 01:23:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Ashok <sashok@cumulusnetworks.com>

When a port goes through a link down/up the multicast router configuration
is not restored.

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: 0909e11758bd ("bridge: Add multicast_router sysfs entries")
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
---
v2: Added the acked-by and sent as a separate patch. I plan to repurpose
    the second patch for net-next, they weren't dependent anyway.

 net/bridge/br_multicast.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index ff667e18b2d6..761fc733bf6d 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -37,6 +37,8 @@
 
 static void br_multicast_start_querier(struct net_bridge *br,
 				       struct bridge_mcast_own_query *query);
+static void br_multicast_add_router(struct net_bridge *br,
+				    struct net_bridge_port *port);
 unsigned int br_mdb_rehash_seq;
 
 static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
@@ -936,6 +938,8 @@ void br_multicast_enable_port(struct net_bridge_port *port)
 #if IS_ENABLED(CONFIG_IPV6)
 	br_multicast_enable(&port->ip6_own_query);
 #endif
+	if (port->multicast_router == 2 && hlist_unhashed(&port->rlist))
+		br_multicast_add_router(br, port);
 
 out:
 	spin_unlock(&br->multicast_lock);
-- 
1.7.10.4
