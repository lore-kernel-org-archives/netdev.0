From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 07/23] e1000: remove unused code and make symbols static
Date: Tue, 19 Sep 2006 10:28:48 -0700
Message-ID: <20060919172847.4605.52992.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:16397 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030342AbWISRTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:19:53 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Nicholas Nunley <nicholas.d.nunley@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |   21 --
 drivers/net/e1000/e1000_ethtool.c |   15 +
 drivers/net/e1000/e1000_hw.c      |  406 +++++++------------------------------
 drivers/net/e1000/e1000_hw.h      |   14 +
 drivers/net/e1000/e1000_main.c    |   31 ++-
 5 files changed, 120 insertions(+), 367 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index e586dd7..a9501e7 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -349,25 +349,4 @@ enum e1000_state_t {
 	__E1000_RESETTING,
 };
 
-/*  e1000_main.c  */
-extern char e1000_driver_name[];
-extern char e1000_driver_version[];
-int e1000_up(struct e1000_adapter *adapter);
-void e1000_down(struct e1000_adapter *adapter);
-void e1000_reset(struct e1000_adapter *adapter);
-void e1000_reinit_locked(struct e1000_adapter *adapter);
-int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
-void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
-int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
-void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
-void e1000_update_stats(struct e1000_adapter *adapter);
-int e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx);
-
-/*  e1000_ethtool.c  */
-void e1000_set_ethtool_ops(struct net_device *netdev);
-
-/*  e1000_param.c  */
-void e1000_check_options(struct e1000_adapter *adapter);
-
-
 #endif /* _E1000_H_ */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index f50faa9..a954746 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -32,6 +32,21 @@
 
 #include <asm/uaccess.h>
 
+extern char e1000_driver_name[];
+extern char e1000_driver_version[];
+
+extern int e1000_up(struct e1000_adapter *adapter);
+extern void e1000_down(struct e1000_adapter *adapter);
+extern void e1000_reinit_locked(struct e1000_adapter *adapter);
+extern void e1000_reset(struct e1000_adapter *adapter);
+extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx);
+extern int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
+extern int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
+extern void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
+extern void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
+extern void e1000_update_stats(struct e1000_adapter *adapter);
+
+
 struct e1000_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int sizeof_stat;
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 34226c4..9422864 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -33,6 +33,62 @@
 
 #include "e1000_hw.h"
 
+static int32_t e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask);
+static void e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask);
+static int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t *data);
+static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t data);
+static int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
+static void e1000_release_software_semaphore(struct e1000_hw *hw);
+
+static uint8_t e1000_arc_subsystem_valid(struct e1000_hw *hw);
+static int32_t e1000_check_downshift(struct e1000_hw *hw);
+static int32_t e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *polarity);
+static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
+static void e1000_clear_vfta(struct e1000_hw *hw);
+static int32_t e1000_commit_shadow_ram(struct e1000_hw *hw);
+static int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw, boolean_t link_up);
+static int32_t e1000_config_fc_after_link_up(struct e1000_hw *hw);
+static int32_t e1000_detect_gig_phy(struct e1000_hw *hw);
+static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank);
+static int32_t e1000_get_auto_rd_done(struct e1000_hw *hw);
+static int32_t e1000_get_cable_length(struct e1000_hw *hw, uint16_t *min_length, uint16_t *max_length);
+static int32_t e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
+static int32_t e1000_get_phy_cfg_done(struct e1000_hw *hw);
+static int32_t e1000_get_software_flag(struct e1000_hw *hw);
+static int32_t e1000_ich8_cycle_init(struct e1000_hw *hw);
+static int32_t e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout);
+static int32_t e1000_id_led_init(struct e1000_hw *hw);
+static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32_t cnf_base_addr, uint32_t cnf_size);
+static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
+static void e1000_init_rx_addrs(struct e1000_hw *hw);
+static boolean_t e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
+static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
+static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
+static int32_t e1000_mng_host_if_write(struct e1000_hw *hw, uint8_t *buffer, uint16_t length, uint16_t offset, uint8_t *sum);
+static int32_t e1000_mng_write_cmd_header(struct e1000_hw* hw, struct e1000_host_mng_command_header* hdr);
+static int32_t e1000_mng_write_commit(struct e1000_hw *hw);
+static int32_t e1000_phy_ife_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static int32_t e1000_phy_igp_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static int32_t e1000_read_eeprom_eerd(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
+static int32_t e1000_write_eeprom_eewr(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
+static int32_t e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
+static int32_t e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
+static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t *data);
+static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte);
+static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte);
+static int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data);
+static int32_t e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, uint16_t *data);
+static int32_t e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, uint16_t data);
+static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
+static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
+static void e1000_release_software_flag(struct e1000_hw *hw);
+static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, boolean_t active);
+static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, boolean_t active);
+static int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop);
+static void e1000_set_pci_express_master_disable(struct e1000_hw *hw);
+static int32_t e1000_wait_autoneg(struct e1000_hw *hw);
+static void e1000_write_reg_io(struct e1000_hw *hw, uint32_t offset, uint32_t value);
 static int32_t e1000_set_phy_type(struct e1000_hw *hw);
 static void e1000_phy_init_script(struct e1000_hw *hw);
 static int32_t e1000_setup_copper_link(struct e1000_hw *hw);
@@ -69,69 +125,10 @@ static int32_t e1000_polarity_reversal_w
 static int32_t e1000_set_phy_mode(struct e1000_hw *hw);
 static int32_t e1000_host_if_read_cookie(struct e1000_hw *hw, uint8_t *buffer);
 static uint8_t e1000_calculate_mng_checksum(char *buffer, uint32_t length);
-static uint8_t e1000_arc_subsystem_valid(struct e1000_hw *hw);
-static int32_t e1000_check_downshift(struct e1000_hw *hw);
-static int32_t e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *polarity);
-static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
-static void e1000_clear_vfta(struct e1000_hw *hw);
-static int32_t e1000_commit_shadow_ram(struct e1000_hw *hw);
-static int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw,
-						  boolean_t link_up);
-static int32_t e1000_config_fc_after_link_up(struct e1000_hw *hw);
-static int32_t e1000_detect_gig_phy(struct e1000_hw *hw);
-static int32_t e1000_get_auto_rd_done(struct e1000_hw *hw);
-static int32_t e1000_get_cable_length(struct e1000_hw *hw,
-				      uint16_t *min_length,
-				      uint16_t *max_length);
-static int32_t e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
-static int32_t e1000_get_phy_cfg_done(struct e1000_hw *hw);
-static int32_t e1000_id_led_init(struct e1000_hw * hw);
-static void e1000_init_rx_addrs(struct e1000_hw *hw);
-static boolean_t e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
-static int32_t e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
-static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
-static int32_t e1000_read_eeprom_eerd(struct e1000_hw *hw, uint16_t offset,
-				      uint16_t words, uint16_t *data);
-static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, boolean_t active);
-static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, boolean_t active);
-static int32_t e1000_wait_autoneg(struct e1000_hw *hw);
-
-static void e1000_write_reg_io(struct e1000_hw *hw, uint32_t offset,
-			       uint32_t value);
-
-#define E1000_WRITE_REG_IO(a, reg, val) \
-	    e1000_write_reg_io((a), E1000_##reg, val)
 static int32_t e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
                                                uint16_t duplex);
 static int32_t e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
 
-static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw,
-					   uint32_t segment);
-static int32_t e1000_get_software_flag(struct e1000_hw *hw);
-static int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
-static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
-static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
-static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset,
-				      uint16_t words, uint16_t *data);
-static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index,
-				    uint8_t* data);
-static int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index,
-				    uint16_t *data);
-static int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr,
-				   uint16_t *data);
-static void e1000_release_software_flag(struct e1000_hw *hw);
-static void e1000_release_software_semaphore(struct e1000_hw *hw);
-static int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw,
-					 uint32_t no_snoop);
-static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw,
-					    uint32_t index, uint8_t byte);
-static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset,
-				       uint16_t words, uint16_t *data);
-static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index,
-				     uint8_t data);
-static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr,
-				    uint16_t data);
-
 /* IGP cable length table */
 static const
 uint16_t e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
@@ -155,13 +152,12 @@ uint16_t e1000_igp_2_cable_length_table[
       83, 89, 95, 100, 105, 109, 113, 116, 119, 122, 124,
       104, 109, 114, 118, 121, 124};
 
-
 /******************************************************************************
  * Set the phy type member in the hw struct.
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_set_phy_type(struct e1000_hw *hw)
 {
     DEBUGFUNC("e1000_set_phy_type");
@@ -207,7 +203,6 @@ e1000_set_phy_type(struct e1000_hw *hw)
     return E1000_SUCCESS;
 }
 
-
 /******************************************************************************
  * IGP phy init script - initializes the GbE PHY
  *
@@ -3416,9 +3411,8 @@ e1000_read_phy_reg(struct e1000_hw *hw,
     return ret_val;
 }
 
-int32_t
-e1000_read_phy_reg_ex(struct e1000_hw *hw,
-                      uint32_t reg_addr,
+static int32_t
+e1000_read_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
                       uint16_t *phy_data)
 {
     uint32_t i;
@@ -3498,8 +3492,7 @@ e1000_read_phy_reg_ex(struct e1000_hw *h
 * data - data to write to the PHY
 ******************************************************************************/
 int32_t
-e1000_write_phy_reg(struct e1000_hw *hw,
-                    uint32_t reg_addr,
+e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
                     uint16_t phy_data)
 {
     uint32_t ret_val;
@@ -3556,10 +3549,9 @@ e1000_write_phy_reg(struct e1000_hw *hw,
     return ret_val;
 }
 
-int32_t
-e1000_write_phy_reg_ex(struct e1000_hw *hw,
-                    uint32_t reg_addr,
-                    uint16_t phy_data)
+static int32_t
+e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
+                       uint16_t phy_data)
 {
     uint32_t i;
     uint32_t mdic = 0;
@@ -3733,6 +3725,7 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
 
         if (hw->mac_type >= e1000_82571)
             msec_delay_irq(10);
+
         e1000_swfw_sync_release(hw, swfw);
     } else {
         /* Read the Extended Device Control Register, assert the PHY_RESET_DIR
@@ -3799,7 +3792,6 @@ e1000_phy_reset(struct e1000_hw *hw)
         ret_val = e1000_phy_hw_reset(hw);
         if (ret_val)
             return ret_val;
-
         break;
     default:
         ret_val = e1000_read_phy_reg(hw, PHY_CTRL, &phy_data);
@@ -3935,7 +3927,7 @@ e1000_kumeran_lock_loss_workaround(struc
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-int32_t
+static int32_t
 e1000_detect_gig_phy(struct e1000_hw *hw)
 {
     int32_t phy_init_status, ret_val;
@@ -4452,7 +4444,7 @@ e1000_init_eeprom_params(struct e1000_hw
         eeprom->use_eewr = FALSE;
         break;
     case e1000_ich8lan:
-    {
+        {
         int32_t  i = 0;
         uint32_t flash_size = E1000_READ_ICH8_REG(hw, ICH8_FLASH_GFPREG);
 
@@ -4479,7 +4471,7 @@ e1000_init_eeprom_params(struct e1000_hw
         hw->flash_bank_size /= 2 * sizeof(uint16_t);
 
         break;
-    }
+        }
     default:
         break;
     }
@@ -4811,7 +4803,7 @@ e1000_release_eeprom(struct e1000_hw *hw
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_spi_eeprom_ready(struct e1000_hw *hw)
 {
     uint16_t retry_count = 0;
@@ -5259,7 +5251,7 @@ e1000_write_eeprom(struct e1000_hw *hw,
  * data - pointer to array of 8 bit words to be written to the EEPROM
  *
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_write_eeprom_spi(struct e1000_hw *hw,
                        uint16_t offset,
                        uint16_t words,
@@ -5325,7 +5317,7 @@ e1000_write_eeprom_spi(struct e1000_hw *
  * data - pointer to array of 16 bit words to be written to the EEPROM
  *
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_write_eeprom_microwire(struct e1000_hw *hw,
                              uint16_t offset,
                              uint16_t words,
@@ -5651,99 +5643,6 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
 }
 
 /******************************************************************************
- * Updates the MAC's list of multicast addresses.
- *
- * hw - Struct containing variables accessed by shared code
- * mc_addr_list - the list of new multicast addresses
- * mc_addr_count - number of addresses
- * pad - number of bytes between addresses in the list
- * rar_used_count - offset where to start adding mc addresses into the RAR's
- *
- * The given list replaces any existing list. Clears the last 15 receive
- * address registers and the multicast table. Uses receive address registers
- * for the first 15 multicast addresses, and hashes the rest into the
- * multicast table.
- *****************************************************************************/
-#if 0
-void
-e1000_mc_addr_list_update(struct e1000_hw *hw,
-                          uint8_t *mc_addr_list,
-                          uint32_t mc_addr_count,
-                          uint32_t pad,
-                          uint32_t rar_used_count)
-{
-    uint32_t hash_value;
-    uint32_t i;
-    uint32_t num_rar_entry;
-    uint32_t num_mta_entry;
-
-    DEBUGFUNC("e1000_mc_addr_list_update");
-
-    /* Set the new number of MC addresses that we are being requested to use. */
-    hw->num_mc_addrs = mc_addr_count;
-
-    /* Clear RAR[1-15] */
-    DEBUGOUT(" Clearing RAR[1-15]\n");
-    num_rar_entry = E1000_RAR_ENTRIES;
-    if (hw->mac_type == e1000_ich8lan)
-        num_rar_entry = E1000_RAR_ENTRIES_ICH8LAN;
-    /* Reserve a spot for the Locally Administered Address to work around
-     * an 82571 issue in which a reset on one port will reload the MAC on
-     * the other port. */
-    if ((hw->mac_type == e1000_82571) && (hw->laa_is_present == TRUE))
-        num_rar_entry -= 1;
-
-    for (i = rar_used_count; i < num_rar_entry; i++) {
-        E1000_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
-        E1000_WRITE_FLUSH(hw);
-        E1000_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
-        E1000_WRITE_FLUSH(hw);
-    }
-
-    /* Clear the MTA */
-    DEBUGOUT(" Clearing MTA\n");
-    num_mta_entry = E1000_NUM_MTA_REGISTERS;
-    if (hw->mac_type == e1000_ich8lan)
-        num_mta_entry = E1000_NUM_MTA_REGISTERS_ICH8LAN;
-    for (i = 0; i < num_mta_entry; i++) {
-        E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
-        E1000_WRITE_FLUSH(hw);
-    }
-
-    /* Add the new addresses */
-    for (i = 0; i < mc_addr_count; i++) {
-        DEBUGOUT(" Adding the multicast addresses:\n");
-        DEBUGOUT7(" MC Addr #%d =%.2X %.2X %.2X %.2X %.2X %.2X\n", i,
-                  mc_addr_list[i * (ETH_LENGTH_OF_ADDRESS + pad)],
-                  mc_addr_list[i * (ETH_LENGTH_OF_ADDRESS + pad) + 1],
-                  mc_addr_list[i * (ETH_LENGTH_OF_ADDRESS + pad) + 2],
-                  mc_addr_list[i * (ETH_LENGTH_OF_ADDRESS + pad) + 3],
-                  mc_addr_list[i * (ETH_LENGTH_OF_ADDRESS + pad) + 4],
-                  mc_addr_list[i * (ETH_LENGTH_OF_ADDRESS + pad) + 5]);
-
-        hash_value = e1000_hash_mc_addr(hw,
-                                        mc_addr_list +
-                                        (i * (ETH_LENGTH_OF_ADDRESS + pad)));
-
-        DEBUGOUT1(" Hash value = 0x%03X\n", hash_value);
-
-        /* Place this multicast address in the RAR if there is room, *
-         * else put it in the MTA
-         */
-        if (rar_used_count < num_rar_entry) {
-            e1000_rar_set(hw,
-                          mc_addr_list + (i * (ETH_LENGTH_OF_ADDRESS + pad)),
-                          rar_used_count);
-            rar_used_count++;
-        } else {
-            e1000_mta_set(hw, hash_value);
-        }
-    }
-    DEBUGOUT("MC Update Complete\n");
-}
-#endif  /*  0  */
-
-/******************************************************************************
  * Hashes an address to determine its location in the multicast table
  *
  * hw - Struct containing variables accessed by shared code
@@ -6301,7 +6200,7 @@ e1000_led_off(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void
+static void
 e1000_clear_hw_cntrs(struct e1000_hw *hw)
 {
     volatile uint32_t temp;
@@ -6604,25 +6503,6 @@ e1000_get_bus_info(struct e1000_hw *hw)
         break;
     }
 }
-/******************************************************************************
- * Reads a value from one of the devices registers using port I/O (as opposed
- * memory mapped I/O). Only 82544 and newer devices support port I/O.
- *
- * hw - Struct containing variables accessed by shared code
- * offset - offset to read from
- *****************************************************************************/
-#if 0
-uint32_t
-e1000_read_reg_io(struct e1000_hw *hw,
-                  uint32_t offset)
-{
-    unsigned long io_addr = hw->io_base;
-    unsigned long io_data = hw->io_base + 4;
-
-    e1000_io_write(hw, io_addr, offset);
-    return e1000_io_read(hw, io_data);
-}
-#endif  /*  0  */
 
 /******************************************************************************
  * Writes a value to one of the devices registers using port I/O (as opposed to
@@ -6644,7 +6524,6 @@ e1000_write_reg_io(struct e1000_hw *hw,
     e1000_io_write(hw, io_data, value);
 }
 
-
 /******************************************************************************
  * Estimates the cable length.
  *
@@ -7275,7 +7154,7 @@ e1000_set_d3_lplu_state(struct e1000_hw 
         } else if (hw->smart_speed == e1000_smart_speed_off) {
             ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
                                          &phy_data);
-	    if (ret_val)
+            if (ret_val)
                 return ret_val;
 
             phy_data &= ~IGP01E1000_PSCFR_SMART_SPEED;
@@ -7385,7 +7264,7 @@ e1000_set_d0_lplu_state(struct e1000_hw 
         } else if (hw->smart_speed == e1000_smart_speed_off) {
             ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
                                          &phy_data);
-	    if (ret_val)
+            if (ret_val)
                 return ret_val;
 
             phy_data &= ~IGP01E1000_PSCFR_SMART_SPEED;
@@ -7491,7 +7370,7 @@ e1000_set_vco_speed(struct e1000_hw *hw)
  *
  * returns: - E1000_SUCCESS .
  ****************************************************************************/
-int32_t
+static int32_t
 e1000_host_if_read_cookie(struct e1000_hw * hw, uint8_t *buffer)
 {
     uint8_t i;
@@ -7702,7 +7581,7 @@ e1000_check_mng_mode(struct e1000_hw *hw
  ****************************************************************************/
 int32_t
 e1000_mng_write_dhcp_info(struct e1000_hw * hw, uint8_t *buffer,
-			  uint16_t length)
+                          uint16_t length)
 {
     int32_t ret_val;
     struct e1000_host_mng_command_header hdr;
@@ -7732,7 +7611,7 @@ e1000_mng_write_dhcp_info(struct e1000_h
  *
  * returns  - checksum of buffer contents.
  ****************************************************************************/
-uint8_t
+static uint8_t
 e1000_calculate_mng_checksum(char *buffer, uint32_t length)
 {
     uint8_t sum = 0;
@@ -7930,32 +7809,6 @@ e1000_set_pci_express_master_disable(str
     E1000_WRITE_REG(hw, CTRL, ctrl);
 }
 
-/***************************************************************************
- *
- * Enables PCI-Express master access.
- *
- * hw: Struct containing variables accessed by shared code
- *
- * returns: - none.
- *
- ***************************************************************************/
-#if 0
-void
-e1000_enable_pciex_master(struct e1000_hw *hw)
-{
-    uint32_t ctrl;
-
-    DEBUGFUNC("e1000_enable_pciex_master");
-
-    if (hw->bus_type != e1000_bus_type_pci_express)
-        return;
-
-    ctrl = E1000_READ_REG(hw, CTRL);
-    ctrl &= ~E1000_CTRL_GIO_MASTER_DISABLE;
-    E1000_WRITE_REG(hw, CTRL, ctrl);
-}
-#endif  /*  0  */
-
 /*******************************************************************************
  *
  * Disables PCI-Express master access and verifies there are no pending requests
@@ -8079,7 +7932,6 @@ e1000_get_phy_cfg_done(struct e1000_hw *
                 msec_delay(1);
             timeout--;
         }
-
         if (!timeout) {
             DEBUGOUT("MNG configuration cycle has not completed.\n");
             return -E1000_ERR_RESET;
@@ -8188,8 +8040,9 @@ e1000_get_software_semaphore(struct e100
 
     DEBUGFUNC("e1000_get_software_semaphore");
 
-    if (hw->mac_type != e1000_80003es2lan)
+    if (hw->mac_type != e1000_80003es2lan) {
         return E1000_SUCCESS;
+    }
 
     while (timeout) {
         swsm = E1000_READ_REG(hw, SWSM);
@@ -8222,8 +8075,9 @@ e1000_release_software_semaphore(struct 
 
     DEBUGFUNC("e1000_release_software_semaphore");
 
-    if (hw->mac_type != e1000_80003es2lan)
+    if (hw->mac_type != e1000_80003es2lan) {
         return;
+    }
 
     swsm = E1000_READ_REG(hw, SWSM);
     /* Release the SW semaphores.*/
@@ -8257,7 +8111,7 @@ e1000_check_phy_reset_block(struct e1000
     if (hw->mac_type > e1000_82547_rev_2)
         manc = E1000_READ_REG(hw, MANC);
     return (manc & E1000_MANC_BLK_PHY_RST_ON_IDE) ?
-	    E1000_BLK_PHY_RESET : E1000_SUCCESS;
+        E1000_BLK_PHY_RESET : E1000_SUCCESS;
 }
 
 static uint8_t
@@ -8393,66 +8247,6 @@ e1000_release_software_flag(struct e1000
     return;
 }
 
-/***************************************************************************
- *
- * Disable dynamic power down mode in ife PHY.
- * It can be used to workaround band-gap problem.
- *
- * hw: Struct containing variables accessed by shared code
- *
- ***************************************************************************/
-#if 0
-int32_t
-e1000_ife_disable_dynamic_power_down(struct e1000_hw *hw)
-{
-    uint16_t phy_data;
-    int32_t ret_val = E1000_SUCCESS;
-
-    DEBUGFUNC("e1000_ife_disable_dynamic_power_down");
-
-    if (hw->phy_type == e1000_phy_ife) {
-        ret_val = e1000_read_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, &phy_data);
-        if (ret_val)
-            return ret_val;
-
-        phy_data |=  IFE_PSC_DISABLE_DYNAMIC_POWER_DOWN;
-        ret_val = e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, phy_data);
-    }
-
-    return ret_val;
-}
-#endif  /*  0  */
-
-/***************************************************************************
- *
- * Enable dynamic power down mode in ife PHY.
- * It can be used to workaround band-gap problem.
- *
- * hw: Struct containing variables accessed by shared code
- *
- ***************************************************************************/
-#if 0
-int32_t
-e1000_ife_enable_dynamic_power_down(struct e1000_hw *hw)
-{
-    uint16_t phy_data;
-    int32_t ret_val = E1000_SUCCESS;
-
-    DEBUGFUNC("e1000_ife_enable_dynamic_power_down");
-
-    if (hw->phy_type == e1000_phy_ife) {
-        ret_val = e1000_read_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, &phy_data);
-        if (ret_val)
-            return ret_val;
-
-        phy_data &=  ~IFE_PSC_DISABLE_DYNAMIC_POWER_DOWN;
-        ret_val = e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, phy_data);
-    }
-
-    return ret_val;
-}
-#endif  /*  0  */
-
 /******************************************************************************
  * Reads a 16 bit word or words from the EEPROM using the ICH8's flash access
  * register.
@@ -9015,44 +8809,6 @@ e1000_erase_ich8_4k_segment(struct e1000
     return error;
 }
 
-/******************************************************************************
- *
- * Reverse duplex setting without breaking the link.
- *
- * hw: Struct containing variables accessed by shared code
- *
- *****************************************************************************/
-#if 0
-int32_t
-e1000_duplex_reversal(struct e1000_hw *hw)
-{
-    int32_t ret_val;
-    uint16_t phy_data;
-
-    if (hw->phy_type != e1000_phy_igp_3)
-        return E1000_SUCCESS;
-
-    ret_val = e1000_read_phy_reg(hw, PHY_CTRL, &phy_data);
-    if (ret_val)
-        return ret_val;
-
-    phy_data ^= MII_CR_FULL_DUPLEX;
-
-    ret_val = e1000_write_phy_reg(hw, PHY_CTRL, phy_data);
-    if (ret_val)
-        return ret_val;
-
-    ret_val = e1000_read_phy_reg(hw, IGP3E1000_PHY_MISC_CTRL, &phy_data);
-    if (ret_val)
-        return ret_val;
-
-    phy_data |= IGP3_PHY_MISC_DUPLEX_MANUAL_SET;
-    ret_val = e1000_write_phy_reg(hw, IGP3E1000_PHY_MISC_CTRL, phy_data);
-
-    return ret_val;
-}
-#endif  /*  0  */
-
 static int32_t
 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
                                       uint32_t cnf_base_addr, uint32_t cnf_size)
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 488dcb0..5ca88a7 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -304,7 +304,7 @@ int32_t e1000_setup_link(struct e1000_hw
 int32_t e1000_phy_setup_autoneg(struct e1000_hw *hw);
 void e1000_config_collision_dist(struct e1000_hw *hw);
 int32_t e1000_check_for_link(struct e1000_hw *hw);
-int32_t e1000_get_speed_and_duplex(struct e1000_hw *hw, uint16_t * speed, uint16_t * duplex);
+int32_t e1000_get_speed_and_duplex(struct e1000_hw *hw, uint16_t *speed, uint16_t *duplex);
 int32_t e1000_force_mac_fc(struct e1000_hw *hw);
 
 /* PHY */
@@ -312,9 +312,9 @@ int32_t e1000_read_phy_reg(struct e1000_
 int32_t e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t data);
 int32_t e1000_phy_hw_reset(struct e1000_hw *hw);
 int32_t e1000_phy_reset(struct e1000_hw *hw);
-void e1000_phy_powerdown_workaround(struct e1000_hw *hw);
 int32_t e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 int32_t e1000_validate_mdi_setting(struct e1000_hw *hw);
+void e1000_phy_powerdown_workaround(struct e1000_hw *hw);
 
 /* EEPROM Functions */
 int32_t e1000_init_eeprom_params(struct e1000_hw *hw);
@@ -383,7 +383,6 @@ int32_t e1000_read_eeprom(struct e1000_h
 int32_t e1000_validate_eeprom_checksum(struct e1000_hw *hw);
 int32_t e1000_update_eeprom_checksum(struct e1000_hw *hw);
 int32_t e1000_write_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, uint16_t *data);
-int32_t e1000_read_part_num(struct e1000_hw *hw, uint32_t * part_num);
 int32_t e1000_read_mac_addr(struct e1000_hw * hw);
 
 /* Filters (multicast, vlan, receive) */
@@ -1603,16 +1602,17 @@ struct e1000_hw {
 #define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
 #define E1000_CTRL_EXT_LINK_MODE_GMII 0x00000000
 #define E1000_CTRL_EXT_LINK_MODE_TBI  0x00C00000
-#define E1000_CTRL_EXT_LINK_MODE_KMRN    0x00000000
+#define E1000_CTRL_EXT_LINK_MODE_KMRN 0x00000000
 #define E1000_CTRL_EXT_LINK_MODE_SERDES  0x00C00000
+#define E1000_CTRL_EXT_LINK_MODE_SGMII   0x00800000
 #define E1000_CTRL_EXT_WR_WMARK_MASK  0x03000000
 #define E1000_CTRL_EXT_WR_WMARK_256   0x00000000
 #define E1000_CTRL_EXT_WR_WMARK_320   0x01000000
 #define E1000_CTRL_EXT_WR_WMARK_384   0x02000000
 #define E1000_CTRL_EXT_WR_WMARK_448   0x03000000
-#define E1000_CTRL_EXT_DRV_LOAD       0x10000000  /* Driver loaded bit for FW */
-#define E1000_CTRL_EXT_IAME           0x08000000  /* Interrupt acknowledge Auto-mask */
-#define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000  /* Clear Interrupt timers after IMS clear */
+#define E1000_CTRL_EXT_DRV_LOAD       0x10000000 /* Driver loaded bit for FW */
+#define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowledge Auto-mask */
+#define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt timers after IMS clear */
 #define E1000_CRTL_EXT_PB_PAREN       0x01000000 /* packet buffer parity error detection enabled */
 #define E1000_CTRL_EXT_DF_PAREN       0x02000000 /* descriptor FIFO parity error detection enable */
 #define E1000_CTRL_EXT_GHOST_PAREN    0x40000000
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index dd01fdc..f3f3d38 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -109,16 +109,24 @@ static struct pci_device_id e1000_pci_tb
 
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
 
+int e1000_up(struct e1000_adapter *adapter);
+void e1000_down(struct e1000_adapter *adapter);
+void e1000_reinit_locked(struct e1000_adapter *adapter);
+void e1000_reset(struct e1000_adapter *adapter);
+int e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx);
+int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
+int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
+void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
+void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
 static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
-                                    struct e1000_tx_ring *txdr);
+                             struct e1000_tx_ring *txdr);
 static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
-                                    struct e1000_rx_ring *rxdr);
+                             struct e1000_rx_ring *rxdr);
 static void e1000_free_tx_resources(struct e1000_adapter *adapter,
-                                    struct e1000_tx_ring *tx_ring);
+                             struct e1000_tx_ring *tx_ring);
 static void e1000_free_rx_resources(struct e1000_adapter *adapter,
-                                    struct e1000_rx_ring *rx_ring);
-
-/* Local Function Prototypes */
+                             struct e1000_rx_ring *rx_ring);
+void e1000_update_stats(struct e1000_adapter *adapter);
 
 static int e1000_init_module(void);
 static void e1000_exit_module(void);
@@ -171,6 +179,7 @@ static void e1000_alloc_rx_buffers_ps(st
 static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
 static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			   int cmd);
+void e1000_set_ethtool_ops(struct net_device *netdev);
 static void e1000_enter_82542_rst(struct e1000_adapter *adapter);
 static void e1000_leave_82542_rst(struct e1000_adapter *adapter);
 static void e1000_tx_timeout(struct net_device *dev);
@@ -195,6 +204,8 @@ static void e1000_shutdown(struct pci_de
 static void e1000_netpoll (struct net_device *netdev);
 #endif
 
+extern void e1000_check_options(struct e1000_adapter *adapter);
+
 static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
                      pci_channel_state_t state);
 static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev);
@@ -4411,14 +4422,6 @@ e1000_write_pci_cfg(struct e1000_hw *hw,
 	pci_write_config_word(adapter->pdev, reg, *value);
 }
 
-#if 0
-uint32_t
-e1000_io_read(struct e1000_hw *hw, unsigned long port)
-{
-	return inl(port);
-}
-#endif  /*  0  */
-
 void
 e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
 {



---
Auke Kok <auke-jan.h.kok@intel.com>
