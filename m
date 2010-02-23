From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 7/7] drivers/net/igb: Use
	netdev_<level>
Date: Mon, 22 Feb 2010 18:57:03 -0800
Message-ID: <3693e510c27c3abd2d9e1d25aab1359f05f11d76.1266893508.git.joe@perches.com>
References: <cover.1266893507.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1266893507.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert hw_dbg to netdev_dbg
Convert a couple printks to pr_<level>
Coalesce some format strings

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/igb/e1000_82575.c |   58 ++++++++++++-----------
 drivers/net/igb/e1000_hw.h    |   12 ++---
 drivers/net/igb/e1000_mac.c   |   84 ++++++++++++++++-----------------
 drivers/net/igb/e1000_nvm.c   |   22 ++++----
 drivers/net/igb/e1000_phy.c   |  104 +++++++++++++++++++++--------------------
 drivers/net/igb/igb.h         |    1 -
 drivers/net/igb/igb_ethtool.c |    6 +--
 drivers/net/igb/igb_main.c    |   43 ++++++-----------
 8 files changed, 157 insertions(+), 173 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 9d7fa2f..0db6032 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -33,8 +33,7 @@
 #include <linux/slab.h>
 #include <linux/if_ether.h>
 
-#include "e1000_mac.h"
-#include "e1000_82575.h"
+#include "igb.h"
 
 static s32  igb_get_invariants_82575(struct e1000_hw *);
 static s32  igb_acquire_phy_82575(struct e1000_hw *);
@@ -322,7 +321,8 @@ static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 	s32 ret_val = -E1000_ERR_PARAM;
 
 	if (offset > E1000_MAX_SGMII_PHY_REG_ADDR) {
-		hw_dbg("PHY Address %u is out of range\n", offset);
+		netdev_dbg(hw_netdev(hw), "PHY Address %u is out of range\n",
+			   offset);
 		goto out;
 	}
 
@@ -354,7 +354,8 @@ static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 
 
 	if (offset > E1000_MAX_SGMII_PHY_REG_ADDR) {
-		hw_dbg("PHY Address %d is out of range\n", offset);
+		netdev_dbg(hw_netdev(hw), "PHY Address %d is out of range\n",
+			   offset);
 		goto out;
 	}
 
@@ -410,8 +411,8 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 	for (phy->addr = 1; phy->addr < 8; phy->addr++) {
 		ret_val = igb_read_phy_reg_sgmii_82575(hw, PHY_ID1, &phy_id);
 		if (ret_val == 0) {
-			hw_dbg("Vendor ID 0x%08X read at address %u\n",
-			       phy_id, phy->addr);
+			netdev_dbg(hw_netdev(hw), "Vendor ID 0x%08X read at address %u\n",
+				   phy_id, phy->addr);
 			/*
 			 * At the time of this writing, The M88 part is
 			 * the only supported SGMII PHY product.
@@ -419,7 +420,8 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 			if (phy_id == M88_VENDOR)
 				break;
 		} else {
-			hw_dbg("PHY address %u was unreadable\n", phy->addr);
+			netdev_dbg(hw_netdev(hw), "PHY address %u was unreadable\n",
+				   phy->addr);
 		}
 	}
 
@@ -454,7 +456,7 @@ static s32 igb_phy_hw_reset_sgmii_82575(struct e1000_hw *hw)
 	 * available to us at this time.
 	 */
 
-	hw_dbg("Soft resetting SGMII attached PHY...\n");
+	netdev_dbg(hw_netdev(hw), "Soft resetting SGMII attached PHY...\n");
 
 	/*
 	 * SFP documentation requires the following to configure the SPF module
@@ -622,7 +624,7 @@ static s32 igb_acquire_swfw_sync_82575(struct e1000_hw *hw, u16 mask)
 	}
 
 	if (i == timeout) {
-		hw_dbg("Driver can't access resource, SW_FW_SYNC timeout.\n");
+		netdev_dbg(hw_netdev(hw), "Driver can't access resource, SW_FW_SYNC timeout\n");
 		ret_val = -E1000_ERR_SWFW_SYNC;
 		goto out;
 	}
@@ -688,7 +690,7 @@ static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
 		timeout--;
 	}
 	if (!timeout)
-		hw_dbg("MNG configuration cycle has not completed.\n");
+		netdev_dbg(hw_netdev(hw), "MNG configuration cycle has not completed\n");
 
 	/* If EEPROM is not marked present, init the PHY manually */
 	if (((rd32(E1000_EECD) & E1000_EECD_PRES) == 0) &&
@@ -859,15 +861,15 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 	 */
 	ret_val = igb_disable_pcie_master(hw);
 	if (ret_val)
-		hw_dbg("PCI-E Master disable polling has failed.\n");
+		netdev_dbg(hw_netdev(hw), "PCI-E Master disable polling has failed\n");
 
 	/* set the completion timeout for interface */
 	ret_val = igb_set_pcie_completion_timeout(hw);
 	if (ret_val) {
-		hw_dbg("PCI-E Set completion timeout has failed.\n");
+		netdev_dbg(hw_netdev(hw), "PCI-E Set completion timeout has failed\n");
 	}
 
-	hw_dbg("Masking off all interrupts\n");
+	netdev_dbg(hw_netdev(hw), "Masking off all interrupts\n");
 	wr32(E1000_IMC, 0xffffffff);
 
 	wr32(E1000_RCTL, 0);
@@ -878,7 +880,7 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 
 	ctrl = rd32(E1000_CTRL);
 
-	hw_dbg("Issuing a global reset to MAC\n");
+	netdev_dbg(hw_netdev(hw), "Issuing a global reset to MAC\n");
 	wr32(E1000_CTRL, ctrl | E1000_CTRL_RST);
 
 	ret_val = igb_get_auto_rd_done(hw);
@@ -888,7 +890,7 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 		 * return with an error. This can happen in situations
 		 * where there is no eeprom and prevents getting link.
 		 */
-		hw_dbg("Auto Read Done did not complete\n");
+		netdev_dbg(hw_netdev(hw), "Auto Read Done did not complete\n");
 	}
 
 	/* If EEPROM is not present, run manual init scripts */
@@ -920,24 +922,24 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 	/* Initialize identification LED */
 	ret_val = igb_id_led_init(hw);
 	if (ret_val) {
-		hw_dbg("Error initializing identification LED\n");
+		netdev_dbg(hw_netdev(hw), "Error initializing identification LED\n");
 		/* This is not fatal and we should not stop init due to this */
 	}
 
 	/* Disabling VLAN filtering */
-	hw_dbg("Initializing the IEEE VLAN\n");
+	netdev_dbg(hw_netdev(hw), "Initializing the IEEE VLAN\n");
 	igb_clear_vfta(hw);
 
 	/* Setup the receive address */
 	igb_init_rx_addrs(hw, rar_count);
 
 	/* Zero out the Multicast HASH table */
-	hw_dbg("Zeroing the MTA\n");
+	netdev_dbg(hw_netdev(hw), "Zeroing the MTA\n");
 	for (i = 0; i < mac->mta_reg_count; i++)
 		array_wr32(E1000_MTA, i, 0);
 
 	/* Zero out the Unicast HASH table */
-	hw_dbg("Zeroing the UTA\n");
+	netdev_dbg(hw_netdev(hw), "Zeroing the UTA\n");
 	for (i = 0; i < mac->uta_reg_count; i++)
 		array_wr32(E1000_UTA, i, 0);
 
@@ -983,7 +985,7 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 
 		ret_val = hw->phy.ops.reset(hw);
 		if (ret_val) {
-			hw_dbg("Error resetting the PHY.\n");
+			netdev_dbg(hw_netdev(hw), "Error resetting the PHY\n");
 			goto out;
 		}
 	}
@@ -1104,12 +1106,14 @@ static s32 igb_setup_serdes_link_82575(struct e1000_hw *hw)
 		/* Set PCS register for autoneg */
 		reg |= E1000_PCS_LCTL_AN_ENABLE | /* Enable Autoneg */
 		       E1000_PCS_LCTL_AN_RESTART; /* Restart autoneg */
-		hw_dbg("Configuring Autoneg:PCS_LCTL=0x%08X\n", reg);
+		netdev_dbg(hw_netdev(hw), "Configuring Autoneg:PCS_LCTL=0x%08X\n",
+			   reg);
 	} else {
 		/* Set PCS register for forced link */
 		reg |= E1000_PCS_LCTL_FSD;        /* Force Speed */
 
-		hw_dbg("Configuring Forced Link:PCS_LCTL=0x%08X\n", reg);
+		netdev_dbg(hw_netdev(hw), "Configuring Forced Link:PCS_LCTL=0x%08X\n",
+			   reg);
 	}
 
 	wr32(E1000_PCS_LCTL, reg);
@@ -1144,7 +1148,7 @@ static bool igb_sgmii_active_82575(struct e1000_hw *hw)
 static s32 igb_reset_init_script_82575(struct e1000_hw *hw)
 {
 	if (hw->mac.type == e1000_82575) {
-		hw_dbg("Running reset init script for 82575\n");
+		netdev_dbg(hw_netdev(hw), "Running reset init script for 82575\n");
 		/* SerDes configuration via SERDESCTRL */
 		igb_write_8bit_ctrl_reg(hw, E1000_SCTL, 0x00, 0x0C);
 		igb_write_8bit_ctrl_reg(hw, E1000_SCTL, 0x01, 0x78);
@@ -1307,7 +1311,7 @@ void igb_rx_fifo_flush_82575(struct e1000_hw *hw)
 	}
 
 	if (ms_wait == 10)
-		hw_dbg("Queue disable timed out after 10ms\n");
+		netdev_dbg(hw_netdev(hw), "Queue disable timed out after 10ms\n");
 
 	/* Clear RLPML, RCTL.SBP, RFCTL.LEF, and set RCTL.LPE so that all
 	 * incoming packets are rejected.  Set enable and wait 2ms so that
@@ -1532,9 +1536,9 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 	 */
 	ret_val = igb_disable_pcie_master(hw);
 	if (ret_val)
-		hw_dbg("PCI-E Master disable polling has failed.\n");
+		netdev_dbg(hw_netdev(hw), "PCI-E Master disable polling has failed\n");
 
-	hw_dbg("Masking off all interrupts\n");
+	netdev_dbg(hw_netdev(hw), "Masking off all interrupts\n");
 	wr32(E1000_IMC, 0xffffffff);
 	wr32(E1000_RCTL, 0);
 	wr32(E1000_TCTL, E1000_TCTL_PSP);
@@ -1566,7 +1570,7 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 		 * return with an error. This can happen in situations
 		 * where there is no eeprom and prevents getting link.
 		 */
-		hw_dbg("Auto Read Done did not complete\n");
+		netdev_dbg(hw_netdev(hw), "Auto Read Done did not complete\n");
 	}
 
 	/* If EEPROM is not present, run manual init scripts */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 4480052..7dc3166 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -31,6 +31,7 @@
 #include <linux/types.h>
 #include <linux/delay.h>
 #include <linux/io.h>
+#include <linux/netdevice.h>
 
 #include "e1000_regs.h"
 #include "e1000_defines.h"
@@ -501,14 +502,11 @@ struct e1000_hw {
 	u8  revision_id;
 };
 
-#ifdef DEBUG
-extern char *igb_get_hw_dev_name(struct e1000_hw *hw);
-#define hw_dbg(format, arg...) \
-	printk(KERN_DEBUG "%s: " format, igb_get_hw_dev_name(hw), ##arg)
-#else
-#define hw_dbg(format, arg...)
-#endif
+/* get (struct net_device *) from (struct e1000_hw *) */
+#define hw_netdev(hw) (((struct igb_adapter *)((hw)->back))->netdev)
+
 #endif
+
 /* These functions must be implemented by drivers */
 s32  igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
 s32  igb_write_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 2a8a886..d8f1cf1 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -28,7 +28,6 @@
 #include <linux/if_ether.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/netdevice.h>
 
 #include "e1000_mac.h"
 
@@ -118,12 +117,12 @@ void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 	u8 mac_addr[ETH_ALEN] = {0};
 
 	/* Setup the receive address */
-	hw_dbg("Programming MAC Address into RAR[0]\n");
+	netdev_dbg(hw_netdev(hw), "Programming MAC Address into RAR[0]\n");
 
 	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
 
 	/* Zero out the other (rar_entry_count - 1) receive addresses */
-	hw_dbg("Clearing RAR[1-%u]\n", rar_count-1);
+	netdev_dbg(hw_netdev(hw), "Clearing RAR[1-%u]\n", rar_count-1);
 	for (i = 1; i < rar_count; i++)
 		hw->mac.ops.rar_set(hw, mac_addr, i);
 }
@@ -180,7 +179,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 	ret_val = hw->nvm.ops.read(hw, NVM_ALT_MAC_ADDR_PTR, 1,
 				 &nvm_alt_mac_addr_offset);
 	if (ret_val) {
-		hw_dbg("NVM Read Error\n");
+		netdev_dbg(hw_netdev(hw), "NVM Read Error\n");
 		goto out;
 	}
 
@@ -195,7 +194,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 		offset = nvm_alt_mac_addr_offset + (i >> 1);
 		ret_val = hw->nvm.ops.read(hw, offset, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg("NVM Read Error\n");
+			netdev_dbg(hw_netdev(hw), "NVM Read Error\n");
 			goto out;
 		}
 
@@ -205,7 +204,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 
 	/* if multicast bit is set, the alternate address will not be used */
 	if (alt_mac_addr[0] & 0x01) {
-		hw_dbg("Ignoring Alternate Mac Address with MC bit set\n");
+		netdev_dbg(hw_netdev(hw), "Ignoring Alternate Mac Address with MC bit set\n");
 		goto out;
 	}
 
@@ -515,7 +514,7 @@ s32 igb_check_for_copper_link(struct e1000_hw *hw)
 	 */
 	ret_val = igb_config_fc_after_link_up(hw);
 	if (ret_val)
-		hw_dbg("Error configuring flow control\n");
+		netdev_dbg(hw_netdev(hw), "Error configuring flow control\n");
 
 out:
 	return ret_val;
@@ -559,7 +558,8 @@ s32 igb_setup_link(struct e1000_hw *hw)
 	 */
 	hw->fc.current_mode = hw->fc.requested_mode;
 
-	hw_dbg("After fix-ups FlowControl is now = %x\n", hw->fc.current_mode);
+	netdev_dbg(hw_netdev(hw), "After fix-ups FlowControl is now = %x\n",
+		   hw->fc.current_mode);
 
 	/* Call the necessary media_type subroutine to configure the link. */
 	ret_val = hw->mac.ops.setup_physical_interface(hw);
@@ -572,7 +572,7 @@ s32 igb_setup_link(struct e1000_hw *hw)
 	 * control is disabled, because it does not hurt anything to
 	 * initialize these registers.
 	 */
-	hw_dbg("Initializing the Flow Control address, type and timer regs\n");
+	netdev_dbg(hw_netdev(hw), "Initializing the Flow Control address, type and timer regs\n");
 	wr32(E1000_FCT, FLOW_CONTROL_TYPE);
 	wr32(E1000_FCAH, FLOW_CONTROL_ADDRESS_HIGH);
 	wr32(E1000_FCAL, FLOW_CONTROL_ADDRESS_LOW);
@@ -668,7 +668,7 @@ static s32 igb_set_default_fc(struct e1000_hw *hw)
 	ret_val = hw->nvm.ops.read(hw, NVM_INIT_CONTROL2_REG, 1, &nvm_data);
 
 	if (ret_val) {
-		hw_dbg("NVM Read Error\n");
+		netdev_dbg(hw_netdev(hw), "NVM Read Error\n");
 		goto out;
 	}
 
@@ -719,7 +719,8 @@ s32 igb_force_mac_fc(struct e1000_hw *hw)
 	 *      3:  Both Rx and TX flow control (symmetric) is enabled.
 	 *  other:  No other values should be possible at this point.
 	 */
-	hw_dbg("hw->fc.current_mode = %u\n", hw->fc.current_mode);
+	netdev_dbg(hw_netdev(hw), "hw->fc.current_mode = %u\n",
+		   hw->fc.current_mode);
 
 	switch (hw->fc.current_mode) {
 	case e1000_fc_none:
@@ -737,7 +738,7 @@ s32 igb_force_mac_fc(struct e1000_hw *hw)
 		ctrl |= (E1000_CTRL_TFCE | E1000_CTRL_RFCE);
 		break;
 	default:
-		hw_dbg("Flow control param set incorrectly\n");
+		netdev_dbg(hw_netdev(hw), "Flow control param set incorrectly\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -779,7 +780,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 	}
 
 	if (ret_val) {
-		hw_dbg("Error forcing flow control settings\n");
+		netdev_dbg(hw_netdev(hw), "Error forcing flow control settings\n");
 		goto out;
 	}
 
@@ -805,8 +806,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			goto out;
 
 		if (!(mii_status_reg & MII_SR_AUTONEG_COMPLETE)) {
-			hw_dbg("Copper PHY and Auto Neg "
-				 "has not completed.\n");
+			netdev_dbg(hw_netdev(hw), "Copper PHY and Auto Neg has not completed\n");
 			goto out;
 		}
 
@@ -871,11 +871,10 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 */
 			if (hw->fc.requested_mode == e1000_fc_full) {
 				hw->fc.current_mode = e1000_fc_full;
-				hw_dbg("Flow Control = FULL.\r\n");
+				netdev_dbg(hw_netdev(hw), "Flow Control = FULL.\r\n");
 			} else {
 				hw->fc.current_mode = e1000_fc_rx_pause;
-				hw_dbg("Flow Control = "
-				       "RX PAUSE frames only.\r\n");
+				netdev_dbg(hw_netdev(hw), "Flow Control = RX PAUSE frames only.\r\n");
 			}
 		}
 		/*
@@ -891,7 +890,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.current_mode = e1000_fc_tx_pause;
-			hw_dbg("Flow Control = TX PAUSE frames only.\r\n");
+			netdev_dbg(hw_netdev(hw), "Flow Control = TX PAUSE frames only.\r\n");
 		}
 		/*
 		 * For transmitting PAUSE frames ONLY.
@@ -906,7 +905,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.current_mode = e1000_fc_rx_pause;
-			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
+			netdev_dbg(hw_netdev(hw), "Flow Control = RX PAUSE frames only.\r\n");
 		}
 		/*
 		 * Per the IEEE spec, at this point flow control should be
@@ -933,10 +932,10 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			  hw->fc.requested_mode == e1000_fc_tx_pause) ||
 			 hw->fc.strict_ieee) {
 			hw->fc.current_mode = e1000_fc_none;
-			hw_dbg("Flow Control = NONE.\r\n");
+			netdev_dbg(hw_netdev(hw), "Flow Control = NONE.\r\n");
 		} else {
 			hw->fc.current_mode = e1000_fc_rx_pause;
-			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
+			netdev_dbg(hw_netdev(hw), "Flow Control = RX PAUSE frames only.\r\n");
 		}
 
 		/*
@@ -946,7 +945,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = hw->mac.ops.get_speed_and_duplex(hw, &speed, &duplex);
 		if (ret_val) {
-			hw_dbg("Error getting link speed and duplex\n");
+			netdev_dbg(hw_netdev(hw), "Error getting link speed and duplex\n");
 			goto out;
 		}
 
@@ -959,7 +958,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = igb_force_mac_fc(hw);
 		if (ret_val) {
-			hw_dbg("Error forcing flow control settings\n");
+			netdev_dbg(hw_netdev(hw), "Error forcing flow control settings\n");
 			goto out;
 		}
 	}
@@ -983,24 +982,22 @@ s32 igb_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
 	u32 status;
 
 	status = rd32(E1000_STATUS);
-	if (status & E1000_STATUS_SPEED_1000) {
+	if (status & E1000_STATUS_SPEED_1000)
 		*speed = SPEED_1000;
-		hw_dbg("1000 Mbs, ");
-	} else if (status & E1000_STATUS_SPEED_100) {
+	else if (status & E1000_STATUS_SPEED_100)
 		*speed = SPEED_100;
-		hw_dbg("100 Mbs, ");
-	} else {
+	else
 		*speed = SPEED_10;
-		hw_dbg("10 Mbs, ");
-	}
 
-	if (status & E1000_STATUS_FD) {
+	if (status & E1000_STATUS_FD)
 		*duplex = FULL_DUPLEX;
-		hw_dbg("Full Duplex\n");
-	} else {
+	else
 		*duplex = HALF_DUPLEX;
-		hw_dbg("Half Duplex\n");
-	}
+
+	netdev_dbg(hw_netdev(hw), "%u Mbps, %s Duplex\n",
+		   (*speed == SPEED_1000) ? 1000 :
+		   (*speed == SPEED_100) ? 100 : 10,
+		   (*duplex == FULL_DUPLEX) ? "Full" : "Half");
 
 	return 0;
 }
@@ -1029,7 +1026,7 @@ s32 igb_get_hw_semaphore(struct e1000_hw *hw)
 	}
 
 	if (i == timeout) {
-		hw_dbg("Driver can't access device - SMBI bit is set.\n");
+		netdev_dbg(hw_netdev(hw), "Driver can't access device - SMBI bit is set\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -1049,7 +1046,7 @@ s32 igb_get_hw_semaphore(struct e1000_hw *hw)
 	if (i == timeout) {
 		/* Release semaphores */
 		igb_put_hw_semaphore(hw);
-		hw_dbg("Driver can't access the NVM\n");
+		netdev_dbg(hw_netdev(hw), "Driver can't access the NVM\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -1095,7 +1092,7 @@ s32 igb_get_auto_rd_done(struct e1000_hw *hw)
 	}
 
 	if (i == AUTO_READ_DONE_TIMEOUT) {
-		hw_dbg("Auto read by HW from NVM has not completed.\n");
+		netdev_dbg(hw_netdev(hw), "Auto read by HW from NVM has not completed\n");
 		ret_val = -E1000_ERR_RESET;
 		goto out;
 	}
@@ -1118,7 +1115,7 @@ static s32 igb_valid_led_default(struct e1000_hw *hw, u16 *data)
 
 	ret_val = hw->nvm.ops.read(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
-		hw_dbg("NVM Read Error\n");
+		netdev_dbg(hw_netdev(hw), "NVM Read Error\n");
 		goto out;
 	}
 
@@ -1294,7 +1291,7 @@ s32 igb_disable_pcie_master(struct e1000_hw *hw)
 	}
 
 	if (!timeout) {
-		hw_dbg("Master requests are pending.\n");
+		netdev_dbg(hw_netdev(hw), "Master requests are pending\n");
 		ret_val = -E1000_ERR_MASTER_REQUESTS_PENDING;
 		goto out;
 	}
@@ -1315,7 +1312,7 @@ s32 igb_validate_mdi_setting(struct e1000_hw *hw)
 	s32 ret_val = 0;
 
 	if (!hw->mac.autoneg && (hw->phy.mdix == 0 || hw->phy.mdix == 3)) {
-		hw_dbg("Invalid MDI setting detected\n");
+		netdev_dbg(hw_netdev(hw), "Invalid MDI setting detected\n");
 		hw->phy.mdix = 1;
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
@@ -1354,7 +1351,8 @@ s32 igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg,
 			break;
 	}
 	if (!(regvalue & E1000_GEN_CTL_READY)) {
-		hw_dbg("Reg %08x did not indicate ready\n", reg);
+		netdev_dbg(hw_netdev(hw), "Reg %08x did not indicate ready\n",
+			   reg);
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index d83b77f..c6b4dad 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -28,7 +28,7 @@
 #include <linux/if_ether.h>
 #include <linux/delay.h>
 
-#include "e1000_mac.h"
+#include "igb.h"
 #include "e1000_nvm.h"
 
 /**
@@ -200,7 +200,7 @@ s32 igb_acquire_nvm(struct e1000_hw *hw)
 	if (!timeout) {
 		eecd &= ~E1000_EECD_REQ;
 		wr32(E1000_EECD, eecd);
-		hw_dbg("Could not acquire NVM grant\n");
+		netdev_dbg(hw_netdev(hw), "Could not acquire NVM grant\n");
 		ret_val = -E1000_ERR_NVM;
 	}
 
@@ -307,7 +307,7 @@ static s32 igb_ready_nvm_eeprom(struct e1000_hw *hw)
 		}
 
 		if (!timeout) {
-			hw_dbg("SPI NVM Status error\n");
+			netdev_dbg(hw_netdev(hw), "SPI NVM Status error\n");
 			ret_val = -E1000_ERR_NVM;
 			goto out;
 		}
@@ -338,7 +338,7 @@ s32 igb_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
-		hw_dbg("nvm parameter(s) out of bounds\n");
+		netdev_dbg(hw_netdev(hw), "nvm parameter(s) out of bounds\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -384,7 +384,7 @@ s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
-		hw_dbg("nvm parameter(s) out of bounds\n");
+		netdev_dbg(hw_netdev(hw), "nvm parameter(s) out of bounds\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -459,14 +459,14 @@ s32 igb_read_part_num(struct e1000_hw *hw, u32 *part_num)
 
 	ret_val = hw->nvm.ops.read(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
 	if (ret_val) {
-		hw_dbg("NVM Read Error\n");
+		netdev_dbg(hw_netdev(hw), "NVM Read Error\n");
 		goto out;
 	}
 	*part_num = (u32)(nvm_data << 16);
 
 	ret_val = hw->nvm.ops.read(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
 	if (ret_val) {
-		hw_dbg("NVM Read Error\n");
+		netdev_dbg(hw_netdev(hw), "NVM Read Error\n");
 		goto out;
 	}
 	*part_num |= nvm_data;
@@ -520,14 +520,14 @@ s32 igb_validate_nvm_checksum(struct e1000_hw *hw)
 	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
 		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg("NVM Read Error\n");
+			netdev_dbg(hw_netdev(hw), "NVM Read Error\n");
 			goto out;
 		}
 		checksum += nvm_data;
 	}
 
 	if (checksum != (u16) NVM_SUM) {
-		hw_dbg("NVM Checksum Invalid\n");
+		netdev_dbg(hw_netdev(hw), "NVM Checksum Invalid\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -553,7 +553,7 @@ s32 igb_update_nvm_checksum(struct e1000_hw *hw)
 	for (i = 0; i < NVM_CHECKSUM_REG; i++) {
 		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg("NVM Read Error while updating checksum.\n");
+			netdev_dbg(hw_netdev(hw), "NVM Read Error while updating checksum\n");
 			goto out;
 		}
 		checksum += nvm_data;
@@ -561,7 +561,7 @@ s32 igb_update_nvm_checksum(struct e1000_hw *hw)
 	checksum = (u16) NVM_SUM - checksum;
 	ret_val = hw->nvm.ops.write(hw, NVM_CHECKSUM_REG, 1, &checksum);
 	if (ret_val)
-		hw_dbg("NVM Write Error while updating checksum.\n");
+		netdev_dbg(hw_netdev(hw), "NVM Write Error while updating checksum\n");
 
 out:
 	return ret_val;
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index cf1f323..cafb8a0 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -28,7 +28,7 @@
 #include <linux/if_ether.h>
 #include <linux/delay.h>
 
-#include "e1000_mac.h"
+#include "igb.h"
 #include "e1000_phy.h"
 
 static s32  igb_phy_setup_autoneg(struct e1000_hw *hw);
@@ -143,7 +143,7 @@ s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	s32 ret_val = 0;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
-		hw_dbg("PHY Address %d is out of range\n", offset);
+		netdev_dbg(hw_netdev(hw), "PHY Address %d is out of range\n", offset);
 		ret_val = -E1000_ERR_PARAM;
 		goto out;
 	}
@@ -171,12 +171,12 @@ s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 			break;
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
-		hw_dbg("MDI Read did not complete\n");
+		netdev_dbg(hw_netdev(hw), "MDI Read did not complete\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
 	if (mdic & E1000_MDIC_ERROR) {
-		hw_dbg("MDI Error\n");
+		netdev_dbg(hw_netdev(hw), "MDI Error\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
@@ -201,7 +201,8 @@ s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	s32 ret_val = 0;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
-		hw_dbg("PHY Address %d is out of range\n", offset);
+		netdev_dbg(hw_netdev(hw), "PHY Address %d is out of range\n",
+			   offset);
 		ret_val = -E1000_ERR_PARAM;
 		goto out;
 	}
@@ -230,12 +231,12 @@ s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 			break;
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
-		hw_dbg("MDI Write did not complete\n");
+		netdev_dbg(hw_netdev(hw), "MDI Write did not complete\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
 	if (mdic & E1000_MDIC_ERROR) {
-		hw_dbg("MDI Error\n");
+		netdev_dbg(hw_netdev(hw), "MDI Error\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
@@ -278,11 +279,11 @@ s32 igb_read_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 *data)
 			break;
 	}
 	if (!(i2ccmd & E1000_I2CCMD_READY)) {
-		hw_dbg("I2CCMD Read did not complete\n");
+		netdev_dbg(hw_netdev(hw), "I2CCMD Read did not complete\n");
 		return -E1000_ERR_PHY;
 	}
 	if (i2ccmd & E1000_I2CCMD_ERROR) {
-		hw_dbg("I2CCMD Error bit set\n");
+		netdev_dbg(hw_netdev(hw), "I2CCMD Error bit set\n");
 		return -E1000_ERR_PHY;
 	}
 
@@ -330,11 +331,11 @@ s32 igb_write_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 data)
 			break;
 	}
 	if (!(i2ccmd & E1000_I2CCMD_READY)) {
-		hw_dbg("I2CCMD Write did not complete\n");
+		netdev_dbg(hw_netdev(hw), "I2CCMD Write did not complete\n");
 		return -E1000_ERR_PHY;
 	}
 	if (i2ccmd & E1000_I2CCMD_ERROR) {
-		hw_dbg("I2CCMD Error bit set\n");
+		netdev_dbg(hw_netdev(hw), "I2CCMD Error bit set\n");
 		return -E1000_ERR_PHY;
 	}
 
@@ -441,7 +442,7 @@ s32 igb_copper_link_setup_82580(struct e1000_hw *hw)
 	if (phy->type == e1000_phy_82580) {
 		ret_val = hw->phy.ops.reset(hw);
 		if (ret_val) {
-			hw_dbg("Error resetting the PHY.\n");
+			netdev_dbg(hw_netdev(hw), "Error resetting the PHY\n");
 			goto out;
 		}
 	}
@@ -561,7 +562,7 @@ s32 igb_copper_link_setup_m88(struct e1000_hw *hw)
 	/* Commit the changes. */
 	ret_val = igb_phy_sw_reset(hw);
 	if (ret_val) {
-		hw_dbg("Error committing the PHY changes\n");
+		netdev_dbg(hw_netdev(hw), "Error committing the PHY changes\n");
 		goto out;
 	}
 
@@ -589,7 +590,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 
 	ret_val = phy->ops.reset(hw);
 	if (ret_val) {
-		hw_dbg("Error resetting the PHY.\n");
+		netdev_dbg(hw_netdev(hw), "Error resetting the PHY\n");
 		goto out;
 	}
 
@@ -608,7 +609,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 		if (phy->ops.set_d3_lplu_state)
 			ret_val = phy->ops.set_d3_lplu_state(hw, false);
 		if (ret_val) {
-			hw_dbg("Error Disabling LPLU D3\n");
+			netdev_dbg(hw_netdev(hw), "Error Disabling LPLU D3\n");
 			goto out;
 		}
 	}
@@ -616,7 +617,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 	/* disable lplu d0 during driver init */
 	ret_val = phy->ops.set_d0_lplu_state(hw, false);
 	if (ret_val) {
-		hw_dbg("Error Disabling LPLU D0\n");
+		netdev_dbg(hw_netdev(hw), "Error Disabling LPLU D0\n");
 		goto out;
 	}
 	/* Configure mdi-mdix settings */
@@ -736,13 +737,13 @@ static s32 igb_copper_link_autoneg(struct e1000_hw *hw)
 	if (phy->autoneg_advertised == 0)
 		phy->autoneg_advertised = phy->autoneg_mask;
 
-	hw_dbg("Reconfiguring auto-neg advertisement params\n");
+	netdev_dbg(hw_netdev(hw), "Reconfiguring auto-neg advertisement params\n");
 	ret_val = igb_phy_setup_autoneg(hw);
 	if (ret_val) {
-		hw_dbg("Error Setting up Auto-Negotiation\n");
+		netdev_dbg(hw_netdev(hw), "Error Setting up Auto-Negotiation\n");
 		goto out;
 	}
-	hw_dbg("Restarting Auto-Neg\n");
+	netdev_dbg(hw_netdev(hw), "Restarting Auto-Neg\n");
 
 	/*
 	 * Restart auto-negotiation by setting the Auto Neg Enable bit and
@@ -764,8 +765,7 @@ static s32 igb_copper_link_autoneg(struct e1000_hw *hw)
 	if (phy->autoneg_wait_to_complete) {
 		ret_val = igb_wait_autoneg(hw);
 		if (ret_val) {
-			hw_dbg("Error while waiting for "
-			       "autoneg to complete\n");
+			netdev_dbg(hw_netdev(hw), "Error while waiting for autoneg to complete\n");
 			goto out;
 		}
 	}
@@ -826,39 +826,40 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 				 NWAY_AR_10T_HD_CAPS);
 	mii_1000t_ctrl_reg &= ~(CR_1000T_HD_CAPS | CR_1000T_FD_CAPS);
 
-	hw_dbg("autoneg_advertised %x\n", phy->autoneg_advertised);
+	netdev_dbg(hw_netdev(hw), "autoneg_advertised %x\n",
+		   phy->autoneg_advertised);
 
 	/* Do we want to advertise 10 Mb Half Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_10_HALF) {
-		hw_dbg("Advertise 10mb Half duplex\n");
+		netdev_dbg(hw_netdev(hw), "Advertise 10mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_HD_CAPS;
 	}
 
 	/* Do we want to advertise 10 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_10_FULL) {
-		hw_dbg("Advertise 10mb Full duplex\n");
+		netdev_dbg(hw_netdev(hw), "Advertise 10mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_FD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Half Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_100_HALF) {
-		hw_dbg("Advertise 100mb Half duplex\n");
+		netdev_dbg(hw_netdev(hw), "Advertise 100mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_HD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_100_FULL) {
-		hw_dbg("Advertise 100mb Full duplex\n");
+		netdev_dbg(hw_netdev(hw), "Advertise 100mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_FD_CAPS;
 	}
 
 	/* We do not allow the Phy to advertise 1000 Mb Half Duplex */
 	if (phy->autoneg_advertised & ADVERTISE_1000_HALF)
-		hw_dbg("Advertise 1000mb Half duplex request denied!\n");
+		netdev_dbg(hw_netdev(hw), "Advertise 1000mb Half duplex request denied!\n");
 
 	/* Do we want to advertise 1000 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_1000_FULL) {
-		hw_dbg("Advertise 1000mb Full duplex\n");
+		netdev_dbg(hw_netdev(hw), "Advertise 1000mb Full duplex\n");
 		mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
 	}
 
@@ -917,7 +918,7 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
 		break;
 	default:
-		hw_dbg("Flow control param set incorrectly\n");
+		netdev_dbg(hw_netdev(hw), "Flow control param set incorrectly\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -926,7 +927,8 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
+	netdev_dbg(hw_netdev(hw), "Auto-Neg Advertising %x\n",
+		   mii_autoneg_adv_reg);
 
 	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
 		ret_val = phy->ops.write_reg(hw,
@@ -968,10 +970,10 @@ s32 igb_setup_copper_link(struct e1000_hw *hw)
 		 * PHY will be set to 10H, 10F, 100H or 100F
 		 * depending on user settings.
 		 */
-		hw_dbg("Forcing Speed and Duplex\n");
+		netdev_dbg(hw_netdev(hw), "Forcing Speed and Duplex\n");
 		ret_val = hw->phy.ops.force_speed_duplex(hw);
 		if (ret_val) {
-			hw_dbg("Error Forcing Speed and Duplex\n");
+			netdev_dbg(hw_netdev(hw), "Error Forcing Speed and Duplex\n");
 			goto out;
 		}
 	}
@@ -988,11 +990,11 @@ s32 igb_setup_copper_link(struct e1000_hw *hw)
 		goto out;
 
 	if (link) {
-		hw_dbg("Valid link established!!!\n");
+		netdev_dbg(hw_netdev(hw), "Valid link established!!!\n");
 		igb_config_collision_dist(hw);
 		ret_val = igb_config_fc_after_link_up(hw);
 	} else {
-		hw_dbg("Unable to establish link!!!\n");
+		netdev_dbg(hw_netdev(hw), "Unable to establish link!!!\n");
 	}
 
 out:
@@ -1039,12 +1041,12 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg("IGP PSCR: %X\n", phy_data);
+	netdev_dbg(hw_netdev(hw), "IGP PSCR: %X\n", phy_data);
 
 	udelay(1);
 
 	if (phy->autoneg_wait_to_complete) {
-		hw_dbg("Waiting for forced speed/duplex link on IGP phy.\n");
+		netdev_dbg(hw_netdev(hw), "Waiting for forced speed/duplex link on IGP phy\n");
 
 		ret_val = igb_phy_has_link(hw,
 						     PHY_FORCE_LIMIT,
@@ -1054,7 +1056,7 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 			goto out;
 
 		if (!link)
-			hw_dbg("Link taking longer than expected.\n");
+			netdev_dbg(hw_netdev(hw), "Link taking longer than expected\n");
 
 		/* Try once more */
 		ret_val = igb_phy_has_link(hw,
@@ -1099,7 +1101,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg("M88E1000 PSCR: %X\n", phy_data);
+	netdev_dbg(hw_netdev(hw), "M88E1000 PSCR: %X\n", phy_data);
 
 	ret_val = phy->ops.read_reg(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
@@ -1117,7 +1119,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 		goto out;
 
 	if (phy->autoneg_wait_to_complete) {
-		hw_dbg("Waiting for forced speed/duplex link on M88 phy.\n");
+		netdev_dbg(hw_netdev(hw), "Waiting for forced speed/duplex link on M88 phy\n");
 
 		ret_val = igb_phy_has_link(hw, PHY_FORCE_LIMIT, 100000, &link);
 		if (ret_val)
@@ -1210,11 +1212,11 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 	if (mac->forced_speed_duplex & E1000_ALL_HALF_DUPLEX) {
 		ctrl &= ~E1000_CTRL_FD;
 		*phy_ctrl &= ~MII_CR_FULL_DUPLEX;
-		hw_dbg("Half Duplex\n");
+		netdev_dbg(hw_netdev(hw), "Half Duplex\n");
 	} else {
 		ctrl |= E1000_CTRL_FD;
 		*phy_ctrl |= MII_CR_FULL_DUPLEX;
-		hw_dbg("Full Duplex\n");
+		netdev_dbg(hw_netdev(hw), "Full Duplex\n");
 	}
 
 	/* Forcing 10mb or 100mb? */
@@ -1222,12 +1224,12 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 		ctrl |= E1000_CTRL_SPD_100;
 		*phy_ctrl |= MII_CR_SPEED_100;
 		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_10);
-		hw_dbg("Forcing 100mb\n");
+		netdev_dbg(hw_netdev(hw), "Forcing 100mb\n");
 	} else {
 		ctrl &= ~(E1000_CTRL_SPD_1000 | E1000_CTRL_SPD_100);
 		*phy_ctrl |= MII_CR_SPEED_10;
 		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_100);
-		hw_dbg("Forcing 10mb\n");
+		netdev_dbg(hw_netdev(hw), "Forcing 10mb\n");
 	}
 
 	igb_config_collision_dist(hw);
@@ -1647,7 +1649,7 @@ s32 igb_get_phy_info_m88(struct e1000_hw *hw)
 	bool link;
 
 	if (phy->media_type != e1000_media_type_copper) {
-		hw_dbg("Phy info is only valid for copper media\n");
+		netdev_dbg(hw_netdev(hw), "Phy info is only valid for copper media\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -1657,7 +1659,7 @@ s32 igb_get_phy_info_m88(struct e1000_hw *hw)
 		goto out;
 
 	if (!link) {
-		hw_dbg("Phy info is only valid if link is up\n");
+		netdev_dbg(hw_netdev(hw), "Phy info is only valid if link is up\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -1727,7 +1729,7 @@ s32 igb_get_phy_info_igp(struct e1000_hw *hw)
 		goto out;
 
 	if (!link) {
-		hw_dbg("Phy info is only valid if link is up\n");
+		netdev_dbg(hw_netdev(hw), "Phy info is only valid if link is up\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -1853,7 +1855,7 @@ out:
  **/
 s32 igb_phy_init_script_igp3(struct e1000_hw *hw)
 {
-	hw_dbg("Running IGP 3 PHY init script\n");
+	netdev_dbg(hw_netdev(hw), "Running IGP 3 PHY init script\n");
 
 	/* PHY init IGP 3 */
 	/* Enable rise/fall, 10-mode work in class-A */
@@ -2031,12 +2033,12 @@ s32 igb_phy_force_speed_duplex_82580(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg("I82580_PHY_CTRL_2: %X\n", phy_data);
+	netdev_dbg(hw_netdev(hw), "I82580_PHY_CTRL_2: %X\n", phy_data);
 
 	udelay(1);
 
 	if (phy->autoneg_wait_to_complete) {
-		hw_dbg("Waiting for forced speed/duplex link on 82580 phy\n");
+		netdev_dbg(hw_netdev(hw), "Waiting for forced speed/duplex link on 82580 phy\n");
 
 		ret_val = igb_phy_has_link(hw,
 		                           PHY_FORCE_LIMIT,
@@ -2046,7 +2048,7 @@ s32 igb_phy_force_speed_duplex_82580(struct e1000_hw *hw)
 			goto out;
 
 		if (!link)
-			hw_dbg("Link taking longer than expected.\n");
+			netdev_dbg(hw_netdev(hw), "Link taking longer than expected\n");
 
 		/* Try once more */
 		ret_val = igb_phy_has_link(hw,
@@ -2083,7 +2085,7 @@ s32 igb_get_phy_info_82580(struct e1000_hw *hw)
 		goto out;
 
 	if (!link) {
-		hw_dbg("Phy info is only valid if link is up\n");
+		netdev_dbg(hw_netdev(hw), "Phy info is only valid if link is up\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index a177570..191a794 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -337,7 +337,6 @@ enum igb_boards {
 extern char igb_driver_name[];
 extern char igb_driver_version[];
 
-extern char *igb_get_hw_dev_name(struct e1000_hw *hw);
 extern int igb_up(struct igb_adapter *);
 extern void igb_down(struct igb_adapter *);
 extern void igb_reinit_locked(struct igb_adapter *);
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index a4cead1..20a4ce8 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -200,8 +200,7 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	/* When SoL/IDER sessions are active, autoneg/speed/duplex
 	 * cannot be changed */
 	if (igb_check_reset_block(hw)) {
-		dev_err(&adapter->pdev->dev, "Cannot change link "
-			"characteristics when SoL/IDER is active.\n");
+		dev_err(&adapter->pdev->dev, "Cannot change link characteristics when SoL/IDER is active\n");
 		return -EINVAL;
 	}
 
@@ -1656,8 +1655,7 @@ static int igb_loopback_test(struct igb_adapter *adapter, u64 *data)
 	 * sessions are active */
 	if (igb_check_reset_block(&adapter->hw)) {
 		dev_err(&adapter->pdev->dev,
-			"Cannot do PHY loopback test "
-			"when SoL/IDER is active.\n");
+			"Cannot do PHY loopback test when SoL/IDER is active\n");
 		*data = 0;
 		goto out;
 	}
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f588e49..e1a7e9e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -25,6 +25,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
@@ -223,16 +225,6 @@ static cycle_t igb_read_clock(const struct cyclecounter *tc)
 
 #ifdef DEBUG
 /**
- * igb_get_hw_dev_name - return device name string
- * used by hardware layer to print debugging information
- **/
-char *igb_get_hw_dev_name(struct e1000_hw *hw)
-{
-	struct igb_adapter *adapter = hw->back;
-	return adapter->netdev->name;
-}
-
-/**
  * igb_get_time_str - format current NIC and system time as string
  */
 static char *igb_get_time_str(struct igb_adapter *adapter,
@@ -266,10 +258,8 @@ static char *igb_get_time_str(struct igb_adapter *adapter,
 static int __init igb_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "%s - version %s\n",
-	       igb_driver_string, igb_driver_version);
-
-	printk(KERN_INFO "%s\n", igb_copyright);
+	pr_info("version %s\n", igb_driver_version);
+	pr_info("%s\n", igb_copyright);
 
 #ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
@@ -1513,7 +1503,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	if (igb_check_reset_block(hw))
 		dev_info(&pdev->dev,
-			"PHY reset is blocked due to SOL/IDER session.\n");
+			"PHY reset is blocked due to SOL/IDER session\n");
 
 	netdev->features = NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
@@ -3106,8 +3096,8 @@ static void igb_watchdog_task(struct work_struct *work)
 				 "Full Duplex" : "Half Duplex",
 			       ((ctrl & E1000_CTRL_TFCE) &&
 			        (ctrl & E1000_CTRL_RFCE)) ? "RX/TX" :
-			       ((ctrl & E1000_CTRL_RFCE) ?  "RX" :
-			       ((ctrl & E1000_CTRL_TFCE) ?  "TX" : "None")));
+			       (ctrl & E1000_CTRL_RFCE) ?  "RX" :
+			       (ctrl & E1000_CTRL_TFCE) ?  "TX" : "None");
 
 			/* tweak tx_queue_len according to speed/duplex and
 			 * adjust the timeout factor */
@@ -3913,7 +3903,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 	}
 
 	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
-		dev_err(&pdev->dev, "MTU > 9216 not supported.\n");
+		dev_err(&pdev->dev, "MTU > 9216 not supported\n");
 		return -EINVAL;
 	}
 
@@ -4561,11 +4551,9 @@ static int igb_ndo_set_vf_vlan(struct net_device *netdev,
 			 "Setting VLAN %d, QOS 0x%x on VF %d\n", vlan, qos, vf);
 		if (test_bit(__IGB_DOWN, &adapter->state)) {
 			dev_warn(&adapter->pdev->dev,
-				 "The VF VLAN has been set,"
-				 " but the PF device is not up.\n");
+				 "The VF VLAN has been set, but the PF device is not up\n");
 			dev_warn(&adapter->pdev->dev,
-				 "Bring the PF device up before"
-				 " attempting to use the VF device.\n");
+				 "Bring the PF device up before attempting to use the VF device\n");
 		}
 	} else {
 		igb_vlvf_set(adapter, adapter->vf_data[vf].pf_vlan,
@@ -6004,7 +5992,7 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
 
 	if (pci_enable_device_mem(pdev)) {
 		dev_err(&pdev->dev,
-			"Cannot re-enable PCI device after reset.\n");
+			"Cannot re-enable PCI device after reset\n");
 		result = PCI_ERS_RESULT_DISCONNECT;
 	} else {
 		pci_set_master(pdev);
@@ -6105,13 +6093,10 @@ static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 		return -EINVAL;
 	adapter->vf_data[vf].flags |= IGB_VF_FLAG_PF_SET_MAC;
 	dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac, vf);
-	dev_info(&adapter->pdev->dev, "Reload the VF driver to make this"
-				      " change effective.");
+	dev_info(&adapter->pdev->dev, "Reload the VF driver to make this change effective.\n");
 	if (test_bit(__IGB_DOWN, &adapter->state)) {
-		dev_warn(&adapter->pdev->dev, "The VF MAC address has been set,"
-			 " but the PF device is not up.\n");
-		dev_warn(&adapter->pdev->dev, "Bring the PF device up before"
-			 " attempting to use the VF device.\n");
+		dev_warn(&adapter->pdev->dev, "The VF MAC address has been set, but the PF device is not up.\n");
+		dev_warn(&adapter->pdev->dev, "Bring the PF device up before attempting to use the VF device.\n");
 	}
 	return igb_set_vf_mac(adapter, vf, mac);
 }
-- 
1.7.0.14.g7e948


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
