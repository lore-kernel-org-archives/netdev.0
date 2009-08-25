From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] ixgbe: cleanup functions that should have been
	defined static
Date: Tue, 25 Aug 2009 07:47:32 -0700
Message-ID: <20090825144731.15560.73592.stgit@localhost.localdomain>
References: <20090825144709.15560.28811.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:37638 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755145AbZHYOrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 10:47:47 -0400
In-Reply-To: <20090825144709.15560.28811.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We have some ~40 functions that were being called out with 'make
namespacecheck'.  This patch changes these functions to be static.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h        |   35 ---------
 drivers/net/ixgbe/ixgbe_82598.c  |    6 +
 drivers/net/ixgbe/ixgbe_82599.c  |  156 ++++++++++++++++++--------------------
 drivers/net/ixgbe/ixgbe_common.c |    3 -
 drivers/net/ixgbe/ixgbe_common.h |    1 
 drivers/net/ixgbe/ixgbe_main.c   |    2 
 6 files changed, 81 insertions(+), 122 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 8f1f8ba..c983c89 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -424,55 +424,20 @@ extern s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc);
 extern s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
                                                  struct ixgbe_atr_input *input,
                                                  u8 queue);
-extern s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
-                                               struct ixgbe_atr_input *input,
-                                               u16 soft_id,
-                                               u8 queue);
-extern u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *input, u32 key);
 extern s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input,
                                        u16 vlan_id);
 extern s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input,
                                         u32 src_addr);
 extern s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input,
                                         u32 dst_addr);
-extern s32 ixgbe_atr_set_src_ipv6_82599(struct ixgbe_atr_input *input,
-                                        u32 src_addr_1, u32 src_addr_2,
-                                        u32 src_addr_3, u32 src_addr_4);
-extern s32 ixgbe_atr_set_dst_ipv6_82599(struct ixgbe_atr_input *input,
-                                        u32 dst_addr_1, u32 dst_addr_2,
-                                        u32 dst_addr_3, u32 dst_addr_4);
 extern s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input,
                                         u16 src_port);
 extern s32 ixgbe_atr_set_dst_port_82599(struct ixgbe_atr_input *input,
                                         u16 dst_port);
 extern s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input,
                                          u16 flex_byte);
-extern s32 ixgbe_atr_set_vm_pool_82599(struct ixgbe_atr_input *input,
-                                       u8 vm_pool);
 extern s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input,
                                       u8 l4type);
-extern s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input,
-                                       u16 *vlan_id);
-extern s32 ixgbe_atr_get_src_ipv4_82599(struct ixgbe_atr_input *input,
-                                        u32 *src_addr);
-extern s32 ixgbe_atr_get_dst_ipv4_82599(struct ixgbe_atr_input *input,
-                                        u32 *dst_addr);
-extern s32 ixgbe_atr_get_src_ipv6_82599(struct ixgbe_atr_input *input,
-                                        u32 *src_addr_1, u32 *src_addr_2,
-                                        u32 *src_addr_3, u32 *src_addr_4);
-extern s32 ixgbe_atr_get_dst_ipv6_82599(struct ixgbe_atr_input *input,
-                                        u32 *dst_addr_1, u32 *dst_addr_2,
-                                        u32 *dst_addr_3, u32 *dst_addr_4);
-extern s32 ixgbe_atr_get_src_port_82599(struct ixgbe_atr_input *input,
-                                        u16 *src_port);
-extern s32 ixgbe_atr_get_dst_port_82599(struct ixgbe_atr_input *input,
-                                        u16 *dst_port);
-extern s32 ixgbe_atr_get_flex_byte_82599(struct ixgbe_atr_input *input,
-                                         u16 *flex_byte);
-extern s32 ixgbe_atr_get_vm_pool_82599(struct ixgbe_atr_input *input,
-                                       u8 *vm_pool);
-extern s32 ixgbe_atr_get_l4type_82599(struct ixgbe_atr_input *input,
-                                      u8 *l4type);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_adapter *adapter,
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 1c227b0..916430f 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -59,7 +59,7 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
  *  increase the value to either 10ms to 250ms for capability version 1 config,
  *  or 16ms to 55ms for version 2.
  **/
-void ixgbe_set_pcie_completion_timeout(struct ixgbe_hw *hw)
+static void ixgbe_set_pcie_completion_timeout(struct ixgbe_hw *hw)
 {
 	struct ixgbe_adapter *adapter = hw->back;
 	u32 gcr = IXGBE_READ_REG(hw, IXGBE_GCR);
@@ -143,7 +143,7 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
  *  not known.  Perform the SFP init if necessary.
  *
  **/
-s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
+static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
 	struct ixgbe_phy_info *phy = &hw->phy;
@@ -204,7 +204,7 @@ out:
  *  Starts the hardware using the generic start_hw function.
  *  Then set pcie completion timeout
  **/
-s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
+static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 {
 	s32 ret_val = 0;
 
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 1984cab..364b6d2 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -38,22 +38,15 @@
 #define IXGBE_82599_MC_TBL_SIZE   128
 #define IXGBE_82599_VFT_TBL_SIZE  128
 
-s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
-                                      ixgbe_link_speed *speed,
-                                      bool *autoneg);
-enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw);
-s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw);
-s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
+static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw);
+static s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
                                      ixgbe_link_speed speed, bool autoneg,
                                      bool autoneg_wait_to_complete);
-s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw);
-s32 ixgbe_check_mac_link_82599(struct ixgbe_hw *hw,
-                               ixgbe_link_speed *speed,
-                               bool *link_up, bool link_up_wait_to_complete);
-s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
-                                     ixgbe_link_speed speed,
-                                     bool autoneg,
-                                     bool autoneg_wait_to_complete);
+static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw);
+static s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
+                                            ixgbe_link_speed speed,
+                                            bool autoneg,
+                                            bool autoneg_wait_to_complete);
 static s32 ixgbe_get_copper_link_capabilities_82599(struct ixgbe_hw *hw,
                                              ixgbe_link_speed *speed,
                                              bool *autoneg);
@@ -62,21 +55,9 @@ static s32 ixgbe_setup_copper_link_speed_82599(struct ixgbe_hw *hw,
                                                ixgbe_link_speed speed,
                                                bool autoneg,
                                                bool autoneg_wait_to_complete);
-s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw);
-s32 ixgbe_set_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
-s32 ixgbe_clear_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
-s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan,
-                         u32 vind, bool vlan_on);
-s32 ixgbe_clear_vfta_82599(struct ixgbe_hw *hw);
-s32 ixgbe_init_uta_tables_82599(struct ixgbe_hw *hw);
-s32 ixgbe_read_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 *val);
-s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val);
-s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw);
-s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw);
-u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw);
 static s32 ixgbe_verify_fw_version_82599(struct ixgbe_hw *hw);
 
-void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
+static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
 	if (hw->phy.multispeed_fiber) {
@@ -93,7 +74,7 @@ void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 	}
 }
 
-s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 {
 	s32 ret_val = 0;
 	u16 list_offset, data_offset, data_value;
@@ -143,7 +124,7 @@ setup_sfp_out:
  *  Read PCIe configuration space, and get the MSI-X vector count from
  *  the capabilities table.
  **/
-u32 ixgbe_get_pcie_msix_count_82599(struct ixgbe_hw *hw)
+static u32 ixgbe_get_pcie_msix_count_82599(struct ixgbe_hw *hw)
 {
 	struct ixgbe_adapter *adapter = hw->back;
 	u16 msix_count;
@@ -182,7 +163,7 @@ static s32 ixgbe_get_invariants_82599(struct ixgbe_hw *hw)
  *  not known.  Perform the SFP init if necessary.
  *
  **/
-s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
 	struct ixgbe_phy_info *phy = &hw->phy;
@@ -225,9 +206,9 @@ s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
  *
  *  Determines the link capabilities by reading the AUTOC register.
  **/
-s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
-                                      ixgbe_link_speed *speed,
-                                      bool *negotiation)
+static s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
+                                             ixgbe_link_speed *speed,
+                                             bool *negotiation)
 {
 	s32 status = 0;
 	u32 autoc = 0;
@@ -344,7 +325,7 @@ static s32 ixgbe_get_copper_link_capabilities_82599(struct ixgbe_hw *hw,
  *
  *  Returns the media type (fiber, copper, backplane)
  **/
-enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
+static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 {
 	enum ixgbe_media_type media_type;
 
@@ -379,7 +360,7 @@ out:
  *  Configures link settings based on values in the ixgbe_hw struct.
  *  Restarts the link.  Performs autonegotiation if needed.
  **/
-s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw)
 {
 	u32 autoc_reg;
 	u32 links_reg;
@@ -428,7 +409,7 @@ s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw)
  *  fails at 10G.
  *  Performs autonegotiation if needed.
  **/
-s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw)
+static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw)
 {
 	s32 status = 0;
 	ixgbe_link_speed link_speed = IXGBE_LINK_SPEED_82599_AUTONEG;
@@ -446,7 +427,7 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw)
  *
  *  Set the link speed in the AUTOC register and restarts link.
  **/
-s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
+static s32 ixgbe_setup_mac_link_speed_multispeed_fiber(struct ixgbe_hw *hw,
                                                 ixgbe_link_speed speed,
                                                 bool autoneg,
                                                 bool autoneg_wait_to_complete)
@@ -613,8 +594,10 @@ out:
  *
  *  Reads the links register to determine if link is up and the current speed
  **/
-s32 ixgbe_check_mac_link_82599(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
-                               bool *link_up, bool link_up_wait_to_complete)
+static s32 ixgbe_check_mac_link_82599(struct ixgbe_hw *hw,
+                                      ixgbe_link_speed *speed,
+                                      bool *link_up,
+                                      bool link_up_wait_to_complete)
 {
 	u32 links_reg;
 	u32 i;
@@ -665,9 +648,10 @@ s32 ixgbe_check_mac_link_82599(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
  *
  *  Set the link speed in the AUTOC register and restarts link.
  **/
-s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
-                                     ixgbe_link_speed speed, bool autoneg,
-                                     bool autoneg_wait_to_complete)
+static s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
+                                            ixgbe_link_speed speed,
+                                            bool autoneg,
+                                            bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
 	u32 autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
@@ -818,7 +802,7 @@ static s32 ixgbe_setup_copper_link_speed_82599(struct ixgbe_hw *hw,
  *  and clears all interrupts, perform a PHY reset, and perform a link (MAC)
  *  reset.
  **/
-s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 {
 	s32 status = 0;
 	u32 ctrl, ctrl_ext;
@@ -943,7 +927,7 @@ reset_hw_out:
  *  @rar: receive address register index to disassociate
  *  @vmdq: VMDq pool index to remove from the rar
  **/
-s32 ixgbe_clear_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
+static s32 ixgbe_clear_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 {
 	u32 mpsar_lo, mpsar_hi;
 	u32 rar_entries = hw->mac.num_rar_entries;
@@ -989,7 +973,7 @@ done:
  *  @rar: receive address register index to associate with a VMDq index
  *  @vmdq: VMDq pool index
  **/
-s32 ixgbe_set_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
+static s32 ixgbe_set_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 {
 	u32 mpsar;
 	u32 rar_entries = hw->mac.num_rar_entries;
@@ -1019,8 +1003,8 @@ s32 ixgbe_set_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
  *
  *  Turn on/off specified VLAN in the VLAN filter table.
  **/
-s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan, u32 vind,
-                         bool vlan_on)
+static s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan, u32 vind,
+                                bool vlan_on)
 {
 	u32 regindex;
 	u32 bitindex;
@@ -1133,7 +1117,7 @@ out:
  *
  *  Clears the VLAN filer table, and the VMDq index associated with the filter
  **/
-s32 ixgbe_clear_vfta_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_clear_vfta_82599(struct ixgbe_hw *hw)
 {
 	u32 offset;
 
@@ -1153,7 +1137,7 @@ s32 ixgbe_clear_vfta_82599(struct ixgbe_hw *hw)
  *  ixgbe_init_uta_tables_82599 - Initialize the Unicast Table Array
  *  @hw: pointer to hardware structure
  **/
-s32 ixgbe_init_uta_tables_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_init_uta_tables_82599(struct ixgbe_hw *hw)
 {
 	int i;
 	hw_dbg(hw, " Clearing UTA\n");
@@ -1430,7 +1414,8 @@ s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc)
  *  @stream: input bitstream to compute the hash on
  *  @key: 32-bit hash key
  **/
-u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *atr_input, u32 key)
+static u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *atr_input,
+                                        u32 key)
 {
 	/*
 	 * The algorithm is as follows:
@@ -1602,8 +1587,8 @@ s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
  *  @src_addr_4: the fourth 4 bytes of the IP address to load
  **/
 s32 ixgbe_atr_set_src_ipv6_82599(struct ixgbe_atr_input *input,
-                                 u32 src_addr_1, u32 src_addr_2,
-                                 u32 src_addr_3, u32 src_addr_4)
+                                        u32 src_addr_1, u32 src_addr_2,
+                                        u32 src_addr_3, u32 src_addr_4)
 {
 	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET] = src_addr_4 & 0xff;
 	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 1] =
@@ -1645,8 +1630,8 @@ s32 ixgbe_atr_set_src_ipv6_82599(struct ixgbe_atr_input *input,
  *  @dst_addr_4: the fourth 4 bytes of the IP address to load
  **/
 s32 ixgbe_atr_set_dst_ipv6_82599(struct ixgbe_atr_input *input,
-                                 u32 dst_addr_1, u32 dst_addr_2,
-                                 u32 dst_addr_3, u32 dst_addr_4)
+                                        u32 dst_addr_1, u32 dst_addr_2,
+                                        u32 dst_addr_3, u32 dst_addr_4)
 {
 	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET] = dst_addr_4 & 0xff;
 	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 1] =
@@ -1723,7 +1708,8 @@ s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input, u16 flex_byte)
  *  @input: input stream to modify
  *  @vm_pool: the Virtual Machine pool to load
  **/
-s32 ixgbe_atr_set_vm_pool_82599(struct ixgbe_atr_input *input, u8 vm_pool)
+s32 ixgbe_atr_set_vm_pool_82599(struct ixgbe_atr_input *input,
+                                       u8 vm_pool)
 {
 	input->byte_stream[IXGBE_ATR_VM_POOL_OFFSET] = vm_pool;
 
@@ -1747,7 +1733,8 @@ s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input, u8 l4type)
  *  @input: input stream to search
  *  @vlan: the VLAN id to load
  **/
-s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input, u16 *vlan)
+static s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input,
+                                       u16 *vlan)
 {
 	*vlan = input->byte_stream[IXGBE_ATR_VLAN_OFFSET];
 	*vlan |= input->byte_stream[IXGBE_ATR_VLAN_OFFSET + 1] << 8;
@@ -1760,7 +1747,8 @@ s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input, u16 *vlan)
  *  @input: input stream to search
  *  @src_addr: the IP address to load
  **/
-s32 ixgbe_atr_get_src_ipv4_82599(struct ixgbe_atr_input *input, u32 *src_addr)
+static s32 ixgbe_atr_get_src_ipv4_82599(struct ixgbe_atr_input *input,
+                                        u32 *src_addr)
 {
 	*src_addr = input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET];
 	*src_addr |= input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 1] << 8;
@@ -1775,7 +1763,8 @@ s32 ixgbe_atr_get_src_ipv4_82599(struct ixgbe_atr_input *input, u32 *src_addr)
  *  @input: input stream to search
  *  @dst_addr: the IP address to load
  **/
-s32 ixgbe_atr_get_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 *dst_addr)
+static s32 ixgbe_atr_get_dst_ipv4_82599(struct ixgbe_atr_input *input,
+                                        u32 *dst_addr)
 {
 	*dst_addr = input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET];
 	*dst_addr |= input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 1] << 8;
@@ -1793,9 +1782,9 @@ s32 ixgbe_atr_get_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 *dst_addr)
  *  @src_addr_3: the third 4 bytes of the IP address to load
  *  @src_addr_4: the fourth 4 bytes of the IP address to load
  **/
-s32 ixgbe_atr_get_src_ipv6_82599(struct ixgbe_atr_input *input,
-                                 u32 *src_addr_1, u32 *src_addr_2,
-                                 u32 *src_addr_3, u32 *src_addr_4)
+static s32 ixgbe_atr_get_src_ipv6_82599(struct ixgbe_atr_input *input,
+                                        u32 *src_addr_1, u32 *src_addr_2,
+                                        u32 *src_addr_3, u32 *src_addr_4)
 {
 	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 12];
 	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 13] << 8;
@@ -1829,8 +1818,8 @@ s32 ixgbe_atr_get_src_ipv6_82599(struct ixgbe_atr_input *input,
  *  @dst_addr_4: the fourth 4 bytes of the IP address to load
  **/
 s32 ixgbe_atr_get_dst_ipv6_82599(struct ixgbe_atr_input *input,
-                                 u32 *dst_addr_1, u32 *dst_addr_2,
-                                 u32 *dst_addr_3, u32 *dst_addr_4)
+                                        u32 *dst_addr_1, u32 *dst_addr_2,
+                                        u32 *dst_addr_3, u32 *dst_addr_4)
 {
 	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 12];
 	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 13] << 8;
@@ -1865,7 +1854,8 @@ s32 ixgbe_atr_get_dst_ipv6_82599(struct ixgbe_atr_input *input,
  *  endianness when retrieving the data.  This can be confusing since the
  *  internal hash engine expects it to be big-endian.
  **/
-s32 ixgbe_atr_get_src_port_82599(struct ixgbe_atr_input *input, u16 *src_port)
+static s32 ixgbe_atr_get_src_port_82599(struct ixgbe_atr_input *input,
+                                        u16 *src_port)
 {
 	*src_port = input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET] << 8;
 	*src_port |= input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET + 1];
@@ -1883,7 +1873,8 @@ s32 ixgbe_atr_get_src_port_82599(struct ixgbe_atr_input *input, u16 *src_port)
  *  endianness when retrieving the data.  This can be confusing since the
  *  internal hash engine expects it to be big-endian.
  **/
-s32 ixgbe_atr_get_dst_port_82599(struct ixgbe_atr_input *input, u16 *dst_port)
+static s32 ixgbe_atr_get_dst_port_82599(struct ixgbe_atr_input *input,
+                                        u16 *dst_port)
 {
 	*dst_port = input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET] << 8;
 	*dst_port |= input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET + 1];
@@ -1896,7 +1887,8 @@ s32 ixgbe_atr_get_dst_port_82599(struct ixgbe_atr_input *input, u16 *dst_port)
  *  @input: input stream to modify
  *  @flex_bytes: the flexible bytes to load
  **/
-s32 ixgbe_atr_get_flex_byte_82599(struct ixgbe_atr_input *input, u16 *flex_byte)
+static s32 ixgbe_atr_get_flex_byte_82599(struct ixgbe_atr_input *input,
+                                         u16 *flex_byte)
 {
 	*flex_byte = input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET];
 	*flex_byte |= input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET + 1] << 8;
@@ -1909,7 +1901,8 @@ s32 ixgbe_atr_get_flex_byte_82599(struct ixgbe_atr_input *input, u16 *flex_byte)
  *  @input: input stream to modify
  *  @vm_pool: the Virtual Machine pool to load
  **/
-s32 ixgbe_atr_get_vm_pool_82599(struct ixgbe_atr_input *input, u8 *vm_pool)
+s32 ixgbe_atr_get_vm_pool_82599(struct ixgbe_atr_input *input,
+                                       u8 *vm_pool)
 {
 	*vm_pool = input->byte_stream[IXGBE_ATR_VM_POOL_OFFSET];
 
@@ -1921,7 +1914,8 @@ s32 ixgbe_atr_get_vm_pool_82599(struct ixgbe_atr_input *input, u8 *vm_pool)
  *  @input: input stream to modify
  *  @l4type: the layer 4 type value to load
  **/
-s32 ixgbe_atr_get_l4type_82599(struct ixgbe_atr_input *input, u8 *l4type)
+static s32 ixgbe_atr_get_l4type_82599(struct ixgbe_atr_input *input,
+                                      u8 *l4type)
 {
 	*l4type = input->byte_stream[IXGBE_ATR_L4TYPE_OFFSET];
 
@@ -2002,9 +1996,9 @@ s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
  *  hardware writes must be protected from one another.
  **/
 s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
-                                        struct ixgbe_atr_input *input,
-                                        u16 soft_id,
-                                        u8 queue)
+                                               struct ixgbe_atr_input *input,
+                                               u16 soft_id,
+                                               u8 queue)
 {
 	u32 fdircmd = 0;
 	u32 fdirhash;
@@ -2097,7 +2091,7 @@ s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
  *
  *  Performs read operation to Omer analog register specified.
  **/
-s32 ixgbe_read_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 *val)
+static s32 ixgbe_read_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 *val)
 {
 	u32  core_ctl;
 
@@ -2119,7 +2113,7 @@ s32 ixgbe_read_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 *val)
  *
  *  Performs write operation to Omer analog register specified.
  **/
-s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val)
+static s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val)
 {
 	u32  core_ctl;
 
@@ -2139,7 +2133,7 @@ s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val)
  *  Then performs device-specific:
  *  Clears the rate limiter registers.
  **/
-s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
 {
 	u32 q_num;
 	s32 ret_val;
@@ -2168,7 +2162,7 @@ s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
  *
  *  Determines the physical layer module found on the current adapter.
  **/
-s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw)
+static s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw)
 {
 	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
 	status = ixgbe_identify_phy_generic(hw);
@@ -2183,7 +2177,7 @@ s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw)
  *
  *  Determines physical layer capabilities of the current configuration.
  **/
-u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
+static u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 {
 	u32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 	u32 autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
@@ -2290,7 +2284,7 @@ out:
  *
  *  Enables the Rx DMA unit for 82599
  **/
-s32 ixgbe_enable_rx_dma_82599(struct ixgbe_hw *hw, u32 regval)
+static s32 ixgbe_enable_rx_dma_82599(struct ixgbe_hw *hw, u32 regval)
 {
 #define IXGBE_MAX_SECRX_POLL 30
 	int i;
@@ -2335,7 +2329,7 @@ s32 ixgbe_enable_rx_dma_82599(struct ixgbe_hw *hw, u32 regval)
  *  This function will read the EEPROM location for the device capabilities,
  *  and return the word through device_caps.
  **/
-s32 ixgbe_get_device_caps_82599(struct ixgbe_hw *hw, u16 *device_caps)
+static s32 ixgbe_get_device_caps_82599(struct ixgbe_hw *hw, u16 *device_caps)
 {
 	hw->eeprom.ops.read(hw, IXGBE_DEVICE_CAPS, device_caps);
 
@@ -2351,8 +2345,8 @@ s32 ixgbe_get_device_caps_82599(struct ixgbe_hw *hw, u16 *device_caps)
  *  pointer, and returns the value at that location.  This is used in both
  *  get and set mac_addr routines.
  **/
-s32 ixgbe_get_san_mac_addr_offset_82599(struct ixgbe_hw *hw,
-                                        u16 *san_mac_offset)
+static s32 ixgbe_get_san_mac_addr_offset_82599(struct ixgbe_hw *hw,
+                                               u16 *san_mac_offset)
 {
 	/*
 	 * First read the EEPROM pointer to see if the MAC addresses are
@@ -2373,7 +2367,7 @@ s32 ixgbe_get_san_mac_addr_offset_82599(struct ixgbe_hw *hw,
  *  set_lan_id() is called by identify_sfp(), but this cannot be relied
  *  upon for non-SFP connections, so we must call it here.
  **/
-s32 ixgbe_get_san_mac_addr_82599(struct ixgbe_hw *hw, u8 *san_mac_addr)
+static s32 ixgbe_get_san_mac_addr_82599(struct ixgbe_hw *hw, u8 *san_mac_addr)
 {
 	u16 san_mac_data, san_mac_offset;
 	u8 i;
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 96a1859..6621e17 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -53,6 +53,7 @@ static void ixgbe_enable_rar(struct ixgbe_hw *hw, u32 index);
 static void ixgbe_disable_rar(struct ixgbe_hw *hw, u32 index);
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
 static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq);
+static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
 
 /**
  *  ixgbe_start_hw_generic - Prepare hardware for Tx/Rx
@@ -1815,7 +1816,7 @@ out:
  *
  *  Called at init time to set up flow control.
  **/
-s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
+static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 {
 	s32 ret_val = 0;
 	u32 reg;
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 0d34d4d..27f3214 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -64,7 +64,6 @@ s32 ixgbe_update_uc_addr_list_generic(struct ixgbe_hw *hw,
 s32 ixgbe_enable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
-s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
 s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packtetbuf_num);
 s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d69d277..3f17706 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3615,7 +3615,7 @@ static void ixgbe_free_q_vectors(struct ixgbe_adapter *adapter)
 	}
 }
 
-void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
+static void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
 {
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;

