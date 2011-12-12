From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH 1/1] net/fec: add KSZ9021RN phy fixup
Date: Mon, 12 Dec 2011 18:09:18 +0800
Message-ID: <1323684558-16796-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
	<shawn.guo@linaro.org>, <jgq516@gmail.com>, <eric.miao@linaro.org>,
	<patches@linaro.org>, Richard Zhao <richard.zhao@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:27950 "EHLO
	TX2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab1LLKJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 05:09:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For imx6q sabrelite board, set phy RGMII pad skew.

Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 112af9b..d3b4463 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1513,6 +1513,21 @@ static inline void fec_reset_phy(struct platform_device *pdev)
 }
 #endif /* CONFIG_OF */
 
+/* For imx6q sabrelite board: set KSZ9021RN RGMII pad skew */
+static int ksz9021rn_phy_fixup(struct phy_device *phydev)
+{
+	/* min rx data delay */
+	phy_write(phydev, 0x0b, 0x8105);
+	phy_write(phydev, 0x0c, 0x0000);
+
+	/* max rx/tx clock delay, min rx/tx control delay */
+	phy_write(phydev, 0x0b, 0x8104);
+	phy_write(phydev, 0x0c, 0xf0f0);
+	phy_write(phydev, 0x0b, 0x104);
+
+	return 0;
+}
+
 static int __devinit
 fec_probe(struct platform_device *pdev)
 {
@@ -1597,6 +1612,10 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_init;
 
+	/* register the PHY board fixup (for Micrel KSZ9021RN) */
+	phy_register_fixup_for_uid(0x00221611, 0xfffffff0,
+					 ksz9021rn_phy_fixup);
+
 	ret = fec_enet_mii_init(pdev);
 	if (ret)
 		goto failed_mii_init;
-- 
1.7.5.4
