From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 1/7] gianfar: Remove unused device_node ref in gfar_private
Date: Thu, 14 Feb 2013 17:00:01 +0200
Message-ID: <1360854007-11094-2-git-send-email-claudiu.manoil@freescale.com>
References: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:8641
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754310Ab3BNPAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 10:00:16 -0500
In-Reply-To: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused device node pointer.
Remove duplicated SET_NETDEV_DEV().

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    4 ----
 drivers/net/ethernet/freescale/gianfar.h |    1 -
 2 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index c82f677..2c6b569 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -663,7 +663,6 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 		return -ENOMEM;
 
 	priv = netdev_priv(dev);
-	priv->node = ofdev->dev.of_node;
 	priv->ndev = dev;
 
 	priv->num_tx_queues = num_tx_qs;
@@ -1001,7 +1000,6 @@ static int gfar_probe(struct platform_device *ofdev)
 	priv = netdev_priv(dev);
 	priv->ndev = dev;
 	priv->ofdev = ofdev;
-	priv->node = ofdev->dev.of_node;
 	SET_NETDEV_DEV(dev, &ofdev->dev);
 
 	spin_lock_init(&priv->bflock);
@@ -1038,8 +1036,6 @@ static int gfar_probe(struct platform_device *ofdev)
 	/* Set the dev->base_addr to the gfar reg region */
 	dev->base_addr = (unsigned long) regs;
 
-	SET_NETDEV_DEV(dev, &ofdev->dev);
-
 	/* Fill in the dev structure */
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->mtu = 1500;
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 78125f1..8b4de57 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1060,7 +1060,6 @@ struct gfar_private {
 	unsigned int total_tx_ring_size;
 	unsigned int total_rx_ring_size;
 
-	struct device_node *node;
 	struct net_device *ndev;
 	struct platform_device *ofdev;
 	enum gfar_errata errata;
-- 
1.7.7.4
