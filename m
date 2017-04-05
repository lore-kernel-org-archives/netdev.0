From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH] net: phy: broadcom: Add support for the BCM54210E
Date: Wed,  5 Apr 2017 15:03:04 +0930
Message-ID: <20170405053304.30246-1-joel@jms.id.au>
Cc: Jon Mason <jon.mason@broadcom.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This device is a single-port RGMII 10/100/1000BASE-T PHY with EEE & WOL.

Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/phy/broadcom.c | 13 +++++++++++++
 include/linux/brcmphy.h    |  2 ++
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 9cd8b27d1292..3df826323129 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -703,6 +703,18 @@ static struct phy_driver broadcom_drivers[] = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= brcm_fet_ack_interrupt,
 	.config_intr	= brcm_fet_config_intr,
+}, {
+	.phy_id         = PHY_ID_BCM54210E,
+	.phy_id_mask    = 0xfffffff0,
+	.name           = "Broadcom BCM54210E",
+	.features       = PHY_GBIT_FEATURES |
+				SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags          = PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init    = bcm54xx_config_init,
+	.config_aneg    = genphy_config_aneg,
+	.read_status    = genphy_read_status,
+	.ack_interrupt  = bcm_phy_ack_intr,
+	.config_intr    = bcm_phy_config_intr,
 } };
 
 module_phy_driver(broadcom_drivers);
@@ -723,6 +735,7 @@ static struct mdio_device_id __maybe_unused broadcom_tbl[] = {
 	{ PHY_ID_BCM57780, 0xfffffff0 },
 	{ PHY_ID_BCMAC131, 0xfffffff0 },
 	{ PHY_ID_BCM5241, 0xfffffff0 },
+	{ PHY_ID_BCM54210E, 0xfffffff0},
 	{ }
 };
 
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 55e517130311..53106b9c89f1 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -40,6 +40,8 @@
 
 #define PHY_ID_BCM_CYGNUS		0xae025200
 
+#define PHY_ID_BCM54210E		0x600d84a0
+
 #define PHY_BCM_OUI_MASK		0xfffffc00
 #define PHY_BCM_OUI_1			0x00206000
 #define PHY_BCM_OUI_2			0x0143bc00
-- 
2.11.0
