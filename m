From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: phy: bcm7xxx: fix spurious MDIO failures during workaround
Date: Fri, 14 Mar 2014 16:09:04 -0700
Message-ID: <1394838545-7746-2-git-send-email-f.fainelli@gmail.com>
References: <1394838545-7746-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:64686 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470AbaCNXJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 19:09:18 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so3307793iec.10
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 16:09:18 -0700 (PDT)
In-Reply-To: <1394838545-7746-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Writing first to the AFE registers, and then the VCO, RCAL, RC_CAL
registers turned out to unveil some spurious MDIO read/write failures
which would make the workaround partially applied. The fix is to write
first to the VCO, RCAL, RC_CAL registers, and then write to the AFE
registers.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 697337220016..07d719d6cc3c 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -87,21 +87,6 @@ static void phy_write_misc(struct phy_device *phydev,
 
 static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
 {
-	/* write AFE_RXCONFIG_0 */
-	phy_write_misc(phydev, 0x38, 0x0000, 0xeb19);
-
-	/* write AFE_RXCONFIG_1 */
-	phy_write_misc(phydev, 0x38, 0x0001, 0x9a3f);
-
-	/* write AFE_RX_LP_COUNTER */
-	phy_write_misc(phydev, 0x38, 0x0003, 0x7fc7);
-
-	/* write AFE_HPF_TRIM_OTHERS */
-	phy_write_misc(phydev, 0x3A, 0x0000, 0x000b);
-
-	/* write AFTE_TX_CONFIG */
-	phy_write_misc(phydev, 0x39, 0x0000, 0x0800);
-
 	/* Increase VCO range to prevent unlocking problem of PLL at low
 	 * temp
 	 */
@@ -127,6 +112,22 @@ static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
 	/* Disable Reset R_CAL/RC_CAL Engine */
 	phy_write_exp(phydev, 0x00b0, 0x0000);
 
+	/* write AFE_RXCONFIG_0 */
+	phy_write_misc(phydev, 0x38, 0x0000, 0xeb19);
+
+	/* write AFE_RXCONFIG_1 */
+	phy_write_misc(phydev, 0x38, 0x0001, 0x9a3f);
+
+	/* write AFE_RX_LP_COUNTER */
+	phy_write_misc(phydev, 0x38, 0x0003, 0x7fc7);
+
+	/* write AFE_HPF_TRIM_OTHERS */
+	phy_write_misc(phydev, 0x3A, 0x0000, 0x000b);
+
+	/* write AFTE_TX_CONFIG */
+	phy_write_misc(phydev, 0x39, 0x0000, 0x0800);
+
+
 	return 0;
 }
 
-- 
1.8.3.2
