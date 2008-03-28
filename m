From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/8] e1000e: reformat comment blocks, cosmetic changes only
Date: Fri, 28 Mar 2008 09:15:03 -0700
Message-ID: <20080328161503.6562.44329.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14757 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622AbYC1QPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 12:15:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Adjusting the comment blocks here to be code-style compliant. no
code changes.

Changed some copyright dates to 2008.

Indentation fixes.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c   |  105 +++++++---
 drivers/net/e1000e/Makefile  |    2 
 drivers/net/e1000e/defines.h |  109 ++++++-----
 drivers/net/e1000e/e1000.h   |   16 +-
 drivers/net/e1000e/es2lan.c  |   89 +++++----
 drivers/net/e1000e/ethtool.c |   97 ++++++----
 drivers/net/e1000e/hw.h      |  145 +++++++-------
 drivers/net/e1000e/ich8lan.c |  262 ++++++++++++++++----------
 drivers/net/e1000e/lib.c     |  213 +++++++++++++--------
 drivers/net/e1000e/netdev.c  |  428 +++++++++++++++++++++++++++---------------
 drivers/net/e1000e/param.c   |   33 ++-
 drivers/net/e1000e/phy.c     |  152 ++++++++++-----
 12 files changed, 1009 insertions(+), 642 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 7fe2031..c58dc2e 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -29,6 +29,9 @@
 /*
  * 82571EB Gigabit Ethernet Controller
  * 82571EB Gigabit Ethernet Controller (Fiber)
+ * 82571EB Dual Port Gigabit Mezzanine Adapter
+ * 82571EB Quad Port Gigabit Mezzanine Adapter
+ * 82571PT Gigabit PT Quad Port Server ExpressModule
  * 82572EI Gigabit Ethernet Controller (Copper)
  * 82572EI Gigabit Ethernet Controller (Fiber)
  * 82572EI Gigabit Ethernet Controller
@@ -150,7 +153,8 @@ static s32 e1000_init_nvm_params_82571(struct e1000_hw *hw)
 		if (((eecd >> 15) & 0x3) == 0x3) {
 			nvm->type = e1000_nvm_flash_hw;
 			nvm->word_size = 2048;
-			/* Autonomous Flash update bit must be cleared due
+			/*
+			 * Autonomous Flash update bit must be cleared due
 			 * to Flash update issue.
 			 */
 			eecd &= ~E1000_EECD_AUPDEN;
@@ -159,10 +163,11 @@ static s32 e1000_init_nvm_params_82571(struct e1000_hw *hw)
 		}
 		/* Fall Through */
 	default:
-		nvm->type	= e1000_nvm_eeprom_spi;
+		nvm->type = e1000_nvm_eeprom_spi;
 		size = (u16)((eecd & E1000_EECD_SIZE_EX_MASK) >>
 				  E1000_EECD_SIZE_EX_SHIFT);
-		/* Added to a constant, "size" becomes the left-shift value
+		/*
+		 * Added to a constant, "size" becomes the left-shift value
 		 * for setting word_size.
 		 */
 		size += NVM_WORD_SIZE_BASE_SHIFT;
@@ -208,8 +213,7 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	/* Set rar entry count */
 	mac->rar_entry_count = E1000_RAR_ENTRIES;
 	/* Set if manageability features are enabled. */
-	mac->arc_subsystem_valid =
-		(er32(FWSM) & E1000_FWSM_MODE_MASK) ? 1 : 0;
+	mac->arc_subsystem_valid = (er32(FWSM) & E1000_FWSM_MODE_MASK) ? 1 : 0;
 
 	/* check for link */
 	switch (hw->media_type) {
@@ -219,14 +223,18 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 		func->get_link_up_info = e1000e_get_speed_and_duplex_copper;
 		break;
 	case e1000_media_type_fiber:
-		func->setup_physical_interface = e1000_setup_fiber_serdes_link_82571;
+		func->setup_physical_interface =
+			e1000_setup_fiber_serdes_link_82571;
 		func->check_for_link = e1000e_check_for_fiber_link;
-		func->get_link_up_info = e1000e_get_speed_and_duplex_fiber_serdes;
+		func->get_link_up_info =
+			e1000e_get_speed_and_duplex_fiber_serdes;
 		break;
 	case e1000_media_type_internal_serdes:
-		func->setup_physical_interface = e1000_setup_fiber_serdes_link_82571;
+		func->setup_physical_interface =
+			e1000_setup_fiber_serdes_link_82571;
 		func->check_for_link = e1000e_check_for_serdes_link;
-		func->get_link_up_info = e1000e_get_speed_and_duplex_fiber_serdes;
+		func->get_link_up_info =
+			e1000e_get_speed_and_duplex_fiber_serdes;
 		break;
 	default:
 		return -E1000_ERR_CONFIG;
@@ -322,10 +330,12 @@ static s32 e1000_get_phy_id_82571(struct e1000_hw *hw)
 	switch (hw->mac.type) {
 	case e1000_82571:
 	case e1000_82572:
-		/* The 82571 firmware may still be configuring the PHY.
+		/*
+		 * The 82571 firmware may still be configuring the PHY.
 		 * In this case, we cannot access the PHY until the
 		 * configuration is done.  So we explicitly set the
-		 * PHY ID. */
+		 * PHY ID.
+		 */
 		phy->id = IGP01E1000_I_PHY_ID;
 		break;
 	case e1000_82573:
@@ -479,8 +489,10 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* If our nvm is an EEPROM, then we're done
-	 * otherwise, commit the checksum to the flash NVM. */
+	/*
+	 * If our nvm is an EEPROM, then we're done
+	 * otherwise, commit the checksum to the flash NVM.
+	 */
 	if (hw->nvm.type != e1000_nvm_flash_hw)
 		return ret_val;
 
@@ -496,7 +508,8 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 
 	/* Reset the firmware if using STM opcode. */
 	if ((er32(FLOP) & 0xFF00) == E1000_STM_OPCODE) {
-		/* The enabling of and the actual reset must be done
+		/*
+		 * The enabling of and the actual reset must be done
 		 * in two write cycles.
 		 */
 		ew32(HICR, E1000_HICR_FW_RESET_ENABLE);
@@ -557,8 +570,10 @@ static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 	u32 eewr = 0;
 	s32 ret_val = 0;
 
-	/* A check for invalid values:  offset too large, too many words,
-	 * and not enough words. */
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * and not enough words.
+	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
@@ -645,30 +660,32 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
 	} else {
 		data &= ~IGP02E1000_PM_D0_LPLU;
 		ret_val = e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, data);
-		/* LPLU and SmartSpeed are mutually exclusive.  LPLU is used
+		/*
+		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
 		 * important.  During driver activity we should enable
-		 * SmartSpeed, so performance is maintained. */
+		 * SmartSpeed, so performance is maintained.
+		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		}
@@ -693,7 +710,8 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 i = 0;
 
-	/* Prevent the PCI-E bus from sticking if there is no TLP connection
+	/*
+	 * Prevent the PCI-E bus from sticking if there is no TLP connection
 	 * on the last TLP read/write transaction when MAC is reset.
 	 */
 	ret_val = e1000e_disable_pcie_master(hw);
@@ -709,8 +727,10 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 
 	msleep(10);
 
-	/* Must acquire the MDIO ownership before MAC reset.
-	 * Ownership defaults to firmware after a reset. */
+	/*
+	 * Must acquire the MDIO ownership before MAC reset.
+	 * Ownership defaults to firmware after a reset.
+	 */
 	if (hw->mac.type == e1000_82573) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
 		extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
@@ -747,7 +767,8 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 		/* We don't want to continue accessing MAC registers. */
 		return ret_val;
 
-	/* Phy configuration from NVM just starts after EECD_AUTO_RD is set.
+	/*
+	 * Phy configuration from NVM just starts after EECD_AUTO_RD is set.
 	 * Need to wait for Phy configuration completion before accessing
 	 * NVM and Phy.
 	 */
@@ -793,7 +814,8 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	e1000e_clear_vfta(hw);
 
 	/* Setup the receive address. */
-	/* If, however, a locally administered address was assigned to the
+	/*
+	 * If, however, a locally administered address was assigned to the
 	 * 82571, we must reserve a RAR for it to work around an issue where
 	 * resetting one port will reload the MAC on the other port.
 	 */
@@ -830,7 +852,8 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 		ew32(GCR, reg_data);
 	}
 
-	/* Clear all of the statistics registers (clear on read).  It is
+	/*
+	 * Clear all of the statistics registers (clear on read).  It is
 	 * important that we do this after we have tried to establish link
 	 * because the symbol error count will increment wildly if there
 	 * is no link.
@@ -922,7 +945,8 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
 
 	if (hw->mac.type == e1000_82573) {
 		if (hw->mng_cookie.vlan_id != 0) {
-			/* The VFTA is a 4096b bit-field, each identifying
+			/*
+			 * The VFTA is a 4096b bit-field, each identifying
 			 * a single VLAN ID.  The following operations
 			 * determine which 32b entry (i.e. offset) into the
 			 * array we want to set the VLAN ID (i.e. bit) of
@@ -936,7 +960,8 @@ void e1000e_clear_vfta(struct e1000_hw *hw)
 		}
 	}
 	for (offset = 0; offset < E1000_VLAN_FILTER_TBL_SIZE; offset++) {
-		/* If the offset we want to clear is the same offset of the
+		/*
+		 * If the offset we want to clear is the same offset of the
 		 * manageability VLAN ID, then clear all bits except that of
 		 * the manageability unit.
 		 */
@@ -984,7 +1009,8 @@ static void e1000_mc_addr_list_update_82571(struct e1000_hw *hw,
  **/
 static s32 e1000_setup_link_82571(struct e1000_hw *hw)
 {
-	/* 82573 does not have a word in the NVM to determine
+	/*
+	 * 82573 does not have a word in the NVM to determine
 	 * the default flow control setting, so we explicitly
 	 * set it to full.
 	 */
@@ -1050,14 +1076,14 @@ static s32 e1000_setup_fiber_serdes_link_82571(struct e1000_hw *hw)
 	switch (hw->mac.type) {
 	case e1000_82571:
 	case e1000_82572:
-		/* If SerDes loopback mode is entered, there is no form
+		/*
+		 * If SerDes loopback mode is entered, there is no form
 		 * of reset to take the adapter out of that mode.  So we
 		 * have to explicitly take the adapter out of loopback
 		 * mode.  This prevents drivers from twiddling their thumbs
 		 * if another tool failed to take it out of loopback mode.
 		 */
-		ew32(SCTL,
-				E1000_SCTL_DISABLE_SERDES_LOOPBACK);
+		ew32(SCTL, E1000_SCTL_DISABLE_SERDES_LOOPBACK);
 		break;
 	default:
 		break;
@@ -1124,7 +1150,8 @@ void e1000e_set_laa_state_82571(struct e1000_hw *hw, bool state)
 
 	/* If workaround is activated... */
 	if (state)
-		/* Hold a copy of the LAA in RAR[14] This is done so that
+		/*
+		 * Hold a copy of the LAA in RAR[14] This is done so that
 		 * between the time RAR[0] gets clobbered and the time it
 		 * gets fixed, the actual LAA is in one of the RARs and no
 		 * incoming packets directed to this port are dropped.
@@ -1152,7 +1179,8 @@ static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw)
 	if (nvm->type != e1000_nvm_flash_hw)
 		return 0;
 
-	/* Check bit 4 of word 10h.  If it is 0, firmware is done updating
+	/*
+	 * Check bit 4 of word 10h.  If it is 0, firmware is done updating
 	 * 10h-12h.  Checksum may need to be fixed.
 	 */
 	ret_val = e1000_read_nvm(hw, 0x10, 1, &data);
@@ -1160,7 +1188,8 @@ static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw)
 		return ret_val;
 
 	if (!(data & 0x10)) {
-		/* Read 0x23 and check bit 15.  This bit is a 1
+		/*
+		 * Read 0x23 and check bit 15.  This bit is a 1
 		 * when the checksum has already been fixed.  If
 		 * the checksum is still wrong and this bit is a
 		 * 1, we need to return bad checksum.  Otherwise,
diff --git a/drivers/net/e1000e/Makefile b/drivers/net/e1000e/Makefile
index 650f866..360c913 100644
--- a/drivers/net/e1000e/Makefile
+++ b/drivers/net/e1000e/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel PRO/1000 Linux driver
-# Copyright(c) 1999 - 2007 Intel Corporation.
+# Copyright(c) 1999 - 2008 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index a4f511f..572cfd4 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -120,10 +120,10 @@
 #define E1000_MANC_ARP_EN        0x00002000 /* Enable ARP Request Filtering */
 #define E1000_MANC_RCV_TCO_EN    0x00020000 /* Receive TCO Packets Enabled */
 #define E1000_MANC_BLK_PHY_RST_ON_IDE   0x00040000 /* Block phy resets */
-#define E1000_MANC_EN_MAC_ADDR_FILTER   0x00100000 /* Enable MAC address
-						    * filtering */
-#define E1000_MANC_EN_MNG2HOST   0x00200000 /* Enable MNG packets to host
-					     * memory */
+/* Enable MAC address filtering */
+#define E1000_MANC_EN_MAC_ADDR_FILTER   0x00100000
+/* Enable MNG packets to host memory */
+#define E1000_MANC_EN_MNG2HOST   0x00200000
 
 /* Receive Control */
 #define E1000_RCTL_EN             0x00000002    /* enable */
@@ -135,25 +135,26 @@
 #define E1000_RCTL_LBM_MAC        0x00000040    /* MAC loopback mode */
 #define E1000_RCTL_LBM_TCVR       0x000000C0    /* tcvr loopback mode */
 #define E1000_RCTL_DTYP_PS        0x00000400    /* Packet Split descriptor */
-#define E1000_RCTL_RDMTS_HALF     0x00000000    /* rx desc min threshold size */
+#define E1000_RCTL_RDMTS_HALF     0x00000000    /* Rx desc min threshold size */
 #define E1000_RCTL_MO_SHIFT       12            /* multicast offset shift */
 #define E1000_RCTL_BAM            0x00008000    /* broadcast enable */
 /* these buffer sizes are valid if E1000_RCTL_BSEX is 0 */
-#define E1000_RCTL_SZ_2048        0x00000000    /* rx buffer size 2048 */
-#define E1000_RCTL_SZ_1024        0x00010000    /* rx buffer size 1024 */
-#define E1000_RCTL_SZ_512         0x00020000    /* rx buffer size 512 */
-#define E1000_RCTL_SZ_256         0x00030000    /* rx buffer size 256 */
+#define E1000_RCTL_SZ_2048        0x00000000    /* Rx buffer size 2048 */
+#define E1000_RCTL_SZ_1024        0x00010000    /* Rx buffer size 1024 */
+#define E1000_RCTL_SZ_512         0x00020000    /* Rx buffer size 512 */
+#define E1000_RCTL_SZ_256         0x00030000    /* Rx buffer size 256 */
 /* these buffer sizes are valid if E1000_RCTL_BSEX is 1 */
-#define E1000_RCTL_SZ_16384       0x00010000    /* rx buffer size 16384 */
-#define E1000_RCTL_SZ_8192        0x00020000    /* rx buffer size 8192 */
-#define E1000_RCTL_SZ_4096        0x00030000    /* rx buffer size 4096 */
+#define E1000_RCTL_SZ_16384       0x00010000    /* Rx buffer size 16384 */
+#define E1000_RCTL_SZ_8192        0x00020000    /* Rx buffer size 8192 */
+#define E1000_RCTL_SZ_4096        0x00030000    /* Rx buffer size 4096 */
 #define E1000_RCTL_VFE            0x00040000    /* vlan filter enable */
 #define E1000_RCTL_CFIEN          0x00080000    /* canonical form enable */
 #define E1000_RCTL_CFI            0x00100000    /* canonical form indicator */
 #define E1000_RCTL_BSEX           0x02000000    /* Buffer size extension */
 #define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */
 
-/* Use byte values for the following shift parameters
+/*
+ * Use byte values for the following shift parameters
  * Usage:
  *     psrctl |= (((ROUNDUP(value0, 128) >> E1000_PSRCTL_BSIZE0_SHIFT) &
  *                  E1000_PSRCTL_BSIZE0_MASK) |
@@ -206,7 +207,8 @@
 #define E1000_CTRL_VME      0x40000000  /* IEEE VLAN mode enable */
 #define E1000_CTRL_PHY_RST  0x80000000  /* PHY Reset */
 
-/* Bit definitions for the Management Data IO (MDIO) and Management Data
+/*
+ * Bit definitions for the Management Data IO (MDIO) and Management Data
  * Clock (MDC) pins in the Device Control Register.
  */
 
@@ -279,7 +281,7 @@
 #define E1000_TXD_STAT_TC    0x00000004 /* Tx Underrun */
 
 /* Transmit Control */
-#define E1000_TCTL_EN     0x00000002    /* enable tx */
+#define E1000_TCTL_EN     0x00000002    /* enable Tx */
 #define E1000_TCTL_PSP    0x00000008    /* pad short packets */
 #define E1000_TCTL_CT     0x00000ff0    /* collision threshold */
 #define E1000_TCTL_COLD   0x003ff000    /* collision distance */
@@ -337,8 +339,8 @@
 #define E1000_KABGTXD_BGSQLBIAS           0x00050000
 
 /* PBA constants */
-#define E1000_PBA_8K  0x0008    /* 8KB, default Rx allocation */
-#define E1000_PBA_16K 0x0010    /* 16KB, default TX allocation */
+#define E1000_PBA_8K  0x0008    /* 8KB */
+#define E1000_PBA_16K 0x0010    /* 16KB */
 
 #define E1000_PBS_16K E1000_PBA_16K
 
@@ -356,12 +358,13 @@
 /* Interrupt Cause Read */
 #define E1000_ICR_TXDW          0x00000001 /* Transmit desc written back */
 #define E1000_ICR_LSC           0x00000004 /* Link Status Change */
-#define E1000_ICR_RXSEQ         0x00000008 /* rx sequence error */
-#define E1000_ICR_RXDMT0        0x00000010 /* rx desc min. threshold (0) */
-#define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */
+#define E1000_ICR_RXSEQ         0x00000008 /* Rx sequence error */
+#define E1000_ICR_RXDMT0        0x00000010 /* Rx desc min. threshold (0) */
+#define E1000_ICR_RXT0          0x00000080 /* Rx timer intr (ring 0) */
 #define E1000_ICR_INT_ASSERTED  0x80000000 /* If this bit asserted, the driver should claim the interrupt */
 
-/* This defines the bits that are set in the Interrupt Mask
+/*
+ * This defines the bits that are set in the Interrupt Mask
  * Set/Read Register.  Each bit is documented below:
  *   o RXT0   = Receiver Timer Interrupt (ring 0)
  *   o TXDW   = Transmit Descriptor Written Back
@@ -379,21 +382,22 @@
 /* Interrupt Mask Set */
 #define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
 #define E1000_IMS_LSC       E1000_ICR_LSC       /* Link Status Change */
-#define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
-#define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
-#define E1000_IMS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
+#define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* Rx sequence error */
+#define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* Rx desc min. threshold */
+#define E1000_IMS_RXT0      E1000_ICR_RXT0      /* Rx timer intr */
 
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
 #define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
+#define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* Rx desc min. threshold */
 
 /* Transmit Descriptor Control */
 #define E1000_TXDCTL_PTHRESH 0x0000003F /* TXDCTL Prefetch Threshold */
 #define E1000_TXDCTL_WTHRESH 0x003F0000 /* TXDCTL Writeback Threshold */
 #define E1000_TXDCTL_FULL_TX_DESC_WB 0x01010000 /* GRAN=1, WTHRESH=1 */
 #define E1000_TXDCTL_MAX_TX_DESC_PREFETCH 0x0100001F /* GRAN=1, PTHRESH=31 */
-#define E1000_TXDCTL_COUNT_DESC 0x00400000 /* Enable the counting of desc.
-					      still to be processed. */
+/* Enable the counting of desc. still to be processed. */
+#define E1000_TXDCTL_COUNT_DESC 0x00400000
 
 /* Flow Control Constants */
 #define FLOW_CONTROL_ADDRESS_LOW  0x00C28001
@@ -404,7 +408,8 @@
 #define E1000_VLAN_FILTER_TBL_SIZE 128  /* VLAN Filter Table (4096 bits) */
 
 /* Receive Address */
-/* Number of high/low register pairs in the RAR. The RAR (Receive Address
+/*
+ * Number of high/low register pairs in the RAR. The RAR (Receive Address
  * Registers) holds the directed and multicast addresses that we monitor.
  * Technically, we have 16 spots.  However, we reserve one of these spots
  * (RAR[15]) for our directed address used by controllers with
@@ -533,8 +538,8 @@
 #define E1000_EECD_REQ       0x00000040 /* NVM Access Request */
 #define E1000_EECD_GNT       0x00000080 /* NVM Access Grant */
 #define E1000_EECD_SIZE      0x00000200 /* NVM Size (0=64 word 1=256 word) */
-#define E1000_EECD_ADDR_BITS 0x00000400 /* NVM Addressing bits based on type
-					 * (0-small, 1-large) */
+/* NVM Addressing bits based on type (0-small, 1-large) */
+#define E1000_EECD_ADDR_BITS 0x00000400
 #define E1000_NVM_GRANT_ATTEMPTS   1000 /* NVM # attempts to gain grant */
 #define E1000_EECD_AUTO_RD          0x00000200  /* NVM Auto Read done */
 #define E1000_EECD_SIZE_EX_MASK     0x00007800  /* NVM Size */
@@ -626,7 +631,8 @@
 #define MAX_PHY_MULTI_PAGE_REG 0xF
 
 /* Bit definitions for valid PHY IDs. */
-/* I = Integrated
+/*
+ * I = Integrated
  * E = External
  */
 #define M88E1000_E_PHY_ID    0x01410C50
@@ -653,37 +659,37 @@
 #define M88E1000_PSCR_MDI_MANUAL_MODE  0x0000  /* MDI Crossover Mode bits 6:5 */
 					       /* Manual MDI configuration */
 #define M88E1000_PSCR_MDIX_MANUAL_MODE 0x0020  /* Manual MDIX configuration */
-#define M88E1000_PSCR_AUTO_X_1000T     0x0040  /* 1000BASE-T: Auto crossover,
-						*  100BASE-TX/10BASE-T:
-						*  MDI Mode
-						*/
-#define M88E1000_PSCR_AUTO_X_MODE      0x0060  /* Auto crossover enabled
-						* all speeds.
-						*/
-					/* 1=Enable Extended 10BASE-T distance
-					 * (Lower 10BASE-T RX Threshold)
-					 * 0=Normal 10BASE-T RX Threshold */
-					/* 1=5-Bit interface in 100BASE-TX
-					 * 0=MII interface in 100BASE-TX */
-#define M88E1000_PSCR_ASSERT_CRS_ON_TX     0x0800 /* 1=Assert CRS on Transmit */
+/* 1000BASE-T: Auto crossover, 100BASE-TX/10BASE-T: MDI Mode */
+#define M88E1000_PSCR_AUTO_X_1000T     0x0040
+/* Auto crossover enabled all speeds */
+#define M88E1000_PSCR_AUTO_X_MODE      0x0060
+/*
+ * 1=Enable Extended 10BASE-T distance (Lower 10BASE-T Rx Threshold)
+ * 0=Normal 10BASE-T Rx Threshold
+ */
+#define M88E1000_PSCR_ASSERT_CRS_ON_TX 0x0800 /* 1=Assert CRS on Transmit */
 
 /* M88E1000 PHY Specific Status Register */
 #define M88E1000_PSSR_REV_POLARITY       0x0002 /* 1=Polarity reversed */
 #define M88E1000_PSSR_DOWNSHIFT          0x0020 /* 1=Downshifted */
 #define M88E1000_PSSR_MDIX               0x0040 /* 1=MDIX; 0=MDI */
-#define M88E1000_PSSR_CABLE_LENGTH       0x0380 /* 0=<50M;1=50-80M;2=80-110M;
-					    * 3=110-140M;4=>140M */
+/* 0=<50M; 1=50-80M; 2=80-110M; 3=110-140M; 4=>140M */
+#define M88E1000_PSSR_CABLE_LENGTH       0x0380
 #define M88E1000_PSSR_SPEED              0xC000 /* Speed, bits 14:15 */
 #define M88E1000_PSSR_1000MBS            0x8000 /* 10=1000Mbs */
 
 #define M88E1000_PSSR_CABLE_LENGTH_SHIFT 7
 
-/* Number of times we will attempt to autonegotiate before downshifting if we
- * are the master */
+/*
+ * Number of times we will attempt to autonegotiate before downshifting if we
+ * are the master
+ */
 #define M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK 0x0C00
 #define M88E1000_EPSCR_MASTER_DOWNSHIFT_1X   0x0000
-/* Number of times we will attempt to autonegotiate before downshifting if we
- * are the slave */
+/*
+ * Number of times we will attempt to autonegotiate before downshifting if we
+ * are the slave
+ */
 #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_MASK  0x0300
 #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X    0x0100
 #define M88E1000_EPSCR_TX_CLK_25      0x0070 /* 25  MHz TX_CLK */
@@ -692,7 +698,8 @@
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK  0x0E00
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X    0x0800
 
-/* Bits...
+/*
+ * Bits...
  * 15-5: page
  * 4-0: register offset
  */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 4bf0c6c..ffba63c 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -61,7 +61,7 @@ struct e1000_info;
 	ndev_printk(KERN_NOTICE , netdev, format, ## arg)
 
 
-/* TX/RX descriptor defines */
+/* Tx/Rx descriptor defines */
 #define E1000_DEFAULT_TXD		256
 #define E1000_MAX_TXD			4096
 #define E1000_MIN_TXD			80
@@ -114,13 +114,13 @@ struct e1000_buffer {
 	dma_addr_t dma;
 	struct sk_buff *skb;
 	union {
-		/* TX */
+		/* Tx */
 		struct {
 			unsigned long time_stamp;
 			u16 length;
 			u16 next_to_watch;
 		};
-		/* RX */
+		/* Rx */
 		/* arrays of page information for packet split */
 		struct e1000_ps_page *ps_pages;
 	};
@@ -177,7 +177,7 @@ struct e1000_adapter {
 	u16 rx_itr;
 
 	/*
-	 * TX
+	 * Tx
 	 */
 	struct e1000_ring *tx_ring /* One per active queue */
 						____cacheline_aligned_in_smp;
@@ -199,7 +199,7 @@ struct e1000_adapter {
 	unsigned int total_rx_bytes;
 	unsigned int total_rx_packets;
 
-	/* TX stats */
+	/* Tx stats */
 	u64 tpt_old;
 	u64 colc_old;
 	u64 gotcl_old;
@@ -211,7 +211,7 @@ struct e1000_adapter {
 	u32 tx_dma_failed;
 
 	/*
-	 * RX
+	 * Rx
 	 */
 	bool (*clean_rx) (struct e1000_adapter *adapter,
 			  int *work_done, int work_to_do)
@@ -223,7 +223,7 @@ struct e1000_adapter {
 	u32 rx_int_delay;
 	u32 rx_abs_int_delay;
 
-	/* RX stats */
+	/* Rx stats */
 	u64 hw_csum_err;
 	u64 hw_csum_good;
 	u64 rx_hdr_split;
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 88657ad..2657754 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -92,7 +92,8 @@
 /* In-Band Control Register (Page 194, Register 18) */
 #define GG82563_ICR_DIS_PADDING			 0x0010 /* Disable Padding */
 
-/* A table for the GG82563 cable length where the range is defined
+/*
+ * A table for the GG82563 cable length where the range is defined
  * with a lower bound at "index" and the upper bound at
  * "index + 5".
  */
@@ -167,12 +168,13 @@ static s32 e1000_init_nvm_params_80003es2lan(struct e1000_hw *hw)
 		break;
 	}
 
-	nvm->type	       = e1000_nvm_eeprom_spi;
+	nvm->type = e1000_nvm_eeprom_spi;
 
 	size = (u16)((eecd & E1000_EECD_SIZE_EX_MASK) >>
 			  E1000_EECD_SIZE_EX_SHIFT);
 
-	/* Added to a constant, "size" becomes the left-shift value
+	/*
+	 * Added to a constant, "size" becomes the left-shift value
 	 * for setting word_size.
 	 */
 	size += NVM_WORD_SIZE_BASE_SHIFT;
@@ -208,8 +210,7 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	/* Set rar entry count */
 	mac->rar_entry_count = E1000_RAR_ENTRIES;
 	/* Set if manageability features are enabled. */
-	mac->arc_subsystem_valid =
-		(er32(FWSM) & E1000_FWSM_MODE_MASK) ? 1 : 0;
+	mac->arc_subsystem_valid = (er32(FWSM) & E1000_FWSM_MODE_MASK) ? 1 : 0;
 
 	/* check for link */
 	switch (hw->media_type) {
@@ -344,8 +345,10 @@ static s32 e1000_acquire_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 		if (!(swfw_sync & (fwmask | swmask)))
 			break;
 
-		/* Firmware currently using resource (fwmask)
-		 * or other software thread using resource (swmask) */
+		/*
+		 * Firmware currently using resource (fwmask)
+		 * or other software thread using resource (swmask)
+		 */
 		e1000e_put_hw_semaphore(hw);
 		mdelay(5);
 		i++;
@@ -407,7 +410,8 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG)
 		page_select = GG82563_PHY_PAGE_SELECT;
 	else
-		/* Use Alternative Page Select register to access
+		/*
+		 * Use Alternative Page Select register to access
 		 * registers 30 and 31
 		 */
 		page_select = GG82563_PHY_PAGE_SELECT_ALT;
@@ -417,7 +421,8 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	if (ret_val)
 		return ret_val;
 
-	/* The "ready" bit in the MDIC register may be incorrectly set
+	/*
+	 * The "ready" bit in the MDIC register may be incorrectly set
 	 * before the device has completed the "Page Select" MDI
 	 * transaction.  So we wait 200us after each MDI command...
 	 */
@@ -462,7 +467,8 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG)
 		page_select = GG82563_PHY_PAGE_SELECT;
 	else
-		/* Use Alternative Page Select register to access
+		/*
+		 * Use Alternative Page Select register to access
 		 * registers 30 and 31
 		 */
 		page_select = GG82563_PHY_PAGE_SELECT_ALT;
@@ -473,7 +479,8 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 		return ret_val;
 
 
-	/* The "ready" bit in the MDIC register may be incorrectly set
+	/*
+	 * The "ready" bit in the MDIC register may be incorrectly set
 	 * before the device has completed the "Page Select" MDI
 	 * transaction.  So we wait 200us after each MDI command...
 	 */
@@ -554,7 +561,8 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	u16 phy_data;
 	bool link;
 
-	/* Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
+	/*
+	 * Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
@@ -593,7 +601,8 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 			return ret_val;
 
 		if (!link) {
-			/* We didn't get link.
+			/*
+			 * We didn't get link.
 			 * Reset the DSP and cross our fingers.
 			 */
 			ret_val = e1000e_phy_reset_dsp(hw);
@@ -612,7 +621,8 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Resetting the phy means we need to verify the TX_CLK corresponds
+	/*
+	 * Resetting the phy means we need to verify the TX_CLK corresponds
 	 * to the link speed.  10Mbps -> 2.5MHz, else 25MHz.
 	 */
 	phy_data &= ~GG82563_MSCR_TX_CLK_MASK;
@@ -621,7 +631,8 @@ static s32 e1000_phy_force_speed_duplex_80003es2lan(struct e1000_hw *hw)
 	else
 		phy_data |= GG82563_MSCR_TX_CLK_100MBPS_25;
 
-	/* In addition, we must re-enable CRS on Tx for both half and full
+	/*
+	 * In addition, we must re-enable CRS on Tx for both half and full
 	 * duplex.
 	 */
 	phy_data |= GG82563_MSCR_ASSERT_CRS_ON_TX;
@@ -704,7 +715,8 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	u32 icr;
 	s32 ret_val;
 
-	/* Prevent the PCI-E bus from sticking if there is no TLP connection
+	/*
+	 * Prevent the PCI-E bus from sticking if there is no TLP connection
 	 * on the last TLP read/write transaction when MAC is reset.
 	 */
 	ret_val = e1000e_disable_pcie_master(hw);
@@ -808,7 +820,8 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	reg_data &= ~0x00100000;
 	E1000_WRITE_REG_ARRAY(hw, E1000_FFLT, 0x0001, reg_data);
 
-	/* Clear all of the statistics registers (clear on read).  It is
+	/*
+	 * Clear all of the statistics registers (clear on read).  It is
 	 * important that we do this after we have tried to establish link
 	 * because the symbol error count will increment wildly if there
 	 * is no link.
@@ -881,7 +894,8 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Options:
+	/*
+	 * Options:
 	 *   MDI/MDI-X = 0 (default)
 	 *   0 - Auto for all speeds
 	 *   1 - MDI mode
@@ -907,7 +921,8 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 		break;
 	}
 
-	/* Options:
+	/*
+	 * Options:
 	 *   disable_polarity_correction = 0 (default)
 	 *       Automatic Correction for Reversed Cable Polarity
 	 *   0 - Disabled
@@ -928,10 +943,9 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	/* Bypass RX and TX FIFO's */
-	ret_val = e1000e_write_kmrn_reg(hw,
-				E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL,
-				E1000_KMRNCTRLSTA_FIFO_CTRL_RX_BYPASS |
+	/* Bypass Rx and Tx FIFO's */
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL,
+					E1000_KMRNCTRLSTA_FIFO_CTRL_RX_BYPASS |
 					E1000_KMRNCTRLSTA_FIFO_CTRL_TX_BYPASS);
 	if (ret_val)
 		return ret_val;
@@ -953,7 +967,8 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Do not init these registers when the HW is in IAMT mode, since the
+	/*
+	 * Do not init these registers when the HW is in IAMT mode, since the
 	 * firmware will have already initialized them.  We only initialize
 	 * them if the HW is not in IAMT mode.
 	 */
@@ -974,7 +989,8 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 			return ret_val;
 	}
 
-	/* Workaround: Disable padding in Kumeran interface in the MAC
+	/*
+	 * Workaround: Disable padding in Kumeran interface in the MAC
 	 * and in the PHY to avoid CRC errors.
 	 */
 	ret_val = e1e_rphy(hw, GG82563_PHY_INBAND_CTRL, &data);
@@ -1007,9 +1023,11 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 	ctrl &= ~(E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
 	ew32(CTRL, ctrl);
 
-	/* Set the mac to wait the maximum time between each
+	/*
+	 * Set the mac to wait the maximum time between each
 	 * iteration and increase the max iterations when
-	 * polling the phy; this fixes erroneous timeouts at 10Mbps. */
+	 * polling the phy; this fixes erroneous timeouts at 10Mbps.
+	 */
 	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
 	if (ret_val)
 		return ret_val;
@@ -1026,9 +1044,8 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 	reg_data |= E1000_KMRNCTRLSTA_INB_CTRL_DIS_PADDING;
-	ret_val = e1000e_write_kmrn_reg(hw,
-				       E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
-				       reg_data);
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_INB_CTRL,
+					reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -1056,9 +1073,8 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 	u16 reg_data;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_10_100_DEFAULT;
-	ret_val = e1000e_write_kmrn_reg(hw,
-				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
-				       reg_data);
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
+					reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -1096,9 +1112,8 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 	u32 tipg;
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_1000_DEFAULT;
-	ret_val = e1000e_write_kmrn_reg(hw,
-				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
-				       reg_data);
+	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
+					reg_data);
 	if (ret_val)
 		return ret_val;
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index f77a742..3b94a87 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -102,7 +102,7 @@ static const char e1000_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Interrupt test (offline)", "Loopback test  (offline)",
 	"Link test   (on/offline)"
 };
-#define E1000_TEST_LEN	ARRAY_SIZE(e1000_gstrings_test)
+#define E1000_TEST_LEN ARRAY_SIZE(e1000_gstrings_test)
 
 static int e1000_get_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
@@ -226,8 +226,10 @@ static int e1000_set_settings(struct net_device *netdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	/* When SoL/IDER sessions are active, autoneg/speed/duplex
-	 * cannot be changed */
+	/*
+	 * When SoL/IDER sessions are active, autoneg/speed/duplex
+	 * cannot be changed
+	 */
 	if (e1000_check_reset_block(hw)) {
 		ndev_err(netdev, "Cannot change link "
 			 "characteristics when SoL/IDER is active.\n");
@@ -558,8 +560,10 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	ret_val = e1000_write_nvm(hw, first_word,
 				  last_word - first_word + 1, eeprom_buff);
 
-	/* Update the checksum over the first part of the EEPROM if needed
-	 * and flush shadow RAM for 82573 controllers */
+	/*
+	 * Update the checksum over the first part of the EEPROM if needed
+	 * and flush shadow RAM for 82573 controllers
+	 */
 	if ((ret_val == 0) && ((first_word <= NVM_CHECKSUM_REG) ||
 			       (hw->mac.type == e1000_82573)))
 		e1000e_update_nvm_checksum(hw);
@@ -578,8 +582,10 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 	strncpy(drvinfo->driver,  e1000e_driver_name, 32);
 	strncpy(drvinfo->version, e1000e_driver_version, 32);
 
-	/* EEPROM image version # is reported as firmware version # for
-	 * PCI-E controllers */
+	/*
+	 * EEPROM image version # is reported as firmware version # for
+	 * PCI-E controllers
+	 */
 	e1000_read_nvm(&adapter->hw, 5, 1, &eeprom_data);
 	sprintf(firmware_version, "%d.%d-%d",
 		(eeprom_data & 0xF000) >> 12,
@@ -658,8 +664,10 @@ static int e1000_set_ringparam(struct net_device *netdev,
 		if (err)
 			goto err_setup_tx;
 
-		/* save the new, restore the old in order to free it,
-		 * then restore the new back again */
+		/*
+		 * restore the old in order to free it,
+		 * then add in the new
+		 */
 		adapter->rx_ring = rx_old;
 		adapter->tx_ring = tx_old;
 		e1000e_free_rx_resources(adapter);
@@ -758,7 +766,8 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	u32 i;
 	u32 toggle;
 
-	/* The status register is Read Only, so a write should fail.
+	/*
+	 * The status register is Read Only, so a write should fail.
 	 * Some bits that get toggled are ignored.
 	 */
 	switch (mac->type) {
@@ -908,7 +917,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		mask = 1 << i;
 
 		if (!shared_int) {
-			/* Disable the interrupt to be reported in
+			/*
+			 * Disable the interrupt to be reported in
 			 * the cause register and then force the same
 			 * interrupt and see if one gets posted.  If
 			 * an interrupt was posted to the bus, the
@@ -925,7 +935,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			}
 		}
 
-		/* Enable the interrupt to be reported in
+		/*
+		 * Enable the interrupt to be reported in
 		 * the cause register and then force the same
 		 * interrupt and see if one gets posted.  If
 		 * an interrupt was not posted to the bus, the
@@ -942,7 +953,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		}
 
 		if (!shared_int) {
-			/* Disable the other interrupts to be reported in
+			/*
+			 * Disable the other interrupts to be reported in
 			 * the cause register and then force the other
 			 * interrupts and see if any get posted.  If
 			 * an interrupt was posted to the bus, the
@@ -1216,8 +1228,10 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	   adapter->hw.phy.type == e1000_phy_m88) {
 		ctrl_reg |= E1000_CTRL_ILOS; /* Invert Loss of Signal */
 	} else {
-		/* Set the ILOS bit on the fiber Nic if half duplex link is
-		 * detected. */
+		/*
+		 * Set the ILOS bit on the fiber Nic if half duplex link is
+		 * detected.
+		 */
 		stat_reg = er32(STATUS);
 		if ((stat_reg & E1000_STATUS_FD) == 0)
 			ctrl_reg |= (E1000_CTRL_ILOS | E1000_CTRL_SLU);
@@ -1225,7 +1239,8 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 
 	ew32(CTRL, ctrl_reg);
 
-	/* Disable the receiver on the PHY so when a cable is plugged in, the
+	/*
+	 * Disable the receiver on the PHY so when a cable is plugged in, the
 	 * PHY does not begin to autoneg when a cable is reconnected to the NIC.
 	 */
 	if (adapter->hw.phy.type == e1000_phy_m88)
@@ -1244,8 +1259,10 @@ static int e1000_set_82571_fiber_loopback(struct e1000_adapter *adapter)
 
 	/* special requirements for 82571/82572 fiber adapters */
 
-	/* jump through hoops to make sure link is up because serdes
-	 * link is hardwired up */
+	/*
+	 * jump through hoops to make sure link is up because serdes
+	 * link is hardwired up
+	 */
 	ctrl |= E1000_CTRL_SLU;
 	ew32(CTRL, ctrl);
 
@@ -1263,8 +1280,10 @@ static int e1000_set_82571_fiber_loopback(struct e1000_adapter *adapter)
 		ew32(CTRL, ctrl);
 	}
 
-	/* special write to serdes control register to enable SerDes analog
-	 * loopback */
+	/*
+	 * special write to serdes control register to enable SerDes analog
+	 * loopback
+	 */
 #define E1000_SERDES_LB_ON 0x410
 	ew32(SCTL, E1000_SERDES_LB_ON);
 	msleep(10);
@@ -1279,8 +1298,10 @@ static int e1000_set_es2lan_mac_loopback(struct e1000_adapter *adapter)
 	u32 ctrlext = er32(CTRL_EXT);
 	u32 ctrl = er32(CTRL);
 
-	/* save CTRL_EXT to restore later, reuse an empty variable (unused
-	   on mac_type 80003es2lan) */
+	/*
+	 * save CTRL_EXT to restore later, reuse an empty variable (unused
+	 * on mac_type 80003es2lan)
+	 */
 	adapter->tx_fifo_head = ctrlext;
 
 	/* clear the serdes mode bits, putting the device into mac loopback */
@@ -1350,8 +1371,7 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 		if (hw->media_type == e1000_media_type_fiber ||
 		    hw->media_type == e1000_media_type_internal_serdes) {
 			/* restore CTRL_EXT, stealing space from tx_fifo_head */
-			ew32(CTRL_EXT,
-					adapter->tx_fifo_head);
+			ew32(CTRL_EXT, adapter->tx_fifo_head);
 			adapter->tx_fifo_head = 0;
 		}
 		/* fall through */
@@ -1414,7 +1434,8 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 
 	ew32(RDT, rx_ring->count - 1);
 
-	/* Calculate the loop count based on the largest descriptor ring
+	/*
+	 * Calculate the loop count based on the largest descriptor ring
 	 * The idea is to wrap the largest ring a number of times using 64
 	 * send/receive pairs during each loop
 	 */
@@ -1454,7 +1475,8 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 			l++;
 			if (l == rx_ring->count)
 				l = 0;
-			/* time + 20 msecs (200 msecs on 2.4) is more than
+			/*
+			 * time + 20 msecs (200 msecs on 2.4) is more than
 			 * enough time to complete the receives, if it's
 			 * exceeded, break and error off
 			 */
@@ -1473,8 +1495,10 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 
 static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 {
-	/* PHY loopback cannot be performed if SoL/IDER
-	 * sessions are active */
+	/*
+	 * PHY loopback cannot be performed if SoL/IDER
+	 * sessions are active
+	 */
 	if (e1000_check_reset_block(&adapter->hw)) {
 		ndev_err(adapter->netdev, "Cannot do PHY loopback test "
 			 "when SoL/IDER is active.\n");
@@ -1508,8 +1532,10 @@ static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 		int i = 0;
 		hw->mac.serdes_has_link = 0;
 
-		/* On some blade server designs, link establishment
-		 * could take as long as 2-3 minutes */
+		/*
+		 * On some blade server designs, link establishment
+		 * could take as long as 2-3 minutes
+		 */
 		do {
 			hw->mac.ops.check_for_link(hw);
 			if (hw->mac.serdes_has_link)
@@ -1562,8 +1588,10 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		ndev_info(netdev, "offline testing starting\n");
 
-		/* Link test performed before hardware reset so autoneg doesn't
-		 * interfere with test result */
+		/*
+		 * Link test performed before hardware reset so autoneg doesn't
+		 * interfere with test result
+		 */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
@@ -1768,8 +1796,7 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
 
 	switch (stringset) {
 	case ETH_SS_TEST:
-		memcpy(data, *e1000_gstrings_test,
-			sizeof(e1000_gstrings_test));
+		memcpy(data, *e1000_gstrings_test, sizeof(e1000_gstrings_test));
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 916025b..2346e2c 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -66,14 +66,14 @@ enum e1e_registers {
 	E1000_IMS      = 0x000D0, /* Interrupt Mask Set - RW */
 	E1000_IMC      = 0x000D8, /* Interrupt Mask Clear - WO */
 	E1000_IAM      = 0x000E0, /* Interrupt Acknowledge Auto Mask */
-	E1000_RCTL     = 0x00100, /* RX Control - RW */
+	E1000_RCTL     = 0x00100, /* Rx Control - RW */
 	E1000_FCTTV    = 0x00170, /* Flow Control Transmit Timer Value - RW */
-	E1000_TXCW     = 0x00178, /* TX Configuration Word - RW */
-	E1000_RXCW     = 0x00180, /* RX Configuration Word - RO */
-	E1000_TCTL     = 0x00400, /* TX Control - RW */
-	E1000_TCTL_EXT = 0x00404, /* Extended TX Control - RW */
-	E1000_TIPG     = 0x00410, /* TX Inter-packet gap -RW */
-	E1000_AIT      = 0x00458, /* Adaptive Interframe Spacing Throttle - RW */
+	E1000_TXCW     = 0x00178, /* Tx Configuration Word - RW */
+	E1000_RXCW     = 0x00180, /* Rx Configuration Word - RO */
+	E1000_TCTL     = 0x00400, /* Tx Control - RW */
+	E1000_TCTL_EXT = 0x00404, /* Extended Tx Control - RW */
+	E1000_TIPG     = 0x00410, /* Tx Inter-packet gap -RW */
+	E1000_AIT      = 0x00458, /* Adaptive Interframe Spacing Throttle -RW */
 	E1000_LEDCTL   = 0x00E00, /* LED Control - RW */
 	E1000_EXTCNF_CTRL  = 0x00F00, /* Extended Configuration Control */
 	E1000_EXTCNF_SIZE  = 0x00F08, /* Extended Configuration Size */
@@ -87,12 +87,12 @@ enum e1e_registers {
 	E1000_FCRTL    = 0x02160, /* Flow Control Receive Threshold Low - RW */
 	E1000_FCRTH    = 0x02168, /* Flow Control Receive Threshold High - RW */
 	E1000_PSRCTL   = 0x02170, /* Packet Split Receive Control - RW */
-	E1000_RDBAL    = 0x02800, /* RX Descriptor Base Address Low - RW */
-	E1000_RDBAH    = 0x02804, /* RX Descriptor Base Address High - RW */
-	E1000_RDLEN    = 0x02808, /* RX Descriptor Length - RW */
-	E1000_RDH      = 0x02810, /* RX Descriptor Head - RW */
-	E1000_RDT      = 0x02818, /* RX Descriptor Tail - RW */
-	E1000_RDTR     = 0x02820, /* RX Delay Timer - RW */
+	E1000_RDBAL    = 0x02800, /* Rx Descriptor Base Address Low - RW */
+	E1000_RDBAH    = 0x02804, /* Rx Descriptor Base Address High - RW */
+	E1000_RDLEN    = 0x02808, /* Rx Descriptor Length - RW */
+	E1000_RDH      = 0x02810, /* Rx Descriptor Head - RW */
+	E1000_RDT      = 0x02818, /* Rx Descriptor Tail - RW */
+	E1000_RDTR     = 0x02820, /* Rx Delay Timer - RW */
 	E1000_RADV     = 0x0282C, /* RX Interrupt Absolute Delay Timer - RW */
 
 /* Convenience macros
@@ -105,17 +105,17 @@ enum e1e_registers {
  */
 #define E1000_RDBAL_REG(_n)   (E1000_RDBAL + (_n << 8))
 	E1000_KABGTXD  = 0x03004, /* AFE Band Gap Transmit Ref Data */
-	E1000_TDBAL    = 0x03800, /* TX Descriptor Base Address Low - RW */
-	E1000_TDBAH    = 0x03804, /* TX Descriptor Base Address High - RW */
-	E1000_TDLEN    = 0x03808, /* TX Descriptor Length - RW */
-	E1000_TDH      = 0x03810, /* TX Descriptor Head - RW */
-	E1000_TDT      = 0x03818, /* TX Descriptor Tail - RW */
-	E1000_TIDV     = 0x03820, /* TX Interrupt Delay Value - RW */
-	E1000_TXDCTL   = 0x03828, /* TX Descriptor Control - RW */
-	E1000_TADV     = 0x0382C, /* TX Interrupt Absolute Delay Val - RW */
-	E1000_TARC0    = 0x03840, /* TX Arbitration Count (0) */
-	E1000_TXDCTL1  = 0x03928, /* TX Descriptor Control (1) - RW */
-	E1000_TARC1    = 0x03940, /* TX Arbitration Count (1) */
+	E1000_TDBAL    = 0x03800, /* Tx Descriptor Base Address Low - RW */
+	E1000_TDBAH    = 0x03804, /* Tx Descriptor Base Address High - RW */
+	E1000_TDLEN    = 0x03808, /* Tx Descriptor Length - RW */
+	E1000_TDH      = 0x03810, /* Tx Descriptor Head - RW */
+	E1000_TDT      = 0x03818, /* Tx Descriptor Tail - RW */
+	E1000_TIDV     = 0x03820, /* Tx Interrupt Delay Value - RW */
+	E1000_TXDCTL   = 0x03828, /* Tx Descriptor Control - RW */
+	E1000_TADV     = 0x0382C, /* Tx Interrupt Absolute Delay Val - RW */
+	E1000_TARC0    = 0x03840, /* Tx Arbitration Count (0) */
+	E1000_TXDCTL1  = 0x03928, /* Tx Descriptor Control (1) - RW */
+	E1000_TARC1    = 0x03940, /* Tx Arbitration Count (1) */
 	E1000_CRCERRS  = 0x04000, /* CRC Error Count - R/clr */
 	E1000_ALGNERRC = 0x04004, /* Alignment Error Count - R/clr */
 	E1000_SYMERRS  = 0x04008, /* Symbol Error Count - R/clr */
@@ -127,53 +127,53 @@ enum e1e_registers {
 	E1000_LATECOL  = 0x04020, /* Late Collision Count - R/clr */
 	E1000_COLC     = 0x04028, /* Collision Count - R/clr */
 	E1000_DC       = 0x04030, /* Defer Count - R/clr */
-	E1000_TNCRS    = 0x04034, /* TX-No CRS - R/clr */
+	E1000_TNCRS    = 0x04034, /* Tx-No CRS - R/clr */
 	E1000_SEC      = 0x04038, /* Sequence Error Count - R/clr */
 	E1000_CEXTERR  = 0x0403C, /* Carrier Extension Error Count - R/clr */
 	E1000_RLEC     = 0x04040, /* Receive Length Error Count - R/clr */
-	E1000_XONRXC   = 0x04048, /* XON RX Count - R/clr */
-	E1000_XONTXC   = 0x0404C, /* XON TX Count - R/clr */
-	E1000_XOFFRXC  = 0x04050, /* XOFF RX Count - R/clr */
-	E1000_XOFFTXC  = 0x04054, /* XOFF TX Count - R/clr */
-	E1000_FCRUC    = 0x04058, /* Flow Control RX Unsupported Count- R/clr */
-	E1000_PRC64    = 0x0405C, /* Packets RX (64 bytes) - R/clr */
-	E1000_PRC127   = 0x04060, /* Packets RX (65-127 bytes) - R/clr */
-	E1000_PRC255   = 0x04064, /* Packets RX (128-255 bytes) - R/clr */
-	E1000_PRC511   = 0x04068, /* Packets RX (255-511 bytes) - R/clr */
-	E1000_PRC1023  = 0x0406C, /* Packets RX (512-1023 bytes) - R/clr */
-	E1000_PRC1522  = 0x04070, /* Packets RX (1024-1522 bytes) - R/clr */
-	E1000_GPRC     = 0x04074, /* Good Packets RX Count - R/clr */
-	E1000_BPRC     = 0x04078, /* Broadcast Packets RX Count - R/clr */
-	E1000_MPRC     = 0x0407C, /* Multicast Packets RX Count - R/clr */
-	E1000_GPTC     = 0x04080, /* Good Packets TX Count - R/clr */
-	E1000_GORCL    = 0x04088, /* Good Octets RX Count Low - R/clr */
-	E1000_GORCH    = 0x0408C, /* Good Octets RX Count High - R/clr */
-	E1000_GOTCL    = 0x04090, /* Good Octets TX Count Low - R/clr */
-	E1000_GOTCH    = 0x04094, /* Good Octets TX Count High - R/clr */
-	E1000_RNBC     = 0x040A0, /* RX No Buffers Count - R/clr */
-	E1000_RUC      = 0x040A4, /* RX Undersize Count - R/clr */
-	E1000_RFC      = 0x040A8, /* RX Fragment Count - R/clr */
-	E1000_ROC      = 0x040AC, /* RX Oversize Count - R/clr */
-	E1000_RJC      = 0x040B0, /* RX Jabber Count - R/clr */
-	E1000_MGTPRC   = 0x040B4, /* Management Packets RX Count - R/clr */
+	E1000_XONRXC   = 0x04048, /* XON Rx Count - R/clr */
+	E1000_XONTXC   = 0x0404C, /* XON Tx Count - R/clr */
+	E1000_XOFFRXC  = 0x04050, /* XOFF Rx Count - R/clr */
+	E1000_XOFFTXC  = 0x04054, /* XOFF Tx Count - R/clr */
+	E1000_FCRUC    = 0x04058, /* Flow Control Rx Unsupported Count- R/clr */
+	E1000_PRC64    = 0x0405C, /* Packets Rx (64 bytes) - R/clr */
+	E1000_PRC127   = 0x04060, /* Packets Rx (65-127 bytes) - R/clr */
+	E1000_PRC255   = 0x04064, /* Packets Rx (128-255 bytes) - R/clr */
+	E1000_PRC511   = 0x04068, /* Packets Rx (255-511 bytes) - R/clr */
+	E1000_PRC1023  = 0x0406C, /* Packets Rx (512-1023 bytes) - R/clr */
+	E1000_PRC1522  = 0x04070, /* Packets Rx (1024-1522 bytes) - R/clr */
+	E1000_GPRC     = 0x04074, /* Good Packets Rx Count - R/clr */
+	E1000_BPRC     = 0x04078, /* Broadcast Packets Rx Count - R/clr */
+	E1000_MPRC     = 0x0407C, /* Multicast Packets Rx Count - R/clr */
+	E1000_GPTC     = 0x04080, /* Good Packets Tx Count - R/clr */
+	E1000_GORCL    = 0x04088, /* Good Octets Rx Count Low - R/clr */
+	E1000_GORCH    = 0x0408C, /* Good Octets Rx Count High - R/clr */
+	E1000_GOTCL    = 0x04090, /* Good Octets Tx Count Low - R/clr */
+	E1000_GOTCH    = 0x04094, /* Good Octets Tx Count High - R/clr */
+	E1000_RNBC     = 0x040A0, /* Rx No Buffers Count - R/clr */
+	E1000_RUC      = 0x040A4, /* Rx Undersize Count - R/clr */
+	E1000_RFC      = 0x040A8, /* Rx Fragment Count - R/clr */
+	E1000_ROC      = 0x040AC, /* Rx Oversize Count - R/clr */
+	E1000_RJC      = 0x040B0, /* Rx Jabber Count - R/clr */
+	E1000_MGTPRC   = 0x040B4, /* Management Packets Rx Count - R/clr */
 	E1000_MGTPDC   = 0x040B8, /* Management Packets Dropped Count - R/clr */
-	E1000_MGTPTC   = 0x040BC, /* Management Packets TX Count - R/clr */
-	E1000_TORL     = 0x040C0, /* Total Octets RX Low - R/clr */
-	E1000_TORH     = 0x040C4, /* Total Octets RX High - R/clr */
-	E1000_TOTL     = 0x040C8, /* Total Octets TX Low - R/clr */
-	E1000_TOTH     = 0x040CC, /* Total Octets TX High - R/clr */
-	E1000_TPR      = 0x040D0, /* Total Packets RX - R/clr */
-	E1000_TPT      = 0x040D4, /* Total Packets TX - R/clr */
-	E1000_PTC64    = 0x040D8, /* Packets TX (64 bytes) - R/clr */
-	E1000_PTC127   = 0x040DC, /* Packets TX (65-127 bytes) - R/clr */
-	E1000_PTC255   = 0x040E0, /* Packets TX (128-255 bytes) - R/clr */
-	E1000_PTC511   = 0x040E4, /* Packets TX (256-511 bytes) - R/clr */
-	E1000_PTC1023  = 0x040E8, /* Packets TX (512-1023 bytes) - R/clr */
-	E1000_PTC1522  = 0x040EC, /* Packets TX (1024-1522 Bytes) - R/clr */
-	E1000_MPTC     = 0x040F0, /* Multicast Packets TX Count - R/clr */
-	E1000_BPTC     = 0x040F4, /* Broadcast Packets TX Count - R/clr */
-	E1000_TSCTC    = 0x040F8, /* TCP Segmentation Context TX - R/clr */
-	E1000_TSCTFC   = 0x040FC, /* TCP Segmentation Context TX Fail - R/clr */
+	E1000_MGTPTC   = 0x040BC, /* Management Packets Tx Count - R/clr */
+	E1000_TORL     = 0x040C0, /* Total Octets Rx Low - R/clr */
+	E1000_TORH     = 0x040C4, /* Total Octets Rx High - R/clr */
+	E1000_TOTL     = 0x040C8, /* Total Octets Tx Low - R/clr */
+	E1000_TOTH     = 0x040CC, /* Total Octets Tx High - R/clr */
+	E1000_TPR      = 0x040D0, /* Total Packets Rx - R/clr */
+	E1000_TPT      = 0x040D4, /* Total Packets Tx - R/clr */
+	E1000_PTC64    = 0x040D8, /* Packets Tx (64 bytes) - R/clr */
+	E1000_PTC127   = 0x040DC, /* Packets Tx (65-127 bytes) - R/clr */
+	E1000_PTC255   = 0x040E0, /* Packets Tx (128-255 bytes) - R/clr */
+	E1000_PTC511   = 0x040E4, /* Packets Tx (256-511 bytes) - R/clr */
+	E1000_PTC1023  = 0x040E8, /* Packets Tx (512-1023 bytes) - R/clr */
+	E1000_PTC1522  = 0x040EC, /* Packets Tx (1024-1522 Bytes) - R/clr */
+	E1000_MPTC     = 0x040F0, /* Multicast Packets Tx Count - R/clr */
+	E1000_BPTC     = 0x040F4, /* Broadcast Packets Tx Count - R/clr */
+	E1000_TSCTC    = 0x040F8, /* TCP Segmentation Context Tx - R/clr */
+	E1000_TSCTFC   = 0x040FC, /* TCP Segmentation Context Tx Fail - R/clr */
 	E1000_IAC      = 0x04100, /* Interrupt Assertion Count */
 	E1000_ICRXPTC  = 0x04104, /* Irq Cause Rx Packet Timer Expire Count */
 	E1000_ICRXATC  = 0x04108, /* Irq Cause Rx Abs Timer Expire Count */
@@ -183,7 +183,7 @@ enum e1e_registers {
 	E1000_ICTXQMTC = 0x0411C, /* Irq Cause Tx Queue MinThreshold Count */
 	E1000_ICRXDMTC = 0x04120, /* Irq Cause Rx Desc MinThreshold Count */
 	E1000_ICRXOC   = 0x04124, /* Irq Cause Receiver Overrun Count */
-	E1000_RXCSUM   = 0x05000, /* RX Checksum Control - RW */
+	E1000_RXCSUM   = 0x05000, /* Rx Checksum Control - RW */
 	E1000_RFCTL    = 0x05008, /* Receive Filter Control */
 	E1000_MTA      = 0x05200, /* Multicast Table Array - RW Array */
 	E1000_RA       = 0x05400, /* Receive Address - RW Array */
@@ -250,8 +250,8 @@ enum e1e_registers {
 #define E1000_VFTA_ENTRY_BIT_SHIFT_MASK	0x1F
 
 #define E1000_HICR_EN			0x01  /* Enable bit - RO */
-#define E1000_HICR_C			0x02  /* Driver sets this bit when done
-					       * to put command in RAM */
+/* Driver sets this bit when done to put command in RAM */
+#define E1000_HICR_C			0x02
 #define E1000_HICR_FW_RESET_ENABLE	0x40
 #define E1000_HICR_FW_RESET		0x80
 
@@ -685,8 +685,7 @@ struct e1000_mac_operations {
 	s32  (*get_link_up_info)(struct e1000_hw *, u16 *, u16 *);
 	s32  (*led_on)(struct e1000_hw *);
 	s32  (*led_off)(struct e1000_hw *);
-	void (*mc_addr_list_update)(struct e1000_hw *, u8 *, u32, u32,
-					 u32);
+	void (*mc_addr_list_update)(struct e1000_hw *, u8 *, u32, u32, u32);
 	s32  (*reset_hw)(struct e1000_hw *);
 	s32  (*init_hw)(struct e1000_hw *);
 	s32  (*setup_link)(struct e1000_hw *);
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 0ae3955..8440156 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -243,8 +243,7 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 	u32 sector_end_addr;
 	u16 i;
 
-	/* Can't read flash registers if the register set isn't mapped.
-	 */
+	/* Can't read flash registers if the register set isn't mapped. */
 	if (!hw->flash_address) {
 		hw_dbg(hw, "ERROR: Flash registers not mapped\n");
 		return -E1000_ERR_CONFIG;
@@ -254,17 +253,21 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 
 	gfpreg = er32flash(ICH_FLASH_GFPREG);
 
-	/* sector_X_addr is a "sector"-aligned address (4096 bytes)
+	/*
+	 * sector_X_addr is a "sector"-aligned address (4096 bytes)
 	 * Add 1 to sector_end_addr since this sector is included in
-	 * the overall size. */
+	 * the overall size.
+	 */
 	sector_base_addr = gfpreg & FLASH_GFPREG_BASE_MASK;
 	sector_end_addr = ((gfpreg >> 16) & FLASH_GFPREG_BASE_MASK) + 1;
 
 	/* flash_base_addr is byte-aligned */
 	nvm->flash_base_addr = sector_base_addr << FLASH_SECTOR_ADDR_SHIFT;
 
-	/* find total size of the NVM, then cut in half since the total
-	 * size represents two separate NVM banks. */
+	/*
+	 * find total size of the NVM, then cut in half since the total
+	 * size represents two separate NVM banks.
+	 */
 	nvm->flash_bank_size = (sector_end_addr - sector_base_addr)
 				<< FLASH_SECTOR_ADDR_SHIFT;
 	nvm->flash_bank_size /= 2;
@@ -496,7 +499,8 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Initialize the PHY from the NVM on ICH platforms.  This
+	/*
+	 * Initialize the PHY from the NVM on ICH platforms.  This
 	 * is needed due to an issue where the NVM configuration is
 	 * not properly autoloaded after power transitions.
 	 * Therefore, after each PHY reset, we will load the
@@ -523,7 +527,8 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 			udelay(100);
 		} while ((!data) && --loop);
 
-		/* If basic configuration is incomplete before the above loop
+		/*
+		 * If basic configuration is incomplete before the above loop
 		 * count reaches 0, loading the configuration from NVM will
 		 * leave the PHY in a bad state possibly resulting in no link.
 		 */
@@ -536,8 +541,10 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 		data &= ~E1000_STATUS_LAN_INIT_DONE;
 		ew32(STATUS, data);
 
-		/* Make sure HW does not configure LCD from PHY
-		 * extended configuration before SW configuration */
+		/*
+		 * Make sure HW does not configure LCD from PHY
+		 * extended configuration before SW configuration
+		 */
 		data = er32(EXTCNF_CTRL);
 		if (data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE)
 			return 0;
@@ -551,8 +558,7 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 		cnf_base_addr = data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK;
 		cnf_base_addr >>= E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT;
 
-		/* Configure LCD from extended configuration
-		 * region. */
+		/* Configure LCD from extended configuration region. */
 
 		/* cnf_base_addr is in DWORD */
 		word_addr = (u16)(cnf_base_addr << 1);
@@ -681,8 +687,8 @@ static s32 e1000_check_polarity_ife_ich8lan(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data, offset, mask;
 
-	/* Polarity is determined based on the reversal feature
-	 * being enabled.
+	/*
+	 * Polarity is determined based on the reversal feature being enabled.
 	 */
 	if (phy->polarity_correction) {
 		offset	= IFE_PHY_EXTENDED_STATUS_CONTROL;
@@ -731,8 +737,10 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
 
-		/* Call gig speed drop workaround on LPLU before accessing
-		 * any PHY registers */
+		/*
+		 * Call gig speed drop workaround on LPLU before accessing
+		 * any PHY registers
+		 */
 		if ((hw->mac.type == e1000_ich8lan) &&
 		    (hw->phy.type == e1000_phy_igp_3))
 			e1000e_gig_downshift_workaround_ich8lan(hw);
@@ -747,30 +755,32 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		phy_ctrl &= ~E1000_PHY_CTRL_D0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
 
-		/* LPLU and SmartSpeed are mutually exclusive.  LPLU is used
+		/*
+		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
 		 * important.  During driver activity we should enable
-		 * SmartSpeed, so performance is maintained. */
+		 * SmartSpeed, so performance is maintained.
+		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		}
@@ -804,34 +814,32 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 	if (!active) {
 		phy_ctrl &= ~E1000_PHY_CTRL_NOND0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
-		/* LPLU and SmartSpeed are mutually exclusive.  LPLU is used
+		/*
+		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
 		 * important.  During driver activity we should enable
-		 * SmartSpeed, so performance is maintained. */
+		 * SmartSpeed, so performance is maintained.
+		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
-			ret_val = e1e_rphy(hw,
-						    IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = e1e_wphy(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
+					   data);
 			if (ret_val)
 				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
-			ret_val = e1e_rphy(hw,
-						    IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = e1e_wphy(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
+					   data);
 			if (ret_val)
 				return ret_val;
 		}
@@ -841,23 +849,21 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		phy_ctrl |= E1000_PHY_CTRL_NOND0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
 
-		/* Call gig speed drop workaround on LPLU before accessing
-		 * any PHY registers */
+		/*
+		 * Call gig speed drop workaround on LPLU before accessing
+		 * any PHY registers
+		 */
 		if ((hw->mac.type == e1000_ich8lan) &&
 		    (hw->phy.type == e1000_phy_igp_3))
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
-		ret_val = e1e_rphy(hw,
-					    IGP01E1000_PHY_PORT_CONFIG,
-					    &data);
+		ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG, &data);
 		if (ret_val)
 			return ret_val;
 
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-		ret_val = e1e_wphy(hw,
-					     IGP01E1000_PHY_PORT_CONFIG,
-					     data);
+		ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG, data);
 	}
 
 	return 0;
@@ -944,7 +950,8 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 
 	ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 
-	/* Either we should have a hardware SPI cycle in progress
+	/*
+	 * Either we should have a hardware SPI cycle in progress
 	 * bit to check against, in order to start a new cycle or
 	 * FDONE bit should be changed in the hardware so that it
 	 * is 1 after hardware reset, which can then be used as an
@@ -953,15 +960,19 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 	 */
 
 	if (hsfsts.hsf_status.flcinprog == 0) {
-		/* There is no cycle running at present,
-		 * so we can start a cycle */
-		/* Begin by setting Flash Cycle Done. */
+		/*
+		 * There is no cycle running at present,
+		 * so we can start a cycle
+		 * Begin by setting Flash Cycle Done.
+		 */
 		hsfsts.hsf_status.flcdone = 1;
 		ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 		ret_val = 0;
 	} else {
-		/* otherwise poll for sometime so the current
-		 * cycle has a chance to end before giving up. */
+		/*
+		 * otherwise poll for sometime so the current
+		 * cycle has a chance to end before giving up.
+		 */
 		for (i = 0; i < ICH_FLASH_READ_COMMAND_TIMEOUT; i++) {
 			hsfsts.regval = __er16flash(hw, ICH_FLASH_HSFSTS);
 			if (hsfsts.hsf_status.flcinprog == 0) {
@@ -971,8 +982,10 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 			udelay(1);
 		}
 		if (ret_val == 0) {
-			/* Successful in waiting for previous cycle to timeout,
-			 * now set the Flash Cycle Done. */
+			/*
+			 * Successful in waiting for previous cycle to timeout,
+			 * now set the Flash Cycle Done.
+			 */
 			hsfsts.hsf_status.flcdone = 1;
 			ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 		} else {
@@ -1077,10 +1090,12 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		ret_val = e1000_flash_cycle_ich8lan(hw,
 						ICH_FLASH_READ_COMMAND_TIMEOUT);
 
-		/* Check if FCERR is set to 1, if set to 1, clear it
+		/*
+		 * Check if FCERR is set to 1, if set to 1, clear it
 		 * and try the whole sequence a few more times, else
 		 * read in (shift in) the Flash Data0, the order is
-		 * least significant byte first msb to lsb */
+		 * least significant byte first msb to lsb
+		 */
 		if (ret_val == 0) {
 			flash_data = er32flash(ICH_FLASH_FDATA0);
 			if (size == 1) {
@@ -1090,7 +1105,8 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 			}
 			break;
 		} else {
-			/* If we've gotten here, then things are probably
+			/*
+			 * If we've gotten here, then things are probably
 			 * completely hosed, but if the error condition is
 			 * detected, it won't hurt to give it another try...
 			 * ICH_FLASH_CYCLE_REPEAT_COUNT times.
@@ -1168,18 +1184,20 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 
 	ret_val = e1000e_update_nvm_checksum_generic(hw);
 	if (ret_val)
-		return ret_val;;
+		return ret_val;
 
 	if (nvm->type != e1000_nvm_flash_sw)
-		return ret_val;;
+		return ret_val;
 
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
 	if (ret_val)
-		return ret_val;;
+		return ret_val;
 
-	/* We're writing to the opposite bank so if we're on bank 1,
+	/*
+	 * We're writing to the opposite bank so if we're on bank 1,
 	 * write to bank 0 etc.  We also need to erase the segment that
-	 * is going to be written */
+	 * is going to be written
+	 */
 	if (!(er32(EECD) & E1000_EECD_SEC1VAL)) {
 		new_bank_offset = nvm->flash_bank_size;
 		old_bank_offset = 0;
@@ -1191,9 +1209,11 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	}
 
 	for (i = 0; i < E1000_ICH8_SHADOW_RAM_WORDS; i++) {
-		/* Determine whether to write the value stored
+		/*
+		 * Determine whether to write the value stored
 		 * in the other NVM bank or a modified value stored
-		 * in the shadow RAM */
+		 * in the shadow RAM
+		 */
 		if (dev_spec->shadow_ram[i].modified) {
 			data = dev_spec->shadow_ram[i].value;
 		} else {
@@ -1202,12 +1222,14 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 						      &data);
 		}
 
-		/* If the word is 0x13, then make sure the signature bits
+		/*
+		 * If the word is 0x13, then make sure the signature bits
 		 * (15:14) are 11b until the commit has completed.
 		 * This will allow us to write 10b which indicates the
 		 * signature is valid.  We want to do this after the write
 		 * has completed so that we don't mark the segment valid
-		 * while the write is still in progress */
+		 * while the write is still in progress
+		 */
 		if (i == E1000_ICH_NVM_SIG_WORD)
 			data |= E1000_ICH_NVM_SIG_MASK;
 
@@ -1230,18 +1252,22 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 			break;
 	}
 
-	/* Don't bother writing the segment valid bits if sector
-	 * programming failed. */
+	/*
+	 * Don't bother writing the segment valid bits if sector
+	 * programming failed.
+	 */
 	if (ret_val) {
 		hw_dbg(hw, "Flash commit failed.\n");
 		e1000_release_swflag_ich8lan(hw);
 		return ret_val;
 	}
 
-	/* Finally validate the new segment by setting bit 15:14
+	/*
+	 * Finally validate the new segment by setting bit 15:14
 	 * to 10b in word 0x13 , this can be done without an
 	 * erase as well since these bits are 11 to start with
-	 * and we need to change bit 14 to 0b */
+	 * and we need to change bit 14 to 0b
+	 */
 	act_offset = new_bank_offset + E1000_ICH_NVM_SIG_WORD;
 	e1000_read_flash_word_ich8lan(hw, act_offset, &data);
 	data &= 0xBFFF;
@@ -1253,10 +1279,12 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	/* And invalidate the previously valid segment by setting
+	/*
+	 * And invalidate the previously valid segment by setting
 	 * its signature word (0x13) high_byte to 0b. This can be
 	 * done without an erase because flash erase sets all bits
-	 * to 1's. We can write 1's to 0's without an erase */
+	 * to 1's. We can write 1's to 0's without an erase
+	 */
 	act_offset = (old_bank_offset + E1000_ICH_NVM_SIG_WORD) * 2 + 1;
 	ret_val = e1000_retry_write_flash_byte_ich8lan(hw, act_offset, 0);
 	if (ret_val) {
@@ -1272,7 +1300,8 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 
 	e1000_release_swflag_ich8lan(hw);
 
-	/* Reload the EEPROM, or else modifications will not appear
+	/*
+	 * Reload the EEPROM, or else modifications will not appear
 	 * until after the next adapter reset.
 	 */
 	e1000e_reload_nvm(hw);
@@ -1294,7 +1323,8 @@ static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 data;
 
-	/* Read 0x19 and check bit 6.  If this bit is 0, the checksum
+	/*
+	 * Read 0x19 and check bit 6.  If this bit is 0, the checksum
 	 * needs to be fixed.  This bit is an indication that the NVM
 	 * was prepared by OEM software and did not calculate the
 	 * checksum...a likely scenario.
@@ -1364,14 +1394,17 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 
 		ew32flash(ICH_FLASH_FDATA0, flash_data);
 
-		/* check if FCERR is set to 1 , if set to 1, clear it
-		 * and try the whole sequence a few more times else done */
+		/*
+		 * check if FCERR is set to 1 , if set to 1, clear it
+		 * and try the whole sequence a few more times else done
+		 */
 		ret_val = e1000_flash_cycle_ich8lan(hw,
 					       ICH_FLASH_WRITE_COMMAND_TIMEOUT);
 		if (!ret_val)
 			break;
 
-		/* If we're here, then things are most likely
+		/*
+		 * If we're here, then things are most likely
 		 * completely hosed, but if the error condition
 		 * is detected, it won't hurt to give it another
 		 * try...ICH_FLASH_CYCLE_REPEAT_COUNT times.
@@ -1462,9 +1495,10 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 
 	hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
 
-	/* Determine HW Sector size: Read BERASE bits of hw flash status
-	 * register */
-	/* 00: The Hw sector is 256 bytes, hence we need to erase 16
+	/*
+	 * Determine HW Sector size: Read BERASE bits of hw flash status
+	 * register
+	 * 00: The Hw sector is 256 bytes, hence we need to erase 16
 	 *     consecutive sectors.  The start index for the nth Hw sector
 	 *     can be calculated as = bank * 4096 + n * 256
 	 * 01: The Hw sector is 4K bytes, hence we need to erase 1 sector.
@@ -1511,13 +1545,16 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 			if (ret_val)
 				return ret_val;
 
-			/* Write a value 11 (block Erase) in Flash
-			 * Cycle field in hw flash control */
+			/*
+			 * Write a value 11 (block Erase) in Flash
+			 * Cycle field in hw flash control
+			 */
 			hsflctl.regval = er16flash(ICH_FLASH_HSFCTL);
 			hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_ERASE;
 			ew16flash(ICH_FLASH_HSFCTL, hsflctl.regval);
 
-			/* Write the last 24 bits of an index within the
+			/*
+			 * Write the last 24 bits of an index within the
 			 * block into Flash Linear address field in Flash
 			 * Address.
 			 */
@@ -1529,13 +1566,14 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 			if (ret_val == 0)
 				break;
 
-			/* Check if FCERR is set to 1.  If 1,
+			/*
+			 * Check if FCERR is set to 1.  If 1,
 			 * clear it and try the whole sequence
-			 * a few more times else Done */
+			 * a few more times else Done
+			 */
 			hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
 			if (hsfsts.hsf_status.flcerr == 1)
-				/* repeat for some time before
-				 * giving up */
+				/* repeat for some time before giving up */
 				continue;
 			else if (hsfsts.hsf_status.flcdone == 0)
 				return ret_val;
@@ -1585,7 +1623,8 @@ static s32 e1000_get_bus_info_ich8lan(struct e1000_hw *hw)
 
 	ret_val = e1000e_get_bus_info_pcie(hw);
 
-	/* ICH devices are "PCI Express"-ish.  They have
+	/*
+	 * ICH devices are "PCI Express"-ish.  They have
 	 * a configuration space, but do not contain
 	 * PCI Express Capability registers, so bus width
 	 * must be hardcoded.
@@ -1608,7 +1647,8 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	u32 ctrl, icr, kab;
 	s32 ret_val;
 
-	/* Prevent the PCI-E bus from sticking if there is no TLP connection
+	/*
+	 * Prevent the PCI-E bus from sticking if there is no TLP connection
 	 * on the last TLP read/write transaction when MAC is reset.
 	 */
 	ret_val = e1000e_disable_pcie_master(hw);
@@ -1619,7 +1659,8 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	hw_dbg(hw, "Masking off all interrupts\n");
 	ew32(IMC, 0xffffffff);
 
-	/* Disable the Transmit and Receive units.  Then delay to allow
+	/*
+	 * Disable the Transmit and Receive units.  Then delay to allow
 	 * any pending transactions to complete before we hit the MAC
 	 * with the global reset.
 	 */
@@ -1640,7 +1681,8 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ctrl = er32(CTRL);
 
 	if (!e1000_check_reset_block(hw)) {
-		/* PHY HW reset requires MAC CORE reset at the same
+		/*
+		 * PHY HW reset requires MAC CORE reset at the same
 		 * time to make sure the interface between MAC and the
 		 * external PHY is reset.
 		 */
@@ -1724,8 +1766,10 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 		 E1000_TXDCTL_MAX_TX_DESC_PREFETCH;
 	ew32(TXDCTL1, txdctl);
 
-	/* ICH8 has opposite polarity of no_snoop bits.
-	 * By default, we should use snoop behavior. */
+	/*
+	 * ICH8 has opposite polarity of no_snoop bits.
+	 * By default, we should use snoop behavior.
+	 */
 	if (mac->type == e1000_ich8lan)
 		snoop = PCIE_ICH8_SNOOP_ALL;
 	else
@@ -1736,7 +1780,8 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	ctrl_ext |= E1000_CTRL_EXT_RO_DIS;
 	ew32(CTRL_EXT, ctrl_ext);
 
-	/* Clear all of the statistics registers (clear on read).  It is
+	/*
+	 * Clear all of the statistics registers (clear on read).  It is
 	 * important that we do this after we have tried to establish link
 	 * because the symbol error count will increment wildly if there
 	 * is no link.
@@ -1813,7 +1858,8 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 	if (e1000_check_reset_block(hw))
 		return 0;
 
-	/* ICH parts do not have a word in the NVM to determine
+	/*
+	 * ICH parts do not have a word in the NVM to determine
 	 * the default flow control setting, so we explicitly
 	 * set it to full.
 	 */
@@ -1853,9 +1899,11 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 	ctrl &= ~(E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
 	ew32(CTRL, ctrl);
 
-	/* Set the mac to wait the maximum time between each iteration
+	/*
+	 * Set the mac to wait the maximum time between each iteration
 	 * and increase the max iterations when polling the phy;
-	 * this fixes erroneous timeouts at 10Mbps. */
+	 * this fixes erroneous timeouts at 10Mbps.
+	 */
 	ret_val = e1000e_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
 	if (ret_val)
 		return ret_val;
@@ -1882,7 +1930,7 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
  *  @speed: pointer to store current link speed
  *  @duplex: pointer to store the current link duplex
  *
- *  Calls the generic get_speed_and_duplex to retreive the current link
+ *  Calls the generic get_speed_and_duplex to retrieve the current link
  *  information and then calls the Kumeran lock loss workaround for links at
  *  gigabit speeds.
  **/
@@ -1930,9 +1978,11 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 	if (!dev_spec->kmrn_lock_loss_workaround_enabled)
 		return 0;
 
-	/* Make sure link is up before proceeding.  If not just return.
+	/*
+	 * Make sure link is up before proceeding.  If not just return.
 	 * Attempting this while link is negotiating fouled up link
-	 * stability */
+	 * stability
+	 */
 	ret_val = e1000e_phy_has_link_generic(hw, 1, 0, &link);
 	if (!link)
 		return 0;
@@ -1961,8 +2011,10 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 		     E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 	ew32(PHY_CTRL, phy_ctrl);
 
-	/* Call gig speed drop workaround on Gig disable before accessing
-	 * any PHY registers */
+	/*
+	 * Call gig speed drop workaround on Gig disable before accessing
+	 * any PHY registers
+	 */
 	e1000e_gig_downshift_workaround_ich8lan(hw);
 
 	/* unable to acquire PCS lock */
@@ -1970,7 +2022,7 @@ static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_kmrn_lock_loss_workaound_ich8lan - Set Kumeran workaround state
+ *  e1000_set_kmrn_lock_loss_workaround_ich8lan - Set Kumeran workaround state
  *  @hw: pointer to the HW structure
  *  @state: boolean value used to set the current Kumeran workaround state
  *
@@ -2017,8 +2069,10 @@ void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
 			E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 		ew32(PHY_CTRL, reg);
 
-		/* Call gig speed drop workaround on Gig disable before
-		 * accessing any PHY registers */
+		/*
+		 * Call gig speed drop workaround on Gig disable before
+		 * accessing any PHY registers
+		 */
 		if (hw->mac.type == e1000_ich8lan)
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 073934c..b7eaff0 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -43,8 +43,8 @@ enum e1000_mng_mode {
 
 #define E1000_FACTPS_MNGCG		0x20000000
 
-#define E1000_IAMT_SIGNATURE		0x544D4149 /* Intel(R) Active Management
-						    * Technology signature */
+/* Intel(R) Active Management Technology signature */
+#define E1000_IAMT_SIGNATURE		0x544D4149
 
 /**
  *  e1000e_get_bus_info_pcie - Get PCIe bus information
@@ -142,7 +142,8 @@ void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 {
 	u32 rar_low, rar_high;
 
-	/* HW expects these in little endian so we reverse the byte order
+	/*
+	 * HW expects these in little endian so we reverse the byte order
 	 * from network order (big endian) to little endian
 	 */
 	rar_low = ((u32) addr[0] |
@@ -171,7 +172,8 @@ static void e1000_mta_set(struct e1000_hw *hw, u32 hash_value)
 {
 	u32 hash_bit, hash_reg, mta;
 
-	/* The MTA is a register array of 32-bit registers. It is
+	/*
+	 * The MTA is a register array of 32-bit registers. It is
 	 * treated like an array of (32*mta_reg_count) bits.  We want to
 	 * set bit BitArray[hash_value]. So we figure out what register
 	 * the bit is in, read it, OR in the new bit, then write
@@ -208,12 +210,15 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 	/* Register count multiplied by bits per register */
 	hash_mask = (hw->mac.mta_reg_count * 32) - 1;
 
-	/* For a mc_filter_type of 0, bit_shift is the number of left-shifts
-	 * where 0xFF would still fall within the hash mask. */
+	/*
+	 * For a mc_filter_type of 0, bit_shift is the number of left-shifts
+	 * where 0xFF would still fall within the hash mask.
+	 */
 	while (hash_mask >> bit_shift != 0xFF)
 		bit_shift++;
 
-	/* The portion of the address that is used for the hash table
+	/*
+	 * The portion of the address that is used for the hash table
 	 * is determined by the mc_filter_type setting.
 	 * The algorithm is such that there is a total of 8 bits of shifting.
 	 * The bit_shift for a mc_filter_type of 0 represents the number of
@@ -224,8 +229,8 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 	 * cases are a variation of this algorithm...essentially raising the
 	 * number of bits to shift mc_addr[5] left, while still keeping the
 	 * 8-bit shifting total.
-	 */
-	/* For example, given the following Destination MAC Address and an
+	 *
+	 * For example, given the following Destination MAC Address and an
 	 * mta register count of 128 (thus a 4096-bit vector and 0xFFF mask),
 	 * we can see that the bit_shift for case 0 is 4.  These are the hash
 	 * values resulting from each mc_filter_type...
@@ -279,7 +284,8 @@ void e1000e_mc_addr_list_update_generic(struct e1000_hw *hw,
 	u32 hash_value;
 	u32 i;
 
-	/* Load the first set of multicast addresses into the exact
+	/*
+	 * Load the first set of multicast addresses into the exact
 	 * filters (RAR).  If there are not enough to fill the RAR
 	 * array, clear the filters.
 	 */
@@ -375,7 +381,8 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 	s32 ret_val;
 	bool link;
 
-	/* We only want to go out to the PHY registers to see if Auto-Neg
+	/*
+	 * We only want to go out to the PHY registers to see if Auto-Neg
 	 * has completed and/or if our link status has changed.  The
 	 * get_link_status flag is set upon receiving a Link Status
 	 * Change or Rx Sequence Error interrupt.
@@ -383,7 +390,8 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 	if (!mac->get_link_status)
 		return 0;
 
-	/* First we want to see if the MII Status Register reports
+	/*
+	 * First we want to see if the MII Status Register reports
 	 * link.  If so, then we want to get the current speed/duplex
 	 * of the PHY.
 	 */
@@ -396,11 +404,14 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 
 	mac->get_link_status = 0;
 
-	/* Check if there was DownShift, must be checked
-	 * immediately after link-up */
+	/*
+	 * Check if there was DownShift, must be checked
+	 * immediately after link-up
+	 */
 	e1000e_check_downshift(hw);
 
-	/* If we are forcing speed/duplex, then we simply return since
+	/*
+	 * If we are forcing speed/duplex, then we simply return since
 	 * we have already determined whether we have link or not.
 	 */
 	if (!mac->autoneg) {
@@ -408,13 +419,15 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	/* Auto-Neg is enabled.  Auto Speed Detection takes care
+	/*
+	 * Auto-Neg is enabled.  Auto Speed Detection takes care
 	 * of MAC speed/duplex configuration.  So we only need to
 	 * configure Collision Distance in the MAC.
 	 */
 	e1000e_config_collision_dist(hw);
 
-	/* Configure Flow Control now that Auto-Neg has completed.
+	/*
+	 * Configure Flow Control now that Auto-Neg has completed.
 	 * First, we need to restore the desired flow control
 	 * settings because we may have had to re-autoneg with a
 	 * different link partner.
@@ -446,7 +459,8 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 	status = er32(STATUS);
 	rxcw = er32(RXCW);
 
-	/* If we don't have link (auto-negotiation failed or link partner
+	/*
+	 * If we don't have link (auto-negotiation failed or link partner
 	 * cannot auto-negotiate), the cable is plugged in (we have signal),
 	 * and our link partner is not trying to auto-negotiate with us (we
 	 * are receiving idles or data), we need to force link up. We also
@@ -477,7 +491,8 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 			return ret_val;
 		}
 	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
-		/* If we are forcing link and we are receiving /C/ ordered
+		/*
+		 * If we are forcing link and we are receiving /C/ ordered
 		 * sets, re-enable auto-negotiation in the TXCW register
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
@@ -511,7 +526,8 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 	status = er32(STATUS);
 	rxcw = er32(RXCW);
 
-	/* If we don't have link (auto-negotiation failed or link partner
+	/*
+	 * If we don't have link (auto-negotiation failed or link partner
 	 * cannot auto-negotiate), and our link partner is not trying to
 	 * auto-negotiate with us (we are receiving idles or data),
 	 * we need to force link up. We also need to give auto-negotiation
@@ -540,7 +556,8 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 			return ret_val;
 		}
 	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
-		/* If we are forcing link and we are receiving /C/ ordered
+		/*
+		 * If we are forcing link and we are receiving /C/ ordered
 		 * sets, re-enable auto-negotiation in the TXCW register
 		 * and disable forced link in the Device Control register
 		 * in an attempt to auto-negotiate with our link partner.
@@ -551,7 +568,8 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 
 		mac->serdes_has_link = 1;
 	} else if (!(E1000_TXCW_ANE & er32(TXCW))) {
-		/* If we force link for non-auto-negotiation switch, check
+		/*
+		 * If we force link for non-auto-negotiation switch, check
 		 * link status based on MAC synchronization for internal
 		 * serdes media type.
 		 */
@@ -589,7 +607,8 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 nvm_data;
 
-	/* Read and store word 0x0F of the EEPROM. This word contains bits
+	/*
+	 * Read and store word 0x0F of the EEPROM. This word contains bits
 	 * that determine the hardware's default PAUSE (flow control) mode,
 	 * a bit that determines whether the HW defaults to enabling or
 	 * disabling auto-negotiation, and the direction of the
@@ -630,7 +649,8 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val;
 
-	/* In the case of the phy reset being blocked, we already have a link.
+	/*
+	 * In the case of the phy reset being blocked, we already have a link.
 	 * We do not need to set it up again.
 	 */
 	if (e1000_check_reset_block(hw))
@@ -646,7 +666,8 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 			return ret_val;
 	}
 
-	/* We want to save off the original Flow Control configuration just
+	/*
+	 * We want to save off the original Flow Control configuration just
 	 * in case we get disconnected and then reconnected into a different
 	 * hub or switch with different Flow Control capabilities.
 	 */
@@ -659,7 +680,8 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Initialize the flow control address, type, and PAUSE timer
+	/*
+	 * Initialize the flow control address, type, and PAUSE timer
 	 * registers to their default values.  This is done even if flow
 	 * control is disabled, because it does not hurt anything to
 	 * initialize these registers.
@@ -686,7 +708,8 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 txcw;
 
-	/* Check for a software override of the flow control settings, and
+	/*
+	 * Check for a software override of the flow control settings, and
 	 * setup the device accordingly.  If auto-negotiation is enabled, then
 	 * software will have to set the "PAUSE" bits to the correct value in
 	 * the Transmit Config Word Register (TXCW) and re-start auto-
@@ -700,7 +723,7 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 	 *	  but not send pause frames).
 	 *      2:  Tx flow control is enabled (we can send pause frames but we
 	 *	  do not support receiving pause frames).
-	 *      3:  Both Rx and TX flow control (symmetric) are enabled.
+	 *      3:  Both Rx and Tx flow control (symmetric) are enabled.
 	 */
 	switch (mac->fc) {
 	case e1000_fc_none:
@@ -708,23 +731,26 @@ static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD);
 		break;
 	case e1000_fc_rx_pause:
-		/* RX Flow control is enabled and TX Flow control is disabled
+		/*
+		 * Rx Flow control is enabled and Tx Flow control is disabled
 		 * by a software over-ride. Since there really isn't a way to
-		 * advertise that we are capable of RX Pause ONLY, we will
-		 * advertise that we support both symmetric and asymmetric RX
+		 * advertise that we are capable of Rx Pause ONLY, we will
+		 * advertise that we support both symmetric and asymmetric Rx
 		 * PAUSE.  Later, we will disable the adapter's ability to send
 		 * PAUSE frames.
 		 */
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
 		break;
 	case e1000_fc_tx_pause:
-		/* TX Flow control is enabled, and RX Flow control is disabled,
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is disabled,
 		 * by a software over-ride.
 		 */
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_ASM_DIR);
 		break;
 	case e1000_fc_full:
-		/* Flow control (both RX and TX) is enabled by a software
+		/*
+		 * Flow control (both Rx and Tx) is enabled by a software
 		 * over-ride.
 		 */
 		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
@@ -754,7 +780,8 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 	u32 i, status;
 	s32 ret_val;
 
-	/* If we have a signal (the cable is plugged in, or assumed true for
+	/*
+	 * If we have a signal (the cable is plugged in, or assumed true for
 	 * serdes media) then poll for a "Link-Up" indication in the Device
 	 * Status Register.  Time-out if a link isn't seen in 500 milliseconds
 	 * seconds (Auto-negotiation should complete in less than 500
@@ -769,7 +796,8 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 	if (i == FIBER_LINK_UP_LIMIT) {
 		hw_dbg(hw, "Never got a valid link from auto-neg!!!\n");
 		mac->autoneg_failed = 1;
-		/* AutoNeg failed to achieve a link, so we'll call
+		/*
+		 * AutoNeg failed to achieve a link, so we'll call
 		 * mac->check_for_link. This routine will force the
 		 * link up if we detect a signal. This will allow us to
 		 * communicate with non-autonegotiating link partners.
@@ -811,7 +839,8 @@ s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Since auto-negotiation is enabled, take the link out of reset (the
+	/*
+	 * Since auto-negotiation is enabled, take the link out of reset (the
 	 * link will be in reset, because we previously reset the chip). This
 	 * will restart auto-negotiation.  If auto-negotiation is successful
 	 * then the link-up status bit will be set and the flow control enable
@@ -823,7 +852,8 @@ s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw)
 	e1e_flush();
 	msleep(1);
 
-	/* For these adapters, the SW defineable pin 1 is set when the optics
+	/*
+	 * For these adapters, the SW definable pin 1 is set when the optics
 	 * detect a signal.  If we have a signal, then poll for a "Link-Up"
 	 * indication.
 	 */
@@ -864,21 +894,23 @@ void e1000e_config_collision_dist(struct e1000_hw *hw)
  *
  *  Sets the flow control high/low threshold (watermark) registers.  If
  *  flow control XON frame transmission is enabled, then set XON frame
- *  tansmission as well.
+ *  transmission as well.
  **/
 s32 e1000e_set_fc_watermarks(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 fcrtl = 0, fcrth = 0;
 
-	/* Set the flow control receive threshold registers.  Normally,
+	/*
+	 * Set the flow control receive threshold registers.  Normally,
 	 * these registers will be set to a default threshold that may be
 	 * adjusted later by the driver's runtime code.  However, if the
 	 * ability to transmit pause frames is not enabled, then these
 	 * registers will be set to 0.
 	 */
 	if (mac->fc & e1000_fc_tx_pause) {
-		/* We need to set up the Receive Threshold high and low water
+		/*
+		 * We need to set up the Receive Threshold high and low water
 		 * marks as well as (optionally) enabling the transmission of
 		 * XON frames.
 		 */
@@ -909,7 +941,8 @@ s32 e1000e_force_mac_fc(struct e1000_hw *hw)
 
 	ctrl = er32(CTRL);
 
-	/* Because we didn't get link via the internal auto-negotiation
+	/*
+	 * Because we didn't get link via the internal auto-negotiation
 	 * mechanism (we either forced link or we got link via PHY
 	 * auto-neg), we have to manually enable/disable transmit an
 	 * receive flow control.
@@ -923,7 +956,7 @@ s32 e1000e_force_mac_fc(struct e1000_hw *hw)
 	 *	  frames but not send pause frames).
 	 *      2:  Tx flow control is enabled (we can send pause frames
 	 *	  frames but we do not receive pause frames).
-	 *      3:  Both Rx and TX flow control (symmetric) is enabled.
+	 *      3:  Both Rx and Tx flow control (symmetric) is enabled.
 	 *  other:  No other values should be possible at this point.
 	 */
 	hw_dbg(hw, "mac->fc = %u\n", mac->fc);
@@ -970,7 +1003,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 	u16 mii_status_reg, mii_nway_adv_reg, mii_nway_lp_ability_reg;
 	u16 speed, duplex;
 
-	/* Check for the case where we have fiber media and auto-neg failed
+	/*
+	 * Check for the case where we have fiber media and auto-neg failed
 	 * so we had to force link.  In this case, we need to force the
 	 * configuration of the MAC to match the "fc" parameter.
 	 */
@@ -988,13 +1022,15 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	/* Check for the case where we have copper media and auto-neg is
+	/*
+	 * Check for the case where we have copper media and auto-neg is
 	 * enabled.  In this case, we need to check and see if Auto-Neg
 	 * has completed, and if so, how the PHY and link partner has
 	 * flow control configured.
 	 */
 	if ((hw->media_type == e1000_media_type_copper) && mac->autoneg) {
-		/* Read the MII Status Register and check to see if AutoNeg
+		/*
+		 * Read the MII Status Register and check to see if AutoNeg
 		 * has completed.  We read this twice because this reg has
 		 * some "sticky" (latched) bits.
 		 */
@@ -1011,7 +1047,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			return ret_val;
 		}
 
-		/* The AutoNeg process has completed, so we now need to
+		/*
+		 * The AutoNeg process has completed, so we now need to
 		 * read both the Auto Negotiation Advertisement
 		 * Register (Address 4) and the Auto_Negotiation Base
 		 * Page Ability Register (Address 5) to determine how
@@ -1024,7 +1061,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		/* Two bits in the Auto Negotiation Advertisement Register
+		/*
+		 * Two bits in the Auto Negotiation Advertisement Register
 		 * (Address 4) and two bits in the Auto Negotiation Base
 		 * Page Ability Register (Address 5) determine flow control
 		 * for both the PHY and the link partner.  The following
@@ -1045,8 +1083,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		 *   1   |    1    |   0   |    0    | e1000_fc_none
 		 *   1   |    1    |   0   |    1    | e1000_fc_rx_pause
 		 *
-		 */
-		/* Are both PAUSE bits set to 1?  If so, this implies
+		 *
+		 * Are both PAUSE bits set to 1?  If so, this implies
 		 * Symmetric Flow Control is enabled at both ends.  The
 		 * ASM_DIR bits are irrelevant per the spec.
 		 *
@@ -1060,9 +1098,10 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		if ((mii_nway_adv_reg & NWAY_AR_PAUSE) &&
 		    (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE)) {
-			/* Now we need to check if the user selected RX ONLY
+			/*
+			 * Now we need to check if the user selected Rx ONLY
 			 * of pause frames.  In this case, we had to advertise
-			 * FULL flow control because we could not advertise RX
+			 * FULL flow control because we could not advertise Rx
 			 * ONLY. Hence, we must now check to see if we need to
 			 * turn OFF  the TRANSMISSION of PAUSE frames.
 			 */
@@ -1075,7 +1114,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 					 "RX PAUSE frames only.\r\n");
 			}
 		}
-		/* For receiving PAUSE frames ONLY.
+		/*
+		 * For receiving PAUSE frames ONLY.
 		 *
 		 *   LOCAL DEVICE  |   LINK PARTNER
 		 * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
@@ -1090,7 +1130,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			mac->fc = e1000_fc_tx_pause;
 			hw_dbg(hw, "Flow Control = TX PAUSE frames only.\r\n");
 		}
-		/* For transmitting PAUSE frames ONLY.
+		/*
+		 * For transmitting PAUSE frames ONLY.
 		 *
 		 *   LOCAL DEVICE  |   LINK PARTNER
 		 * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
@@ -1113,7 +1154,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			hw_dbg(hw, "Flow Control = NONE.\r\n");
 		}
 
-		/* Now we need to do one last check...  If we auto-
+		/*
+		 * Now we need to do one last check...  If we auto-
 		 * negotiated to HALF DUPLEX, flow control should not be
 		 * enabled per IEEE 802.3 spec.
 		 */
@@ -1126,7 +1168,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		if (duplex == HALF_DUPLEX)
 			mac->fc = e1000_fc_none;
 
-		/* Now we call a subroutine to actually force the MAC
+		/*
+		 * Now we call a subroutine to actually force the MAC
 		 * controller to use the correct flow control settings.
 		 */
 		ret_val = e1000e_force_mac_fc(hw);
@@ -1398,8 +1441,10 @@ s32 e1000e_blink_led(struct e1000_hw *hw)
 		ledctl_blink = E1000_LEDCTL_LED0_BLINK |
 		     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
 	} else {
-		/* set the blink bit for each LED that's "on" (0x0E)
-		 * in ledctl_mode2 */
+		/*
+		 * set the blink bit for each LED that's "on" (0x0E)
+		 * in ledctl_mode2
+		 */
 		ledctl_blink = hw->mac.ledctl_mode2;
 		for (i = 0; i < 4; i++)
 			if (((hw->mac.ledctl_mode2 >> (i * 8)) & 0xFF) ==
@@ -1562,8 +1607,7 @@ void e1000e_update_adaptive(struct e1000_hw *hw)
 				else
 					mac->current_ifs_val +=
 						mac->ifs_step_size;
-				ew32(AIT,
-						mac->current_ifs_val);
+				ew32(AIT, mac->current_ifs_val);
 			}
 		}
 	} else {
@@ -1826,10 +1870,12 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 		udelay(1);
 		timeout = NVM_MAX_RETRY_SPI;
 
-		/* Read "Status Register" repeatedly until the LSB is cleared.
+		/*
+		 * Read "Status Register" repeatedly until the LSB is cleared.
 		 * The EEPROM will signal that the command has been completed
 		 * by clearing bit 0 of the internal status register.  If it's
-		 * not cleared within 'timeout', then error out. */
+		 * not cleared within 'timeout', then error out.
+		 */
 		while (timeout) {
 			e1000_shift_out_eec_bits(hw, NVM_RDSR_OPCODE_SPI,
 						 hw->nvm.opcode_bits);
@@ -1866,8 +1912,10 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	u32 i, eerd = 0;
 	s32 ret_val = 0;
 
-	/* A check for invalid values:  offset too large, too many words,
-	 * and not enough words. */
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * too many words for the offset, and not enough words.
+	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
@@ -1883,8 +1931,7 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		if (ret_val)
 			break;
 
-		data[i] = (er32(EERD) >>
-			   E1000_NVM_RW_REG_DATA);
+		data[i] = (er32(EERD) >> E1000_NVM_RW_REG_DATA);
 	}
 
 	return ret_val;
@@ -1908,8 +1955,10 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	s32 ret_val;
 	u16 widx = 0;
 
-	/* A check for invalid values:  offset too large, too many words,
-	 * and not enough words. */
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * and not enough words.
+	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
@@ -1939,8 +1988,10 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 
 		e1000_standby_nvm(hw);
 
-		/* Some SPI eeproms use the 8th address bit embedded in the
-		 * opcode */
+		/*
+		 * Some SPI eeproms use the 8th address bit embedded in the
+		 * opcode
+		 */
 		if ((nvm->address_bits == 8) && (offset >= 128))
 			write_opcode |= NVM_A8_OPCODE_SPI;
 
@@ -1985,9 +2036,9 @@ s32 e1000e_read_mac_addr(struct e1000_hw *hw)
 		/* Check for an alternate MAC address.  An alternate MAC
 		 * address can be setup by pre-boot software and must be
 		 * treated like a permanent address and must override the
-		 * actual permanent MAC address. */
+		 * actual permanent MAC address.*/
 		ret_val = e1000_read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
-						&mac_addr_offset);
+					 &mac_addr_offset);
 		if (ret_val) {
 			hw_dbg(hw, "NVM Read Error\n");
 			return ret_val;
@@ -2000,7 +2051,7 @@ s32 e1000e_read_mac_addr(struct e1000_hw *hw)
 				mac_addr_offset += ETH_ALEN/sizeof(u16);
 
 			/* make sure we have a valid mac address here
-			 * before using it */
+			* before using it */
 			ret_val = e1000_read_nvm(hw, mac_addr_offset, 1,
 						 &nvm_data);
 			if (ret_val) {
@@ -2012,7 +2063,7 @@ s32 e1000e_read_mac_addr(struct e1000_hw *hw)
 		}
 
 		if (mac_addr_offset)
-			hw->dev_spec.e82571.alt_mac_addr_is_present = 1;
+		hw->dev_spec.e82571.alt_mac_addr_is_present = 1;
 	}
 
 	for (i = 0; i < ETH_ALEN; i += 2) {
@@ -2188,7 +2239,7 @@ bool e1000e_check_mng_mode(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_enable_tx_pkt_filtering - Enable packet filtering on TX
+ *  e1000e_enable_tx_pkt_filtering - Enable packet filtering on Tx
  *  @hw: pointer to the HW structure
  *
  *  Enables packet filtering on transmit packets if manageability is enabled
@@ -2208,7 +2259,8 @@ bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
 		return 0;
 	}
 
-	/* If we can't read from the host interface for whatever
+	/*
+	 * If we can't read from the host interface for whatever
 	 * reason, disable filtering.
 	 */
 	ret_val = e1000_mng_enable_host_if(hw);
@@ -2226,7 +2278,8 @@ bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
 	hdr->checksum = 0;
 	csum = e1000_calculate_checksum((u8 *)hdr,
 					E1000_MNG_DHCP_COOKIE_LENGTH);
-	/* If either the checksums or signature don't match, then
+	/*
+	 * If either the checksums or signature don't match, then
 	 * the cookie area isn't considered valid, in which case we
 	 * take the safe route of assuming Tx filtering is enabled.
 	 */
@@ -2318,8 +2371,10 @@ static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer,
 	/* Calculate length in DWORDs */
 	length >>= 2;
 
-	/* The device driver writes the relevant command block into the
-	 * ram area. */
+	/*
+	 * The device driver writes the relevant command block into the
+	 * ram area.
+	 */
 	for (i = 0; i < length; i++) {
 		for (j = 0; j < sizeof(u32); j++) {
 			*(tmp + j) = *bufptr++;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f501dd5..88fac39 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -82,7 +82,7 @@ static int e1000_desc_unused(struct e1000_ring *ring)
 }
 
 /**
- * e1000_receive_skb - helper function to handle rx indications
+ * e1000_receive_skb - helper function to handle Rx indications
  * @adapter: board private structure
  * @status: descriptor status field as written by hardware
  * @vlan: descriptor vlan field as written by hardware (no le/be conversion)
@@ -138,8 +138,9 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 		/* TCP checksum is good */
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else {
-		/* IP fragment with UDP payload */
-		/* Hardware complements the payload checksum, so we undo it
+		/*
+		 * IP fragment with UDP payload
+		 * Hardware complements the payload checksum, so we undo it
 		 * and then put the value in host order for further stack use.
 		 */
 		__sum16 sum = (__force __sum16)htons(csum);
@@ -182,7 +183,8 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 			break;
 		}
 
-		/* Make buffer alignment 2 beyond a 16 byte boundary
+		/*
+		 * Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
 		 */
@@ -213,10 +215,12 @@ map_skb:
 		if (i-- == 0)
 			i = (rx_ring->count - 1);
 
-		/* Force memory writes to complete before letting h/w
+		/*
+		 * Force memory writes to complete before letting h/w
 		 * know there are new descriptors to fetch.  (Only
 		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64). */
+		 * such as IA-64).
+		 */
 		wmb();
 		writel(i, adapter->hw.hw_addr + rx_ring->tail);
 	}
@@ -285,7 +289,8 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 			break;
 		}
 
-		/* Make buffer alignment 2 beyond a 16 byte boundary
+		/*
+		 * Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
 		 */
@@ -319,12 +324,15 @@ no_buffers:
 		if (!(i--))
 			i = (rx_ring->count - 1);
 
-		/* Force memory writes to complete before letting h/w
+		/*
+		 * Force memory writes to complete before letting h/w
 		 * know there are new descriptors to fetch.  (Only
 		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64). */
+		 * such as IA-64).
+		 */
 		wmb();
-		/* Hardware increments by 16 bytes, but packet split
+		/*
+		 * Hardware increments by 16 bytes, but packet split
 		 * descriptors are 32 bytes...so we increment tail
 		 * twice as much.
 		 */
@@ -409,9 +417,11 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		total_rx_bytes += length;
 		total_rx_packets++;
 
-		/* code added for copybreak, this should improve
+		/*
+		 * code added for copybreak, this should improve
 		 * performance for small packets with large amounts
-		 * of reassembly being done in the stack */
+		 * of reassembly being done in the stack
+		 */
 		if (length < copybreak) {
 			struct sk_buff *new_skb =
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
@@ -581,14 +591,15 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	}
 
 	if (adapter->detect_tx_hung) {
-		/* Detect a transmit hang in hardware, this serializes the
-		 * check with the clearing of time_stamp and movement of i */
+		/*
+		 * Detect a transmit hang in hardware, this serializes the
+		 * check with the clearing of time_stamp and movement of i
+		 */
 		adapter->detect_tx_hung = 0;
 		if (tx_ring->buffer_info[eop].dma &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp
 			       + (adapter->tx_timeout_factor * HZ))
-		    && !(er32(STATUS) &
-			 E1000_STATUS_TXOFF)) {
+		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 			e1000_print_tx_hang(adapter);
 			netif_stop_queue(netdev);
 		}
@@ -677,21 +688,28 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		skb_put(skb, length);
 
 		{
-		/* this looks ugly, but it seems compiler issues make it
-		   more efficient than reusing j */
+		/*
+		 * this looks ugly, but it seems compiler issues make it
+		 * more efficient than reusing j
+		 */
 		int l1 = le16_to_cpu(rx_desc->wb.upper.length[0]);
 
-		/* page alloc/put takes too long and effects small packet
-		 * throughput, so unsplit small packets and save the alloc/put*/
+		/*
+		 * page alloc/put takes too long and effects small packet
+		 * throughput, so unsplit small packets and save the alloc/put
+		 * only valid in softirq (napi) context to call kmap_*
+		 */
 		if (l1 && (l1 <= copybreak) &&
 		    ((length + l1) <= adapter->rx_ps_bsize0)) {
 			u8 *vaddr;
 
 			ps_page = &buffer_info->ps_pages[0];
 
-			/* there is no documentation about how to call
+			/*
+			 * there is no documentation about how to call
 			 * kmap_atomic, so we can't hold the mapping
-			 * very long */
+			 * very long
+			 */
 			pci_dma_sync_single_for_cpu(pdev, ps_page->dma,
 				PAGE_SIZE, PCI_DMA_FROMDEVICE);
 			vaddr = kmap_atomic(ps_page->page, KM_SKB_DATA_SOFTIRQ);
@@ -836,19 +854,25 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 icr = er32(ICR);
 
-	/* read ICR disables interrupts using IAM */
+	/*
+	 * read ICR disables interrupts using IAM
+	 */
 
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
-		/* ICH8 workaround-- Call gig speed drop workaround on cable
-		 * disconnect (LSC) before accessing any PHY registers */
+		/*
+		 * ICH8 workaround-- Call gig speed drop workaround on cable
+		 * disconnect (LSC) before accessing any PHY registers
+		 */
 		if ((adapter->flags & FLAG_LSC_GIG_SPEED_DROP) &&
 		    (!(er32(STATUS) & E1000_STATUS_LU)))
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
-		/* 80003ES2LAN workaround-- For packet buffer work-around on
+		/*
+		 * 80003ES2LAN workaround-- For packet buffer work-around on
 		 * link down event; disable receives here in the ISR and reset
-		 * adapter in watchdog */
+		 * adapter in watchdog
+		 */
 		if (netif_carrier_ok(netdev) &&
 		    adapter->flags & FLAG_RX_NEEDS_RESTART) {
 			/* disable receives */
@@ -886,23 +910,31 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	if (!icr)
 		return IRQ_NONE;  /* Not our interrupt */
 
-	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
-	 * not set, then the adapter didn't send an interrupt */
+	/*
+	 * IMS will not auto-mask if INT_ASSERTED is not set, and if it is
+	 * not set, then the adapter didn't send an interrupt
+	 */
 	if (!(icr & E1000_ICR_INT_ASSERTED))
 		return IRQ_NONE;
 
-	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
-	 * need for the IMC write */
+	/*
+	 * Interrupt Auto-Mask...upon reading ICR,
+	 * interrupts are masked.  No need for the
+	 * IMC write
+	 */
 
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
-		/* ICH8 workaround-- Call gig speed drop workaround on cable
-		 * disconnect (LSC) before accessing any PHY registers */
+		/*
+		 * ICH8 workaround-- Call gig speed drop workaround on cable
+		 * disconnect (LSC) before accessing any PHY registers
+		 */
 		if ((adapter->flags & FLAG_LSC_GIG_SPEED_DROP) &&
 		    (!(er32(STATUS) & E1000_STATUS_LU)))
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
-		/* 80003ES2LAN workaround--
+		/*
+		 * 80003ES2LAN workaround--
 		 * For packet buffer work-around on link down event;
 		 * disable receives here in the ISR and
 		 * reset adapter in watchdog
@@ -1011,8 +1043,7 @@ static void e1000_get_hw_control(struct e1000_adapter *adapter)
 		ew32(SWSM, swsm | E1000_SWSM_DRV_LOAD);
 	} else if (adapter->flags & FLAG_HAS_CTRLEXT_ON_LOAD) {
 		ctrl_ext = er32(CTRL_EXT);
-		ew32(CTRL_EXT,
-				ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
+		ew32(CTRL_EXT, ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
 	}
 }
 
@@ -1038,8 +1069,7 @@ static void e1000_release_hw_control(struct e1000_adapter *adapter)
 		ew32(SWSM, swsm & ~E1000_SWSM_DRV_LOAD);
 	} else if (adapter->flags & FLAG_HAS_CTRLEXT_ON_LOAD) {
 		ctrl_ext = er32(CTRL_EXT);
-		ew32(CTRL_EXT,
-				ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
+		ew32(CTRL_EXT, ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
 	}
 }
 
@@ -1341,9 +1371,11 @@ static void e1000_set_itr(struct e1000_adapter *adapter)
 
 set_itr_now:
 	if (new_itr != adapter->itr) {
-		/* this attempts to bias the interrupt rate towards Bulk
+		/*
+		 * this attempts to bias the interrupt rate towards Bulk
 		 * by adding intermediate steps when interrupt rate is
-		 * increasing */
+		 * increasing
+		 */
 		new_itr = new_itr > adapter->itr ?
 			     min(adapter->itr + (new_itr >> 2), new_itr) :
 			     new_itr;
@@ -1354,7 +1386,7 @@ set_itr_now:
 
 /**
  * e1000_clean - NAPI Rx polling callback
- * @adapter: board private structure
+ * @napi: struct associated with this polling callback
  * @budget: amount of packets driver is allowed to process this poll
  **/
 static int e1000_clean(struct napi_struct *napi, int budget)
@@ -1366,10 +1398,12 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
 
-	/* e1000_clean is called per-cpu.  This lock protects
+	/*
+	 * e1000_clean is called per-cpu.  This lock protects
 	 * tx_ring from being cleaned by multiple cpus
 	 * simultaneously.  A failure obtaining the lock means
-	 * tx_ring is currently being cleaned anyway. */
+	 * tx_ring is currently being cleaned anyway.
+	 */
 	if (spin_trylock(&adapter->tx_queue_lock)) {
 		tx_cleaned = e1000_clean_tx_irq(adapter);
 		spin_unlock(&adapter->tx_queue_lock);
@@ -1539,9 +1573,11 @@ static void e1000_init_manageability(struct e1000_adapter *adapter)
 
 	manc = er32(MANC);
 
-	/* enable receiving management packets to the host. this will probably
+	/*
+	 * enable receiving management packets to the host. this will probably
 	 * generate destination unreachable messages from the host OS, but
-	 * the packets will be handled on SMBUS */
+	 * the packets will be handled on SMBUS
+	 */
 	manc |= E1000_MANC_EN_MNG2HOST;
 	manc2h = er32(MANC2H);
 #define E1000_MNG2HOST_PORT_623 (1 << 5)
@@ -1591,7 +1627,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 
 	/* Set the Tx Interrupt Delay register */
 	ew32(TIDV, adapter->tx_int_delay);
-	/* tx irq moderation */
+	/* Tx irq moderation */
 	ew32(TADV, adapter->tx_abs_int_delay);
 
 	/* Program the Transmit Control Register */
@@ -1602,8 +1638,10 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 
 	if (adapter->flags & FLAG_TARC_SPEED_MODE_BIT) {
 		tarc = er32(TARC0);
-		/* set the speed mode bit, we'll clear it if we're not at
-		 * gigabit link later */
+		/*
+		 * set the speed mode bit, we'll clear it if we're not at
+		 * gigabit link later
+		 */
 #define SPEED_MODE_BIT (1 << 21)
 		tarc |= SPEED_MODE_BIT;
 		ew32(TARC0, tarc);
@@ -1724,8 +1762,10 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 		/* Configure extra packet-split registers */
 		rfctl = er32(RFCTL);
 		rfctl |= E1000_RFCTL_EXTEN;
-		/* disable packet split support for IPv6 extension headers,
-		 * because some malformed IPv6 headers can hang the RX */
+		/*
+		 * disable packet split support for IPv6 extension headers,
+		 * because some malformed IPv6 headers can hang the Rx
+		 */
 		rfctl |= (E1000_RFCTL_IPV6_EX_DIS |
 			  E1000_RFCTL_NEW_IPV6_EXT_DIS);
 
@@ -1794,8 +1834,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	/* irq moderation */
 	ew32(RADV, adapter->rx_abs_int_delay);
 	if (adapter->itr_setting != 0)
-		ew32(ITR,
-			1000000000 / (adapter->itr * 256));
+		ew32(ITR, 1000000000 / (adapter->itr * 256));
 
 	ctrl_ext = er32(CTRL_EXT);
 	/* Reset delay timers after every interrupt */
@@ -1806,8 +1845,10 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	ew32(CTRL_EXT, ctrl_ext);
 	e1e_flush();
 
-	/* Setup the HW Rx Head and Tail Descriptor Pointers and
-	 * the Base and Length of the Rx Descriptor Ring */
+	/*
+	 * Setup the HW Rx Head and Tail Descriptor Pointers and
+	 * the Base and Length of the Rx Descriptor Ring
+	 */
 	rdba = rx_ring->dma;
 	ew32(RDBAL, (rdba & DMA_32BIT_MASK));
 	ew32(RDBAH, (rdba >> 32));
@@ -1822,8 +1863,10 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	if (adapter->flags & FLAG_RX_CSUM_ENABLED) {
 		rxcsum |= E1000_RXCSUM_TUOFL;
 
-		/* IPv4 payload checksum for UDP fragments must be
-		 * used in conjunction with packet-split. */
+		/*
+		 * IPv4 payload checksum for UDP fragments must be
+		 * used in conjunction with packet-split.
+		 */
 		if (adapter->rx_ps_pages)
 			rxcsum |= E1000_RXCSUM_IPPCSE;
 	} else {
@@ -1832,9 +1875,11 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	}
 	ew32(RXCSUM, rxcsum);
 
-	/* Enable early receives on supported devices, only takes effect when
+	/*
+	 * Enable early receives on supported devices, only takes effect when
 	 * packet size is equal or larger than the specified value (in 8 byte
-	 * units), e.g. using jumbo frames when setting to E1000_ERT_2048 */
+	 * units), e.g. using jumbo frames when setting to E1000_ERT_2048
+	 */
 	if ((adapter->flags & FLAG_HAS_ERT) &&
 	    (adapter->netdev->mtu > ETH_DATA_LEN))
 		ew32(ERT, E1000_ERT_2048);
@@ -1930,7 +1975,7 @@ static void e1000_set_multi(struct net_device *netdev)
 }
 
 /**
- * e1000_configure - configure the hardware for RX and TX
+ * e1000_configure - configure the hardware for Rx and Tx
  * @adapter: private board structure
  **/
 static void e1000_configure(struct e1000_adapter *adapter)
@@ -1943,8 +1988,7 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	e1000_configure_tx(adapter);
 	e1000_setup_rctl(adapter);
 	e1000_configure_rx(adapter);
-	adapter->alloc_rx_buf(adapter,
-			      e1000_desc_unused(adapter->rx_ring));
+	adapter->alloc_rx_buf(adapter, e1000_desc_unused(adapter->rx_ring));
 }
 
 /**
@@ -1961,8 +2005,10 @@ void e1000e_power_up_phy(struct e1000_adapter *adapter)
 
 	/* Just clear the power down bit to wake the phy back up */
 	if (adapter->hw.media_type == e1000_media_type_copper) {
-		/* according to the manual, the phy will retain its
-		 * settings across a power-down/up cycle */
+		/*
+		 * According to the manual, the phy will retain its
+		 * settings across a power-down/up cycle
+		 */
 		e1e_rphy(&adapter->hw, PHY_CONTROL, &mii_reg);
 		mii_reg &= ~MII_CR_POWER_DOWN;
 		e1e_wphy(&adapter->hw, PHY_CONTROL, mii_reg);
@@ -1991,8 +2037,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		return;
 
 	/* reset is blocked because of a SoL/IDER session */
-	if (e1000e_check_mng_mode(hw) ||
-	    e1000_check_reset_block(hw))
+	if (e1000e_check_mng_mode(hw) || e1000_check_reset_block(hw))
 		return;
 
 	/* manageability (AMT) is enabled */
@@ -2012,7 +2057,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
  * This function boots the hardware and enables some settings that
  * require a configuration cycle of the hardware - those cannot be
  * set/changed during runtime. After reset the device needs to be
- * properly configured for rx, tx etc.
+ * properly configured for Rx, Tx etc.
  */
 void e1000e_reset(struct e1000_adapter *adapter)
 {
@@ -2022,23 +2067,27 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	u32 pba;
 	u16 hwm;
 
+	/* reset Packet Buffer Allocation to default */
 	ew32(PBA, adapter->pba);
 
 	if (mac->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN ) {
-		/* To maintain wire speed transmits, the Tx FIFO should be
+		/*
+		 * To maintain wire speed transmits, the Tx FIFO should be
 		 * large enough to accommodate two full transmit packets,
 		 * rounded up to the next 1KB and expressed in KB.  Likewise,
 		 * the Rx FIFO should be large enough to accommodate at least
 		 * one full receive packet and is similarly rounded up and
-		 * expressed in KB. */
+		 * expressed in KB.
+		 */
 		pba = er32(PBA);
 		/* upper 16 bits has Tx packet buffer allocation size in KB */
 		tx_space = pba >> 16;
 		/* lower 16 bits has Rx packet buffer allocation size in KB */
 		pba &= 0xffff;
-		/* the tx fifo also stores 16 bytes of information about the tx
-		 * but don't include ethernet FCS because hardware appends it */
-		min_tx_space = (mac->max_frame_size +
+		/*
+		 * the Tx fifo also stores 16 bytes of information about the tx
+		 * but don't include ethernet FCS because hardware appends it
+		 */		min_tx_space = (mac->max_frame_size +
 				sizeof(struct e1000_tx_desc) -
 				ETH_FCS_LEN) * 2;
 		min_tx_space = ALIGN(min_tx_space, 1024);
@@ -2048,15 +2097,19 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		min_rx_space = ALIGN(min_rx_space, 1024);
 		min_rx_space >>= 10;
 
-		/* If current Tx allocation is less than the min Tx FIFO size,
+		/*
+		 * If current Tx allocation is less than the min Tx FIFO size,
 		 * and the min Tx FIFO size is less than the current Rx FIFO
-		 * allocation, take space away from current Rx allocation */
+		 * allocation, take space away from current Rx allocation
+		 */
 		if ((tx_space < min_tx_space) &&
 		    ((min_tx_space - tx_space) < pba)) {
 			pba -= min_tx_space - tx_space;
 
-			/* if short on rx space, rx wins and must trump tx
-			 * adjustment or use Early Receive if available */
+			/*
+			 * if short on Rx space, Rx wins and must trump tx
+			 * adjustment or use Early Receive if available
+			 */
 			if ((pba < min_rx_space) &&
 			    (!(adapter->flags & FLAG_HAS_ERT)))
 				/* ERT enabled in e1000_configure_rx */
@@ -2067,14 +2120,17 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	}
 
 
-	/* flow control settings */
-	/* The high water mark must be low enough to fit one full frame
+	/*
+	 * flow control settings
+	 *
+	 * The high water mark must be low enough to fit one full frame
 	 * (or the size used for early receive) above it in the Rx FIFO.
 	 * Set it to the lower of:
 	 * - 90% of the Rx FIFO size, and
 	 * - the full Rx FIFO size minus the early receive size (for parts
 	 *   with ERT support assuming ERT set to E1000_ERT_2048), or
-	 * - the full Rx FIFO size minus one full frame */
+	 * - the full Rx FIFO size minus one full frame
+	 */
 	if (adapter->flags & FLAG_HAS_ERT)
 		hwm = min(((adapter->pba << 10) * 9 / 10),
 			  ((adapter->pba << 10) - (E1000_ERT_2048 << 3)));
@@ -2108,9 +2164,11 @@ void e1000e_reset(struct e1000_adapter *adapter)
 
 	if (!(adapter->flags & FLAG_SMART_POWER_DOWN)) {
 		u16 phy_data = 0;
-		/* speed up time to link by disabling smart power down, ignore
+		/*
+		 * speed up time to link by disabling smart power down, ignore
 		 * the return value of this function because there is nothing
-		 * different we would do if it failed */
+		 * different we would do if it failed
+		 */
 		e1e_rphy(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
 		phy_data &= ~IGP02E1000_PM_SPD;
 		e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
@@ -2140,8 +2198,10 @@ void e1000e_down(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 tctl, rctl;
 
-	/* signal that we're down so the interrupt handler does not
-	 * reschedule our watchdog timer */
+	/*
+	 * signal that we're down so the interrupt handler does not
+	 * reschedule our watchdog timer
+	 */
 	set_bit(__E1000_DOWN, &adapter->state);
 
 	/* disable receives in the hardware */
@@ -2272,16 +2332,20 @@ static int e1000_open(struct net_device *netdev)
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN))
 		e1000_update_mng_vlan(adapter);
 
-	/* If AMT is enabled, let the firmware know that the network
-	 * interface is now open */
+	/*
+	 * If AMT is enabled, let the firmware know that the network
+	 * interface is now open
+	 */
 	if ((adapter->flags & FLAG_HAS_AMT) &&
 	    e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
-	/* before we allocate an interrupt, we must be ready to handle it.
+	/*
+	 * before we allocate an interrupt, we must be ready to handle it.
 	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
 	 * as soon as we call pci_request_irq, so we have to setup our
-	 * clean_rx handler before we do so.  */
+	 * clean_rx handler before we do so.
+	 */
 	e1000_configure(adapter);
 
 	err = e1000_request_irq(adapter);
@@ -2335,16 +2399,20 @@ static int e1000_close(struct net_device *netdev)
 	e1000e_free_tx_resources(adapter);
 	e1000e_free_rx_resources(adapter);
 
-	/* kill manageability vlan ID if supported, but not if a vlan with
-	 * the same ID is registered on the host OS (let 8021q kill it) */
+	/*
+	 * kill manageability vlan ID if supported, but not if a vlan with
+	 * the same ID is registered on the host OS (let 8021q kill it)
+	 */
 	if ((adapter->hw.mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	     !(adapter->vlgrp &&
 	       vlan_group_get_device(adapter->vlgrp, adapter->mng_vlan_id)))
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 
-	/* If AMT is enabled, let the firmware know that the network
-	 * interface is now closed */
+	/*
+	 * If AMT is enabled, let the firmware know that the network
+	 * interface is now closed
+	 */
 	if ((adapter->flags & FLAG_HAS_AMT) &&
 	    e1000e_check_mng_mode(&adapter->hw))
 		e1000_release_hw_control(adapter);
@@ -2375,12 +2443,14 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 		/* activate the work around */
 		e1000e_set_laa_state_82571(&adapter->hw, 1);
 
-		/* Hold a copy of the LAA in RAR[14] This is done so that
+		/*
+		 * Hold a copy of the LAA in RAR[14] This is done so that
 		 * between the time RAR[0] gets clobbered  and the time it
 		 * gets fixed (in e1000_watchdog), the actual LAA is in one
 		 * of the RARs and no incoming packets directed to this port
 		 * are dropped. Eventually the LAA will be in RAR[0] and
-		 * RAR[14] */
+		 * RAR[14]
+		 */
 		e1000e_rar_set(&adapter->hw,
 			      adapter->hw.mac.addr,
 			      adapter->hw.mac.rar_entry_count - 1);
@@ -2389,8 +2459,10 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
-/* Need to wait a few seconds after link up to get diagnostic information from
- * the phy */
+/*
+ * Need to wait a few seconds after link up to get diagnostic information from
+ * the phy
+ */
 static void e1000_update_phy_info(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
@@ -2421,7 +2493,8 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 
 	spin_lock_irqsave(&adapter->stats_lock, irq_flags);
 
-	/* these counters are modified from e1000_adjust_tbi_stats,
+	/*
+	 * these counters are modified from e1000_adjust_tbi_stats,
 	 * called from the interrupt context, so they must only
 	 * be written while holding adapter->stats_lock
 	 */
@@ -2515,8 +2588,10 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 
 	/* Rx Errors */
 
-	/* RLEC on some newer hardware can be incorrect so build
-	* our own version based on RUC and ROC */
+	/*
+	 * RLEC on some newer hardware can be incorrect so build
+	 * our own version based on RUC and ROC
+	 */
 	adapter->net_stats.rx_errors = adapter->stats.rxerrc +
 		adapter->stats.crcerrs + adapter->stats.algnerrc +
 		adapter->stats.ruc + adapter->stats.roc +
@@ -2628,8 +2703,10 @@ static void e1000_watchdog_task(struct work_struct *work)
 						   &adapter->link_speed,
 						   &adapter->link_duplex);
 			e1000_print_link_info(adapter);
-			/* tweak tx_queue_len according to speed/duplex
-			 * and adjust the timeout factor */
+			/*
+			 * tweak tx_queue_len according to speed/duplex
+			 * and adjust the timeout factor
+			 */
 			netdev->tx_queue_len = adapter->tx_queue_len;
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
@@ -2645,8 +2722,10 @@ static void e1000_watchdog_task(struct work_struct *work)
 				break;
 			}
 
-			/* workaround: re-program speed mode bit after
-			 * link-up event */
+			/*
+			 * workaround: re-program speed mode bit after
+			 * link-up event
+			 */
 			if ((adapter->flags & FLAG_TARC_SPEED_MODE_BIT) &&
 			    !txb2b) {
 				u32 tarc0;
@@ -2655,8 +2734,10 @@ static void e1000_watchdog_task(struct work_struct *work)
 				ew32(TARC0, tarc0);
 			}
 
-			/* disable TSO for pcie and 10/100 speeds, to avoid
-			 * some hardware issues */
+			/*
+			 * disable TSO for pcie and 10/100 speeds, to avoid
+			 * some hardware issues
+			 */
 			if (!(adapter->flags & FLAG_TSO_FORCE)) {
 				switch (adapter->link_speed) {
 				case SPEED_10:
@@ -2676,8 +2757,10 @@ static void e1000_watchdog_task(struct work_struct *work)
 				}
 			}
 
-			/* enable transmits in the hardware, need to do this
-			 * after setting TARC0 */
+			/*
+			 * enable transmits in the hardware, need to do this
+			 * after setting TARC(0)
+			 */
 			tctl = er32(TCTL);
 			tctl |= E1000_TCTL_EN;
 			ew32(TCTL, tctl);
@@ -2731,23 +2814,27 @@ link_up:
 		tx_pending = (e1000_desc_unused(tx_ring) + 1 <
 			       tx_ring->count);
 		if (tx_pending) {
-			/* We've lost link, so the controller stops DMA,
+			/*
+			 * We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
-			 * (Do the reset outside of interrupt context). */
+			 * (Do the reset outside of interrupt context).
+			 */
 			adapter->tx_timeout_count++;
 			schedule_work(&adapter->reset_task);
 		}
 	}
 
-	/* Cause software interrupt to ensure rx ring is cleaned */
+	/* Cause software interrupt to ensure Rx ring is cleaned */
 	ew32(ICS, E1000_ICS_RXDMT0);
 
 	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung = 1;
 
-	/* With 82571 controllers, LAA may be overwritten due to controller
-	 * reset from the other port. Set the appropriate LAA in RAR[0] */
+	/*
+	 * With 82571 controllers, LAA may be overwritten due to controller
+	 * reset from the other port. Set the appropriate LAA in RAR[0]
+	 */
 	if (e1000e_get_laa_state_82571(hw))
 		e1000e_rar_set(hw, adapter->hw.mac.addr, 0);
 
@@ -3023,16 +3110,20 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
 
-	/* Force memory writes to complete before letting h/w
+	/*
+	 * Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
-	 * such as IA-64). */
+	 * such as IA-64).
+	 */
 	wmb();
 
 	tx_ring->next_to_use = i;
 	writel(i, adapter->hw.hw_addr + tx_ring->tail);
-	/* we need this if more than one processor can write to our tail
-	 * at a time, it synchronizes IO on IA64/Altix systems */
+	/*
+	 * we need this if more than one processor can write to our tail
+	 * at a time, it synchronizes IO on IA64/Altix systems
+	 */
 	mmiowb();
 }
 
@@ -3080,13 +3171,17 @@ static int __e1000_maybe_stop_tx(struct net_device *netdev, int size)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	netif_stop_queue(netdev);
-	/* Herbert's original patch had:
+	/*
+	 * Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
-	 * but since that doesn't exist yet, just open code it. */
+	 * but since that doesn't exist yet, just open code it.
+	 */
 	smp_mb();
 
-	/* We need to check again in a case another CPU has just
-	 * made room available. */
+	/*
+	 * We need to check again in a case another CPU has just
+	 * made room available.
+	 */
 	if (e1000_desc_unused(adapter->tx_ring) < size)
 		return -EBUSY;
 
@@ -3133,21 +3228,29 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	mss = skb_shinfo(skb)->gso_size;
-	/* The controller does a simple calculation to
+	/*
+	 * The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
 	 * initiating the DMA for each buffer.  The calc is:
 	 * 4 = ceil(buffer len/mss).  To make sure we don't
 	 * overrun the FIFO, adjust the max buffer len if mss
-	 * drops. */
+	 * drops.
+	 */
 	if (mss) {
 		u8 hdr_len;
 		max_per_txd = min(mss << 2, max_per_txd);
 		max_txd_pwr = fls(max_per_txd) - 1;
 
-		/* TSO Workaround for 82571/2/3 Controllers -- if skb->data
-		* points to just header, pull a few bytes of payload from
-		* frags into skb->data */
+		/*
+		 * TSO Workaround for 82571/2/3 Controllers -- if skb->data
+		 * points to just header, pull a few bytes of payload from
+		 * frags into skb->data
+		 */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		/*
+		 * we do this workaround for ES2LAN, but it is un-necessary,
+		 * avoiding it could save a lot of cycles
+		 */
 		if (skb->data_len && (hdr_len == len)) {
 			unsigned int pull_size;
 
@@ -3181,8 +3284,10 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* Collision - tell upper layer to requeue */
 		return NETDEV_TX_LOCKED;
 
-	/* need: count + 2 desc gap to keep tail from touching
-	 * head, otherwise try next time */
+	/*
+	 * need: count + 2 desc gap to keep tail from touching
+	 * head, otherwise try next time
+	 */
 	if (e1000_maybe_stop_tx(netdev, count + 2)) {
 		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
 		return NETDEV_TX_BUSY;
@@ -3207,9 +3312,11 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	else if (e1000_tx_csum(adapter, skb))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
 
-	/* Old method was to assume IPv4 packet by default if TSO was enabled.
+	/*
+	 * Old method was to assume IPv4 packet by default if TSO was enabled.
 	 * 82571 hardware supports TSO capabilities for IPv6 as well...
-	 * no longer assume, we must. */
+	 * no longer assume, we must.
+	 */
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
@@ -3311,10 +3418,12 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	if (netif_running(netdev))
 		e1000e_down(adapter);
 
-	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
+	/*
+	 * NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
 	 * means we reserve 2 more, this pushes us to allocate from the next
 	 * larger slab size.
-	 * i.e. RXBUFFER_2048 --> size-4096 slab */
+	 * i.e. RXBUFFER_2048 --> size-4096 slab
+	 */
 
 	if (max_frame <= 256)
 		adapter->rx_buffer_len = 256;
@@ -3331,7 +3440,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN) ||
 	     (max_frame == ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN))
 		adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN
-					 + ETH_FCS_LEN ;
+					 + ETH_FCS_LEN;
 
 	ndev_info(netdev, "changing MTU from %d to %d\n",
 		netdev->mtu, new_mtu);
@@ -3467,8 +3576,10 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (adapter->hw.phy.type == e1000_phy_igp_3)
 		e1000e_igp3_phy_powerdown_workaround_ich8lan(&adapter->hw);
 
-	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
-	 * would have already happened in close and is redundant. */
+	/*
+	 * Release control of h/w to f/w.  If f/w is AMT enabled, this
+	 * would have already happened in close and is redundant.
+	 */
 	e1000_release_hw_control(adapter);
 
 	pci_disable_device(pdev);
@@ -3543,9 +3654,11 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	/* If the controller has AMT, do not set DRV_LOAD until the interface
+	/*
+	 * If the controller has AMT, do not set DRV_LOAD until the interface
 	 * is up.  For all other cases, let the f/w know that the h/w is now
-	 * under the control of the driver. */
+	 * under the control of the driver.
+	 */
 	if (!(adapter->flags & FLAG_HAS_AMT) || !e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
@@ -3656,9 +3769,11 @@ static void e1000_io_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	/* If the controller has AMT, do not set DRV_LOAD until the interface
+	/*
+	 * If the controller has AMT, do not set DRV_LOAD until the interface
 	 * is up.  For all other cases, let the f/w know that the h/w is now
-	 * under the control of the driver. */
+	 * under the control of the driver.
+	 */
 	if (!(adapter->flags & FLAG_HAS_AMT) ||
 	    !e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
@@ -3852,15 +3967,19 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	/* We should not be using LLTX anymore, but we are still TX faster with
-	 * it. */
+	/*
+	 * We should not be using LLTX anymore, but we are still Tx faster with
+	 * it.
+	 */
 	netdev->features |= NETIF_F_LLTX;
 
 	if (e1000e_enable_mng_pass_thru(&adapter->hw))
 		adapter->flags |= FLAG_MNG_PT_ENABLED;
 
-	/* before reading the NVM, reset the controller to
-	 * put the device in a known good starting state */
+	/*
+	 * before reading the NVM, reset the controller to
+	 * put the device in a known good starting state
+	 */
 	adapter->hw.mac.ops.reset_hw(&adapter->hw);
 
 	/*
@@ -3954,9 +4073,11 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* reset the hardware with the new settings */
 	e1000e_reset(adapter);
 
-	/* If the controller has AMT, do not set DRV_LOAD until the interface
+	/*
+	 * If the controller has AMT, do not set DRV_LOAD until the interface
 	 * is up.  For all other cases, let the f/w know that the h/w is now
-	 * under the control of the driver. */
+	 * under the control of the driver.
+	 */
 	if (!(adapter->flags & FLAG_HAS_AMT) ||
 	    !e1000e_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
@@ -4013,16 +4134,20 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	/* flush_scheduled work may reschedule our watchdog task, so
-	 * explicitly disable watchdog tasks from being rescheduled  */
+	/*
+	 * flush_scheduled work may reschedule our watchdog task, so
+	 * explicitly disable watchdog tasks from being rescheduled
+	 */
 	set_bit(__E1000_DOWN, &adapter->state);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
 	flush_scheduled_work();
 
-	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
-	 * would have already happened in close and is redundant. */
+	/*
+	 * Release control of h/w to f/w.  If f/w is AMT enabled, this
+	 * would have already happened in close and is redundant.
+	 */
 	e1000_release_hw_control(adapter);
 
 	unregister_netdev(netdev);
@@ -4060,13 +4185,16 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES_DUAL), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES_QUAD), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571PT_QUAD_COPPER), board_82571 },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI), board_82572 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI_COPPER), board_82572 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI_FIBER), board_82572 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82572EI_SERDES), board_82572 },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82573E), board_82573 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82573E_IAMT), board_82573 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82573L), board_82573 },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_80003ES2LAN_COPPER_DPT),
 	  board_80003es2lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_80003ES2LAN_COPPER_SPT),
@@ -4075,6 +4203,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	  board_80003es2lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_80003ES2LAN_SERDES_SPT),
 	  board_80003es2lan },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IFE), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IFE_G), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IFE_GT), board_ich8lan },
@@ -4082,6 +4211,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_C), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_M), board_ich8lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH8_IGP_M_AMT), board_ich8lan },
+
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_G), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_GT), board_ich9lan },
@@ -4099,7 +4229,7 @@ static struct pci_driver e1000_driver = {
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
 #ifdef CONFIG_PM
-	/* Power Managment Hooks */
+	/* Power Management Hooks */
 	.suspend  = e1000_suspend,
 	.resume   = e1000_resume,
 #endif
@@ -4118,7 +4248,7 @@ static int __init e1000_init_module(void)
 	int ret;
 	printk(KERN_INFO "%s: Intel(R) PRO/1000 Network Driver - %s\n",
 	       e1000e_driver_name, e1000e_driver_version);
-	printk(KERN_INFO "%s: Copyright (c) 1999-2007 Intel Corporation.\n",
+	printk(KERN_INFO "%s: Copyright (c) 1999-2008 Intel Corporation.\n",
 	       e1000e_driver_name);
 	ret = pci_register_driver(&e1000_driver);
 
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index df266c3..a66b92e 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -30,7 +30,8 @@
 
 #include "e1000.h"
 
-/* This is the only thing that needs to be changed to adjust the
+/*
+ * This is the only thing that needs to be changed to adjust the
  * maximum number of ports that the driver can manage.
  */
 
@@ -46,7 +47,8 @@ module_param(copybreak, uint, 0644);
 MODULE_PARM_DESC(copybreak,
 	"Maximum size of packet that is copied to a new buffer on receive");
 
-/* All parameters are treated the same, as an integer array of values.
+/*
+ * All parameters are treated the same, as an integer array of values.
  * This macro just reduces the need to repeat the same declaration code
  * over and over (plus this helps to avoid typo bugs).
  */
@@ -60,8 +62,9 @@ MODULE_PARM_DESC(copybreak,
 	MODULE_PARM_DESC(X, desc);
 
 
-/* Transmit Interrupt Delay in units of 1.024 microseconds
- *  Tx interrupt delay needs to typically be set to something non zero
+/*
+ * Transmit Interrupt Delay in units of 1.024 microseconds
+ * Tx interrupt delay needs to typically be set to something non zero
  *
  * Valid Range: 0-65535
  */
@@ -70,7 +73,8 @@ E1000_PARAM(TxIntDelay, "Transmit Interrupt Delay");
 #define MAX_TXDELAY 0xFFFF
 #define MIN_TXDELAY 0
 
-/* Transmit Absolute Interrupt Delay in units of 1.024 microseconds
+/*
+ * Transmit Absolute Interrupt Delay in units of 1.024 microseconds
  *
  * Valid Range: 0-65535
  */
@@ -79,8 +83,9 @@ E1000_PARAM(TxAbsIntDelay, "Transmit Absolute Interrupt Delay");
 #define MAX_TXABSDELAY 0xFFFF
 #define MIN_TXABSDELAY 0
 
-/* Receive Interrupt Delay in units of 1.024 microseconds
- *   hardware will likely hang if you set this to anything but zero.
+/*
+ * Receive Interrupt Delay in units of 1.024 microseconds
+ * hardware will likely hang if you set this to anything but zero.
  *
  * Valid Range: 0-65535
  */
@@ -89,7 +94,8 @@ E1000_PARAM(RxIntDelay, "Receive Interrupt Delay");
 #define MAX_RXDELAY 0xFFFF
 #define MIN_RXDELAY 0
 
-/* Receive Absolute Interrupt Delay in units of 1.024 microseconds
+/*
+ * Receive Absolute Interrupt Delay in units of 1.024 microseconds
  *
  * Valid Range: 0-65535
  */
@@ -98,7 +104,8 @@ E1000_PARAM(RxAbsIntDelay, "Receive Absolute Interrupt Delay");
 #define MAX_RXABSDELAY 0xFFFF
 #define MIN_RXABSDELAY 0
 
-/* Interrupt Throttle Rate (interrupts/sec)
+/*
+ * Interrupt Throttle Rate (interrupts/sec)
  *
  * Valid Range: 100-100000 (0=off, 1=dynamic, 3=dynamic conservative)
  */
@@ -107,7 +114,8 @@ E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
 #define MAX_ITR 100000
 #define MIN_ITR 100
 
-/* Enable Smart Power Down of the PHY
+/*
+ * Enable Smart Power Down of the PHY
  *
  * Valid Range: 0, 1
  *
@@ -115,7 +123,8 @@ E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
  */
 E1000_PARAM(SmartPowerDownEnable, "Enable PHY smart power down");
 
-/* Enable Kumeran Lock Loss workaround
+/*
+ * Enable Kumeran Lock Loss workaround
  *
  * Valid Range: 0, 1
  *
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index dab3c46..a2da1c4 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -134,7 +134,8 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 		return -E1000_ERR_PARAM;
 	}
 
-	/* Set up Op-code, Phy Address, and register offset in the MDI
+	/*
+	 * Set up Op-code, Phy Address, and register offset in the MDI
 	 * Control register.  The MAC will take care of interfacing with the
 	 * PHY to retrieve the desired data.
 	 */
@@ -144,7 +145,11 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 
 	ew32(MDIC, mdic);
 
-	/* Poll the ready bit to see if the MDI read completed */
+	/*
+	 * Poll the ready bit to see if the MDI read completed
+	 * Increasing the time out as testing showed failures with
+	 * the lower time out
+	 */
 	for (i = 0; i < 64; i++) {
 		udelay(50);
 		mdic = er32(MDIC);
@@ -182,7 +187,8 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 		return -E1000_ERR_PARAM;
 	}
 
-	/* Set up Op-code, Phy Address, and register offset in the MDI
+	/*
+	 * Set up Op-code, Phy Address, and register offset in the MDI
 	 * Control register.  The MAC will take care of interfacing with the
 	 * PHY to retrieve the desired data.
 	 */
@@ -409,14 +415,15 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	/* Enable CRS on TX. This must be set for half-duplex operation. */
+	/* Enable CRS on Tx. This must be set for half-duplex operation. */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
 		return ret_val;
 
 	phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
 
-	/* Options:
+	/*
+	 * Options:
 	 *   MDI/MDI-X = 0 (default)
 	 *   0 - Auto for all speeds
 	 *   1 - MDI mode
@@ -441,7 +448,8 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 		break;
 	}
 
-	/* Options:
+	/*
+	 * Options:
 	 *   disable_polarity_correction = 0 (default)
 	 *       Automatic Correction for Reversed Cable Polarity
 	 *   0 - Disabled
@@ -456,7 +464,8 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 		return ret_val;
 
 	if (phy->revision < 4) {
-		/* Force TX_CLK in the Extended PHY Specific Control Register
+		/*
+		 * Force TX_CLK in the Extended PHY Specific Control Register
 		 * to 25MHz clock.
 		 */
 		ret_val = e1e_rphy(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data);
@@ -543,19 +552,21 @@ s32 e1000e_copper_link_setup_igp(struct e1000_hw *hw)
 
 	/* set auto-master slave resolution settings */
 	if (hw->mac.autoneg) {
-		/* when autonegotiation advertisement is only 1000Mbps then we
+		/*
+		 * when autonegotiation advertisement is only 1000Mbps then we
 		 * should disable SmartSpeed and enable Auto MasterSlave
-		 * resolution as hardware default. */
+		 * resolution as hardware default.
+		 */
 		if (phy->autoneg_advertised == ADVERTISE_1000_FULL) {
 			/* Disable SmartSpeed */
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 
@@ -630,14 +641,16 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 			return ret_val;
 	}
 
-	/* Need to parse both autoneg_advertised and fc and set up
+	/*
+	 * Need to parse both autoneg_advertised and fc and set up
 	 * the appropriate PHY registers.  First we will parse for
 	 * autoneg_advertised software override.  Since we can advertise
 	 * a plethora of combinations, we need to check each bit
 	 * individually.
 	 */
 
-	/* First we clear all the 10/100 mb speed bits in the Auto-Neg
+	/*
+	 * First we clear all the 10/100 mb speed bits in the Auto-Neg
 	 * Advertisement Register (Address 4) and the 1000 mb speed bits in
 	 * the  1000Base-T Control Register (Address 9).
 	 */
@@ -683,7 +696,8 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 		mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
 	}
 
-	/* Check for a software override of the flow control settings, and
+	/*
+	 * Check for a software override of the flow control settings, and
 	 * setup the PHY advertisement registers accordingly.  If
 	 * auto-negotiation is enabled, then software will have to set the
 	 * "PAUSE" bits to the correct value in the Auto-Negotiation
@@ -696,38 +710,42 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 	 *	  but not send pause frames).
 	 *      2:  Tx flow control is enabled (we can send pause frames
 	 *	  but we do not support receiving pause frames).
-	 *      3:  Both Rx and TX flow control (symmetric) are enabled.
+	 *      3:  Both Rx and Tx flow control (symmetric) are enabled.
 	 *  other:  No software override.  The flow control configuration
 	 *	  in the EEPROM is used.
 	 */
 	switch (hw->mac.fc) {
 	case e1000_fc_none:
-		/* Flow control (RX & TX) is completely disabled by a
+		/*
+		 * Flow control (Rx & Tx) is completely disabled by a
 		 * software over-ride.
 		 */
 		mii_autoneg_adv_reg &= ~(NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
 		break;
 	case e1000_fc_rx_pause:
-		/* RX Flow control is enabled, and TX Flow control is
+		/*
+		 * Rx Flow control is enabled, and Tx Flow control is
 		 * disabled, by a software over-ride.
-		 */
-		/* Since there really isn't a way to advertise that we are
-		 * capable of RX Pause ONLY, we will advertise that we
-		 * support both symmetric and asymmetric RX PAUSE.  Later
+		 *
+		 * Since there really isn't a way to advertise that we are
+		 * capable of Rx Pause ONLY, we will advertise that we
+		 * support both symmetric and asymmetric Rx PAUSE.  Later
 		 * (in e1000e_config_fc_after_link_up) we will disable the
 		 * hw's ability to send PAUSE frames.
 		 */
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
 		break;
 	case e1000_fc_tx_pause:
-		/* TX Flow control is enabled, and RX Flow control is
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is
 		 * disabled, by a software over-ride.
 		 */
 		mii_autoneg_adv_reg |= NWAY_AR_ASM_DIR;
 		mii_autoneg_adv_reg &= ~NWAY_AR_PAUSE;
 		break;
 	case e1000_fc_full:
-		/* Flow control (both RX and TX) is enabled by a software
+		/*
+		 * Flow control (both Rx and Tx) is enabled by a software
 		 * over-ride.
 		 */
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
@@ -758,7 +776,7 @@ static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
  *  Performs initial bounds checking on autoneg advertisement parameter, then
  *  configure to advertise the full capability.  Setup the PHY to autoneg
  *  and restart the negotiation process between the link partner.  If
- *  wait_for_link, then wait for autoneg to complete before exiting.
+ *  autoneg_wait_to_complete, then wait for autoneg to complete before exiting.
  **/
 static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 {
@@ -766,12 +784,14 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_ctrl;
 
-	/* Perform some bounds checking on the autoneg advertisement
+	/*
+	 * Perform some bounds checking on the autoneg advertisement
 	 * parameter.
 	 */
 	phy->autoneg_advertised &= phy->autoneg_mask;
 
-	/* If autoneg_advertised is zero, we assume it was not defaulted
+	/*
+	 * If autoneg_advertised is zero, we assume it was not defaulted
 	 * by the calling code so we set to advertise full capability.
 	 */
 	if (phy->autoneg_advertised == 0)
@@ -785,7 +805,8 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	}
 	hw_dbg(hw, "Restarting Auto-Neg\n");
 
-	/* Restart auto-negotiation by setting the Auto Neg Enable bit and
+	/*
+	 * Restart auto-negotiation by setting the Auto Neg Enable bit and
 	 * the Auto Neg Restart bit in the PHY control register.
 	 */
 	ret_val = e1e_rphy(hw, PHY_CONTROL, &phy_ctrl);
@@ -797,7 +818,8 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Does the user want to wait for Auto-Neg to complete here, or
+	/*
+	 * Does the user want to wait for Auto-Neg to complete here, or
 	 * check at a later time (for example, callback routine).
 	 */
 	if (phy->wait_for_link) {
@@ -829,14 +851,18 @@ s32 e1000e_setup_copper_link(struct e1000_hw *hw)
 	bool link;
 
 	if (hw->mac.autoneg) {
-		/* Setup autoneg and flow control advertisement and perform
-		 * autonegotiation. */
+		/*
+		 * Setup autoneg and flow control advertisement and perform
+		 * autonegotiation.
+		 */
 		ret_val = e1000_copper_link_autoneg(hw);
 		if (ret_val)
 			return ret_val;
 	} else {
-		/* PHY will be set to 10H, 10F, 100H or 100F
-		 * depending on user settings. */
+		/*
+		 * PHY will be set to 10H, 10F, 100H or 100F
+		 * depending on user settings.
+		 */
 		hw_dbg(hw, "Forcing Speed and Duplex\n");
 		ret_val = e1000_phy_force_speed_duplex(hw);
 		if (ret_val) {
@@ -845,7 +871,8 @@ s32 e1000e_setup_copper_link(struct e1000_hw *hw)
 		}
 	}
 
-	/* Check link status. Wait up to 100 microseconds for link to become
+	/*
+	 * Check link status. Wait up to 100 microseconds for link to become
 	 * valid.
 	 */
 	ret_val = e1000e_phy_has_link_generic(hw,
@@ -891,7 +918,8 @@ s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Clear Auto-Crossover to force MDI manually.  IGP requires MDI
+	/*
+	 * Clear Auto-Crossover to force MDI manually.  IGP requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
 	ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CTRL, &phy_data);
@@ -941,7 +969,7 @@ s32 e1000e_phy_force_speed_duplex_igp(struct e1000_hw *hw)
  *  Calls the PHY setup function to force speed and duplex.  Clears the
  *  auto-crossover to force MDI manually.  Resets the PHY to commit the
  *  changes.  If time expires while waiting for link up, we reset the DSP.
- *  After reset, TX_CLK and CRS on TX must be set.  Return successful upon
+ *  After reset, TX_CLK and CRS on Tx must be set.  Return successful upon
  *  successful completion, else return corresponding error code.
  **/
 s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
@@ -951,7 +979,8 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	u16 phy_data;
 	bool link;
 
-	/* Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
+	/*
+	 * Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
 	 * forced whenever speed and duplex are forced.
 	 */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
@@ -989,10 +1018,12 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 			return ret_val;
 
 		if (!link) {
-			/* We didn't get link.
+			/*
+			 * We didn't get link.
 			 * Reset the DSP and cross our fingers.
 			 */
-			ret_val = e1e_wphy(hw, M88E1000_PHY_PAGE_SELECT, 0x001d);
+			ret_val = e1e_wphy(hw, M88E1000_PHY_PAGE_SELECT,
+					   0x001d);
 			if (ret_val)
 				return ret_val;
 			ret_val = e1000e_phy_reset_dsp(hw);
@@ -1011,7 +1042,8 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* Resetting the phy means we need to re-force TX_CLK in the
+	/*
+	 * Resetting the phy means we need to re-force TX_CLK in the
 	 * Extended PHY Specific Control Register to 25MHz clock from
 	 * the reset value of 2.5MHz.
 	 */
@@ -1020,7 +1052,8 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* In addition, we must re-enable CRS on Tx for both half and full
+	/*
+	 * In addition, we must re-enable CRS on Tx for both half and full
 	 * duplex.
 	 */
 	ret_val = e1e_rphy(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
@@ -1124,30 +1157,32 @@ s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 					     data);
 		if (ret_val)
 			return ret_val;
-		/* LPLU and SmartSpeed are mutually exclusive.  LPLU is used
+		/*
+		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
 		 * important.  During driver activity we should enable
-		 * SmartSpeed, so performance is maintained. */
+		 * SmartSpeed, so performance is maintained.
+		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						    &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
 			ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+					   &data);
 			if (ret_val)
 				return ret_val;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
 			ret_val = e1e_wphy(hw, IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+					   data);
 			if (ret_val)
 				return ret_val;
 		}
@@ -1249,8 +1284,10 @@ static s32 e1000_check_polarity_igp(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 data, offset, mask;
 
-	/* Polarity is determined based on the speed of
-	 * our connection. */
+	/*
+	 * Polarity is determined based on the speed of
+	 * our connection.
+	 */
 	ret_val = e1e_rphy(hw, IGP01E1000_PHY_PORT_STATUS, &data);
 	if (ret_val)
 		return ret_val;
@@ -1260,7 +1297,8 @@ static s32 e1000_check_polarity_igp(struct e1000_hw *hw)
 		offset	= IGP01E1000_PHY_PCS_INIT_REG;
 		mask	= IGP01E1000_PHY_POLARITY_MASK;
 	} else {
-		/* This really only applies to 10Mbps since
+		/*
+		 * This really only applies to 10Mbps since
 		 * there is no polarity for 100Mbps (always 0).
 		 */
 		offset	= IGP01E1000_PHY_PORT_STATUS;
@@ -1278,7 +1316,7 @@ static s32 e1000_check_polarity_igp(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_wait_autoneg - Wait for auto-neg compeletion
+ *  e1000_wait_autoneg - Wait for auto-neg completion
  *  @hw: pointer to the HW structure
  *
  *  Waits for auto-negotiation to complete or for the auto-negotiation time
@@ -1302,7 +1340,8 @@ static s32 e1000_wait_autoneg(struct e1000_hw *hw)
 		msleep(100);
 	}
 
-	/* PHY_AUTO_NEG_TIME expiration doesn't guarantee auto-negotiation
+	/*
+	 * PHY_AUTO_NEG_TIME expiration doesn't guarantee auto-negotiation
 	 * has completed.
 	 */
 	return ret_val;
@@ -1324,7 +1363,8 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 	u16 i, phy_status;
 
 	for (i = 0; i < iterations; i++) {
-		/* Some PHYs require the PHY_STATUS register to be read
+		/*
+		 * Some PHYs require the PHY_STATUS register to be read
 		 * twice due to the link bit being sticky.  No harm doing
 		 * it across the board.
 		 */
@@ -1412,10 +1452,12 @@ s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		/* Getting bits 15:9, which represent the combination of
+		/*
+		 * Getting bits 15:9, which represent the combination of
 		 * course and fine gain values.  The result is a number
 		 * that can be put into the lookup table to obtain the
-		 * approximate cable length. */
+		 * approximate cable length.
+		 */
 		cur_agc_index = (phy_data >> IGP02E1000_AGC_LENGTH_SHIFT) &
 				IGP02E1000_AGC_LENGTH_MASK;
 

