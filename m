From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 1/5] bnx2x: Remove setting XAUI low-power for
 BCM8073
Date: Sun, 30 Jan 2011 16:14:48 +0200
Message-ID: <1296396889.10095.50.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1623 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753927Ab1A3ORn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jan 2011 09:17:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A rare link issue with the BCM8073 PHY may occur due to setting XAUI low power mode, while the PHY microcode already does that.
The fix is not to set set XAUI low power mode for this PHY.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   44 ----------------------------------------
 1 files changed, 0 insertions(+), 44 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 7160ec5..53a95a2 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -3948,48 +3948,6 @@ static u8 bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
 	return rc;
 }
 
-static void bnx2x_8073_set_xaui_low_power_mode(struct bnx2x *bp,
-					       struct bnx2x_phy *phy)
-{
-	u16 val;
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_CHIP_REV, &val);
-
-	if (val == 0) {
-		/* Mustn't set low power mode in 8073 A0 */
-		return;
-	}
-
-	/* Disable PLL sequencer (use read-modify-write to clear bit 13) */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, &val);
-	val &= ~(1<<13);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
-
-	/* PLL controls */
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805E, 0x1077);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805D, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805C, 0x030B);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805B, 0x1240);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805A, 0x2490);
-
-	/* Tx Controls */
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A7, 0x0C74);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A6, 0x9041);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A5, 0x4640);
-
-	/* Rx Controls */
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FE, 0x01C4);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FD, 0x9249);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FC, 0x2015);
-
-	/* Enable PLL sequencer  (use read-modify-write to set bit 13) */
-	bnx2x_cl45_read(bp, phy, MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, &val);
-	val |= (1<<13);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
-}
-
 /******************************************************************/
 /*			BCM8073 PHY SECTION			  */
 /******************************************************************/
@@ -4148,8 +4106,6 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 
 	bnx2x_8073_set_pause_cl37(params, phy, vars);
 
-	bnx2x_8073_set_xaui_low_power_mode(bp, phy);
-
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &tmp1);
 
-- 
1.7.1









