From: Joe Perches <joe@perches.com>
Subject: [PATCH 6/6] drivers/net/e1000 - Convert int32_t to s32
Date: Tue, 18 Mar 2008 09:13:49 -0700
Message-ID: <c18867835e6cd98fe94fa418abf7f2432a7786a5.1205779102.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
	<41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
	<d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
	<84e6a8fed68d45f3271a23b7333bfd4627d646c1.1205779102.git.joe@perches.com>
	<1c1d35f8165b53f5e1e050c88cf97922b0694229.1205779102.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>, Jeb Cramer <cramerj@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1c1d35f8165b53f5e1e050c88cf97922b0694229.1205779102.git.joe@perches.com>
In-Reply-To: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
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


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e1000/e1000_hw.c   |  486 ++++++++++++++++++++--------------------
 drivers/net/e1000/e1000_hw.h   |   58 +++---
 drivers/net/e1000/e1000_main.c |    4 +-
 3 files changed, 274 insertions(+), 274 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index b5082fd..9a4b6cb 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -33,103 +33,103 @@
 
 #include "e1000_hw.h"
 
-static int32_t e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask);
+static s32 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask);
 static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask);
-static int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 *data);
-static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
-static int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
+static s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 *data);
+static s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
+static s32 e1000_get_software_semaphore(struct e1000_hw *hw);
 static void e1000_release_software_semaphore(struct e1000_hw *hw);
 
 static u8 e1000_arc_subsystem_valid(struct e1000_hw *hw);
-static int32_t e1000_check_downshift(struct e1000_hw *hw);
-static int32_t e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *polarity);
+static s32 e1000_check_downshift(struct e1000_hw *hw);
+static s32 e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *polarity);
 static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
 static void e1000_clear_vfta(struct e1000_hw *hw);
-static int32_t e1000_commit_shadow_ram(struct e1000_hw *hw);
-static int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw,
+static s32 e1000_commit_shadow_ram(struct e1000_hw *hw);
+static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw,
 						  bool link_up);
-static int32_t e1000_config_fc_after_link_up(struct e1000_hw *hw);
-static int32_t e1000_detect_gig_phy(struct e1000_hw *hw);
-static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank);
-static int32_t e1000_get_auto_rd_done(struct e1000_hw *hw);
-static int32_t e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length, u16 *max_length);
-static int32_t e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
-static int32_t e1000_get_phy_cfg_done(struct e1000_hw *hw);
-static int32_t e1000_get_software_flag(struct e1000_hw *hw);
-static int32_t e1000_ich8_cycle_init(struct e1000_hw *hw);
-static int32_t e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout);
-static int32_t e1000_id_led_init(struct e1000_hw *hw);
-static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, u32 cnf_base_addr, u32 cnf_size);
-static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
+static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw);
+static s32 e1000_detect_gig_phy(struct e1000_hw *hw);
+static s32 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank);
+static s32 e1000_get_auto_rd_done(struct e1000_hw *hw);
+static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length, u16 *max_length);
+static s32 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
+static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
+static s32 e1000_get_software_flag(struct e1000_hw *hw);
+static s32 e1000_ich8_cycle_init(struct e1000_hw *hw);
+static s32 e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout);
+static s32 e1000_id_led_init(struct e1000_hw *hw);
+static s32 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, u32 cnf_base_addr, u32 cnf_size);
+static s32 e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
 static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
 static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
-static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
-static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
-static int32_t e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, u16 length, u16 offset, u8 *sum);
-static int32_t e1000_mng_write_cmd_header(struct e1000_hw* hw, struct e1000_host_mng_command_header* hdr);
-static int32_t e1000_mng_write_commit(struct e1000_hw *hw);
-static int32_t e1000_phy_ife_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
-static int32_t e1000_phy_igp_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
-static int32_t e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
-static int32_t e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
-static int32_t e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
-static int32_t e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static s32 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
+static s32 e1000_mng_enable_host_if(struct e1000_hw *hw);
+static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, u16 length, u16 offset, u8 *sum);
+static s32 e1000_mng_write_cmd_header(struct e1000_hw* hw, struct e1000_host_mng_command_header* hdr);
+static s32 e1000_mng_write_commit(struct e1000_hw *hw);
+static s32 e1000_phy_ife_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static s32 e1000_phy_igp_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static s32 e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
+static s32 e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
-static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8 *data);
-static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
-static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
-static int32_t e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data);
-static int32_t e1000_read_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 *data);
-static int32_t e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 data);
-static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
-static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8 *data);
+static s32 e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
+static s32 e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
+static s32 e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data);
+static s32 e1000_read_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 *data);
+static s32 e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 data);
+static s32 e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 static void e1000_release_software_flag(struct e1000_hw *hw);
-static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
-static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
-static int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop);
+static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
+static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
+static s32 e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop);
 static void e1000_set_pci_express_master_disable(struct e1000_hw *hw);
-static int32_t e1000_wait_autoneg(struct e1000_hw *hw);
+static s32 e1000_wait_autoneg(struct e1000_hw *hw);
 static void e1000_write_reg_io(struct e1000_hw *hw, u32 offset, u32 value);
-static int32_t e1000_set_phy_type(struct e1000_hw *hw);
+static s32 e1000_set_phy_type(struct e1000_hw *hw);
 static void e1000_phy_init_script(struct e1000_hw *hw);
-static int32_t e1000_setup_copper_link(struct e1000_hw *hw);
-static int32_t e1000_setup_fiber_serdes_link(struct e1000_hw *hw);
-static int32_t e1000_adjust_serdes_amplitude(struct e1000_hw *hw);
-static int32_t e1000_phy_force_speed_duplex(struct e1000_hw *hw);
-static int32_t e1000_config_mac_to_phy(struct e1000_hw *hw);
+static s32 e1000_setup_copper_link(struct e1000_hw *hw);
+static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw);
+static s32 e1000_adjust_serdes_amplitude(struct e1000_hw *hw);
+static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw);
+static s32 e1000_config_mac_to_phy(struct e1000_hw *hw);
 static void e1000_raise_mdi_clk(struct e1000_hw *hw, u32 *ctrl);
 static void e1000_lower_mdi_clk(struct e1000_hw *hw, u32 *ctrl);
 static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, u32 data,
                                      u16 count);
 static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw);
-static int32_t e1000_phy_reset_dsp(struct e1000_hw *hw);
-static int32_t e1000_write_eeprom_spi(struct e1000_hw *hw, u16 offset,
+static s32 e1000_phy_reset_dsp(struct e1000_hw *hw);
+static s32 e1000_write_eeprom_spi(struct e1000_hw *hw, u16 offset,
                                       u16 words, u16 *data);
-static int32_t e1000_write_eeprom_microwire(struct e1000_hw *hw,
+static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw,
                                             u16 offset, u16 words,
                                             u16 *data);
-static int32_t e1000_spi_eeprom_ready(struct e1000_hw *hw);
+static s32 e1000_spi_eeprom_ready(struct e1000_hw *hw);
 static void e1000_raise_ee_clk(struct e1000_hw *hw, u32 *eecd);
 static void e1000_lower_ee_clk(struct e1000_hw *hw, u32 *eecd);
 static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data,
                                     u16 count);
-static int32_t e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
+static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
                                       u16 phy_data);
-static int32_t e1000_read_phy_reg_ex(struct e1000_hw *hw,u32 reg_addr,
+static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw,u32 reg_addr,
                                      u16 *phy_data);
 static u16 e1000_shift_in_ee_bits(struct e1000_hw *hw, u16 count);
-static int32_t e1000_acquire_eeprom(struct e1000_hw *hw);
+static s32 e1000_acquire_eeprom(struct e1000_hw *hw);
 static void e1000_release_eeprom(struct e1000_hw *hw);
 static void e1000_standby_eeprom(struct e1000_hw *hw);
-static int32_t e1000_set_vco_speed(struct e1000_hw *hw);
-static int32_t e1000_polarity_reversal_workaround(struct e1000_hw *hw);
-static int32_t e1000_set_phy_mode(struct e1000_hw *hw);
-static int32_t e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer);
+static s32 e1000_set_vco_speed(struct e1000_hw *hw);
+static s32 e1000_polarity_reversal_workaround(struct e1000_hw *hw);
+static s32 e1000_set_phy_mode(struct e1000_hw *hw);
+static s32 e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer);
 static u8 e1000_calculate_mng_checksum(char *buffer, u32 length);
-static int32_t e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
+static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
                                                u16 duplex);
-static int32_t e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
+static s32 e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
 
 /* IGP cable length table */
 static const
@@ -159,7 +159,7 @@ u16 e1000_igp_2_cable_length_table[IGP02E1000_AGC_LENGTH_TABLE_SIZE] =
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_set_phy_type(struct e1000_hw *hw)
 {
     DEBUGFUNC("e1000_set_phy_type");
@@ -306,7 +306,7 @@ e1000_phy_init_script(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_set_mac_type(struct e1000_hw *hw)
 {
 	DEBUGFUNC("e1000_set_mac_type");
@@ -528,7 +528,7 @@ e1000_set_media_type(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_reset_hw(struct e1000_hw *hw)
 {
     u32 ctrl;
@@ -538,7 +538,7 @@ e1000_reset_hw(struct e1000_hw *hw)
     u32 led_ctrl;
     u32 timeout;
     u32 extcnf_ctrl;
-    int32_t ret_val;
+    s32 ret_val;
 
     DEBUGFUNC("e1000_reset_hw");
 
@@ -866,12 +866,12 @@ e1000_initialize_hardware_bits(struct e1000_hw *hw)
  * configuration and flow control settings. Clears all on-chip counters. Leaves
  * the transmit and receive units disabled and uninitialized.
  *****************************************************************************/
-int32_t
+s32
 e1000_init_hw(struct e1000_hw *hw)
 {
     u32 ctrl;
     u32 i;
-    int32_t ret_val;
+    s32 ret_val;
     u32 mta_size;
     u32 reg_data;
     u32 ctrl_ext;
@@ -1054,11 +1054,11 @@ e1000_init_hw(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
 {
     u16 eeprom_data;
-    int32_t  ret_val;
+    s32  ret_val;
 
     DEBUGFUNC("e1000_adjust_serdes_amplitude");
 
@@ -1100,11 +1100,11 @@ e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
  * established. Assumes the hardware has previously been reset and the
  * transmitter and receiver are not enabled.
  *****************************************************************************/
-int32_t
+s32
 e1000_setup_link(struct e1000_hw *hw)
 {
     u32 ctrl_ext;
-    int32_t ret_val;
+    s32 ret_val;
     u16 eeprom_data;
 
     DEBUGFUNC("e1000_setup_link");
@@ -1233,7 +1233,7 @@ e1000_setup_link(struct e1000_hw *hw)
  * link. Assumes the hardware has been previously reset and the transmitter
  * and receiver are not enabled.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 {
     u32 ctrl;
@@ -1241,7 +1241,7 @@ e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
     u32 txcw = 0;
     u32 i;
     u32 signal = 0;
-    int32_t ret_val;
+    s32 ret_val;
 
     DEBUGFUNC("e1000_setup_fiber_serdes_link");
 
@@ -1380,11 +1380,11 @@ e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_copper_link_preconfig(struct e1000_hw *hw)
 {
     u32 ctrl;
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_preconfig");
@@ -1440,11 +1440,11 @@ e1000_copper_link_preconfig(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static int32_t
+static s32
 e1000_copper_link_igp_setup(struct e1000_hw *hw)
 {
     u32 led_ctrl;
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_igp_setup");
@@ -1587,10 +1587,10 @@ e1000_copper_link_igp_setup(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static int32_t
+static s32
 e1000_copper_link_ggp_setup(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
     u32 reg_data;
 
@@ -1735,10 +1735,10 @@ e1000_copper_link_ggp_setup(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static int32_t
+static s32
 e1000_copper_link_mgp_setup(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_mgp_setup");
@@ -1839,10 +1839,10 @@ e1000_copper_link_mgp_setup(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static int32_t
+static s32
 e1000_copper_link_autoneg(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_autoneg");
@@ -1910,10 +1910,10 @@ e1000_copper_link_autoneg(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_copper_link_postconfig(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     DEBUGFUNC("e1000_copper_link_postconfig");
 
     if (hw->mac_type >= e1000_82544) {
@@ -1948,10 +1948,10 @@ e1000_copper_link_postconfig(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_setup_copper_link(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 i;
     u16 phy_data;
     u16 reg_data;
@@ -2062,10 +2062,10 @@ e1000_setup_copper_link(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
 {
-    int32_t ret_val = E1000_SUCCESS;
+    s32 ret_val = E1000_SUCCESS;
     u32 tipg;
     u16 reg_data;
 
@@ -2098,10 +2098,10 @@ e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
     return ret_val;
 }
 
-static int32_t
+static s32
 e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
 {
-    int32_t ret_val = E1000_SUCCESS;
+    s32 ret_val = E1000_SUCCESS;
     u16 reg_data;
     u32 tipg;
 
@@ -2135,10 +2135,10 @@ e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-int32_t
+s32
 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 mii_autoneg_adv_reg;
     u16 mii_1000t_ctrl_reg;
 
@@ -2284,11 +2284,11 @@ e1000_phy_setup_autoneg(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 {
     u32 ctrl;
-    int32_t ret_val;
+    s32 ret_val;
     u16 mii_ctrl_reg;
     u16 mii_status_reg;
     u16 phy_data;
@@ -2565,11 +2565,11 @@ e1000_config_collision_dist(struct e1000_hw *hw)
 * The contents of the PHY register containing the needed information need to
 * be passed in.
 ******************************************************************************/
-static int32_t
+static s32
 e1000_config_mac_to_phy(struct e1000_hw *hw)
 {
     u32 ctrl;
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_config_mac_to_phy");
@@ -2624,7 +2624,7 @@ e1000_config_mac_to_phy(struct e1000_hw *hw)
  * by the PHY rather than the MAC. Software must also configure these
  * bits when link is forced on a fiber connection.
  *****************************************************************************/
-int32_t
+s32
 e1000_force_mac_fc(struct e1000_hw *hw)
 {
     u32 ctrl;
@@ -2691,10 +2691,10 @@ e1000_force_mac_fc(struct e1000_hw *hw)
  * based on the flow control negotiated by the PHY. In TBI mode, the TFCE
  * and RFCE bits will be automaticaly set to the negotiated flow control mode.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 mii_status_reg;
     u16 mii_nway_adv_reg;
     u16 mii_nway_lp_ability_reg;
@@ -2896,7 +2896,7 @@ e1000_config_fc_after_link_up(struct e1000_hw *hw)
  *
  * Called by any function that needs to check the link status of the adapter.
  *****************************************************************************/
-int32_t
+s32
 e1000_check_for_link(struct e1000_hw *hw)
 {
     u32 rxcw = 0;
@@ -2905,7 +2905,7 @@ e1000_check_for_link(struct e1000_hw *hw)
     u32 rctl;
     u32 icr;
     u32 signal = 0;
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_check_for_link");
@@ -3132,13 +3132,13 @@ e1000_check_for_link(struct e1000_hw *hw)
  * speed - Speed of the connection
  * duplex - Duplex setting of the connection
  *****************************************************************************/
-int32_t
+s32
 e1000_get_speed_and_duplex(struct e1000_hw *hw,
                            u16 *speed,
                            u16 *duplex)
 {
     u32 status;
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_get_speed_and_duplex");
@@ -3214,10 +3214,10 @@ e1000_get_speed_and_duplex(struct e1000_hw *hw,
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_wait_autoneg(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 i;
     u16 phy_data;
 
@@ -3384,13 +3384,13 @@ e1000_shift_in_mdi_bits(struct e1000_hw *hw)
     return data;
 }
 
-static int32_t
+static s32
 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
 {
     u32 swfw_sync = 0;
     u32 swmask = mask;
     u32 fwmask = mask << 16;
-    int32_t timeout = 200;
+    s32 timeout = 200;
 
     DEBUGFUNC("e1000_swfw_sync_acquire");
 
@@ -3464,7 +3464,7 @@ e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
 * hw - Struct containing variables accessed by shared code
 * reg_addr - address of the PHY register to read
 ******************************************************************************/
-int32_t
+s32
 e1000_read_phy_reg(struct e1000_hw *hw,
                    u32 reg_addr,
                    u16 *phy_data)
@@ -3523,7 +3523,7 @@ e1000_read_phy_reg(struct e1000_hw *hw,
     return ret_val;
 }
 
-static int32_t
+static s32
 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
                       u16 *phy_data)
 {
@@ -3603,7 +3603,7 @@ e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 * reg_addr - address of the PHY register to write
 * data - data to write to the PHY
 ******************************************************************************/
-int32_t
+s32
 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr,
                     u16 phy_data)
 {
@@ -3661,7 +3661,7 @@ e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr,
     return ret_val;
 }
 
-static int32_t
+static s32
 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
                        u16 phy_data)
 {
@@ -3723,7 +3723,7 @@ e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
     return E1000_SUCCESS;
 }
 
-static int32_t
+static s32
 e1000_read_kmrn_reg(struct e1000_hw *hw,
                     u32 reg_addr,
                     u16 *data)
@@ -3756,7 +3756,7 @@ e1000_read_kmrn_reg(struct e1000_hw *hw,
     return E1000_SUCCESS;
 }
 
-static int32_t
+static s32
 e1000_write_kmrn_reg(struct e1000_hw *hw,
                      u32 reg_addr,
                      u16 data)
@@ -3788,12 +3788,12 @@ e1000_write_kmrn_reg(struct e1000_hw *hw,
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-int32_t
+s32
 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
     u32 ctrl, ctrl_ext;
     u32 led_ctrl;
-    int32_t ret_val;
+    s32 ret_val;
     u16 swfw;
 
     DEBUGFUNC("e1000_phy_hw_reset");
@@ -3882,10 +3882,10 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
 *
 * Sets bit 15 of the MII Control register
 ******************************************************************************/
-int32_t
+s32
 e1000_phy_reset(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_phy_reset");
@@ -3937,9 +3937,9 @@ e1000_phy_reset(struct e1000_hw *hw)
 void
 e1000_phy_powerdown_workaround(struct e1000_hw *hw)
 {
-    int32_t reg;
+    s32 reg;
     u16 phy_data;
-    int32_t retry = 0;
+    s32 retry = 0;
 
     DEBUGFUNC("e1000_phy_powerdown_workaround");
 
@@ -3987,12 +3987,12 @@ e1000_phy_powerdown_workaround(struct e1000_hw *hw)
 *
 * hw - struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    int32_t reg;
-    int32_t cnt;
+    s32 ret_val;
+    s32 reg;
+    s32 cnt;
     u16 phy_data;
 
     if (hw->kmrn_lock_loss_workaround_disabled)
@@ -4040,10 +4040,10 @@ e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_detect_gig_phy(struct e1000_hw *hw)
 {
-    int32_t phy_init_status, ret_val;
+    s32 phy_init_status, ret_val;
     u16 phy_id_high, phy_id_low;
     bool match = false;
 
@@ -4136,10 +4136,10 @@ e1000_detect_gig_phy(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_reset_dsp(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     DEBUGFUNC("e1000_phy_reset_dsp");
 
     do {
@@ -4163,11 +4163,11 @@ e1000_phy_reset_dsp(struct e1000_hw *hw)
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_igp_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data, min_length, max_length, average;
     e1000_rev_polarity polarity;
 
@@ -4240,11 +4240,11 @@ e1000_phy_igp_get_info(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_ife_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
     e1000_rev_polarity polarity;
 
@@ -4290,11 +4290,11 @@ e1000_phy_ife_get_info(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_m88_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
     e1000_rev_polarity polarity;
 
@@ -4369,11 +4369,11 @@ e1000_phy_m88_get_info(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-int32_t
+s32
 e1000_phy_get_info(struct e1000_hw *hw,
                    struct e1000_phy_info *phy_info)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_phy_get_info");
@@ -4415,7 +4415,7 @@ e1000_phy_get_info(struct e1000_hw *hw,
         return e1000_phy_m88_get_info(hw, phy_info);
 }
 
-int32_t
+s32
 e1000_validate_mdi_setting(struct e1000_hw *hw)
 {
     DEBUGFUNC("e1000_validate_mdi_settings");
@@ -4436,12 +4436,12 @@ e1000_validate_mdi_setting(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_init_eeprom_params(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 eecd = E1000_READ_REG(hw, EECD);
-    int32_t ret_val = E1000_SUCCESS;
+    s32 ret_val = E1000_SUCCESS;
     u16 eeprom_size;
 
     DEBUGFUNC("e1000_init_eeprom_params");
@@ -4561,7 +4561,7 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
         break;
     case e1000_ich8lan:
         {
-        int32_t  i = 0;
+        s32  i = 0;
         u32 flash_size = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_GFPREG);
 
         eeprom->type = e1000_eeprom_ich8;
@@ -4762,7 +4762,7 @@ e1000_shift_in_ee_bits(struct e1000_hw *hw,
  * Lowers EEPROM clock. Clears input pin. Sets the chip select pin. This
  * function should be called before issuing a command to the EEPROM.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_acquire_eeprom(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
@@ -4921,7 +4921,7 @@ e1000_release_eeprom(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_spi_eeprom_ready(struct e1000_hw *hw)
 {
     u16 retry_count = 0;
@@ -4967,7 +4967,7 @@ e1000_spi_eeprom_ready(struct e1000_hw *hw)
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-int32_t
+s32
 e1000_read_eeprom(struct e1000_hw *hw,
                   u16 offset,
                   u16 words,
@@ -5068,14 +5068,14 @@ e1000_read_eeprom(struct e1000_hw *hw,
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static int32_t
+static s32
 e1000_read_eeprom_eerd(struct e1000_hw *hw,
                   u16 offset,
                   u16 words,
                   u16 *data)
 {
     u32 i, eerd = 0;
-    int32_t error = 0;
+    s32 error = 0;
 
     for (i = 0; i < words; i++) {
         eerd = ((offset+i) << E1000_EEPROM_RW_ADDR_SHIFT) +
@@ -5102,7 +5102,7 @@ e1000_read_eeprom_eerd(struct e1000_hw *hw,
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static int32_t
+static s32
 e1000_write_eeprom_eewr(struct e1000_hw *hw,
                    u16 offset,
                    u16 words,
@@ -5110,7 +5110,7 @@ e1000_write_eeprom_eewr(struct e1000_hw *hw,
 {
     u32    register_value = 0;
     u32    i              = 0;
-    int32_t     error          = 0;
+    s32     error          = 0;
 
     if (e1000_swfw_sync_acquire(hw, E1000_SWFW_EEP_SM))
         return -E1000_ERR_SWFW_SYNC;
@@ -5143,12 +5143,12 @@ e1000_write_eeprom_eewr(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 {
     u32 attempts = 100000;
     u32 i, reg = 0;
-    int32_t done = E1000_ERR_EEPROM;
+    s32 done = E1000_ERR_EEPROM;
 
     for (i = 0; i < attempts; i++) {
         if (eerd == E1000_EEPROM_POLL_READ)
@@ -5204,7 +5204,7 @@ e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
  * If the the sum of the 64 16 bit words is 0xBABA, the EEPROM's checksum is
  * valid.
  *****************************************************************************/
-int32_t
+s32
 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 {
     u16 checksum = 0;
@@ -5268,7 +5268,7 @@ e1000_validate_eeprom_checksum(struct e1000_hw *hw)
  * Sums the first 63 16 bit words of the EEPROM. Subtracts the sum from 0xBABA.
  * Writes the difference to word offset 63 of the EEPROM.
  *****************************************************************************/
-int32_t
+s32
 e1000_update_eeprom_checksum(struct e1000_hw *hw)
 {
     u32 ctrl_ext;
@@ -5313,14 +5313,14 @@ e1000_update_eeprom_checksum(struct e1000_hw *hw)
  * If e1000_update_eeprom_checksum is not called after this function, the
  * EEPROM will most likely contain an invalid checksum.
  *****************************************************************************/
-int32_t
+s32
 e1000_write_eeprom(struct e1000_hw *hw,
                    u16 offset,
                    u16 words,
                    u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    int32_t status = 0;
+    s32 status = 0;
 
     DEBUGFUNC("e1000_write_eeprom");
 
@@ -5370,7 +5370,7 @@ e1000_write_eeprom(struct e1000_hw *hw,
  * data - pointer to array of 8 bit words to be written to the EEPROM
  *
  *****************************************************************************/
-static int32_t
+static s32
 e1000_write_eeprom_spi(struct e1000_hw *hw,
                        u16 offset,
                        u16 words,
@@ -5436,7 +5436,7 @@ e1000_write_eeprom_spi(struct e1000_hw *hw,
  * data - pointer to array of 16 bit words to be written to the EEPROM
  *
  *****************************************************************************/
-static int32_t
+static s32
 e1000_write_eeprom_microwire(struct e1000_hw *hw,
                              u16 offset,
                              u16 words,
@@ -5523,14 +5523,14 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static int32_t
+static s32
 e1000_commit_shadow_ram(struct e1000_hw *hw)
 {
     u32 attempts = 100000;
     u32 eecd = 0;
     u32 flop = 0;
     u32 i = 0;
-    int32_t error = E1000_SUCCESS;
+    s32 error = E1000_SUCCESS;
     u32 old_bank_offset = 0;
     u32 new_bank_offset = 0;
     u8 low_byte = 0;
@@ -5687,7 +5687,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_read_mac_addr(struct e1000_hw * hw)
 {
     u16 offset;
@@ -6003,7 +6003,7 @@ e1000_clear_vfta(struct e1000_hw *hw)
     }
 }
 
-static int32_t
+static s32
 e1000_id_led_init(struct e1000_hw * hw)
 {
     u32 ledctl;
@@ -6086,11 +6086,11 @@ e1000_id_led_init(struct e1000_hw * hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_setup_led(struct e1000_hw *hw)
 {
     u32 ledctl;
-    int32_t ret_val = E1000_SUCCESS;
+    s32 ret_val = E1000_SUCCESS;
 
     DEBUGFUNC("e1000_setup_led");
 
@@ -6145,7 +6145,7 @@ e1000_setup_led(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_blink_led_start(struct e1000_hw *hw)
 {
     s16  i;
@@ -6180,10 +6180,10 @@ e1000_blink_led_start(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_cleanup_led(struct e1000_hw *hw)
 {
-    int32_t ret_val = E1000_SUCCESS;
+    s32 ret_val = E1000_SUCCESS;
 
     DEBUGFUNC("e1000_cleanup_led");
 
@@ -6222,7 +6222,7 @@ e1000_cleanup_led(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_led_on(struct e1000_hw *hw)
 {
     u32 ctrl = E1000_READ_REG(hw, CTRL);
@@ -6273,7 +6273,7 @@ e1000_led_on(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_led_off(struct e1000_hw *hw)
 {
     u32 ctrl = E1000_READ_REG(hw, CTRL);
@@ -6573,7 +6573,7 @@ e1000_tbi_adjust_stats(struct e1000_hw *hw,
 void
 e1000_get_bus_info(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 pci_ex_link_status;
     u32 status;
 
@@ -6672,12 +6672,12 @@ e1000_write_reg_io(struct e1000_hw *hw,
  * register to the minimum and maximum range.
  * For IGP phy's, the function calculates the range by the AGC registers.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_get_cable_length(struct e1000_hw *hw,
                        u16 *min_length,
                        u16 *max_length)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 agc_value = 0;
     u16 i, phy_data;
     u16 cable_length;
@@ -6863,11 +6863,11 @@ e1000_get_cable_length(struct e1000_hw *hw,
  * return 0.  If the link speed is 1000 Mbps the polarity status is in the
  * IGP01E1000_PHY_PCS_INIT_REG.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_check_polarity(struct e1000_hw *hw,
                      e1000_rev_polarity *polarity)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_check_polarity");
@@ -6939,10 +6939,10 @@ e1000_check_polarity(struct e1000_hw *hw,
  * Link Health register.  In IGP this bit is latched high, so the driver must
  * read it immediately after link is established.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_check_downshift(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
 
     DEBUGFUNC("e1000_check_downshift");
@@ -6985,11 +6985,11 @@ e1000_check_downshift(struct e1000_hw *hw)
  *
  ****************************************************************************/
 
-static int32_t
+static s32
 e1000_config_dsp_after_link_change(struct e1000_hw *hw,
                                    bool link_up)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data, phy_saved_data, speed, duplex, i;
     u16 dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
                                         {IGP01E1000_PHY_AGC_PARAM_A,
@@ -7173,10 +7173,10 @@ e1000_config_dsp_after_link_change(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  ****************************************************************************/
-static int32_t
+static s32
 e1000_set_phy_mode(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 eeprom_data;
 
     DEBUGFUNC("e1000_set_phy_mode");
@@ -7218,12 +7218,12 @@ e1000_set_phy_mode(struct e1000_hw *hw)
  *
  ****************************************************************************/
 
-static int32_t
+static s32
 e1000_set_d3_lplu_state(struct e1000_hw *hw,
                         bool active)
 {
     u32 phy_ctrl = 0;
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
     DEBUGFUNC("e1000_set_d3_lplu_state");
 
@@ -7348,12 +7348,12 @@ e1000_set_d3_lplu_state(struct e1000_hw *hw,
  *
  ****************************************************************************/
 
-static int32_t
+static s32
 e1000_set_d0_lplu_state(struct e1000_hw *hw,
                         bool active)
 {
     u32 phy_ctrl = 0;
-    int32_t ret_val;
+    s32 ret_val;
     u16 phy_data;
     DEBUGFUNC("e1000_set_d0_lplu_state");
 
@@ -7439,10 +7439,10 @@ e1000_set_d0_lplu_state(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_set_vco_speed(struct e1000_hw *hw)
 {
-    int32_t  ret_val;
+    s32  ret_val;
     u16 default_page = 0;
     u16 phy_data;
 
@@ -7503,7 +7503,7 @@ e1000_set_vco_speed(struct e1000_hw *hw)
  *
  * returns: - E1000_SUCCESS .
  ****************************************************************************/
-static int32_t
+static s32
 e1000_host_if_read_cookie(struct e1000_hw * hw, u8 *buffer)
 {
     u8 i;
@@ -7530,7 +7530,7 @@ e1000_host_if_read_cookie(struct e1000_hw * hw, u8 *buffer)
  *            timeout
  *          - E1000_SUCCESS for success.
  ****************************************************************************/
-static int32_t
+static s32
 e1000_mng_enable_host_if(struct e1000_hw * hw)
 {
     u32 hicr;
@@ -7564,7 +7564,7 @@ e1000_mng_enable_host_if(struct e1000_hw * hw)
  *
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
-static int32_t
+static s32
 e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
                         u16 length, u16 offset, u8 *sum)
 {
@@ -7632,7 +7632,7 @@ e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
  *
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
-static int32_t
+static s32
 e1000_mng_write_cmd_header(struct e1000_hw * hw,
                            struct e1000_host_mng_command_header * hdr)
 {
@@ -7672,7 +7672,7 @@ e1000_mng_write_cmd_header(struct e1000_hw * hw,
  *
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
-static int32_t
+static s32
 e1000_mng_write_commit(struct e1000_hw * hw)
 {
     u32 hicr;
@@ -7712,11 +7712,11 @@ e1000_check_mng_mode(struct e1000_hw *hw)
 /*****************************************************************************
  * This function writes the dhcp info .
  ****************************************************************************/
-int32_t
+s32
 e1000_mng_write_dhcp_info(struct e1000_hw * hw, u8 *buffer,
                           u16 length)
 {
-    int32_t ret_val;
+    s32 ret_val;
     struct e1000_host_mng_command_header hdr;
 
     hdr.command_id = E1000_MNG_DHCP_TX_PAYLOAD_CMD;
@@ -7769,7 +7769,7 @@ e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
 {
     /* called in init as well as watchdog timer functions */
 
-    int32_t ret_val, checksum;
+    s32 ret_val, checksum;
     bool tx_filter = false;
     struct e1000_host_mng_dhcp_cookie *hdr = &(hw->mng_cookie);
     u8 *buffer = (u8 *) &(hw->mng_cookie);
@@ -7832,10 +7832,10 @@ e1000_enable_mng_pass_thru(struct e1000_hw *hw)
     return false;
 }
 
-static int32_t
+static s32
 e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     u16 mii_status_reg;
     u16 i;
 
@@ -7952,10 +7952,10 @@ e1000_set_pci_express_master_disable(struct e1000_hw *hw)
  *            E1000_SUCCESS master requests disabled.
  *
  ******************************************************************************/
-int32_t
+s32
 e1000_disable_pciex_master(struct e1000_hw *hw)
 {
-    int32_t timeout = MASTER_DISABLE_TIMEOUT;   /* 80ms */
+    s32 timeout = MASTER_DISABLE_TIMEOUT;   /* 80ms */
 
     DEBUGFUNC("e1000_disable_pciex_master");
 
@@ -7990,10 +7990,10 @@ e1000_disable_pciex_master(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ******************************************************************************/
-static int32_t
+static s32
 e1000_get_auto_rd_done(struct e1000_hw *hw)
 {
-    int32_t timeout = AUTO_READ_DONE_TIMEOUT;
+    s32 timeout = AUTO_READ_DONE_TIMEOUT;
 
     DEBUGFUNC("e1000_get_auto_rd_done");
 
@@ -8038,10 +8038,10 @@ e1000_get_auto_rd_done(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-static int32_t
+static s32
 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 {
-    int32_t timeout = PHY_CFG_TIMEOUT;
+    s32 timeout = PHY_CFG_TIMEOUT;
     u32 cfg_mask = E1000_EEPROM_CFG_DONE;
 
     DEBUGFUNC("e1000_get_phy_cfg_done");
@@ -8085,10 +8085,10 @@ e1000_get_phy_cfg_done(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-static int32_t
+static s32
 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
 {
-    int32_t timeout;
+    s32 timeout;
     u32 swsm;
 
     DEBUGFUNC("e1000_get_hw_eeprom_semaphore");
@@ -8164,10 +8164,10 @@ e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-static int32_t
+static s32
 e1000_get_software_semaphore(struct e1000_hw *hw)
 {
-    int32_t timeout = hw->eeprom.word_size + 1;
+    s32 timeout = hw->eeprom.word_size + 1;
     u32 swsm;
 
     DEBUGFUNC("e1000_get_software_semaphore");
@@ -8228,7 +8228,7 @@ e1000_release_software_semaphore(struct e1000_hw *hw)
  *            E1000_SUCCESS
  *
  *****************************************************************************/
-int32_t
+s32
 e1000_check_phy_reset_block(struct e1000_hw *hw)
 {
     u32 manc = 0;
@@ -8283,7 +8283,7 @@ e1000_arc_subsystem_valid(struct e1000_hw *hw)
  * returns: E1000_SUCCESS
  *
  *****************************************************************************/
-static int32_t
+static s32
 e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop)
 {
     u32 gcr_reg = 0;
@@ -8324,10 +8324,10 @@ e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop)
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
-static int32_t
+static s32
 e1000_get_software_flag(struct e1000_hw *hw)
 {
-    int32_t timeout = PHY_CFG_TIMEOUT;
+    s32 timeout = PHY_CFG_TIMEOUT;
     u32 extcnf_ctrl;
 
     DEBUGFUNC("e1000_get_software_flag");
@@ -8388,11 +8388,11 @@ e1000_release_software_flag(struct e1000_hw *hw)
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static int32_t
+static s32
 e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
                        u16 *data)
 {
-    int32_t  error = E1000_SUCCESS;
+    s32  error = E1000_SUCCESS;
     u32 flash_bank = 0;
     u32 act_offset = 0;
     u32 bank_offset = 0;
@@ -8444,12 +8444,12 @@ e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
  * words - number of words to write
  * data - words to write to the EEPROM
  *****************************************************************************/
-static int32_t
+static s32
 e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
                         u16 *data)
 {
     u32 i = 0;
-    int32_t error = E1000_SUCCESS;
+    s32 error = E1000_SUCCESS;
 
     error = e1000_get_software_flag(hw);
     if (error != E1000_SUCCESS)
@@ -8491,12 +8491,12 @@ e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
  *
  * hw - The pointer to the hw structure
  ****************************************************************************/
-static int32_t
+static s32
 e1000_ich8_cycle_init(struct e1000_hw *hw)
 {
     union ich8_hws_flash_status hsfsts;
-    int32_t error = E1000_ERR_EEPROM;
-    int32_t i     = 0;
+    s32 error = E1000_ERR_EEPROM;
+    s32 i     = 0;
 
     DEBUGFUNC("e1000_ich8_cycle_init");
 
@@ -8558,12 +8558,12 @@ e1000_ich8_cycle_init(struct e1000_hw *hw)
  *
  * hw - The pointer to the hw structure
  ****************************************************************************/
-static int32_t
+static s32
 e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout)
 {
     union ich8_hws_flash_ctrl hsflctl;
     union ich8_hws_flash_status hsfsts;
-    int32_t error = E1000_ERR_EEPROM;
+    s32 error = E1000_ERR_EEPROM;
     u32 i = 0;
 
     /* Start a cycle by writing 1 in Flash Cycle Go in Hw Flash Control */
@@ -8593,7 +8593,7 @@ e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout)
  * size - Size of data to read, 1=byte 2=word
  * data - Pointer to the word to store the value read.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_read_ich8_data(struct e1000_hw *hw, u32 index,
                      u32 size, u16* data)
 {
@@ -8601,8 +8601,8 @@ e1000_read_ich8_data(struct e1000_hw *hw, u32 index,
     union ich8_hws_flash_ctrl hsflctl;
     u32 flash_linear_address;
     u32 flash_data = 0;
-    int32_t error = -E1000_ERR_EEPROM;
-    int32_t count = 0;
+    s32 error = -E1000_ERR_EEPROM;
+    s32 count = 0;
 
     DEBUGFUNC("e1000_read_ich8_data");
 
@@ -8672,7 +8672,7 @@ e1000_read_ich8_data(struct e1000_hw *hw, u32 index,
  * size - Size of data to read, 1=byte 2=word
  * data - The byte(s) to write to the NVM.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
                       u16 data)
 {
@@ -8680,8 +8680,8 @@ e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
     union ich8_hws_flash_ctrl hsflctl;
     u32 flash_linear_address;
     u32 flash_data = 0;
-    int32_t error = -E1000_ERR_EEPROM;
-    int32_t count = 0;
+    s32 error = -E1000_ERR_EEPROM;
+    s32 count = 0;
 
     DEBUGFUNC("e1000_write_ich8_data");
 
@@ -8747,10 +8747,10 @@ e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
  * index - The index of the byte to read.
  * data - Pointer to a byte to store the value read.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8* data)
 {
-    int32_t status = E1000_SUCCESS;
+    s32 status = E1000_SUCCESS;
     u16 word = 0;
 
     status = e1000_read_ich8_data(hw, index, 1, &word);
@@ -8770,11 +8770,11 @@ e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8* data)
  * index - The index of the byte to write.
  * byte - The byte to write to the NVM.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte)
 {
-    int32_t error = E1000_SUCCESS;
-    int32_t program_retries = 0;
+    s32 error = E1000_SUCCESS;
+    s32 program_retries = 0;
 
     DEBUGOUT2("Byte := %2.2X Offset := %d\n", byte, index);
 
@@ -8803,10 +8803,10 @@ e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte)
  * index - The index of the byte to read.
  * data - The byte to write to the NVM.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 data)
 {
-    int32_t status = E1000_SUCCESS;
+    s32 status = E1000_SUCCESS;
     u16 word = (u16)data;
 
     status = e1000_write_ich8_data(hw, index, 1, word);
@@ -8821,10 +8821,10 @@ e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 data)
  * index - The starting byte index of the word to read.
  * data - Pointer to a word to store the value read.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data)
 {
-    int32_t status = E1000_SUCCESS;
+    s32 status = E1000_SUCCESS;
     status = e1000_read_ich8_data(hw, index, 2, data);
     return status;
 }
@@ -8840,19 +8840,19 @@ e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data)
  * amount of NVM used in each bank is a *minimum* of 4 KBytes, but in fact the
  * bank size may be 4, 8 or 64 KBytes
  *****************************************************************************/
-static int32_t
+static s32
 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
     u32 flash_linear_address;
-    int32_t  count = 0;
-    int32_t  error = E1000_ERR_EEPROM;
-    int32_t  iteration;
-    int32_t  sub_sector_size = 0;
-    int32_t  bank_size;
-    int32_t  j = 0;
-    int32_t  error_flag = 0;
+    s32  count = 0;
+    s32  error = E1000_ERR_EEPROM;
+    s32  iteration;
+    s32  sub_sector_size = 0;
+    s32  bank_size;
+    s32  j = 0;
+    s32  error_flag = 0;
 
     hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
 
@@ -8930,7 +8930,7 @@ e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank)
     return error;
 }
 
-static int32_t
+static s32
 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
                                       u32 cnf_base_addr, u32 cnf_size)
 {
@@ -8972,7 +8972,7 @@ e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
  *
  * hw: Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_init_lcd_from_nvm(struct e1000_hw *hw)
 {
     u32 reg_data, cnf_base_addr, cnf_size, ret_val, loop;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 696e8cb..b2db4ca 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -308,31 +308,31 @@ typedef enum {
 
 /* Function prototypes */
 /* Initialization */
-int32_t e1000_reset_hw(struct e1000_hw *hw);
-int32_t e1000_init_hw(struct e1000_hw *hw);
-int32_t e1000_set_mac_type(struct e1000_hw *hw);
+s32 e1000_reset_hw(struct e1000_hw *hw);
+s32 e1000_init_hw(struct e1000_hw *hw);
+s32 e1000_set_mac_type(struct e1000_hw *hw);
 void e1000_set_media_type(struct e1000_hw *hw);
 
 /* Link Configuration */
-int32_t e1000_setup_link(struct e1000_hw *hw);
-int32_t e1000_phy_setup_autoneg(struct e1000_hw *hw);
+s32 e1000_setup_link(struct e1000_hw *hw);
+s32 e1000_phy_setup_autoneg(struct e1000_hw *hw);
 void e1000_config_collision_dist(struct e1000_hw *hw);
-int32_t e1000_check_for_link(struct e1000_hw *hw);
-int32_t e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex);
-int32_t e1000_force_mac_fc(struct e1000_hw *hw);
+s32 e1000_check_for_link(struct e1000_hw *hw);
+s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex);
+s32 e1000_force_mac_fc(struct e1000_hw *hw);
 
 /* PHY */
-int32_t e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data);
-int32_t e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
-int32_t e1000_phy_hw_reset(struct e1000_hw *hw);
-int32_t e1000_phy_reset(struct e1000_hw *hw);
-int32_t e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
-int32_t e1000_validate_mdi_setting(struct e1000_hw *hw);
+s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data);
+s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
+s32 e1000_phy_hw_reset(struct e1000_hw *hw);
+s32 e1000_phy_reset(struct e1000_hw *hw);
+s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+s32 e1000_validate_mdi_setting(struct e1000_hw *hw);
 
 void e1000_phy_powerdown_workaround(struct e1000_hw *hw);
 
 /* EEPROM Functions */
-int32_t e1000_init_eeprom_params(struct e1000_hw *hw);
+s32 e1000_init_eeprom_params(struct e1000_hw *hw);
 
 /* MNG HOST IF functions */
 u32 e1000_enable_mng_pass_thru(struct e1000_hw *hw);
@@ -389,15 +389,15 @@ struct e1000_host_mng_dhcp_cookie{
 };
 #endif
 
-int32_t e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer,
+s32 e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer,
                                   u16 length);
 bool e1000_check_mng_mode(struct e1000_hw *hw);
 bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
-int32_t e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
-int32_t e1000_validate_eeprom_checksum(struct e1000_hw *hw);
-int32_t e1000_update_eeprom_checksum(struct e1000_hw *hw);
-int32_t e1000_write_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
-int32_t e1000_read_mac_addr(struct e1000_hw * hw);
+s32 e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
+s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw);
+s32 e1000_update_eeprom_checksum(struct e1000_hw *hw);
+s32 e1000_write_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
+s32 e1000_read_mac_addr(struct e1000_hw * hw);
 
 /* Filters (multicast, vlan, receive) */
 u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 * mc_addr);
@@ -406,11 +406,11 @@ void e1000_rar_set(struct e1000_hw *hw, u8 * mc_addr, u32 rar_index);
 void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);
 
 /* LED functions */
-int32_t e1000_setup_led(struct e1000_hw *hw);
-int32_t e1000_cleanup_led(struct e1000_hw *hw);
-int32_t e1000_led_on(struct e1000_hw *hw);
-int32_t e1000_led_off(struct e1000_hw *hw);
-int32_t e1000_blink_led_start(struct e1000_hw *hw);
+s32 e1000_setup_led(struct e1000_hw *hw);
+s32 e1000_cleanup_led(struct e1000_hw *hw);
+s32 e1000_led_on(struct e1000_hw *hw);
+s32 e1000_led_off(struct e1000_hw *hw);
+s32 e1000_blink_led_start(struct e1000_hw *hw);
 
 /* Adaptive IFS Functions */
 
@@ -421,13 +421,13 @@ void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats, u
 void e1000_get_bus_info(struct e1000_hw *hw);
 void e1000_pci_set_mwi(struct e1000_hw *hw);
 void e1000_pci_clear_mwi(struct e1000_hw *hw);
-int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
+s32 e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
 void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc);
 int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
 /* Port I/O is only supported on 82544 and newer */
 void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
-int32_t e1000_disable_pciex_master(struct e1000_hw *hw);
-int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
+s32 e1000_disable_pciex_master(struct e1000_hw *hw);
+s32 e1000_check_phy_reset_block(struct e1000_hw *hw);
 
 
 #define E1000_READ_REG_IO(a, reg) \
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 04a7f71..59579b1 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2638,7 +2638,7 @@ e1000_watchdog(unsigned long data)
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	u32 link, tctl;
-	int32_t ret_val;
+	s32 ret_val;
 
 	ret_val = e1000_check_for_link(&adapter->hw);
 	if ((ret_val == E1000_ERR_PHY) &&
@@ -4959,7 +4959,7 @@ e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
 	pcix_set_mmrbc(adapter->pdev, mmrbc);
 }
 
-int32_t
+s32
 e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 {
     struct e1000_adapter *adapter = hw->back;
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
