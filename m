From: akpm@osdl.org
Subject: [patch 9/9] drivers/net/e1000/: possible cleanups
Date: Thu, 06 Jul 2006 23:58:27 -0700
Message-ID: <200607070658.k676wSou030386@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bunk@stusta.de,
	auke-jan.h.kok@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:451 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751233AbWGGHBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 03:01:49 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

- make needlessly global functions static
- #if 0 the following unused global functions:
  - e1000_hw.c: e1000_mc_addr_list_update()
  - e1000_hw.c: e1000_read_reg_io()
  - e1000_hw.c: e1000_enable_pciex_master()
  - e1000_hw.c: e1000_ife_disable_dynamic_power_down()
  - e1000_hw.c: e1000_ife_enable_dynamic_power_down()
  - e1000_hw.c: e1000_write_ich8_word()
  - e1000_hw.c: e1000_duplex_reversal()
  - e1000_main.c: e1000_io_read()

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e1000/e1000_hw.c   |   89 ++++++++++++++++++++++---------
 drivers/net/e1000/e1000_hw.h   |   32 -----------
 drivers/net/e1000/e1000_main.c |    2 
 3 files changed, 67 insertions(+), 56 deletions(-)

diff -puN drivers/net/e1000/e1000_hw.c~drivers-net-e1000-possible-cleanups drivers/net/e1000/e1000_hw.c
--- a/drivers/net/e1000/e1000_hw.c~drivers-net-e1000-possible-cleanups
+++ a/drivers/net/e1000/e1000_hw.c
@@ -105,6 +105,33 @@ static int32_t e1000_configure_kmrn_for_
                                                uint16_t duplex);
 static int32_t e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
 
+static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw,
+					   uint32_t segment);
+static int32_t e1000_get_software_flag(struct e1000_hw *hw);
+static int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
+static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
+static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
+static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset,
+				      uint16_t words, uint16_t *data);
+static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index,
+				    uint8_t* data);
+static int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index,
+				    uint16_t *data);
+static int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr,
+				   uint16_t *data);
+static void e1000_release_software_flag(struct e1000_hw *hw);
+static void e1000_release_software_semaphore(struct e1000_hw *hw);
+static int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw,
+					 uint32_t no_snoop);
+static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw,
+					    uint32_t index, uint8_t byte);
+static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset,
+				       uint16_t words, uint16_t *data);
+static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index,
+				     uint8_t data);
+static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr,
+				    uint16_t data);
+
 /* IGP cable length table */
 static const
 uint16_t e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
@@ -3233,7 +3260,7 @@ e1000_shift_in_mdi_bits(struct e1000_hw 
     return data;
 }
 
-int32_t
+static int32_t
 e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask)
 {
     uint32_t swfw_sync = 0;
@@ -3277,7 +3304,7 @@ e1000_swfw_sync_acquire(struct e1000_hw 
     return E1000_SUCCESS;
 }
 
-void
+static void
 e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask)
 {
     uint32_t swfw_sync;
@@ -3575,7 +3602,7 @@ e1000_write_phy_reg_ex(struct e1000_hw *
     return E1000_SUCCESS;
 }
 
-int32_t
+static int32_t
 e1000_read_kmrn_reg(struct e1000_hw *hw,
                     uint32_t reg_addr,
                     uint16_t *data)
@@ -3608,7 +3635,7 @@ e1000_read_kmrn_reg(struct e1000_hw *hw,
     return E1000_SUCCESS;
 }
 
-int32_t
+static int32_t
 e1000_write_kmrn_reg(struct e1000_hw *hw,
                      uint32_t reg_addr,
                      uint16_t data)
@@ -3839,7 +3866,7 @@ e1000_phy_powerdown_workaround(struct e1
 *
 * hw - struct containing variables accessed by shared code
 ******************************************************************************/
-int32_t
+static int32_t
 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
 {
     int32_t ret_val;
@@ -4086,7 +4113,7 @@ e1000_phy_igp_get_info(struct e1000_hw *
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-int32_t
+static int32_t
 e1000_phy_ife_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
@@ -5643,6 +5670,7 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
  * for the first 15 multicast addresses, and hashes the rest into the
  * multicast table.
  *****************************************************************************/
+#if 0
 void
 e1000_mc_addr_list_update(struct e1000_hw *hw,
                           uint8_t *mc_addr_list,
@@ -5719,6 +5747,7 @@ e1000_mc_addr_list_update(struct e1000_h
     }
     DEBUGOUT("MC Update Complete\n");
 }
+#endif  /*  0  */
 
 /******************************************************************************
  * Hashes an address to determine its location in the multicast table
@@ -6587,6 +6616,7 @@ e1000_get_bus_info(struct e1000_hw *hw)
  * hw - Struct containing variables accessed by shared code
  * offset - offset to read from
  *****************************************************************************/
+#if 0
 uint32_t
 e1000_read_reg_io(struct e1000_hw *hw,
                   uint32_t offset)
@@ -6597,6 +6627,7 @@ e1000_read_reg_io(struct e1000_hw *hw,
     e1000_io_write(hw, io_addr, offset);
     return e1000_io_read(hw, io_data);
 }
+#endif  /*  0  */
 
 /******************************************************************************
  * Writes a value to one of the devices registers using port I/O (as opposed to
@@ -7909,6 +7940,7 @@ e1000_set_pci_express_master_disable(str
  * returns: - none.
  *
  ***************************************************************************/
+#if 0
 void
 e1000_enable_pciex_master(struct e1000_hw *hw)
 {
@@ -7923,6 +7955,7 @@ e1000_enable_pciex_master(struct e1000_h
     ctrl &= ~E1000_CTRL_GIO_MASTER_DISABLE;
     E1000_WRITE_REG(hw, CTRL, ctrl);
 }
+#endif  /*  0  */
 
 /*******************************************************************************
  *
@@ -8148,7 +8181,7 @@ e1000_put_hw_eeprom_semaphore(struct e10
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-int32_t
+static int32_t
 e1000_get_software_semaphore(struct e1000_hw *hw)
 {
     int32_t timeout = hw->eeprom.word_size + 1;
@@ -8183,7 +8216,7 @@ e1000_get_software_semaphore(struct e100
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
-void
+static void
 e1000_release_software_semaphore(struct e1000_hw *hw)
 {
     uint32_t swsm;
@@ -8265,7 +8298,7 @@ e1000_arc_subsystem_valid(struct e1000_h
  * returns: E1000_SUCCESS
  *
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop)
 {
     uint32_t gcr_reg = 0;
@@ -8306,7 +8339,7 @@ e1000_set_pci_ex_no_snoop(struct e1000_h
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
-int32_t
+static int32_t
 e1000_get_software_flag(struct e1000_hw *hw)
 {
     int32_t timeout = PHY_CFG_TIMEOUT;
@@ -8345,7 +8378,7 @@ e1000_get_software_flag(struct e1000_hw 
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
-void
+static void
 e1000_release_software_flag(struct e1000_hw *hw)
 {
     uint32_t extcnf_ctrl;
@@ -8369,6 +8402,7 @@ e1000_release_software_flag(struct e1000
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
+#if 0
 int32_t
 e1000_ife_disable_dynamic_power_down(struct e1000_hw *hw)
 {
@@ -8388,6 +8422,7 @@ e1000_ife_disable_dynamic_power_down(str
 
     return ret_val;
 }
+#endif  /*  0  */
 
 /***************************************************************************
  *
@@ -8397,6 +8432,7 @@ e1000_ife_disable_dynamic_power_down(str
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
+#if 0
 int32_t
 e1000_ife_enable_dynamic_power_down(struct e1000_hw *hw)
 {
@@ -8416,6 +8452,7 @@ e1000_ife_enable_dynamic_power_down(stru
 
     return ret_val;
 }
+#endif  /*  0  */
 
 /******************************************************************************
  * Reads a 16 bit word or words from the EEPROM using the ICH8's flash access
@@ -8426,7 +8463,7 @@ e1000_ife_enable_dynamic_power_down(stru
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
                        uint16_t *data)
 {
@@ -8482,7 +8519,7 @@ e1000_read_eeprom_ich8(struct e1000_hw *
  * words - number of words to write
  * data - words to write to the EEPROM
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
                         uint16_t *data)
 {
@@ -8529,7 +8566,7 @@ e1000_write_eeprom_ich8(struct e1000_hw 
  *
  * hw - The pointer to the hw structure
  ****************************************************************************/
-int32_t
+static int32_t
 e1000_ich8_cycle_init(struct e1000_hw *hw)
 {
     union ich8_hws_flash_status hsfsts;
@@ -8596,7 +8633,7 @@ e1000_ich8_cycle_init(struct e1000_hw *h
  *
  * hw - The pointer to the hw structure
  ****************************************************************************/
-int32_t
+static int32_t
 e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout)
 {
     union ich8_hws_flash_ctrl hsflctl;
@@ -8631,7 +8668,7 @@ e1000_ich8_flash_cycle(struct e1000_hw *
  * size - Size of data to read, 1=byte 2=word
  * data - Pointer to the word to store the value read.
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
                      uint32_t size, uint16_t* data)
 {
@@ -8710,7 +8747,7 @@ e1000_read_ich8_data(struct e1000_hw *hw
  * size - Size of data to read, 1=byte 2=word
  * data - The byte(s) to write to the NVM.
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
                       uint16_t data)
 {
@@ -8785,7 +8822,7 @@ e1000_write_ich8_data(struct e1000_hw *h
  * index - The index of the byte to read.
  * data - Pointer to a byte to store the value read.
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t* data)
 {
     int32_t status = E1000_SUCCESS;
@@ -8808,7 +8845,7 @@ e1000_read_ich8_byte(struct e1000_hw *hw
  * index - The index of the byte to write.
  * byte - The byte to write to the NVM.
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte)
 {
     int32_t error = E1000_SUCCESS;
@@ -8839,7 +8876,7 @@ e1000_verify_write_ich8_byte(struct e100
  * index - The index of the byte to read.
  * data - The byte to write to the NVM.
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t data)
 {
     int32_t status = E1000_SUCCESS;
@@ -8857,7 +8894,7 @@ e1000_write_ich8_byte(struct e1000_hw *h
  * index - The starting byte index of the word to read.
  * data - Pointer to a word to store the value read.
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data)
 {
     int32_t status = E1000_SUCCESS;
@@ -8872,6 +8909,7 @@ e1000_read_ich8_word(struct e1000_hw *hw
  * index - The starting byte index of the word to read.
  * data - The word to write to the NVM.
  *****************************************************************************/
+#if 0
 int32_t
 e1000_write_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t data)
 {
@@ -8879,6 +8917,7 @@ e1000_write_ich8_word(struct e1000_hw *h
     status = e1000_write_ich8_data(hw, index, 2, data);
     return status;
 }
+#endif  /*  0  */
 
 /******************************************************************************
  * Erases the bank specified. Each bank is a 4k block. Segments are 0 based.
@@ -8887,7 +8926,7 @@ e1000_write_ich8_word(struct e1000_hw *h
  * hw - pointer to e1000_hw structure
  * segment - 0 for first segment, 1 for second segment, etc.
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t segment)
 {
     union ich8_hws_flash_status hsfsts;
@@ -8984,6 +9023,7 @@ e1000_erase_ich8_4k_segment(struct e1000
  * hw: Struct containing variables accessed by shared code
  *
  *****************************************************************************/
+#if 0
 int32_t
 e1000_duplex_reversal(struct e1000_hw *hw)
 {
@@ -9012,8 +9052,9 @@ e1000_duplex_reversal(struct e1000_hw *h
 
     return ret_val;
 }
+#endif  /*  0  */
 
-int32_t
+static int32_t
 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
                                       uint32_t cnf_base_addr, uint32_t cnf_size)
 {
@@ -9047,7 +9088,7 @@ e1000_init_lcd_from_nvm_config_region(st
 }
 
 
-int32_t
+static int32_t
 e1000_init_lcd_from_nvm(struct e1000_hw *hw)
 {
     uint32_t reg_data, cnf_base_addr, cnf_size, ret_val, loop;
diff -puN drivers/net/e1000/e1000_hw.h~drivers-net-e1000-possible-cleanups drivers/net/e1000/e1000_hw.h
--- a/drivers/net/e1000/e1000_hw.h~drivers-net-e1000-possible-cleanups
+++ a/drivers/net/e1000/e1000_hw.h
@@ -323,13 +323,8 @@ int32_t e1000_write_phy_reg(struct e1000
 int32_t e1000_phy_hw_reset(struct e1000_hw *hw);
 int32_t e1000_phy_reset(struct e1000_hw *hw);
 void e1000_phy_powerdown_workaround(struct e1000_hw *hw);
-int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
-int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32_t cnf_base_addr, uint32_t cnf_size);
-int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 int32_t e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 int32_t e1000_validate_mdi_setting(struct e1000_hw *hw);
-int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t *data);
-int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t data);
 
 /* EEPROM Functions */
 int32_t e1000_init_eeprom_params(struct e1000_hw *hw);
@@ -400,13 +395,8 @@ int32_t e1000_update_eeprom_checksum(str
 int32_t e1000_write_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, uint16_t *data);
 int32_t e1000_read_part_num(struct e1000_hw *hw, uint32_t * part_num);
 int32_t e1000_read_mac_addr(struct e1000_hw * hw);
-int32_t e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask);
-void e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask);
-void e1000_release_software_flag(struct e1000_hw *hw);
-int32_t e1000_get_software_flag(struct e1000_hw *hw);
 
 /* Filters (multicast, vlan, receive) */
-void e1000_mc_addr_list_update(struct e1000_hw *hw, uint8_t * mc_addr_list, uint32_t mc_addr_count, uint32_t pad, uint32_t rar_used_count);
 uint32_t e1000_hash_mc_addr(struct e1000_hw *hw, uint8_t * mc_addr);
 void e1000_mta_set(struct e1000_hw *hw, uint32_t hash_value);
 void e1000_rar_set(struct e1000_hw *hw, uint8_t * mc_addr, uint32_t rar_index);
@@ -431,31 +421,9 @@ void e1000_pci_clear_mwi(struct e1000_hw
 void e1000_read_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
 void e1000_write_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
 /* Port I/O is only supported on 82544 and newer */
-uint32_t e1000_io_read(struct e1000_hw *hw, unsigned long port);
-uint32_t e1000_read_reg_io(struct e1000_hw *hw, uint32_t offset);
 void e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value);
-void e1000_enable_pciex_master(struct e1000_hw *hw);
 int32_t e1000_disable_pciex_master(struct e1000_hw *hw);
-int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
-void e1000_release_software_semaphore(struct e1000_hw *hw);
 int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
-int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop);
-
-int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index,
-                             uint8_t *data);
-int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index,
-                                     uint8_t byte);
-int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index,
-                              uint8_t byte);
-int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index,
-                             uint16_t *data);
-int32_t e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
-                             uint32_t size, uint16_t *data);
-int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset,
-                               uint16_t words, uint16_t *data);
-int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset,
-                                uint16_t words, uint16_t *data);
-int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t segment);
 
 
 #define E1000_READ_REG_IO(a, reg) \
diff -puN drivers/net/e1000/e1000_main.c~drivers-net-e1000-possible-cleanups drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c~drivers-net-e1000-possible-cleanups
+++ a/drivers/net/e1000/e1000_main.c
@@ -4387,11 +4387,13 @@ e1000_write_pci_cfg(struct e1000_hw *hw,
 	pci_write_config_word(adapter->pdev, reg, *value);
 }
 
+#if 0
 uint32_t
 e1000_io_read(struct e1000_hw *hw, unsigned long port)
 {
 	return inl(port);
 }
+#endif  /*  0  */
 
 void
 e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
_
