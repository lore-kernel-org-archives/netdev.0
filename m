From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] atl1: fix suspend regression
Date: Sun, 1 Jun 2008 18:44:41 -0500
Message-ID: <20080601184441.790521f8@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, csnook@redhat.com, avuton@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([207.115.11.55]:41225 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbYFAXot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 19:44:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jacliburn@bellsouth.net>
Date: Sun, 1 Jun 2008 16:57:11 -0500
Subject: [PATCH] atl1: fix suspend regression

Using vendor magic to force the PHY into power save mode breaks
suspend.  It isn't needed anyway, so remove it.

Tested-by: Avuton Olrich <avuton@gmail.com>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   17 -----------------
 1 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 6e4c80d..1a2f93d 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -637,22 +637,6 @@ static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
 }
 
 /*
- * Force the PHY into power saving mode using vendor magic.
- */
-#ifdef CONFIG_PM
-static void atl1_phy_enter_power_saving(struct atl1_hw *hw)
-{
-	atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
-	atl1_write_phy_reg(hw, MII_DBG_DATA, 0x124E);
-	atl1_write_phy_reg(hw, MII_DBG_ADDR, 2);
-	atl1_write_phy_reg(hw, MII_DBG_DATA, 0x3000);
-	atl1_write_phy_reg(hw, MII_DBG_ADDR, 3);
-	atl1_write_phy_reg(hw, MII_DBG_DATA, 0);
-
-}
-#endif
-
-/*
  * Resets the PHY and make all config validate
  * hw - Struct containing variables accessed by shared code
  *
@@ -2859,7 +2843,6 @@ disable_wol:
 	ctrl |= PCIE_PHYMISC_FORCE_RCV_DET;
 	iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHYMISC);
 	ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
-	atl1_phy_enter_power_saving(hw);
 	hw->phy_configured = false;
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
 exit:
-- 
1.5.5.1

