From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/10] sky2: dont enable PME legacy mode
Date: Fri, 12 Feb 2010 08:58:00 -0800
Message-ID: <20100212165937.724074712@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49490 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757372Ab0BLRHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:07:54 -0500
Content-Disposition: inline; filename=sky2-no-pme-legacy.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bit is not changed by vendor driver, and should be left alone.
The documentation implies this a debug bit. 
  0 = WAKE# only asserted when VMAIN not available
  1 = WAKE# is depend on wake events and independent of VMAIN.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2010-02-10 11:45:02.392648891 -0800
+++ b/drivers/net/sky2.c	2010-02-10 11:45:15.221399139 -0800
@@ -733,7 +733,6 @@ static void sky2_wol_init(struct sky2_po
 	unsigned port = sky2->port;
 	enum flow_control save_mode;
 	u16 ctrl;
-	u32 reg1;
 
 	/* Bring hardware out of reset */
 	sky2_write16(hw, B0_CTST, CS_RST_CLR);
@@ -787,11 +786,6 @@ static void sky2_wol_init(struct sky2_po
 	/* Disable PiG firmware */
 	sky2_write16(hw, B0_CTST, Y2_HW_WOL_OFF);
 
-	/* Turn on legacy PCI-Express PME mode */
-	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
-	reg1 |= PCI_Y2_PME_LEGACY;
-	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
-
 	/* block receiver */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 }

-- 

