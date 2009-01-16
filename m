From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH] PS3: gelic: convert to net_device_ops
Date: Fri, 16 Jan 2009 13:57:15 +0900
Message-ID: <20090116134050.0B5B.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Geoff Levand <geoffrey.levand@am.sony.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms14-1.Sony.CO.JP ([211.125.136.232]:34944 "EHLO
	ms14.sony.co.jp" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752478AbZAPFdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 00:33:49 -0500
Received: from ms4.sony.co.jp (ms4.Sony.CO.JP [211.125.136.198])
 by ms14.sony.co.jp (R8/Sony) with ESMTP id n0G4xcJS020809
 for <netdev@vger.kernel.org>; Fri, 16 Jan 2009 13:59:38 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the gelic driver to net_device_ops

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1403,6 +1403,18 @@ void gelic_net_tx_timeout(struct net_dev
 		atomic_dec(&card->tx_timeout_task_counter);
 }
 
+static const struct net_device_ops gelic_netdevice_ops = {
+	.ndo_open = gelic_net_open,
+	.ndo_stop = gelic_net_stop,
+	.ndo_start_xmit = gelic_net_xmit,
+	.ndo_set_multicast_list = gelic_net_set_multi,
+	.ndo_change_mtu = gelic_net_change_mtu,
+	.ndo_tx_timeout = gelic_net_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = gelic_net_poll_controller,
+#endif
+};
+
 /**
  * gelic_ether_setup_netdev_ops - initialization of net_device operations
  * @netdev: net_device structure
@@ -1412,21 +1424,12 @@ void gelic_net_tx_timeout(struct net_dev
 static void gelic_ether_setup_netdev_ops(struct net_device *netdev,
 					 struct napi_struct *napi)
 {
-	netdev->open = &gelic_net_open;
-	netdev->stop = &gelic_net_stop;
-	netdev->hard_start_xmit = &gelic_net_xmit;
-	netdev->set_multicast_list = &gelic_net_set_multi;
-	netdev->change_mtu = &gelic_net_change_mtu;
-	/* tx watchdog */
-	netdev->tx_timeout = &gelic_net_tx_timeout;
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
 	/* NAPI */
 	netif_napi_add(netdev, napi,
 		       gelic_net_poll, GELIC_NET_NAPI_WEIGHT);
 	netdev->ethtool_ops = &gelic_ether_ethtool_ops;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = gelic_net_poll_controller;
-#endif
+	netdev->netdev_ops = &gelic_netdevice_ops;
 }
 
 /**

-- 
Masakazu Mokuno

