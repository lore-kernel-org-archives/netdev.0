From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/13]: netdev: Convert all drivers away from
 netif_schedule().
Date: Thu, 10 Jul 2008 03:57:20 -0700 (PDT)
Message-ID: <20080710.035720.82564592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60727
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754592AbYGJK5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:57:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 62A7EC8C17F
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:57:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


They logically all want to trigger a schedule for all device
TX queues.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/au1000_eth.c           |    2 +-
 drivers/net/bfin_mac.c             |    2 +-
 drivers/net/fec_mpc52xx.c          |    2 +-
 drivers/net/fs_enet/fs_enet-main.c |    2 +-
 drivers/net/gianfar.c              |    4 ++--
 drivers/net/macb.c                 |    2 +-
 drivers/net/sh_eth.c               |    2 +-
 drivers/net/tc35815.c              |    2 +-
 drivers/net/ucc_geth.c             |    4 ++--
 9 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 7023d77..3ab61e4 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -912,7 +912,7 @@ au1000_adjust_link(struct net_device *dev)
 		// link state changed
 
 		if (phydev->link) // link went up
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 		else { // link went down
 			aup->old_speed = 0;
 			aup->old_duplex = -1;
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 4144343..a6a3da8 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -357,7 +357,7 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 		if (!lp->old_link) {
 			new_state = 1;
 			lp->old_link = 1;
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 		}
 	} else if (lp->old_link) {
 		new_state = 1;
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 329edd9..ae9ecb7 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -197,7 +197,7 @@ static void mpc52xx_fec_adjust_link(struct net_device *dev)
 		if (priv->link == PHY_DOWN) {
 			new_state = 1;
 			priv->link = phydev->link;
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 			netif_carrier_on(dev);
 			netif_start_queue(dev);
 		}
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index fb7c477..bdb81f5 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -738,7 +738,7 @@ static void generic_adjust_link(struct  net_device *dev)
 		if (!fep->oldlink) {
 			new_state = 1;
 			fep->oldlink = 1;
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 			netif_carrier_on(dev);
 			netif_start_queue(dev);
 		}
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 393a0f1..7e627bd 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1259,7 +1259,7 @@ static void gfar_timeout(struct net_device *dev)
 		startup_gfar(dev);
 	}
 
-	netif_schedule(dev);
+	netif_tx_schedule_all(dev);
 }
 
 /* Interrupt Handler for Transmit complete */
@@ -1784,7 +1784,7 @@ static void adjust_link(struct net_device *dev)
 		if (!priv->oldlink) {
 			new_state = 1;
 			priv->oldlink = 1;
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 		}
 	} else if (priv->oldlink) {
 		new_state = 1;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index e346302..50688a5 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -165,7 +165,7 @@ static void macb_handle_link_change(struct net_device *dev)
 
 	if (phydev->link != bp->link) {
 		if (phydev->link)
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 		else {
 			bp->speed = 0;
 			bp->duplex = -1;
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 37f3116..a4bc812 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -642,7 +642,7 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 					| ECMR_DM, ioaddr + ECMR);
 			new_state = 1;
 			mdp->link = phydev->link;
-			netif_schedule(ndev);
+			netif_tx_schedule_all(ndev);
 			netif_carrier_on(ndev);
 			netif_start_queue(ndev);
 		}
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index b07b8cb..41d3ac4 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -672,7 +672,7 @@ static void tc_handle_link_change(struct net_device *dev)
 			if (dev->flags & IFF_PROMISC)
 				tc35815_set_multicast_list(dev);
 #endif
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 		} else {
 			lp->speed = 0;
 			lp->duplex = -1;
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index fb0b918..e2c598a 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1588,7 +1588,7 @@ static void adjust_link(struct net_device *dev)
 		if (!ugeth->oldlink) {
 			new_state = 1;
 			ugeth->oldlink = 1;
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 		}
 	} else if (ugeth->oldlink) {
 			new_state = 1;
@@ -3372,7 +3372,7 @@ static void ucc_geth_timeout(struct net_device *dev)
 		ucc_geth_startup(ugeth);
 	}
 
-	netif_schedule(dev);
+	netif_tx_schedule_all(dev);
 }
 
 /* This is called by the kernel when a frame is ready for transmission. */
-- 
1.5.6.2.255.gbed62

