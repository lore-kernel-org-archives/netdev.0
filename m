From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 09/11] can: at91_can: register mb0 sysfs entry only on at91sam9263
Date: Mon,  6 Jun 2011 15:42:58 +0200
Message-ID: <1307367780-30715-10-git-send-email-mkl@pengutronix.de>
References: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48440 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756963Ab1FFNnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 09:43:11 -0400
In-Reply-To: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares the driver for the at91sam9X5 processors,
which don't have the mb0 bug.
(See commit 3a5655a5b545e9647c3437473ee3d815fe1b9050 for more details.)

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 248e03f..2b97281 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1257,7 +1257,6 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 	dev->netdev_ops	= &at91_netdev_ops;
 	dev->irq = irq;
 	dev->flags |= IFF_ECHO;
-	dev->sysfs_groups[0] = &at91_sysfs_attr_group;
 
 	priv = netdev_priv(dev);
 	priv->can.clock.freq = clk_get_rate(clk);
@@ -1275,6 +1274,9 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 
 	netif_napi_add(dev, &priv->napi, at91_poll, get_mb_rx_num(priv));
 
+	if (at91_is_sam9263(priv))
+		dev->sysfs_groups[0] = &at91_sysfs_attr_group;
+
 	dev_set_drvdata(&pdev->dev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-- 
1.7.4.1

