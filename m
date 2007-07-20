From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 5/10] ps3: removed conditional ethtool support
Date: Fri, 20 Jul 2007 17:28:59 +0900
Message-ID: <20070720172733.6795.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW3.Sony.CO.JP ([137.153.0.15]:49540 "EHLO mgw3.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936378AbXGTI3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:29:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed conditional ethtool support.  Always enabled.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |    4 ----
 drivers/net/ps3_gelic_net.h |    2 --
 2 files changed, 6 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1160,7 +1160,6 @@ alloc_tx_failed:
 	return -ENOMEM;
 }
 
-#ifdef GELIC_NET_ETHTOOL
 static void gelic_net_get_drvinfo (struct net_device *netdev,
 				   struct ethtool_drvinfo *info)
 {
@@ -1280,7 +1279,6 @@ static struct ethtool_ops gelic_net_etht
 	.get_rx_csum	= gelic_net_get_rx_csum,
 	.set_rx_csum	= gelic_net_set_rx_csum,
 };
-#endif
 
 /**
  * gelic_net_tx_timeout_task - task scheduled by the watchdog timeout
@@ -1348,9 +1346,7 @@ static void gelic_net_setup_netdev_ops(s
 	/* NAPI */
 	netdev->poll = &gelic_net_poll;
 	netdev->weight = GELIC_NET_NAPI_WEIGHT;
-#ifdef GELIC_NET_ETHTOOL
 	netdev->ethtool_ops = &gelic_net_ethtool_ops;
-#endif
 }
 
 /**
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -28,8 +28,6 @@
 #ifndef _GELIC_NET_H
 #define _GELIC_NET_H
 
-#define GELIC_NET_ETHTOOL               /* use ethtool */
-
 /* descriptors */
 #define GELIC_NET_RX_DESCRIPTORS        128 /* num of descriptors */
 #define GELIC_NET_TX_DESCRIPTORS        128 /* num of descriptors */

--
Masakazu MOKUNO

