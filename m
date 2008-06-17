From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/5] sky2: phy setup changes
Date: Tue, 17 Jun 2008 09:04:24 -0700
Message-ID: <20080617160503.360344972@vyatta.com>
References: <20080617160423.205070938@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:45989 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326AbYFQQJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 12:09:03 -0400
Content-Disposition: inline; filename=sky2-phy2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the setup of the PHY registers on some chip ids. These changes
make the latest sky2 driver follow the vendor driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2008-06-16 09:38:33.000000000 -0700
+++ b/drivers/net/sky2.c	2008-06-16 09:38:34.000000000 -0700
@@ -659,8 +659,7 @@ static void sky2_phy_init(struct sky2_hw
 		ledover |= PHY_M_LED_MO_RX(MO_LED_OFF);
 	}
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
-	    hw->chip_rev == CHIP_REV_YU_EC_U_A1) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
 		/* apply fixes in PHY AFE */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 255);
 
@@ -679,7 +678,8 @@ static void sky2_phy_init(struct sky2_hw
 		/* apply workaround for integrated resistors calibration */
 		gm_phy_write(hw, port, PHY_MARV_PAGE_ADDR, 17);
 		gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0x3f60);
-	} else if (hw->chip_id != CHIP_ID_YUKON_EX) {
+	} else if (hw->chip_id != CHIP_ID_YUKON_EX &&
+		   hw->chip_id < CHIP_ID_YUKON_SUPR) {
 		/* no effect on Yukon-XL */
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 

-- 

