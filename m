From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] sky2: more fixes for Yukon Ultra
Date: Wed, 17 May 2006 14:37:05 -0700
Message-ID: <20060517213802.260158000@localhost.localdomain>
References: <20060517213702.322762000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46008 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751148AbWEQVlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 17:41:23 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-ec-u.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Logic error in the phy initialization code. Also, turn on wake on lan
bit in status control.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-05-17 08:55:51.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-17 08:55:54.000000000 -0700
@@ -236,6 +236,7 @@
 		}
 
 		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+			sky2_write16(hw, B0_CTST, Y2_HW_WOL_ON);
 			sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 			reg1 = sky2_pci_read32(hw, PCI_DEV_REG4);
 			reg1 &= P_ASPM_CONTROL_MSK;
@@ -307,7 +308,7 @@
 	u16 ctrl, ct1000, adv, pg, ledctrl, ledover;
 
 	if (sky2->autoneg == AUTONEG_ENABLE &&
-	    (hw->chip_id != CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)) {
+	    !(hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)) {
 		u16 ectrl = gm_phy_read(hw, port, PHY_MARV_EXT_CTRL);
 
 		ectrl &= ~(PHY_M_EC_M_DSC_MSK | PHY_M_EC_S_DSC_MSK |
--- sky2.orig/drivers/net/sky2.h	2006-05-17 08:55:51.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-05-17 08:55:54.000000000 -0700
@@ -214,6 +214,8 @@
 enum {
 	Y2_VMAIN_AVAIL	= 1<<17,/* VMAIN available (YUKON-2 only) */
 	Y2_VAUX_AVAIL	= 1<<16,/* VAUX available (YUKON-2 only) */
+	Y2_HW_WOL_ON	= 1<<15,/* HW WOL On  (Yukon-EC Ultra A1 only) */
+	Y2_HW_WOL_OFF	= 1<<14,/* HW WOL On  (Yukon-EC Ultra A1 only) */
 	Y2_ASF_ENABLE	= 1<<13,/* ASF Unit Enable (YUKON-2 only) */
 	Y2_ASF_DISABLE	= 1<<12,/* ASF Unit Disable (YUKON-2 only) */
 	Y2_CLK_RUN_ENA	= 1<<11,/* CLK_RUN Enable  (YUKON-2 only) */

--

