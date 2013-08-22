From: <dinguyen@altera.com>
Subject: [PATCH] net/phy: Remove duplicate micrel phy defines
Date: Thu, 22 Aug 2013 16:01:54 -0500
Message-ID: <1377205314-16338-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dinh Nguyen <dinguyen@altera.com>, Sean Cross <xobs@kosagi.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <dinh.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:2205 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753595Ab3HVVBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 17:01:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

Commit <f275487fa phy: micrel: Add definitions for common Micrel PHY
registers>, that is currently in Shawn Guo for-next tree at:
http://git.linaro.org/git-ro/people/shawnguo/linux-2.6.git, has moved
a few of the Micrel PHY defines to include/linux/micrel_phy.h.

This commit removes the duplicate defines from commit:
<954c3967 net/phy: micrel: Add OF configuration support for ksz9021>.

It also moves a few defines to the include file.

Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
Cc: Sean Cross <xobs@kosagi.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/phy/micrel.c   |   26 +++++++-------------------
 include/linux/micrel_phy.h |    4 ++++
 2 files changed, 11 insertions(+), 19 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index c31aad0..6ddaa87 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -54,18 +54,6 @@
 #define KS8737_CTRL_INT_ACTIVE_HIGH		(1 << 14)
 #define KSZ8051_RMII_50MHZ_CLK			(1 << 7)
 
-/* Write/read to/from extended registers */
-#define MII_KSZPHY_EXTREG                       0x0b
-#define KSZPHY_EXTREG_WRITE                     0x8000
-
-#define MII_KSZPHY_EXTREG_WRITE                 0x0c
-#define MII_KSZPHY_EXTREG_READ                  0x0d
-
-/* Extended registers */
-#define MII_KSZPHY_CLK_CONTROL_PAD_SKEW         0x104
-#define MII_KSZPHY_RX_DATA_PAD_SKEW             0x105
-#define MII_KSZPHY_TX_DATA_PAD_SKEW             0x106
-
 #define PS_TO_REG				200
 
 static int ksz_config_flags(struct phy_device *phydev)
@@ -83,15 +71,15 @@ static int ksz_config_flags(struct phy_device *phydev)
 static int kszphy_extended_write(struct phy_device *phydev,
                                  u32 regnum, u16 val)
 {
-	phy_write(phydev, MII_KSZPHY_EXTREG, KSZPHY_EXTREG_WRITE | regnum);
-	return phy_write(phydev, MII_KSZPHY_EXTREG_WRITE, val);
+	phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL, KSZPHY_EXTREG_WRITE | regnum);
+	return phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, val);
 }
 
 static int kszphy_extended_read(struct phy_device *phydev,
                                  u32 regnum)
 {
-	phy_write(phydev, MII_KSZPHY_EXTREG, regnum);
-	return phy_read(phydev, MII_KSZPHY_EXTREG_READ);
+	phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL, regnum);
+	return phy_read(phydev, MICREL_KSZ9021_EXTREG_DATA_READ);
 }
 
 static int kszphy_ack_interrupt(struct phy_device *phydev)
@@ -227,15 +215,15 @@ static int ksz9021_config_init(struct phy_device *phydev)
 
 	if (of_node) {
 		ksz9021_load_values_from_of(phydev, of_node,
-				    MII_KSZPHY_CLK_CONTROL_PAD_SKEW,
+				    MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW,
 				    "txen-skew-ps", "txc-skew-ps",
 				    "rxdv-skew-ps", "rxc-skew-ps");
 		ksz9021_load_values_from_of(phydev, of_node,
-				    MII_KSZPHY_RX_DATA_PAD_SKEW,
+				    MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW,
 				    "rxd0-skew-ps", "rxd1-skew-ps",
 				    "rxd2-skew-ps", "rxd3-skew-ps");
 		ksz9021_load_values_from_of(phydev, of_node,
-				    MII_KSZPHY_TX_DATA_PAD_SKEW,
+				    MICREL_KSZ9021_RGMII_TX_DATA_PAD_SKEW,
 				    "txd0-skew-ps", "txd1-skew-ps",
 				    "txd2-skew-ps", "txd3-skew-ps");
 	}
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index ad05ce6..f9cf9bb 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -38,7 +38,11 @@
 
 #define MICREL_KSZ9021_EXTREG_CTRL	0xB
 #define MICREL_KSZ9021_EXTREG_DATA_WRITE	0xC
+#define MICREL_KSZ9021_EXTREG_DATA_READ		0xD
 #define MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW	0x104
 #define MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW	0x105
+#define MICREL_KSZ9021_RGMII_TX_DATA_PAD_SCEW   0x106
+
+#define KSZPHY_EXTREG_WRITE                     0x8000
 
 #endif /* _MICREL_PHY_H */
-- 
1.7.9.5
