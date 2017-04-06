From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 07/19] batman-adv: Omit unnecessary memset of netdev private data
Date: Thu,  6 Apr 2017 16:07:29 +0200
Message-ID: <20170406140741.30745-8-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Tobias Klauser <tklauser@distanz.ch>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32940 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935014AbdDFOHs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:48 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

The memory for netdev_priv is allocated using kzalloc in alloc_netdev
(or alloc_netdev_mq respectively) so there is no need to set it to 0
again.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/soft-interface.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 5d099b2e6cfc..8226495c6664 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -972,8 +972,6 @@ static void batadv_softif_free(struct net_device *dev)
  */
 static void batadv_softif_init_early(struct net_device *dev)
 {
-	struct batadv_priv *priv = netdev_priv(dev);
-
 	ether_setup(dev);
 
 	dev->netdev_ops = &batadv_netdev_ops;
@@ -990,8 +988,6 @@ static void batadv_softif_init_early(struct net_device *dev)
 	eth_hw_addr_random(dev);
 
 	dev->ethtool_ops = &batadv_ethtool_ops;
-
-	memset(priv, 0, sizeof(*priv));
 }
 
 struct net_device *batadv_softif_create(struct net *net, const char *name)
-- 
2.11.0
