From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 16/20] tg3 / broadcom: Refine AC131 APD support
Date: Mon, 2 Nov 2009 16:31:11 -0800
Message-ID: <1257212006.22028@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3562 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757621AbZKCBd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auto power-down (APD) support is a power-saving feature.  It should be
selectively enabled since it might expose MAC bugs.  This patch changes
the code to enable APD only if the PHY_BRCM_AUTO_PWRDWN_ENABLE flag is
set.  The tg3 driver was changed to set this bit.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |    8 +++++---
 drivers/net/tg3.c          |    1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 5d2a2e9..bddf4a4 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -561,9 +561,11 @@ static int brcm_fet_config_init(struct phy_device *phydev)
 	if (err < 0)
 		goto done;
 
-	/* Enable auto power down */
-	err = brcm_phy_setbits(phydev, MII_BRCM_FET_SHDW_AUXSTAT2,
-				       MII_BRCM_FET_SHDW_AS2_APDE);
+	if (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE) {
+		/* Enable auto power down */
+		err = brcm_phy_setbits(phydev, MII_BRCM_FET_SHDW_AUXSTAT2,
+					       MII_BRCM_FET_SHDW_AS2_APDE);
+	}
 
 done:
 	/* Disable shadow register access */
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e7128f6..592b5bf 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1114,6 +1114,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	case TG3_PHY_ID_RTL8201E:
 	case TG3_PHY_ID_BCMAC131:
 		phydev->interface = PHY_INTERFACE_MODE_MII;
+		phydev->dev_flags |= PHY_BRCM_AUTO_PWRDWN_ENABLE;
 		tp->tg3_flags3 |= TG3_FLG3_PHY_IS_FET;
 		break;
 	}
-- 
1.6.4.4


