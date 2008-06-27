From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 05/18] igb: eliminate hw from the
	hw_dbg macro	arguments
Date: Fri, 27 Jun 2008 11:00:18 -0700
Message-ID: <20080627180012.22428.54284.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>

Various cosmetic cleanups. Comment fixes. Eliminate the hw part out
of the hw_dbg macro since it's always used.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c   |  115 +++++++++++++++++----------------------
 drivers/net/igb/e1000_82575.h   |    6 +-
 drivers/net/igb/e1000_defines.h |   27 ++-------
 drivers/net/igb/e1000_hw.h      |    8 +--
 drivers/net/igb/e1000_mac.c     |   75 +++++++++++++------------
 drivers/net/igb/e1000_nvm.c     |   22 ++++---
 drivers/net/igb/e1000_phy.c     |   76 +++++++++++++-------------
 7 files changed, 147 insertions(+), 182 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index e6dd387..84ef695 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -272,7 +272,7 @@ static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 	u32 i, i2ccmd = 0;
 
 	if (offset > E1000_MAX_SGMII_PHY_REG_ADDR) {
-		hw_dbg(hw, "PHY Address %u is out of range\n", offset);
+		hw_dbg("PHY Address %u is out of range\n", offset);
 		return -E1000_ERR_PARAM;
 	}
 
@@ -295,11 +295,11 @@ static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 			break;
 	}
 	if (!(i2ccmd & E1000_I2CCMD_READY)) {
-		hw_dbg(hw, "I2CCMD Read did not complete\n");
+		hw_dbg("I2CCMD Read did not complete\n");
 		return -E1000_ERR_PHY;
 	}
 	if (i2ccmd & E1000_I2CCMD_ERROR) {
-		hw_dbg(hw, "I2CCMD Error bit set\n");
+		hw_dbg("I2CCMD Error bit set\n");
 		return -E1000_ERR_PHY;
 	}
 
@@ -326,7 +326,7 @@ static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 	u16 phy_data_swapped;
 
 	if (offset > E1000_MAX_SGMII_PHY_REG_ADDR) {
-		hw_dbg(hw, "PHY Address %d is out of range\n", offset);
+		hw_dbg("PHY Address %d is out of range\n", offset);
 		return -E1000_ERR_PARAM;
 	}
 
@@ -353,11 +353,11 @@ static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 			break;
 	}
 	if (!(i2ccmd & E1000_I2CCMD_READY)) {
-		hw_dbg(hw, "I2CCMD Write did not complete\n");
+		hw_dbg("I2CCMD Write did not complete\n");
 		return -E1000_ERR_PHY;
 	}
 	if (i2ccmd & E1000_I2CCMD_ERROR) {
-		hw_dbg(hw, "I2CCMD Error bit set\n");
+		hw_dbg("I2CCMD Error bit set\n");
 		return -E1000_ERR_PHY;
 	}
 
@@ -368,7 +368,7 @@ static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
  *  igb_get_phy_id_82575 - Retrieve PHY addr and id
  *  @hw: pointer to the HW structure
  *
- *  Retreives the PHY address and ID for both PHY's which do and do not use
+ *  Retrieves the PHY address and ID for both PHY's which do and do not use
  *  sgmi interface.
  **/
 static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
@@ -397,9 +397,8 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 	for (phy->addr = 1; phy->addr < 8; phy->addr++) {
 		ret_val = igb_read_phy_reg_sgmii_82575(hw, PHY_ID1, &phy_id);
 		if (ret_val == 0) {
-			hw_dbg(hw, "Vendor ID 0x%08X read at address %u\n",
-				  phy_id,
-				  phy->addr);
+			hw_dbg("Vendor ID 0x%08X read at address %u\n",
+			       phy_id, phy->addr);
 			/*
 			 * At the time of this writing, The M88 part is
 			 * the only supported SGMII PHY product.
@@ -407,8 +406,7 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 			if (phy_id == M88_VENDOR)
 				break;
 		} else {
-			hw_dbg(hw, "PHY address %u was unreadable\n",
-				  phy->addr);
+			hw_dbg("PHY address %u was unreadable\n", phy->addr);
 		}
 	}
 
@@ -440,7 +438,7 @@ static s32 igb_phy_hw_reset_sgmii_82575(struct e1000_hw *hw)
 	 * available to us at this time.
 	 */
 
-	hw_dbg(hw, "Soft resetting SGMII attached PHY...\n");
+	hw_dbg("Soft resetting SGMII attached PHY...\n");
 
 	/*
 	 * SFP documentation requires the following to configure the SPF module
@@ -475,34 +473,29 @@ static s32 igb_set_d0_lplu_state_82575(struct e1000_hw *hw, bool active)
 	s32 ret_val;
 	u16 data;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
-					   &data);
+	ret_val = phy->ops.read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &data);
 	if (ret_val)
 		goto out;
 
 	if (active) {
 		data |= IGP02E1000_PM_D0_LPLU;
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					      IGP02E1000_PHY_POWER_MGMT,
-					      data);
+		ret_val = phy->ops.write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
+						 data);
 		if (ret_val)
 			goto out;
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
-		ret_val = hw->phy.ops.read_phy_reg(hw,
-					     IGP01E1000_PHY_PORT_CONFIG,
-					     &data);
+		ret_val = phy->ops.read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+						&data);
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					      IGP01E1000_PHY_PORT_CONFIG,
-					      data);
+		ret_val = phy->ops.write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+						 data);
 		if (ret_val)
 			goto out;
 	} else {
 		data &= ~IGP02E1000_PM_D0_LPLU;
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					      IGP02E1000_PHY_POWER_MGMT,
-					      data);
+		ret_val = phy->ops.write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
+						 data);
 		/*
 		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
@@ -510,29 +503,25 @@ static s32 igb_set_d0_lplu_state_82575(struct e1000_hw *hw, bool active)
 		 * SmartSpeed, so performance is maintained.
 		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
-			ret_val = hw->phy.ops.read_phy_reg(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+			ret_val = phy->ops.read_phy_reg(hw,
+					IGP01E1000_PHY_PORT_CONFIG, &data);
 			if (ret_val)
 				goto out;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = hw->phy.ops.write_phy_reg(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+			ret_val = phy->ops.write_phy_reg(hw,
+					IGP01E1000_PHY_PORT_CONFIG, data);
 			if (ret_val)
 				goto out;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
-			ret_val = hw->phy.ops.read_phy_reg(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+			ret_val = phy->ops.read_phy_reg(hw,
+					IGP01E1000_PHY_PORT_CONFIG, &data);
 			if (ret_val)
 				goto out;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = hw->phy.ops.write_phy_reg(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+			ret_val = phy->ops.write_phy_reg(hw,
+					IGP01E1000_PHY_PORT_CONFIG, data);
 			if (ret_val)
 				goto out;
 		}
@@ -546,7 +535,7 @@ out:
  *  igb_acquire_nvm_82575 - Request for access to EEPROM
  *  @hw: pointer to the HW structure
  *
- *  Acquire the necessary semaphores for exclussive access to the EEPROM.
+ *  Acquire the necessary semaphores for exclusive access to the EEPROM.
  *  Set the EEPROM access request bit and wait for EEPROM access grant bit.
  *  Return successful if access grant bit set, else clear the request for
  *  EEPROM access and return -E1000_ERR_NVM (-1).
@@ -617,7 +606,7 @@ static s32 igb_acquire_swfw_sync_82575(struct e1000_hw *hw, u16 mask)
 	}
 
 	if (i == timeout) {
-		hw_dbg(hw, "Can't access resource, SW_FW_SYNC timeout.\n");
+		hw_dbg("Driver can't access resource, SW_FW_SYNC timeout.\n");
 		ret_val = -E1000_ERR_SWFW_SYNC;
 		goto out;
 	}
@@ -679,7 +668,7 @@ static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
 		timeout--;
 	}
 	if (!timeout)
-		hw_dbg(hw, "MNG configuration cycle has not completed.\n");
+		hw_dbg("MNG configuration cycle has not completed.\n");
 
 	/* If EEPROM is not marked present, init the PHY manually */
 	if (((rd32(E1000_EECD) & E1000_EECD_PRES) == 0) &&
@@ -718,7 +707,7 @@ static s32 igb_check_for_link_82575(struct e1000_hw *hw)
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
  *
- *  Using the physical coding sub-layer (PCS), retreive the current speed and
+ *  Using the physical coding sub-layer (PCS), retrieve the current speed and
  *  duplex, then store the values in the pointers provided.
  **/
 static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
@@ -802,9 +791,9 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 	 */
 	ret_val = igb_disable_pcie_master(hw);
 	if (ret_val)
-		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
+		hw_dbg("PCI-E Master disable polling has failed.\n");
 
-	hw_dbg(hw, "Masking off all interrupts\n");
+	hw_dbg("Masking off all interrupts\n");
 	wr32(E1000_IMC, 0xffffffff);
 
 	wr32(E1000_RCTL, 0);
@@ -815,7 +804,7 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 
 	ctrl = rd32(E1000_CTRL);
 
-	hw_dbg(hw, "Issuing a global reset to MAC\n");
+	hw_dbg("Issuing a global reset to MAC\n");
 	wr32(E1000_CTRL, ctrl | E1000_CTRL_RST);
 
 	ret_val = igb_get_auto_rd_done(hw);
@@ -825,7 +814,7 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 		 * return with an error. This can happen in situations
 		 * where there is no eeprom and prevents getting link.
 		 */
-		hw_dbg(hw, "Auto Read Done did not complete\n");
+		hw_dbg("Auto Read Done did not complete\n");
 	}
 
 	/* If EEPROM is not present, run manual init scripts */
@@ -856,18 +845,18 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 	/* Initialize identification LED */
 	ret_val = igb_id_led_init(hw);
 	if (ret_val) {
-		hw_dbg(hw, "Error initializing identification LED\n");
+		hw_dbg("Error initializing identification LED\n");
 		/* This is not fatal and we should not stop init due to this */
 	}
 
 	/* Disabling VLAN filtering */
-	hw_dbg(hw, "Initializing the IEEE VLAN\n");
+	hw_dbg("Initializing the IEEE VLAN\n");
 	igb_clear_vfta(hw);
 
 	/* Setup the receive address */
 	igb_init_rx_addrs(hw, rar_count);
 	/* Zero out the Multicast HASH table */
-	hw_dbg(hw, "Zeroing the MTA\n");
+	hw_dbg("Zeroing the MTA\n");
 	for (i = 0; i < mac->mta_reg_count; i++)
 		array_wr32(E1000_MTA, i, 0);
 
@@ -937,10 +926,10 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 		 * PHY will be set to 10H, 10F, 100H or 100F
 		 * depending on user settings.
 		 */
-		hw_dbg(hw, "Forcing Speed and Duplex\n");
+		hw_dbg("Forcing Speed and Duplex\n");
 		ret_val = igb_phy_force_speed_duplex(hw);
 		if (ret_val) {
-			hw_dbg(hw, "Error Forcing Speed and Duplex\n");
+			hw_dbg("Error Forcing Speed and Duplex\n");
 			goto out;
 		}
 	}
@@ -953,20 +942,17 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 	 * Check link status. Wait up to 100 microseconds for link to become
 	 * valid.
 	 */
-	ret_val = igb_phy_has_link(hw,
-					     COPPER_LINK_UP_LIMIT,
-					     10,
-					     &link);
+	ret_val = igb_phy_has_link(hw, COPPER_LINK_UP_LIMIT, 10, &link);
 	if (ret_val)
 		goto out;
 
 	if (link) {
-		hw_dbg(hw, "Valid link established!!!\n");
+		hw_dbg("Valid link established!!!\n");
 		/* Config the MAC and PHY after link is up */
 		igb_config_collision_dist(hw);
 		ret_val = igb_config_fc_after_link_up(hw);
 	} else {
-		hw_dbg(hw, "Unable to establish link!!!\n");
+		hw_dbg("Unable to establish link!!!\n");
 	}
 
 out:
@@ -1022,7 +1008,7 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 		       E1000_PCS_LCTL_FDV_FULL |      /* SerDes Full duplex */
 		       E1000_PCS_LCTL_AN_ENABLE |     /* Enable Autoneg */
 		       E1000_PCS_LCTL_AN_RESTART;     /* Restart autoneg */
-		hw_dbg(hw, "Configuring Autoneg; PCS_LCTL = 0x%08X\n", reg);
+		hw_dbg("Configuring Autoneg; PCS_LCTL = 0x%08X\n", reg);
 	} else {
 		/* Set PCS register for forced speed */
 		reg |= E1000_PCS_LCTL_FLV_LINK_UP |   /* Force link up */
@@ -1030,7 +1016,7 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 		       E1000_PCS_LCTL_FDV_FULL |      /* SerDes Full duplex */
 		       E1000_PCS_LCTL_FSD |           /* Force Speed */
 		       E1000_PCS_LCTL_FORCE_LINK;     /* Force Link */
-		hw_dbg(hw, "Configuring Forced Link; PCS_LCTL = 0x%08X\n", reg);
+		hw_dbg("Configuring Forced Link; PCS_LCTL = 0x%08X\n", reg);
 	}
 	wr32(E1000_PCS_LCTL, reg);
 
@@ -1071,7 +1057,7 @@ static s32 igb_configure_pcs_link_82575(struct e1000_hw *hw)
 		 */
 		reg |= E1000_PCS_LCTL_AN_RESTART | E1000_PCS_LCTL_AN_ENABLE;
 	} else {
-		/* Set PCS regiseter for forced speed */
+		/* Set PCS register for forced speed */
 
 		/* Turn off bits for full duplex, speed, and autoneg */
 		reg &= ~(E1000_PCS_LCTL_FSV_1000 |
@@ -1092,8 +1078,7 @@ static s32 igb_configure_pcs_link_82575(struct e1000_hw *hw)
 		       E1000_PCS_LCTL_FORCE_LINK |
 		       E1000_PCS_LCTL_FLV_LINK_UP;
 
-		hw_dbg(hw,
-		       "Wrote 0x%08X to PCS_LCTL to configure forced link\n",
+		hw_dbg("Wrote 0x%08X to PCS_LCTL to configure forced link\n",
 		       reg);
 	}
 	wr32(E1000_PCS_LCTL, reg);
@@ -1138,7 +1123,7 @@ out:
 static s32 igb_reset_init_script_82575(struct e1000_hw *hw)
 {
 	if (hw->mac.type == e1000_82575) {
-		hw_dbg(hw, "Running reset init script for 82575\n");
+		hw_dbg("Running reset init script for 82575\n");
 		/* SerDes configuration via SERDESCTRL */
 		igb_write_8bit_ctrl_reg(hw, E1000_SCTL, 0x00, 0x0C);
 		igb_write_8bit_ctrl_reg(hw, E1000_SCTL, 0x01, 0x78);
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 76ea846..5fb79dd 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -56,7 +56,7 @@
 #define E1000_EIMS_RX_QUEUE E1000_EICR_RX_QUEUE
 #define E1000_EIMS_TX_QUEUE E1000_EICR_TX_QUEUE
 
-/* Immediate Interrupt RX (A.K.A. Low Latency Interrupt) */
+/* Immediate Interrupt Rx (A.K.A. Low Latency Interrupt) */
 
 /* Receive Descriptor - Advanced */
 union e1000_adv_rx_desc {
@@ -145,6 +145,6 @@ struct e1000_adv_tx_context_desc {
 
 
 
-#define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* TX Desc writeback RO bit */
+#define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
 
 #endif
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 8da9ffe..1006d53 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -91,12 +91,12 @@
 #define E1000_MAX_SGMII_PHY_REG_ADDR  255
 #define E1000_I2CCMD_PHY_TIMEOUT      200
 
-/* Receive Decriptor bit definitions */
+/* Receive Descriptor bit definitions */
 #define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
 #define E1000_RXD_STAT_EOP      0x02    /* End of Packet */
 #define E1000_RXD_STAT_IXSM     0x04    /* Ignore checksum */
 #define E1000_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
-#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum caculated */
+#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
 #define E1000_RXD_STAT_TCPCS    0x20    /* TCP xsum calculated */
 #define E1000_RXD_STAT_DYNINT   0x800   /* Pkt caused INT via DYNINT */
 #define E1000_RXD_ERR_CE        0x01    /* CRC Error */
@@ -379,7 +379,7 @@
 #define E1000_ICR_RXO           0x00000040 /* rx overrun */
 #define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */
 #define E1000_ICR_MDAC          0x00000200 /* MDIO access complete */
-#define E1000_ICR_RXCFG         0x00000400 /* RX /c/ ordered set */
+#define E1000_ICR_RXCFG         0x00000400 /* Rx /c/ ordered set */
 #define E1000_ICR_GPI_EN0       0x00000800 /* GP Int 0 */
 #define E1000_ICR_GPI_EN1       0x00001000 /* GP Int 1 */
 #define E1000_ICR_GPI_EN2       0x00002000 /* GP Int 2 */
@@ -443,12 +443,6 @@
 #define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
 #define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
 #define E1000_IMS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
-/* queue 0 Rx descriptor FIFO parity error */
-/* queue 0 Tx descriptor FIFO parity error */
-/* host arb read buffer parity error */
-/* packet buffer parity error */
-/* queue 1 Rx descriptor FIFO parity error */
-/* queue 1 Tx descriptor FIFO parity error */
 
 /* Extended Interrupt Mask Set */
 #define E1000_EIMS_TCP_TIMER    E1000_EICR_TCP_TIMER /* TCP Timer */
@@ -457,12 +451,6 @@
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
 #define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
-/* queue 0 Rx descriptor FIFO parity error */
-/* queue 0 Tx descriptor FIFO parity error */
-/* host arb read buffer parity error */
-/* packet buffer parity error */
-/* queue 1 Rx descriptor FIFO parity error */
-/* queue 1 Tx descriptor FIFO parity error */
 
 /* Extended Interrupt Cause Set */
 
@@ -567,7 +555,6 @@
 /* 1000BASE-T Control Register */
 #define CR_1000T_HD_CAPS         0x0100 /* Advertise 1000T HD capability */
 #define CR_1000T_FD_CAPS         0x0200 /* Advertise 1000T FD capability  */
-					/* 0=DTE device */
 #define CR_1000T_MS_VALUE        0x0800 /* 1=Configure PHY as Master */
 					/* 0=Configure PHY as Slave */
 #define CR_1000T_MS_ENABLE       0x1000 /* 1=Master/Slave manual config value */
@@ -581,7 +568,7 @@
 /* PHY 1000 MII Register/Bit Definitions */
 /* PHY Registers defined by IEEE */
 #define PHY_CONTROL      0x00 /* Control Register */
-#define PHY_STATUS       0x01 /* Status Regiser */
+#define PHY_STATUS       0x01 /* Status Register */
 #define PHY_ID1          0x02 /* Phy Id Reg (word 1) */
 #define PHY_ID2          0x03 /* Phy Id Reg (word 2) */
 #define PHY_AUTONEG_ADV  0x04 /* Autoneg Advertisement */
@@ -708,8 +695,8 @@
 /* Auto crossover enabled all speeds */
 #define M88E1000_PSCR_AUTO_X_MODE      0x0060
 /*
- * 1=Enable Extended 10BASE-T distance (Lower 10BASE-T RX Threshold
- * 0=Normal 10BASE-T RX Threshold
+ * 1=Enable Extended 10BASE-T distance (Lower 10BASE-T Rx Threshold
+ * 0=Normal 10BASE-T Rx Threshold
  */
 /* 1=5-bit interface in 100BASE-TX, 0=MII interface in 100BASE-TX */
 #define M88E1000_PSCR_ASSERT_CRS_ON_TX     0x0800 /* 1=Assert CRS on Transmit */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 7b2c70a..746c3ea 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -586,14 +586,10 @@ struct e1000_hw {
 
 #ifdef DEBUG
 extern char *igb_get_hw_dev_name(struct e1000_hw *hw);
-#define hw_dbg(hw, format, arg...) \
+#define hw_dbg(format, arg...) \
 	printk(KERN_DEBUG "%s: " format, igb_get_hw_dev_name(hw), ##arg)
 #else
-static inline int __attribute__ ((format (printf, 2, 3)))
-hw_dbg(struct e1000_hw *hw, const char *format, ...)
-{
-	return 0;
-}
+#define hw_dbg(format, arg...)
 #endif
 
 #endif
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 0dadcfd..47ad2c4 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -158,12 +158,12 @@ void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 	u32 i;
 
 	/* Setup the receive address */
-	hw_dbg(hw, "Programming MAC Address into RAR[0]\n");
+	hw_dbg("Programming MAC Address into RAR[0]\n");
 
 	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
 
 	/* Zero out the other (rar_entry_count - 1) receive addresses */
-	hw_dbg(hw, "Clearing RAR[1-%u]\n", rar_count-1);
+	hw_dbg("Clearing RAR[1-%u]\n", rar_count-1);
 	for (i = 1; i < rar_count; i++) {
 		array_wr32(E1000_RA, (i << 1), 0);
 		wrfl();
@@ -193,7 +193,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 	ret_val = hw->nvm.ops.read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
 				 &nvm_alt_mac_addr_offset);
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 
@@ -209,7 +209,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 		offset = nvm_alt_mac_addr_offset + (i >> 1);
 		ret_val = hw->nvm.ops.read_nvm(hw, offset, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg(hw, "NVM Read Error\n");
+			hw_dbg("NVM Read Error\n");
 			goto out;
 		}
 
@@ -336,7 +336,7 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
 	}
 
 	/* Clear the old settings from the MTA */
-	hw_dbg(hw, "Clearing MTA\n");
+	hw_dbg("Clearing MTA\n");
 	for (i = 0; i < hw->mac.mta_reg_count; i++) {
 		array_wr32(E1000_MTA, i, 0);
 		wrfl();
@@ -345,7 +345,7 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
 	/* Load any remaining multicast addresses into the hash table. */
 	for (; mc_addr_count > 0; mc_addr_count--) {
 		hash_value = igb_hash_mc_addr(hw, mc_addr_list);
-		hw_dbg(hw, "Hash value = 0x%03X\n", hash_value);
+		hw_dbg("Hash value = 0x%03X\n", hash_value);
 		igb_mta_set(hw, hash_value);
 		mc_addr_list += ETH_ALEN;
 	}
@@ -540,7 +540,7 @@ s32 igb_check_for_copper_link(struct e1000_hw *hw)
 	 */
 	ret_val = igb_config_fc_after_link_up(hw);
 	if (ret_val)
-		hw_dbg(hw, "Error configuring flow control\n");
+		hw_dbg("Error configuring flow control\n");
 
 out:
 	return ret_val;
@@ -578,7 +578,7 @@ s32 igb_setup_link(struct e1000_hw *hw)
 	 */
 	hw->fc.original_type = hw->fc.type;
 
-	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n", hw->fc.type);
+	hw_dbg("After fix-ups FlowControl is now = %x\n", hw->fc.type);
 
 	/* Call the necessary media_type subroutine to configure the link. */
 	ret_val = hw->mac.ops.setup_physical_interface(hw);
@@ -591,8 +591,7 @@ s32 igb_setup_link(struct e1000_hw *hw)
 	 * control is disabled, because it does not hurt anything to
 	 * initialize these registers.
 	 */
-	hw_dbg(hw,
-	       "Initializing the Flow Control address, type and timer regs\n");
+	hw_dbg("Initializing the Flow Control address, type and timer regs\n");
 	wr32(E1000_FCT, FLOW_CONTROL_TYPE);
 	wr32(E1000_FCAH, FLOW_CONTROL_ADDRESS_HIGH);
 	wr32(E1000_FCAL, FLOW_CONTROL_ADDRESS_LOW);
@@ -689,7 +688,7 @@ static s32 igb_set_default_fc(struct e1000_hw *hw)
 				       &nvm_data);
 
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 
@@ -740,7 +739,7 @@ s32 igb_force_mac_fc(struct e1000_hw *hw)
 	 *      3:  Both Rx and TX flow control (symmetric) is enabled.
 	 *  other:  No other values should be possible at this point.
 	 */
-	hw_dbg(hw, "hw->fc.type = %u\n", hw->fc.type);
+	hw_dbg("hw->fc.type = %u\n", hw->fc.type);
 
 	switch (hw->fc.type) {
 	case e1000_fc_none:
@@ -758,7 +757,7 @@ s32 igb_force_mac_fc(struct e1000_hw *hw)
 		ctrl |= (E1000_CTRL_TFCE | E1000_CTRL_RFCE);
 		break;
 	default:
-		hw_dbg(hw, "Flow control param set incorrectly\n");
+		hw_dbg("Flow control param set incorrectly\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -801,7 +800,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 	}
 
 	if (ret_val) {
-		hw_dbg(hw, "Error forcing flow control settings\n");
+		hw_dbg("Error forcing flow control settings\n");
 		goto out;
 	}
 
@@ -827,7 +826,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			goto out;
 
 		if (!(mii_status_reg & MII_SR_AUTONEG_COMPLETE)) {
-			hw_dbg(hw, "Copper PHY and Auto Neg "
+			hw_dbg("Copper PHY and Auto Neg "
 				 "has not completed.\n");
 			goto out;
 		}
@@ -893,11 +892,11 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 */
 			if (hw->fc.original_type == e1000_fc_full) {
 				hw->fc.type = e1000_fc_full;
-				hw_dbg(hw, "Flow Control = FULL.\r\n");
+				hw_dbg("Flow Control = FULL.\r\n");
 			} else {
 				hw->fc.type = e1000_fc_rx_pause;
-				hw_dbg(hw, "Flow Control = "
-					 "RX PAUSE frames only.\r\n");
+				hw_dbg("Flow Control = "
+				       "RX PAUSE frames only.\r\n");
 			}
 		}
 		/*
@@ -913,7 +912,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.type = e1000_fc_tx_pause;
-			hw_dbg(hw, "Flow Control = TX PAUSE frames only.\r\n");
+			hw_dbg("Flow Control = TX PAUSE frames only.\r\n");
 		}
 		/*
 		 * For transmitting PAUSE frames ONLY.
@@ -928,7 +927,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.type = e1000_fc_rx_pause;
-			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\r\n");
+			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
 		}
 		/*
 		 * Per the IEEE spec, at this point flow control should be
@@ -955,10 +954,10 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			  hw->fc.original_type == e1000_fc_tx_pause) ||
 			 hw->fc.strict_ieee) {
 			hw->fc.type = e1000_fc_none;
-			hw_dbg(hw, "Flow Control = NONE.\r\n");
+			hw_dbg("Flow Control = NONE.\r\n");
 		} else {
 			hw->fc.type = e1000_fc_rx_pause;
-			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\r\n");
+			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
 		}
 
 		/*
@@ -968,7 +967,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = hw->mac.ops.get_speed_and_duplex(hw, &speed, &duplex);
 		if (ret_val) {
-			hw_dbg(hw, "Error getting link speed and duplex\n");
+			hw_dbg("Error getting link speed and duplex\n");
 			goto out;
 		}
 
@@ -981,7 +980,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = igb_force_mac_fc(hw);
 		if (ret_val) {
-			hw_dbg(hw, "Error forcing flow control settings\n");
+			hw_dbg("Error forcing flow control settings\n");
 			goto out;
 		}
 	}
@@ -1007,21 +1006,21 @@ s32 igb_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
 	status = rd32(E1000_STATUS);
 	if (status & E1000_STATUS_SPEED_1000) {
 		*speed = SPEED_1000;
-		hw_dbg(hw, "1000 Mbs, ");
+		hw_dbg("1000 Mbs, ");
 	} else if (status & E1000_STATUS_SPEED_100) {
 		*speed = SPEED_100;
-		hw_dbg(hw, "100 Mbs, ");
+		hw_dbg("100 Mbs, ");
 	} else {
 		*speed = SPEED_10;
-		hw_dbg(hw, "10 Mbs, ");
+		hw_dbg("10 Mbs, ");
 	}
 
 	if (status & E1000_STATUS_FD) {
 		*duplex = FULL_DUPLEX;
-		hw_dbg(hw, "Full Duplex\n");
+		hw_dbg("Full Duplex\n");
 	} else {
 		*duplex = HALF_DUPLEX;
-		hw_dbg(hw, "Half Duplex\n");
+		hw_dbg("Half Duplex\n");
 	}
 
 	return 0;
@@ -1051,7 +1050,7 @@ s32 igb_get_hw_semaphore(struct e1000_hw *hw)
 	}
 
 	if (i == timeout) {
-		hw_dbg(hw, "Driver can't access device - SMBI bit is set.\n");
+		hw_dbg("Driver can't access device - SMBI bit is set.\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -1071,7 +1070,7 @@ s32 igb_get_hw_semaphore(struct e1000_hw *hw)
 	if (i == timeout) {
 		/* Release semaphores */
 		igb_put_hw_semaphore(hw);
-		hw_dbg(hw, "Driver can't access the NVM\n");
+		hw_dbg("Driver can't access the NVM\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -1117,7 +1116,7 @@ s32 igb_get_auto_rd_done(struct e1000_hw *hw)
 	}
 
 	if (i == AUTO_READ_DONE_TIMEOUT) {
-		hw_dbg(hw, "Auto read by HW from NVM has not completed.\n");
+		hw_dbg("Auto read by HW from NVM has not completed.\n");
 		ret_val = -E1000_ERR_RESET;
 		goto out;
 	}
@@ -1140,7 +1139,7 @@ static s32 igb_valid_led_default(struct e1000_hw *hw, u16 *data)
 
 	ret_val = hw->nvm.ops.read_nvm(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 
@@ -1322,7 +1321,7 @@ s32 igb_disable_pcie_master(struct e1000_hw *hw)
 	}
 
 	if (!timeout) {
-		hw_dbg(hw, "Master requests are pending.\n");
+		hw_dbg("Master requests are pending.\n");
 		ret_val = -E1000_ERR_MASTER_REQUESTS_PENDING;
 		goto out;
 	}
@@ -1342,7 +1341,7 @@ void igb_reset_adaptive(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 
 	if (!mac->adaptive_ifs) {
-		hw_dbg(hw, "Not in Adaptive IFS mode!\n");
+		hw_dbg("Not in Adaptive IFS mode!\n");
 		goto out;
 	}
 
@@ -1372,7 +1371,7 @@ void igb_update_adaptive(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 
 	if (!mac->adaptive_ifs) {
-		hw_dbg(hw, "Not in Adaptive IFS mode!\n");
+		hw_dbg("Not in Adaptive IFS mode!\n");
 		goto out;
 	}
 
@@ -1413,7 +1412,7 @@ s32 igb_validate_mdi_setting(struct e1000_hw *hw)
 	s32 ret_val = 0;
 
 	if (!hw->mac.autoneg && (hw->phy.mdix == 0 || hw->phy.mdix == 3)) {
-		hw_dbg(hw, "Invalid MDI setting detected\n");
+		hw_dbg("Invalid MDI setting detected\n");
 		hw->phy.mdix = 1;
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
@@ -1452,7 +1451,7 @@ s32 igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg,
 			break;
 	}
 	if (!(regvalue & E1000_GEN_CTL_READY)) {
-		hw_dbg(hw, "Reg %08x did not indicate ready\n", reg);
+		hw_dbg("Reg %08x did not indicate ready\n", reg);
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index 780ba79..a84e4e4 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -202,7 +202,7 @@ s32 igb_acquire_nvm(struct e1000_hw *hw)
 	if (!timeout) {
 		eecd &= ~E1000_EECD_REQ;
 		wr32(E1000_EECD, eecd);
-		hw_dbg(hw, "Could not acquire NVM grant\n");
+		hw_dbg("Could not acquire NVM grant\n");
 		ret_val = -E1000_ERR_NVM;
 	}
 
@@ -337,7 +337,7 @@ static s32 igb_ready_nvm_eeprom(struct e1000_hw *hw)
 		}
 
 		if (!timeout) {
-			hw_dbg(hw, "SPI NVM Status error\n");
+			hw_dbg("SPI NVM Status error\n");
 			ret_val = -E1000_ERR_NVM;
 			goto out;
 		}
@@ -368,7 +368,7 @@ s32 igb_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
-		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
+		hw_dbg("nvm parameter(s) out of bounds\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -414,7 +414,7 @@ s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
-		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
+		hw_dbg("nvm parameter(s) out of bounds\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -489,14 +489,14 @@ s32 igb_read_part_num(struct e1000_hw *hw, u32 *part_num)
 
 	ret_val = hw->nvm.ops.read_nvm(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 	*part_num = (u32)(nvm_data << 16);
 
 	ret_val = hw->nvm.ops.read_nvm(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 	*part_num |= nvm_data;
@@ -522,7 +522,7 @@ s32 igb_read_mac_addr(struct e1000_hw *hw)
 		offset = i >> 1;
 		ret_val = hw->nvm.ops.read_nvm(hw, offset, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg(hw, "NVM Read Error\n");
+			hw_dbg("NVM Read Error\n");
 			goto out;
 		}
 		hw->mac.perm_addr[i] = (u8)(nvm_data & 0xFF);
@@ -556,14 +556,14 @@ s32 igb_validate_nvm_checksum(struct e1000_hw *hw)
 	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
 		ret_val = hw->nvm.ops.read_nvm(hw, i, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg(hw, "NVM Read Error\n");
+			hw_dbg("NVM Read Error\n");
 			goto out;
 		}
 		checksum += nvm_data;
 	}
 
 	if (checksum != (u16) NVM_SUM) {
-		hw_dbg(hw, "NVM Checksum Invalid\n");
+		hw_dbg("NVM Checksum Invalid\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -589,7 +589,7 @@ s32 igb_update_nvm_checksum(struct e1000_hw *hw)
 	for (i = 0; i < NVM_CHECKSUM_REG; i++) {
 		ret_val = hw->nvm.ops.read_nvm(hw, i, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg(hw, "NVM Read Error while updating checksum.\n");
+			hw_dbg("NVM Read Error while updating checksum.\n");
 			goto out;
 		}
 		checksum += nvm_data;
@@ -597,7 +597,7 @@ s32 igb_update_nvm_checksum(struct e1000_hw *hw)
 	checksum = (u16) NVM_SUM - checksum;
 	ret_val = hw->nvm.ops.write_nvm(hw, NVM_CHECKSUM_REG, 1, &checksum);
 	if (ret_val)
-		hw_dbg(hw, "NVM Write Error while updating checksum.\n");
+		hw_dbg("NVM Write Error while updating checksum.\n");
 
 out:
 	return ret_val;
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index 220e471..17fddb9 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -144,7 +144,7 @@ static s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	s32 ret_val = 0;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
-		hw_dbg(hw, "PHY Address %d is out of range\n", offset);
+		hw_dbg("PHY Address %d is out of range\n", offset);
 		ret_val = -E1000_ERR_PARAM;
 		goto out;
 	}
@@ -172,12 +172,12 @@ static s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 			break;
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
-		hw_dbg(hw, "MDI Read did not complete\n");
+		hw_dbg("MDI Read did not complete\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
 	if (mdic & E1000_MDIC_ERROR) {
-		hw_dbg(hw, "MDI Error\n");
+		hw_dbg("MDI Error\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
@@ -202,7 +202,7 @@ static s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	s32 ret_val = 0;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
-		hw_dbg(hw, "PHY Address %d is out of range\n", offset);
+		hw_dbg("PHY Address %d is out of range\n", offset);
 		ret_val = -E1000_ERR_PARAM;
 		goto out;
 	}
@@ -231,12 +231,12 @@ static s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 			break;
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
-		hw_dbg(hw, "MDI Write did not complete\n");
+		hw_dbg("MDI Write did not complete\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
 	if (mdic & E1000_MDIC_ERROR) {
-		hw_dbg(hw, "MDI Error\n");
+		hw_dbg("MDI Error\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
@@ -423,7 +423,7 @@ s32 igb_copper_link_setup_m88(struct e1000_hw *hw)
 	/* Commit the changes. */
 	ret_val = igb_phy_sw_reset(hw);
 	if (ret_val) {
-		hw_dbg(hw, "Error committing the PHY changes\n");
+		hw_dbg("Error committing the PHY changes\n");
 		goto out;
 	}
 
@@ -451,7 +451,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 
 	ret_val = hw->phy.ops.reset_phy(hw);
 	if (ret_val) {
-		hw_dbg(hw, "Error resetting the PHY.\n");
+		hw_dbg("Error resetting the PHY.\n");
 		goto out;
 	}
 
@@ -467,7 +467,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 		if (hw->phy.ops.set_d3_lplu_state)
 			ret_val = hw->phy.ops.set_d3_lplu_state(hw, false);
 		if (ret_val) {
-			hw_dbg(hw, "Error Disabling LPLU D3\n");
+			hw_dbg("Error Disabling LPLU D3\n");
 			goto out;
 		}
 	}
@@ -475,7 +475,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 	/* disable lplu d0 during driver init */
 	ret_val = hw->phy.ops.set_d0_lplu_state(hw, false);
 	if (ret_val) {
-		hw_dbg(hw, "Error Disabling LPLU D0\n");
+		hw_dbg("Error Disabling LPLU D0\n");
 		goto out;
 	}
 	/* Configure mdi-mdix settings */
@@ -597,13 +597,13 @@ s32 igb_copper_link_autoneg(struct e1000_hw *hw)
 	if (phy->autoneg_advertised == 0)
 		phy->autoneg_advertised = phy->autoneg_mask;
 
-	hw_dbg(hw, "Reconfiguring auto-neg advertisement params\n");
+	hw_dbg("Reconfiguring auto-neg advertisement params\n");
 	ret_val = igb_phy_setup_autoneg(hw);
 	if (ret_val) {
-		hw_dbg(hw, "Error Setting up Auto-Negotiation\n");
+		hw_dbg("Error Setting up Auto-Negotiation\n");
 		goto out;
 	}
-	hw_dbg(hw, "Restarting Auto-Neg\n");
+	hw_dbg("Restarting Auto-Neg\n");
 
 	/*
 	 * Restart auto-negotiation by setting the Auto Neg Enable bit and
@@ -625,8 +625,8 @@ s32 igb_copper_link_autoneg(struct e1000_hw *hw)
 	if (phy->autoneg_wait_to_complete) {
 		ret_val = igb_wait_autoneg(hw);
 		if (ret_val) {
-			hw_dbg(hw, "Error while waiting for "
-				 "autoneg to complete\n");
+			hw_dbg("Error while waiting for "
+			       "autoneg to complete\n");
 			goto out;
 		}
 	}
@@ -689,39 +689,39 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 				 NWAY_AR_10T_HD_CAPS);
 	mii_1000t_ctrl_reg &= ~(CR_1000T_HD_CAPS | CR_1000T_FD_CAPS);
 
-	hw_dbg(hw, "autoneg_advertised %x\n", phy->autoneg_advertised);
+	hw_dbg("autoneg_advertised %x\n", phy->autoneg_advertised);
 
 	/* Do we want to advertise 10 Mb Half Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_10_HALF) {
-		hw_dbg(hw, "Advertise 10mb Half duplex\n");
+		hw_dbg("Advertise 10mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_HD_CAPS;
 	}
 
 	/* Do we want to advertise 10 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_10_FULL) {
-		hw_dbg(hw, "Advertise 10mb Full duplex\n");
+		hw_dbg("Advertise 10mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_FD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Half Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_100_HALF) {
-		hw_dbg(hw, "Advertise 100mb Half duplex\n");
+		hw_dbg("Advertise 100mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_HD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_100_FULL) {
-		hw_dbg(hw, "Advertise 100mb Full duplex\n");
+		hw_dbg("Advertise 100mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_FD_CAPS;
 	}
 
 	/* We do not allow the Phy to advertise 1000 Mb Half Duplex */
 	if (phy->autoneg_advertised & ADVERTISE_1000_HALF)
-		hw_dbg(hw, "Advertise 1000mb Half duplex request denied!\n");
+		hw_dbg("Advertise 1000mb Half duplex request denied!\n");
 
 	/* Do we want to advertise 1000 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_1000_FULL) {
-		hw_dbg(hw, "Advertise 1000mb Full duplex\n");
+		hw_dbg("Advertise 1000mb Full duplex\n");
 		mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
 	}
 
@@ -780,7 +780,7 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
 		break;
 	default:
-		hw_dbg(hw, "Flow control param set incorrectly\n");
+		hw_dbg("Flow control param set incorrectly\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -790,7 +790,7 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg(hw, "Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
+	hw_dbg("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
 	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
 		ret_val = hw->phy.ops.write_phy_reg(hw,
@@ -846,13 +846,12 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg(hw, "IGP PSCR: %X\n", phy_data);
+	hw_dbg("IGP PSCR: %X\n", phy_data);
 
 	udelay(1);
 
 	if (phy->autoneg_wait_to_complete) {
-		hw_dbg(hw,
-		       "Waiting for forced speed/duplex link on IGP phy.\n");
+		hw_dbg("Waiting for forced speed/duplex link on IGP phy.\n");
 
 		ret_val = igb_phy_has_link(hw,
 						     PHY_FORCE_LIMIT,
@@ -862,7 +861,7 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 			goto out;
 
 		if (!link)
-			hw_dbg(hw, "Link taking longer than expected.\n");
+			hw_dbg("Link taking longer than expected.\n");
 
 		/* Try once more */
 		ret_val = igb_phy_has_link(hw,
@@ -909,7 +908,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg(hw, "M88E1000 PSCR: %X\n", phy_data);
+	hw_dbg("M88E1000 PSCR: %X\n", phy_data);
 
 	ret_val = hw->phy.ops.read_phy_reg(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
@@ -927,8 +926,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	udelay(1);
 
 	if (phy->autoneg_wait_to_complete) {
-		hw_dbg(hw,
-		       "Waiting for forced speed/duplex link on M88 phy.\n");
+		hw_dbg("Waiting for forced speed/duplex link on M88 phy.\n");
 
 		ret_val = igb_phy_has_link(hw,
 						     PHY_FORCE_LIMIT,
@@ -1028,11 +1026,11 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 	if (mac->forced_speed_duplex & E1000_ALL_HALF_DUPLEX) {
 		ctrl &= ~E1000_CTRL_FD;
 		*phy_ctrl &= ~MII_CR_FULL_DUPLEX;
-		hw_dbg(hw, "Half Duplex\n");
+		hw_dbg("Half Duplex\n");
 	} else {
 		ctrl |= E1000_CTRL_FD;
 		*phy_ctrl |= MII_CR_FULL_DUPLEX;
-		hw_dbg(hw, "Full Duplex\n");
+		hw_dbg("Full Duplex\n");
 	}
 
 	/* Forcing 10mb or 100mb? */
@@ -1040,12 +1038,12 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 		ctrl |= E1000_CTRL_SPD_100;
 		*phy_ctrl |= MII_CR_SPEED_100;
 		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_10);
-		hw_dbg(hw, "Forcing 100mb\n");
+		hw_dbg("Forcing 100mb\n");
 	} else {
 		ctrl &= ~(E1000_CTRL_SPD_1000 | E1000_CTRL_SPD_100);
 		*phy_ctrl |= MII_CR_SPEED_10;
 		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_100);
-		hw_dbg(hw, "Forcing 10mb\n");
+		hw_dbg("Forcing 10mb\n");
 	}
 
 	igb_config_collision_dist(hw);
@@ -1459,7 +1457,7 @@ s32 igb_get_phy_info_m88(struct e1000_hw *hw)
 	bool link;
 
 	if (hw->phy.media_type != e1000_media_type_copper) {
-		hw_dbg(hw, "Phy info is only valid for copper media\n");
+		hw_dbg("Phy info is only valid for copper media\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -1469,7 +1467,7 @@ s32 igb_get_phy_info_m88(struct e1000_hw *hw)
 		goto out;
 
 	if (!link) {
-		hw_dbg(hw, "Phy info is only valid if link is up\n");
+		hw_dbg("Phy info is only valid if link is up\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -1543,7 +1541,7 @@ s32 igb_get_phy_info_igp(struct e1000_hw *hw)
 		goto out;
 
 	if (!link) {
-		hw_dbg(hw, "Phy info is only valid if link is up\n");
+		hw_dbg("Phy info is only valid if link is up\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -1728,7 +1726,7 @@ s32 igb_phy_force_speed_duplex(struct e1000_hw *hw)
  **/
 s32 igb_phy_init_script_igp3(struct e1000_hw *hw)
 {
-	hw_dbg(hw, "Running IGP 3 PHY init script\n");
+	hw_dbg("Running IGP 3 PHY init script\n");
 
 	/* PHY init IGP 3 */
 	/* Enable rise/fall, 10-mode work in class-A */


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
