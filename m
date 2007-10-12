From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/6] sky2: fix power settings on Yukon XL
Date: Thu, 11 Oct 2007 18:19:54 -0700
Message-ID: <20071012012125.169362665@linux-foundation.org>
References: <20071012011951.575936605@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49754 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753545AbXJLBWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:22:24 -0400
Content-Disposition: inline; filename=sky2-phy-power.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure PCI register for PHY power gets set correctly.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-10-11 18:12:56.000000000 -0700
+++ b/drivers/net/sky2.c	2007-10-11 18:13:00.000000000 -0700
@@ -606,20 +606,19 @@ static void sky2_phy_power(struct sky2_h
 {
 	struct pci_dev *pdev = hw->pdev;
 	u32 reg1;
-	static const u32 phy_power[]
-		= { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
-
-	/* looks like this XL is back asswards .. */
-	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
-		onoff = !onoff;
+	static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
+	static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
 
 	pci_read_config_dword(pdev, PCI_DEV_REG1, &reg1);
+	/* Turn on/off phy power saving */
 	if (onoff)
-		/* Turn off phy power saving */
 		reg1 &= ~phy_power[port];
 	else
 		reg1 |= phy_power[port];
 
+	if (onoff && hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
+		reg1 |= coma_mode[port];
+
 	pci_write_config_dword(pdev, PCI_DEV_REG1, reg1);
 	pci_read_config_dword(pdev, PCI_DEV_REG1, &reg1);
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

