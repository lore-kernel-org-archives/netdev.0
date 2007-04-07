From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] sky2: phy workarounds for Yukon EC-U A1
Date: Sat, 07 Apr 2007 16:02:28 -0700
Message-ID: <20070407230326.058733747@linux-foundation.org>
References: <20070407230224.486666854@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36284 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877AbXDGXnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Apr 2007 19:43:09 -0400
Content-Disposition: inline; filename=sky2-ec-u-a1.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The workaround Yukon EC-U wasn't comparing with correct
version and wasn't doing correct setup. Without it, 88e8056
throws all sorts of errors.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- netdev-2.6.orig/drivers/net/sky2.c	2007-04-07 15:12:55.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2007-04-07 15:13:31.000000000 -0700
@@ -510,9 +510,9 @@
 		ledover &= ~PHY_M_LED_MO_RX;
 	}
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U && hw->chip_rev == CHIP_REV_YU_EC_A1) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
+	    hw->chip_rev == CHIP_REV_YU_EC_U_A1) {
 		/* apply fixes in PHY AFE */
-		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 255);
 
 		/* increase differential signal amplitude in 10BASE-T */
@@ -524,7 +524,7 @@
 		gm_phy_write(hw, port, 0x17, 0x2002);
 
 		/* set page register to 0 */
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	} else if (hw->chip_id != CHIP_ID_YUKON_EX) {
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 

--

