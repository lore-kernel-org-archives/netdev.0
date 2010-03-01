From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6] bridge: Fix build error when IGMP_SNOOPING is
 not enabled
Date: Mon, 01 Mar 2010 11:53:04 -0800
Message-ID: <1267473184.31728.7.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:32987 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab0CATxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 14:53:14 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o21JnkH1031448
	for <netdev@vger.kernel.org>; Mon, 1 Mar 2010 12:49:46 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o21Jr50u072570
	for <netdev@vger.kernel.org>; Mon, 1 Mar 2010 12:53:08 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o21JtRYt020111
	for <netdev@vger.kernel.org>; Mon, 1 Mar 2010 12:55:27 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following build error when IGMP_SNOOPING is not enabled.
In file included from net/bridge/br.c:24:
net/bridge/br_private.h: In function 'br_multicast_is_router':
net/bridge/br_private.h:361: error: 'struct net_bridge' has no member named 'multicast_router'
net/bridge/br_private.h:362: error: 'struct net_bridge' has no member named 'multicast_router'
net/bridge/br_private.h:363: error: 'struct net_bridge' has no member named 'multicast_router_timer'

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 9191198..1cf2cef 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -302,6 +302,13 @@ extern int br_multicast_set_port_router(struct net_bridge_port *p,
 					unsigned long val);
 extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
+
+static inline bool br_multicast_is_router(struct net_bridge *br)
+{
+	return br->multicast_router == 2 ||
+	       (br->multicast_router == 1 &&
+		timer_pending(&br->multicast_router_timer));
+}
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
 				   struct net_bridge_port *port,
@@ -354,14 +361,11 @@ static inline void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
 					struct sk_buff *skb2)
 {
 }
-#endif
-
 static inline bool br_multicast_is_router(struct net_bridge *br)
 {
-	return br->multicast_router == 2 ||
-	       (br->multicast_router == 1 &&
-		timer_pending(&br->multicast_router_timer));
+	return 0;
 }
+#endif
 
 /* br_netfilter.c */
 #ifdef CONFIG_BRIDGE_NETFILTER


