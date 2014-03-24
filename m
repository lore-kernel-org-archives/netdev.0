From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/3] net: phy: bcm7xxx: fix spurious MDIO failures during workaround
Date: Mon, 24 Mar 2014 16:36:48 -0700
Message-ID: <1395704209-30019-3-git-send-email-f.fainelli@gmail.com>
References: <1395704209-30019-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:56742 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737AbaCXXhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 19:37:04 -0400
Received: by mail-pa0-f43.google.com with SMTP id bj1so6122042pad.16
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 16:37:03 -0700 (PDT)
In-Reply-To: <1395704209-30019-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Writing first to the AFE registers, and then the VCO, RCAL, RC_CAL
registers turned out to unveil some spurious MDIO read/write failures
which would make the workaround partially applied. The fix is to write
first to the VCO, RCAL, RC_CAL registers, and then write to the AFE
registers.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
- Use named registers constants 

 drivers/net/phy/bcm7xxx.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 314194179168..5991168bcbef 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -103,21 +103,6 @@ static void phy_write_misc(struct phy_device *phydev,
 
 static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
 {
-	/* write AFE_RXCONFIG_0 */
-	phy_write_misc(phydev, AFE_RXCONFIG_0, 0xeb19);
-
-	/* write AFE_RXCONFIG_1 */
-	phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9a3f);
-
-	/* write AFE_RX_LP_COUNTER */
-	phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc7);
-
-	/* write AFE_HPF_TRIM_OTHERS */
-	phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x000b);
-
-	/* write AFTE_TX_CONFIG */
-	phy_write_misc(phydev, AFE_TX_CONFIG, 0x0800);
-
 	/* Increase VCO range to prevent unlocking problem of PLL at low
 	 * temp
 	 */
@@ -143,6 +128,21 @@ static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
 	/* Disable Reset R_CAL/RC_CAL Engine */
 	phy_write_exp(phydev, CORE_EXPB0, 0x0000);
 
+	/* write AFE_RXCONFIG_0 */
+	phy_write_misc(phydev, AFE_RXCONFIG_0, 0xeb19);
+
+	/* write AFE_RXCONFIG_1 */
+	phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9a3f);
+
+	/* write AFE_RX_LP_COUNTER */
+	phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc7);
+
+	/* write AFE_HPF_TRIM_OTHERS */
+	phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x000b);
+
+	/* write AFTE_TX_CONFIG */
+	phy_write_misc(phydev, AFE_TX_CONFIG, 0x0800);
+
 	return 0;
 }
 
-- 
1.8.3.2
