From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 4/7] e1000e: cleanup: fix long lines
Date: Thu,  9 Dec 2010 02:40:54 +0000
Message-ID: <1291862457-16671-5-git-send-email-asbjorn@asbjorn.biz>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch breaks long lines, so they do not exceed 80 characters.

Fixes 2 errors and 26 warnings reported by checkpatch.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 drivers/net/e1000e/defines.h |   15 ++++++++++-----
 drivers/net/e1000e/e1000.h   |   27 ++++++++++++++++++---------
 drivers/net/e1000e/es2lan.c  |    3 ++-
 drivers/net/e1000e/ethtool.c |    3 ++-
 drivers/net/e1000e/lib.c     |   12 ++++++++----
 drivers/net/e1000e/netdev.c  |   18 +++++++++++-------
 drivers/net/e1000e/param.c   |    6 ++++--
 7 files changed, 55 insertions(+), 29 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 10760be..f1260fc 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -83,8 +83,10 @@
 #define E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES  0x00C00000
 #define E1000_CTRL_EXT_EIAME          0x01000000
 #define E1000_CTRL_EXT_DRV_LOAD       0x10000000 /* Driver loaded bit for FW */
-#define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowledge Auto-mask */
-#define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt timers after IMS clear */
+#define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowledge
+						  * Auto-mask */
+#define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt timers
+						  * after IMS clear */
 #define E1000_CTRL_EXT_PBA_CLR        0x80000000 /* PBA Clear */
 #define E1000_CTRL_EXT_PHYPDEN        0x00100000
 
@@ -247,7 +249,8 @@
 #define E1000_STATUS_SPEED_1000 0x00000080      /* Speed 1000Mb/s */
 #define E1000_STATUS_LAN_INIT_DONE 0x00000200   /* Lan Init Completion by NVM */
 #define E1000_STATUS_PHYRA      0x00000400      /* PHY Reset Asserted */
-#define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000 /* Status of Master requests. */
+#define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000 /* Status of Master
+						   * requests. */
 
 /* Constants used to interpret the masked PCI-X bus speed. */
 
@@ -394,7 +397,8 @@
 #define E1000_ICR_RXSEQ         0x00000008 /* Rx sequence error */
 #define E1000_ICR_RXDMT0        0x00000010 /* Rx desc min. threshold (0) */
 #define E1000_ICR_RXT0          0x00000080 /* Rx timer intr (ring 0) */
-#define E1000_ICR_INT_ASSERTED  0x80000000 /* If this bit asserted, the driver should claim the interrupt */
+#define E1000_ICR_INT_ASSERTED  0x80000000 /* If this bit asserted, the driver
+					    * should claim the interrupt */
 #define E1000_ICR_RXQ0          0x00100000 /* Rx Queue 0 Interrupt */
 #define E1000_ICR_RXQ1          0x00200000 /* Rx Queue 1 Interrupt */
 #define E1000_ICR_TXQ0          0x00400000 /* Tx Queue 0 Interrupt */
@@ -612,7 +616,8 @@
 #define E1000_EECD_SEC1VAL   0x00400000 /* Sector One Valid */
 #define E1000_EECD_SEC1VAL_VALID_MASK (E1000_EECD_AUTO_RD | E1000_EECD_PRES)
 
-#define E1000_NVM_RW_REG_DATA   16   /* Offset to data in NVM read/write registers */
+#define E1000_NVM_RW_REG_DATA   16   /* Offset to data in NVM
+				      * read/write registers */
 #define E1000_NVM_RW_REG_DONE   2    /* Offset to READ/WRITE done bit */
 #define E1000_NVM_RW_REG_START  1    /* Start operation */
 #define E1000_NVM_RW_ADDR_SHIFT 2    /* Shift to the address bits */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 47eb0ba..97fa58a 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -542,8 +542,10 @@ extern s32 e1000e_led_off_generic(struct e1000_hw *hw);
 extern s32 e1000e_get_bus_info_pcie(struct e1000_hw *hw);
 extern void e1000_set_lan_id_multi_port_pcie(struct e1000_hw *hw);
 extern void e1000_set_lan_id_single_port(struct e1000_hw *hw);
-extern s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *duplex);
-extern s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16 *duplex);
+extern s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw,
+					      u16 *speed, u16 *duplex);
+extern s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw,
+						    u16 *speed, u16 *duplex);
 extern s32 e1000e_disable_pcie_master(struct e1000_hw *hw);
 extern s32 e1000e_get_auto_rd_done(struct e1000_hw *hw);
 extern s32 e1000e_id_led_init(struct e1000_hw *hw);
@@ -566,7 +568,8 @@ extern void e1000e_config_collision_dist(struct e1000_hw *hw);
 extern s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw);
 extern s32 e1000e_force_mac_fc(struct e1000_hw *hw);
 extern s32 e1000e_blink_led(struct e1000_hw *hw);
-extern void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset, u32 value);
+extern void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset,
+				     u32 value);
 extern s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw);
 extern void e1000e_reset_adaptive(struct e1000_hw *hw);
 extern void e1000e_update_adaptive(struct e1000_hw *hw);
@@ -600,7 +603,8 @@ extern s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_read_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data);
-extern void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl);
+extern void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw,
+						u16 *phy_ctrl);
 extern s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_write_kmrn_reg_locked(struct e1000_hw *hw, u32 offset,
 					u16 data);
@@ -661,10 +665,12 @@ static inline s32 e1000_get_cable_length(struct e1000_hw *hw)
 }
 
 extern s32 e1000e_acquire_nvm(struct e1000_hw *hw);
-extern s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+extern s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words,
+				u16 *data);
 extern s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw);
 extern s32 e1000e_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg);
-extern s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+extern s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words,
+				u16 *data);
 extern s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw);
 extern void e1000e_release_nvm(struct e1000_hw *hw);
 extern void e1000e_reload_nvm(struct e1000_hw *hw);
@@ -688,12 +694,14 @@ static inline s32 e1000e_update_nvm_checksum(struct e1000_hw *hw)
 	return hw->nvm.ops.update(hw);
 }
 
-static inline s32 e1000_read_nvm(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+static inline s32 e1000_read_nvm(struct e1000_hw *hw, u16 offset, u16 words,
+				 u16 *data)
 {
 	return hw->nvm.ops.read(hw, offset, words, data);
 }
 
-static inline s32 e1000_write_nvm(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+static inline s32 e1000_write_nvm(struct e1000_hw *hw, u16 offset, u16 words,
+				  u16 *data)
 {
 	return hw->nvm.ops.write(hw, offset, words, data);
 }
@@ -710,7 +718,8 @@ static inline s32 e1000e_check_mng_mode(struct e1000_hw *hw)
 
 extern bool e1000e_check_mng_mode_generic(struct e1000_hw *hw);
 extern bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw);
-extern s32 e1000e_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length);
+extern s32 e1000e_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer,
+				      u16 length);
 
 static inline u32 __er32(struct e1000_hw *hw, unsigned long reg)
 {
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 6069e9f..56a1321 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -233,7 +233,8 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	/* check for link */
 	switch (hw->phy.media_type) {
 	case e1000_media_type_copper:
-		func->setup_physical_interface = e1000_setup_copper_link_80003es2lan;
+		func->setup_physical_interface =
+					e1000_setup_copper_link_80003es2lan;
 		func->check_for_link = e1000e_check_for_copper_link;
 		break;
 	case e1000_media_type_fiber:
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8ff3a8a..4fee336 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -567,7 +567,8 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	if (eeprom->len == 0)
 		return -EOPNOTSUPP;
 
-	if (eeprom->magic != (adapter->pdev->vendor | (adapter->pdev->device << 16)))
+	if (eeprom->magic != (adapter->pdev->vendor |
+			      (adapter->pdev->device << 16)))
 		return -EFAULT;
 
 	if (adapter->flags & FLAG_READ_ONLY_NVM)
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 513b4d1..b950db3 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1135,7 +1135,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		ret_val = e1e_rphy(hw, PHY_AUTONEG_ADV, &mii_nway_adv_reg);
 		if (ret_val)
 			return ret_val;
-		ret_val = e1e_rphy(hw, PHY_LP_ABILITY, &mii_nway_lp_ability_reg);
+		ret_val = e1e_rphy(hw, PHY_LP_ABILITY,
+				   &mii_nway_lp_ability_reg);
 		if (ret_val)
 			return ret_val;
 
@@ -1266,7 +1267,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
  *  Read the status register for the current speed/duplex and store the current
  *  speed and duplex for copper connections.
  **/
-s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *duplex)
+s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
+				       u16 *duplex)
 {
 	u32 status;
 
@@ -1299,7 +1301,8 @@ s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *dup
  *  Sets the speed and duplex to gigabit full duplex (the only possible option)
  *  for fiber/serdes links.
  **/
-s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16 *duplex)
+s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed,
+					     u16 *duplex)
 {
 	*speed = SPEED_1000;
 	*duplex = FULL_DUPLEX;
@@ -2359,7 +2362,8 @@ bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
 	len    = E1000_MNG_DHCP_COOKIE_LENGTH >> 2;
 	offset = E1000_MNG_DHCP_COOKIE_OFFSET >> 2;
 	for (i = 0; i < len; i++)
-		*(buffer + i) = E1000_READ_REG_ARRAY(hw, E1000_HOST_IF, offset + i);
+		*(buffer + i) = E1000_READ_REG_ARRAY(hw, E1000_HOST_IF,
+						     offset + i);
 	hdr_csum = hdr->checksum;
 	hdr->checksum = 0;
 	csum = e1000_calculate_checksum((u8 *)hdr,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d71854f..bb6a1f5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -601,7 +601,8 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 			ps_page = &buffer_info->ps_pages[j];
 			if (j >= adapter->rx_ps_pages) {
 				/* all unused desc entries get hw null ptr */
-				rx_desc->read.buffer_addr[j+1] = ~cpu_to_le64(0);
+				rx_desc->read.buffer_addr[j+1] =
+								~cpu_to_le64(0);
 				continue;
 			}
 			if (!ps_page->page) {
@@ -871,7 +872,8 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 				  ((u32)(rx_desc->errors) << 24),
 				  le16_to_cpu(rx_desc->csum), skb);
 
-		e1000_receive_skb(adapter, netdev, skb,status,rx_desc->special);
+		e1000_receive_skb(adapter, netdev, skb, status,
+				  rx_desc->special);
 
 next_desc:
 		rx_desc->status = 0;
@@ -2372,7 +2374,8 @@ err:
  **/
 static int e1000_clean(struct napi_struct *napi, int budget)
 {
-	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
+	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter,
+						     napi);
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *poll_dev = adapter->netdev;
 	int tx_cleaned = 1, work_done = 0;
@@ -4664,9 +4667,9 @@ static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
 	u16 length, offset;
 
 	if (vlan_tx_tag_present(skb)) {
-		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
-		    (adapter->hw.mng_cookie.status &
-			E1000_MNG_DHCP_COOKIE_STATUS_VLAN)))
+		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id)
+			&& (adapter->hw.mng_cookie.status &
+			    E1000_MNG_DHCP_COOKIE_STATUS_VLAN)))
 			return 0;
 	}
 
@@ -6079,7 +6082,8 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_COPPER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER), board_82571 },
-	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER_LP), board_82571 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER_LP),
+	  board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_SERDES_DUAL), board_82571 },
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 2687295..992be2b 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -147,7 +147,8 @@ E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
  *
  * Default Value: 1 (enabled)
  */
-E1000_PARAM(WriteProtectNVM, "Write-protect NVM [WARNING: disabling this can lead to corrupted NVM]");
+E1000_PARAM(WriteProtectNVM, "Write-protect NVM [WARNING: disabling "
+			     "this can lead to corrupted NVM]");
 
 /*
  * Enable CRC Stripping
@@ -464,7 +465,8 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 
 		if (adapter->flags & FLAG_IS_ICH) {
 			if (num_WriteProtectNVM > bd) {
-				unsigned int write_protect_nvm = WriteProtectNVM[bd];
+				unsigned int write_protect_nvm =
+							WriteProtectNVM[bd];
 				e1000_validate_option(&write_protect_nvm, &opt,
 						      adapter);
 				if (write_protect_nvm)
-- 
1.7.2.3
