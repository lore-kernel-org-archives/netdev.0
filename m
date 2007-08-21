From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/3] sky2: clear PCI power control reg at startup
Date: Tue, 21 Aug 2007 14:34:02 -0700
Message-ID: <20070821213456.563726682@linux-foundation.org>
References: <20070821213401.543412708@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarxik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36991 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753484AbXHUViM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 17:38:12 -0400
Content-Disposition: inline; filename=sky2-phy-power.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure PCI register for PHY power gets cleared on boot, and make
sure to avoid any PCI posting problems.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-08-21 10:17:59.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-21 10:18:02.000000000 -0700
@@ -219,9 +219,12 @@ static void sky2_power_on(struct sky2_hw
 	else
 		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_EX) {
 		u32 reg;
 
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+
 		reg = sky2_pci_read32(hw, PCI_DEV_REG4);
 		/* set all bits to 0 except bits 15..12 and 8 */
 		reg &= P_ASPM_CONTROL_MSK;
@@ -238,6 +241,8 @@ static void sky2_power_on(struct sky2_hw
 		reg = sky2_read32(hw, B2_GP_IO);
 		reg |= GLB_GPIO_STAT_RACE_DIS;
 		sky2_write32(hw, B2_GP_IO, reg);
+
+		sky2_read32(hw, B2_GP_IO);
 	}
 }
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

