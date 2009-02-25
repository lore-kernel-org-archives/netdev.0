From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/4] mv643xx_eth: convert to net_device_ops
Date: Wed, 25 Feb 2009 02:41:40 +0100
Message-ID: <20090225014140.GX17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53057 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234AbZBYBln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:41:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 5736dcd..b711404 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2862,6 +2862,21 @@ static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
 	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 }
 
+static const struct net_device_ops mv643xx_eth_netdev_ops = {
+	.ndo_open		= mv643xx_eth_open,
+	.ndo_stop		= mv643xx_eth_stop,
+	.ndo_start_xmit		= mv643xx_eth_xmit,
+	.ndo_set_rx_mode	= mv643xx_eth_set_rx_mode,
+	.ndo_set_mac_address	= mv643xx_eth_set_mac_address,
+	.ndo_do_ioctl		= mv643xx_eth_ioctl,
+	.ndo_change_mtu		= mv643xx_eth_change_mtu,
+	.ndo_tx_timeout		= mv643xx_eth_tx_timeout,
+	.ndo_get_stats		= mv643xx_eth_get_stats,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= mv643xx_eth_netpoll,
+#endif
+};
+
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
@@ -2933,18 +2948,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	BUG_ON(!res);
 	dev->irq = res->start;
 
-	dev->get_stats = mv643xx_eth_get_stats;
-	dev->hard_start_xmit = mv643xx_eth_xmit;
-	dev->open = mv643xx_eth_open;
-	dev->stop = mv643xx_eth_stop;
-	dev->set_rx_mode = mv643xx_eth_set_rx_mode;
-	dev->set_mac_address = mv643xx_eth_set_mac_address;
-	dev->do_ioctl = mv643xx_eth_ioctl;
-	dev->change_mtu = mv643xx_eth_change_mtu;
-	dev->tx_timeout = mv643xx_eth_tx_timeout;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = mv643xx_eth_netpoll;
-#endif
+	dev->netdev_ops = &mv643xx_eth_netdev_ops;
+
 	dev->watchdog_timeo = 2 * HZ;
 	dev->base_addr = 0;
 
-- 
1.5.6.4
