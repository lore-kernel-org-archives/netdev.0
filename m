From: Takashi Iwai <tiwai@suse.de>
Subject: [PATCH 2/2] net: Add missing TST_CFG_WRITE bits around sky2_pci_write
Date: Thu,  3 Dec 2009 16:12:02 +0100
Message-ID: <1259853122-21134-3-git-send-email-tiwai@suse.de>
References: <1259853122-21134-1-git-send-email-tiwai@suse.de>
 <1259853122-21134-2-git-send-email-tiwai@suse.de>
Cc: Takashi Iwai <tiwai@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34306 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756276AbZLCPMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 10:12:06 -0500
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.221.2])
	by mx2.suse.de (Postfix) with ESMTP id F192187D82
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2009 16:12:12 +0100 (CET)
In-Reply-To: <1259853122-21134-2-git-send-email-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing TST_CFG_WRITE bits around sky2_pci_write*() in Optima
setup routines.  Without the cfg-write bits, the driver may spew endless
link-up messages through qlink irq.

Signed-off-by: Takashi Iwai <tiwai@suse.de>
---
 drivers/net/sky2.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 0718cdd..4c0a677 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2152,7 +2152,9 @@ static void sky2_qlink_intr(struct sky2_hw *hw)
 
 	/* reset PHY Link Detect */
 	phy = sky2_pci_read16(hw, PSM_CONFIG_REG4);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	sky2_pci_write16(hw, PSM_CONFIG_REG4, phy | 1);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 	sky2_link_up(sky2);
 }
@@ -3082,6 +3084,7 @@ static void sky2_reset(struct sky2_hw *hw)
 		reg <<= PSM_CONFIG_REG4_TIMER_PHY_LINK_DETECT_BASE;
 
 		/* reset PHY Link Detect */
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		sky2_pci_write16(hw, PSM_CONFIG_REG4,
 				 reg | PSM_CONFIG_REG4_RST_PHY_LINK_DETECT);
 		sky2_pci_write16(hw, PSM_CONFIG_REG4, reg);
@@ -3099,6 +3102,7 @@ static void sky2_reset(struct sky2_hw *hw)
 			/* restore the PCIe Link Control register */
 			sky2_pci_write16(hw, cap + PCI_EXP_LNKCTL, reg);
 		}
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 		/* re-enable PEX PM in PEX PHY debug reg. 8 (clear bit 12) */
 		sky2_write32(hw, Y2_PEX_PHY_DATA, PEX_DB_ACCESS | (0x08UL << 16));
-- 
1.6.5.3

