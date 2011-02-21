From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 6/9] ax88796: remove platform_device member from struct ax_device
Date: Mon, 21 Feb 2011 14:03:17 +0100
Message-ID: <1298293400-21570-7-git-send-email-mkl@pengutronix.de>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35854 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075Ab1BUNDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:30 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/ax88796.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 1370cac..782d73e 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -87,7 +87,6 @@ struct ax_device {
 
 	u32 msg_enable;
 	void __iomem *map2;
-	struct platform_device *dev;
 	struct resource *mem;
 	struct resource *mem2;
 	struct ax_plat_data *plat;
@@ -545,11 +544,11 @@ static int ax_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 static void ax_get_drvinfo(struct net_device *dev,
 			   struct ethtool_drvinfo *info)
 {
-	struct ax_device *ax = to_ax_dev(dev);
+	struct platform_device *pdev = to_platform_device(dev->dev.parent);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
-	strcpy(info->bus_info, ax->dev->name);
+	strcpy(info->bus_info, pdev->name);
 }
 
 static int ax_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -848,7 +847,6 @@ static int ax_probe(struct platform_device *pdev)
 
 	spin_lock_init(&ax->mii_lock);
 
-	ax->dev = pdev;
 	ax->plat = pdev->dev.platform_data;
 	platform_set_drvdata(pdev, dev);
 
-- 
1.7.2.3

