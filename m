From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/3] net: phy: bcm7xxx: define constants for our registers
Date: Mon, 24 Mar 2014 16:36:47 -0700
Message-ID: <1395704209-30019-2-git-send-email-f.fainelli@gmail.com>
References: <1395704209-30019-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:64112 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbaCXXhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 19:37:03 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl14so6138771pab.18
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 16:37:02 -0700 (PDT)
In-Reply-To: <1395704209-30019-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define constants for the various registers used in
bcm7xxx_28nm_afe_config_init() to help clarify what this workaround is
about.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 697337220016..314194179168 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -28,6 +28,22 @@
 #define MII_BCM7XXX_TEST		0x1f
 #define  MII_BCM7XXX_SHD_MODE_2		BIT(2)
 
+/* 28nm only register definitions */
+#define MISC_ADDR(base, channel)	base, channel
+
+#define DSP_TAP10			MISC_ADDR(0x0a, 0)
+#define PLL_PLLCTRL_1			MISC_ADDR(0x32, 1)
+#define PLL_PLLCTRL_2			MISC_ADDR(0x32, 2)
+#define PLL_PLLCTRL_4			MISC_ADDR(0x33, 0)
+
+#define AFE_RXCONFIG_0			MISC_ADDR(0x38, 0)
+#define AFE_RXCONFIG_1			MISC_ADDR(0x38, 1)
+#define AFE_RX_LP_COUNTER		MISC_ADDR(0x38, 3)
+#define AFE_TX_CONFIG			MISC_ADDR(0x39, 0)
+#define AFE_HPF_TRIM_OTHERS		MISC_ADDR(0x3a, 0)
+
+#define CORE_EXPB0			0xb0
+
 static int bcm7445_config_init(struct phy_device *phydev)
 {
 	int ret;
@@ -88,44 +104,44 @@ static void phy_write_misc(struct phy_device *phydev,
 static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
 {
 	/* write AFE_RXCONFIG_0 */
-	phy_write_misc(phydev, 0x38, 0x0000, 0xeb19);
+	phy_write_misc(phydev, AFE_RXCONFIG_0, 0xeb19);
 
 	/* write AFE_RXCONFIG_1 */
-	phy_write_misc(phydev, 0x38, 0x0001, 0x9a3f);
+	phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9a3f);
 
 	/* write AFE_RX_LP_COUNTER */
-	phy_write_misc(phydev, 0x38, 0x0003, 0x7fc7);
+	phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc7);
 
 	/* write AFE_HPF_TRIM_OTHERS */
-	phy_write_misc(phydev, 0x3A, 0x0000, 0x000b);
+	phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x000b);
 
 	/* write AFTE_TX_CONFIG */
-	phy_write_misc(phydev, 0x39, 0x0000, 0x0800);
+	phy_write_misc(phydev, AFE_TX_CONFIG, 0x0800);
 
 	/* Increase VCO range to prevent unlocking problem of PLL at low
 	 * temp
 	 */
-	phy_write_misc(phydev, 0x0032, 0x0001, 0x0048);
+	phy_write_misc(phydev, PLL_PLLCTRL_1, 0x0048);
 
 	/* Change Ki to 011 */
-	phy_write_misc(phydev, 0x0032, 0x0002, 0x021b);
+	phy_write_misc(phydev, PLL_PLLCTRL_2, 0x021b);
 
 	/* Disable loading of TVCO buffer to bandgap, set bandgap trim
 	 * to 111
 	 */
-	phy_write_misc(phydev, 0x0033, 0x0000, 0x0e20);
+	phy_write_misc(phydev, PLL_PLLCTRL_4, 0x0e20);
 
 	/* Adjust bias current trim by -3 */
-	phy_write_misc(phydev, 0x000a, 0x0000, 0x690b);
+	phy_write_misc(phydev, DSP_TAP10, 0x690b);
 
 	/* Switch to CORE_BASE1E */
 	phy_write(phydev, MII_BCM7XXX_CORE_BASE1E, 0xd);
 
 	/* Reset R_CAL/RC_CAL Engine */
-	phy_write_exp(phydev, 0x00b0, 0x0010);
+	phy_write_exp(phydev, CORE_EXPB0, 0x0010);
 
 	/* Disable Reset R_CAL/RC_CAL Engine */
-	phy_write_exp(phydev, 0x00b0, 0x0000);
+	phy_write_exp(phydev, CORE_EXPB0, 0x0000);
 
 	return 0;
 }
-- 
1.8.3.2
