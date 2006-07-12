From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 6/7] sky2: PHY power on delays
Date: Wed, 12 Jul 2006 15:23:47 -0700
Message-ID: <20060712222646.660842048@localhost.localdomain>
References: <20060712222341.686007133@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19849 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751468AbWGLWb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 18:31:59 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-phy-read-timeout.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The documentation says we need to wait after turning on the PHY.
Also, don't enable WOL by default.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-07-11 15:25:40.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-07-11 15:35:31.000000000 -0700
@@ -234,7 +234,6 @@
 		}
 
 		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
-			sky2_write16(hw, B0_CTST, Y2_HW_WOL_ON);
 			sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 			reg1 = sky2_pci_read32(hw, PCI_DEV_REG4);
 			reg1 &= P_ASPM_CONTROL_MSK;
@@ -243,6 +242,7 @@
 		}
 
 		sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+		udelay(100);
 
 		break;
 
@@ -255,6 +255,7 @@
 		else
 			reg1 |= (PCI_Y2_PHY1_POWD | PCI_Y2_PHY2_POWD);
 		sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+		udelay(100);
 
 		if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 			sky2_write8(hw, B2_Y2_CLK_GATE, 0);

--

