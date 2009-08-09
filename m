From: Phil Sutter <n0-1@freewrt.org>
Subject: [PATCH 3/3] korina: convert to net_device_ops
Date: Sun,  9 Aug 2009 02:06:28 +0200
Message-ID: <20090809000650.2495F4CEAA@orbit.nwl.cc>
References: <20090808164512.02C174CEAA@orbit.nwl.cc>
 <1249776388-4626-1-git-send-email-n0-1@freewrt.org>
 <1249776388-4626-2-git-send-email-n0-1@freewrt.org>
 <1249776388-4626-3-git-send-email-n0-1@freewrt.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org,
	Roel Kluin <roel.kluin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:49794 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753365AbZHIAGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Aug 2009 20:06:49 -0400
In-Reply-To: <1249776388-4626-3-git-send-email-n0-1@freewrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <n0-1@freewrt.org>
---
 drivers/net/korina.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index d256022..894f686 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -1088,6 +1088,18 @@ static int korina_close(struct net_device *dev)
 	return 0;
 }
 
+static const struct net_device_ops korina_netdev_ops = {
+	.ndo_open               = korina_open,
+	.ndo_stop               = korina_close,
+	.ndo_start_xmit         = korina_send_packet,
+	.ndo_set_multicast_list = korina_multicast_list,
+	.ndo_tx_timeout         = korina_tx_timeout,
+	.ndo_do_ioctl           = korina_ioctl,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller    = korina_poll_controller,
+#endif
+};
+
 static int korina_probe(struct platform_device *pdev)
 {
 	struct korina_device *bif = platform_get_drvdata(pdev);
@@ -1156,17 +1168,10 @@ static int korina_probe(struct platform_device *pdev)
 	dev->irq = lp->rx_irq;
 	lp->dev = dev;
 
-	dev->open = korina_open;
-	dev->stop = korina_close;
-	dev->hard_start_xmit = korina_send_packet;
-	dev->set_multicast_list = &korina_multicast_list;
+	dev->netdev_ops = &korina_netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-	dev->tx_timeout = korina_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->do_ioctl = &korina_ioctl;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = korina_poll_controller;
-#endif
+
 	netif_napi_add(dev, &lp->napi, korina_poll, 64);
 
 	lp->phy_addr = (((lp->rx_irq == 0x2c? 1:0) << 8) | 0x05);
-- 
1.6.0.6

