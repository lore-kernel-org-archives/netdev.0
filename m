From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 3/6] sky2: phy power down needs PCI config write enabled
Date: Wed, 20 Dec 2006 13:06:35 -0800
Message-ID: <20061220210922.982975678@osdl.org>
References: <20061220210632.183204605@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58168 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423155AbWLVAkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 19:40:37 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-phy-power-write.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to change PCI registers (via the iomap'd window),
it needs to be enabled; this wasn't being done in sky2_phy_power
the function that turns on/off power to the PHY.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/sky2.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- sky2-2.6.orig/drivers/net/sky2.c	2006-12-19 15:33:38.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2006-12-19 15:34:31.000000000 -0800
@@ -569,8 +569,8 @@
 	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 		onoff = !onoff;
 
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
-
 	if (onoff)
 		/* Turn off phy power saving */
 		reg1 &= ~phy_power[port];
@@ -579,6 +579,7 @@
 
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 	sky2_pci_read32(hw, PCI_DEV_REG1);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	udelay(100);
 }
 

--
Stephen Hemminger <shemminger@osdl.org>

