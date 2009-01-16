From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 1/2] PS3: gelic: convert the ethernet part to net_device_ops
Date: Fri, 16 Jan 2009 17:47:29 +0900
Message-ID: <20090116174555.0B6E.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Geoff Levand <geoffrey.levand@am.sony.com>
To: jgarzik@pobox.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms6.Sony.CO.JP ([211.125.136.204]:46603 "EHLO ms6.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756406AbZAPIrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2009 03:47:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the gelic driver to net_device_ops

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 V2: added setting for ndo_validate_addr

 drivers/net/ps3_gelic_net.c |   24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1403,6 +1403,19 @@ void gelic_net_tx_timeout(struct net_dev
 		atomic_dec(&card->tx_timeout_task_counter);
 }
 
+static const struct net_device_ops gelic_netdevice_ops = {
+	.ndo_open = gelic_net_open,
+	.ndo_stop = gelic_net_stop,
+	.ndo_start_xmit = gelic_net_xmit,
+	.ndo_set_multicast_list = gelic_net_set_multi,
+	.ndo_change_mtu = gelic_net_change_mtu,
+	.ndo_tx_timeout = gelic_net_tx_timeout,
+	.ndo_validate_addr = eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = gelic_net_poll_controller,
+#endif
+};
+
 /**
  * gelic_ether_setup_netdev_ops - initialization of net_device operations
  * @netdev: net_device structure
@@ -1412,21 +1425,12 @@ void gelic_net_tx_timeout(struct net_dev
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

