From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/5] net: phy: bcm7xxx: introduce r_rc_cal_reset helper
Date: Tue, 11 Nov 2014 14:55:12 -0800
Message-ID: <1415746514-11189-4-git-send-email-f.fainelli@gmail.com>
References: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:41743 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbaKKWzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 17:55:23 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so11613880pad.29
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 14:55:23 -0800 (PST)
In-Reply-To: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function performs a R/RC calibration reset and will start being
used by more than one function in the next patches, create a helper
function to factor code.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 417e16c618fa..82824dde7f5f 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -69,6 +69,15 @@ static void phy_write_misc(struct phy_device *phydev,
 	phy_write(phydev, MII_BCM54XX_EXP_DATA, value);
 }
 
+static void r_rc_cal_reset(struct phy_device *phydev)
+{
+	/* Reset R_CAL/RC_CAL Engine */
+	phy_write_exp(phydev, 0x00b0, 0x0010);
+
+	/* Disable Reset R_AL/RC_CAL Engine */
+	phy_write_exp(phydev, 0x00b0, 0x0000);
+}
+
 static int bcm7xxx_28nm_b0_afe_config_init(struct phy_device *phydev)
 {
 	/* Increase VCO range to prevent unlocking problem of PLL at low
@@ -90,11 +99,7 @@ static int bcm7xxx_28nm_b0_afe_config_init(struct phy_device *phydev)
 	/* Switch to CORE_BASE1E */
 	phy_write(phydev, MII_BCM7XXX_CORE_BASE1E, 0xd);
 
-	/* Reset R_CAL/RC_CAL Engine */
-	phy_write_exp(phydev, CORE_EXPB0, 0x0010);
-
-	/* Disable Reset R_CAL/RC_CAL Engine */
-	phy_write_exp(phydev, CORE_EXPB0, 0x0000);
+	r_rc_cal_reset(phydev);
 
 	/* write AFE_RXCONFIG_0 */
 	phy_write_misc(phydev, AFE_RXCONFIG_0, 0xeb19);
-- 
1.9.1
