From: Arun Parameswaran <arunp@broadcom.com>
Subject: [PATCH v2 5/5] net: phy: bcm7xxx: Modified to use global core register defines
Date: Wed, 30 Sep 2015 17:16:43 -0700
Message-ID: <1443658603-1848-6-git-send-email-arunp@broadcom.com>
References: <1443658603-1848-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>,
	Arun Parameswaran <arunp@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443658603-1848-1-git-send-email-arunp@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modified the bcm7xxx phy driver to remove local core register
defines and use the common ones from "include/linux/brcmphy.h"

Signed-off-by: Arun Parameswaran <arunp@broadcom.com>
---
 drivers/net/phy/bcm7xxx.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index efa31a6..03d4809 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -25,7 +25,6 @@
 #define MII_BCM7XXX_100TX_DISC		0x14
 #define MII_BCM7XXX_AUX_MODE		0x1d
 #define  MII_BCM7XX_64CLK_MDIO		BIT(12)
-#define MII_BCM7XXX_CORE_BASE1E		0x1e
 #define MII_BCM7XXX_TEST		0x1f
 #define  MII_BCM7XXX_SHD_MODE_2		BIT(2)
 
@@ -46,8 +45,6 @@
 #define AFE_VDAC_OTHERS_0		MISC_ADDR(0x39, 3)
 #define AFE_HPF_TRIM_OTHERS		MISC_ADDR(0x3a, 0)
 
-#define CORE_EXPB0			0xb0
-
 static void r_rc_cal_reset(struct phy_device *phydev)
 {
 	/* Reset R_CAL/RC_CAL Engine */
@@ -76,7 +73,7 @@ static int bcm7xxx_28nm_b0_afe_config_init(struct phy_device *phydev)
 	bcm_phy_write_misc(phydev, DSP_TAP10, 0x690b);
 
 	/* Switch to CORE_BASE1E */
-	phy_write(phydev, MII_BCM7XXX_CORE_BASE1E, 0xd);
+	phy_write(phydev, MII_BRCM_CORE_BASE1E, 0xd);
 
 	r_rc_cal_reset(phydev);
 
@@ -127,7 +124,7 @@ static int bcm7xxx_28nm_d0_afe_config_init(struct phy_device *phydev)
 	bcm_phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x00e3);
 
 	/* CORE_BASE1E, force trim to overwrite and set I_ext trim to 0000 */
-	phy_write(phydev, MII_BCM7XXX_CORE_BASE1E, 0x0010);
+	phy_write(phydev, MII_BRCM_CORE_BASE1E, 0x0010);
 
 	/* DSP_TAP10, adjust bias current trim (+0% swing, +0 tick) */
 	bcm_phy_write_misc(phydev, DSP_TAP10, 0x011b);
@@ -155,7 +152,7 @@ static int bcm7xxx_28nm_e0_plus_afe_config_init(struct phy_device *phydev)
 	bcm_phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x00e3);
 
 	/* CORE_BASE1E, force trim to overwrite and set I_ext trim to 0000 */
-	phy_write(phydev, MII_BCM7XXX_CORE_BASE1E, 0x0010);
+	phy_write(phydev, MII_BRCM_CORE_BASE1E, 0x0010);
 
 	/* DSP_TAP10, adjust bias current trim (+0% swing, +0 tick) */
 	bcm_phy_write_misc(phydev, DSP_TAP10, 0x011b);
-- 
2.5.2
