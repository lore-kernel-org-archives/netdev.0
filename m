From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 1/2] net: fec: refactor dt probing
Date: Mon, 21 Jan 2013 09:37:54 +0100
Message-ID: <1358757475-21035-2-git-send-email-s.hauer@pengutronix.de>
References: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, shawn.guo@linaro.org,
	davem@davemloft.net, Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55485 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329Ab3AUIiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 03:38:01 -0500
In-Reply-To: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For devicetree parsing only the fec_get_phy_mode_dt() is
available. Rename it to fec_probe_dt() to be able to add more devicetree
parsing to it.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 0704bca..2f86557 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1484,12 +1484,14 @@ static int fec_enet_init(struct net_device *ndev)
 }
 
 #ifdef CONFIG_OF
-static int fec_get_phy_mode_dt(struct platform_device *pdev)
+static int fec_probe_dt(struct fec_enet_private *fep)
 {
-	struct device_node *np = pdev->dev.of_node;
+	struct device_node *np = fep->pdev->dev.of_node;
 
-	if (np)
-		return of_get_phy_mode(np);
+	if (!np)
+		return -ENODEV;
+
+	fep->phy_interface = of_get_phy_mode(np);
 
 	return -ENODEV;
 }
@@ -1519,7 +1521,7 @@ static void fec_reset_phy(struct platform_device *pdev)
 	gpio_set_value(phy_reset, 1);
 }
 #else /* CONFIG_OF */
-static inline int fec_get_phy_mode_dt(struct platform_device *pdev)
+static inline int fec_probe_dt(struct fec_enet_private *fep)
 {
 	return -ENODEV;
 }
@@ -1581,15 +1583,13 @@ fec_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 
-	ret = fec_get_phy_mode_dt(pdev);
+	ret = fec_probe_dt(fep);
 	if (ret < 0) {
 		pdata = pdev->dev.platform_data;
 		if (pdata)
 			fep->phy_interface = pdata->phy;
 		else
 			fep->phy_interface = PHY_INTERFACE_MODE_MII;
-	} else {
-		fep->phy_interface = ret;
 	}
 
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
-- 
1.7.10.4
