From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] neigh: use NEIGH_VAR_INIT in ndo_neigh_setup functions.
Date: Thu,  9 Jan 2014 14:13:47 +0100
Message-ID: <1389273227-17532-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jes@trained-monkey.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:65276 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbaAINNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 08:13:55 -0500
Received: by mail-ea0-f178.google.com with SMTP id d10so1445477eaj.37
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 05:13:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ndo_neigh_setup is called, the bitfield used by NEIGH_VAR_SET is
not initialized yet. This might cause confusion for the people who use
NEIGH_VAR_SET in ndo_neigh_setup. So rather introduce NEIGH_VAR_INIT for
usage in ndo_neigh_setup.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/neighbour.h | 5 +++++
 net/802/hippi.c         | 4 ++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 4c09bd2..7277caf 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -92,6 +92,11 @@ static inline void neigh_var_set(struct neigh_parms *p, int index, int val)
 }
 
 #define NEIGH_VAR(p, attr) ((p)->data[NEIGH_VAR_ ## attr])
+
+/* In ndo_neigh_setup, NEIGH_VAR_INIT should be used.
+ * In other cases, NEIGH_VAR_SET should be used.
+ */
+#define NEIGH_VAR_INIT(p, attr, val) (NEIGH_VAR(p, attr) = val)
 #define NEIGH_VAR_SET(p, attr, val) neigh_var_set(p, NEIGH_VAR_ ## attr, val)
 
 static inline void neigh_parms_data_state_setall(struct neigh_parms *p)
diff --git a/net/802/hippi.c b/net/802/hippi.c
index a97a3bd..5ff2a71 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -172,14 +172,14 @@ EXPORT_SYMBOL(hippi_mac_addr);
 int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
 {
 	/* Never send broadcast/multicast ARP messages */
-	NEIGH_VAR_SET(p, MCAST_PROBES, 0);
+	NEIGH_VAR_INIT(p, MCAST_PROBES, 0);
 
 	/* In IPv6 unicast probes are valid even on NBMA,
 	* because they are encapsulated in normal IPv6 protocol.
 	* Should be a generic flag.
 	*/
 	if (p->tbl->family != AF_INET6)
-		NEIGH_VAR_SET(p, UCAST_PROBES, 0);
+		NEIGH_VAR_INIT(p, UCAST_PROBES, 0);
 	return 0;
 }
 EXPORT_SYMBOL(hippi_neigh_setup_dev);
-- 
1.8.3.1
