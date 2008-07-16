From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 08/10] mv643xx_eth: use symbolic MII register addresses and values
Date: Wed, 16 Jul 2008 12:32:53 +0200
Message-ID: <20080716103253.GI8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44740 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756635AbYGPKcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:32:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of hardcoding MII register addresses and values, use the
symbolic constants defined in linux/mii.h.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 9d20056..5bed6b3 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1831,14 +1831,14 @@ static void phy_reset(struct mv643xx_eth_private *mp)
 {
 	unsigned int data;
 
-	smi_reg_read(mp, mp->phy_addr, 0, &data);
-	data |= 0x8000;
-	smi_reg_write(mp, mp->phy_addr, 0, data);
+	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
+	data |= BMCR_RESET;
+	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data);
 
 	do {
 		udelay(1);
-		smi_reg_read(mp, mp->phy_addr, 0, &data);
-	} while (data & 0x8000);
+		smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
+	} while (data & BMCR_RESET);
 }
 
 static void port_start(struct mv643xx_eth_private *mp)
@@ -2385,14 +2385,14 @@ static int phy_detect(struct mv643xx_eth_private *mp)
 	unsigned int data;
 	unsigned int data2;
 
-	smi_reg_read(mp, mp->phy_addr, 0, &data);
-	smi_reg_write(mp, mp->phy_addr, 0, data ^ 0x1000);
+	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
+	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data ^ BMCR_ANENABLE);
 
-	smi_reg_read(mp, mp->phy_addr, 0, &data2);
-	if (((data ^ data2) & 0x1000) == 0)
+	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data2);
+	if (((data ^ data2) & BMCR_ANENABLE) == 0)
 		return -ENODEV;
 
-	smi_reg_write(mp, mp->phy_addr, 0, data);
+	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data);
 
 	return 0;
 }
-- 
1.5.3.4
