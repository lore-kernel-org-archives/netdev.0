From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/6] drivers/net/e1000 - Convert u_int8_t to u8
Date: Tue, 18 Mar 2008 09:13:44 -0700
Message-ID: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
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
 drivers/net/e1000/e1000.h         |    4 +-
 drivers/net/e1000/e1000_ethtool.c |   18 ++++----
 drivers/net/e1000/e1000_hw.c      |   90 ++++++++++++++++++------------------
 drivers/net/e1000/e1000_hw.h      |   94 ++++++++++++++++++------------------
 drivers/net/e1000/e1000_main.c    |   18 ++++----
 5 files changed, 112 insertions(+), 112 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a05aa51..4522896 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -260,7 +260,7 @@ struct e1000_adapter {
 	uint16_t rx_itr;
 
 	struct work_struct reset_task;
-	uint8_t fc_autoneg;
+	u8 fc_autoneg;
 
 	struct timer_list blink_timer;
 	unsigned long led_status;
@@ -280,7 +280,7 @@ struct e1000_adapter {
 	uint32_t tx_fifo_head;
 	uint32_t tx_head_addr;
 	uint32_t tx_fifo_size;
-	uint8_t  tx_timeout_factor;
+	u8  tx_timeout_factor;
 	atomic_t tx_fifo_stall;
 	bool pcix_82544;
 	bool detect_tx_hung;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 05e1fb3..20b1e1b 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -477,7 +477,7 @@ e1000_get_eeprom_len(struct net_device *netdev)
 
 static int
 e1000_get_eeprom(struct net_device *netdev,
-                      struct ethtool_eeprom *eeprom, uint8_t *bytes)
+                      struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -514,7 +514,7 @@ e1000_get_eeprom(struct net_device *netdev,
 	for (i = 0; i < last_word - first_word + 1; i++)
 		le16_to_cpus(&eeprom_buff[i]);
 
-	memcpy(bytes, (uint8_t *)eeprom_buff + (eeprom->offset & 1),
+	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1),
 			eeprom->len);
 	kfree(eeprom_buff);
 
@@ -523,7 +523,7 @@ e1000_get_eeprom(struct net_device *netdev,
 
 static int
 e1000_set_eeprom(struct net_device *netdev,
-                      struct ethtool_eeprom *eeprom, uint8_t *bytes)
+                      struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -733,7 +733,7 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, uint64_t *data,
 {
 	static const uint32_t test[] =
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
-	uint8_t __iomem *address = adapter->hw.hw_addr + reg;
+	u8 __iomem *address = adapter->hw.hw_addr + reg;
 	uint32_t read;
 	int i;
 
@@ -754,7 +754,7 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, uint64_t *data,
 static bool reg_set_and_check(struct e1000_adapter *adapter, uint64_t *data,
 			      int reg, uint32_t mask, uint32_t write)
 {
-	uint8_t __iomem *address = adapter->hw.hw_addr + reg;
+	u8 __iomem *address = adapter->hw.hw_addr + reg;
 	uint32_t read;
 
 	writel(write & mask, address);
@@ -1658,8 +1658,8 @@ e1000_diag_test(struct net_device *netdev,
 
 		/* save speed, duplex, autoneg settings */
 		uint16_t autoneg_advertised = adapter->hw.autoneg_advertised;
-		uint8_t forced_speed_duplex = adapter->hw.forced_speed_duplex;
-		uint8_t autoneg = adapter->hw.autoneg;
+		u8 forced_speed_duplex = adapter->hw.forced_speed_duplex;
+		u8 autoneg = adapter->hw.autoneg;
 
 		DPRINTK(HW, INFO, "offline testing starting\n");
 
@@ -1942,9 +1942,9 @@ e1000_get_ethtool_stats(struct net_device *netdev,
 }
 
 static void
-e1000_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+e1000_get_strings(struct net_device *netdev, uint32_t stringset, u8 *data)
 {
-	uint8_t *p = data;
+	u8 *p = data;
 	int i;
 
 	switch (stringset) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index b642034..91ce084 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -40,7 +40,7 @@ static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint
 static int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
 static void e1000_release_software_semaphore(struct e1000_hw *hw);
 
-static uint8_t e1000_arc_subsystem_valid(struct e1000_hw *hw);
+static u8 e1000_arc_subsystem_valid(struct e1000_hw *hw);
 static int32_t e1000_check_downshift(struct e1000_hw *hw);
 static int32_t e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *polarity);
 static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
@@ -66,7 +66,7 @@ static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
 static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
 static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
 static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
-static int32_t e1000_mng_host_if_write(struct e1000_hw *hw, uint8_t *buffer, uint16_t length, uint16_t offset, uint8_t *sum);
+static int32_t e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, uint16_t length, uint16_t offset, u8 *sum);
 static int32_t e1000_mng_write_cmd_header(struct e1000_hw* hw, struct e1000_host_mng_command_header* hdr);
 static int32_t e1000_mng_write_commit(struct e1000_hw *hw);
 static int32_t e1000_phy_ife_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
@@ -76,9 +76,9 @@ static int32_t e1000_write_eeprom_eewr(struct e1000_hw *hw, uint16_t offset, uin
 static int32_t e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
 static int32_t e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
-static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t *data);
-static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte);
-static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte);
+static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 *data);
+static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 byte);
+static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 byte);
 static int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data);
 static int32_t e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, uint16_t *data);
 static int32_t e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, uint16_t data);
@@ -125,8 +125,8 @@ static void e1000_standby_eeprom(struct e1000_hw *hw);
 static int32_t e1000_set_vco_speed(struct e1000_hw *hw);
 static int32_t e1000_polarity_reversal_workaround(struct e1000_hw *hw);
 static int32_t e1000_set_phy_mode(struct e1000_hw *hw);
-static int32_t e1000_host_if_read_cookie(struct e1000_hw *hw, uint8_t *buffer);
-static uint8_t e1000_calculate_mng_checksum(char *buffer, uint32_t length);
+static int32_t e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer);
+static u8 e1000_calculate_mng_checksum(char *buffer, uint32_t length);
 static int32_t e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
                                                uint16_t duplex);
 static int32_t e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
@@ -3343,7 +3343,7 @@ e1000_shift_in_mdi_bits(struct e1000_hw *hw)
 {
     uint32_t ctrl;
     uint16_t data = 0;
-    uint8_t i;
+    u8 i;
 
     /* In order to read a register from the PHY, we need to shift in a total
      * of 18 bits from the PHY. The first two bit (turnaround) times are used
@@ -4925,7 +4925,7 @@ static int32_t
 e1000_spi_eeprom_ready(struct e1000_hw *hw)
 {
     uint16_t retry_count = 0;
-    uint8_t spi_stat_reg;
+    u8 spi_stat_reg;
 
     DEBUGFUNC("e1000_spi_eeprom_ready");
 
@@ -4938,7 +4938,7 @@ e1000_spi_eeprom_ready(struct e1000_hw *hw)
     do {
         e1000_shift_out_ee_bits(hw, EEPROM_RDSR_OPCODE_SPI,
                                 hw->eeprom.opcode_bits);
-        spi_stat_reg = (uint8_t)e1000_shift_in_ee_bits(hw, 8);
+        spi_stat_reg = (u8)e1000_shift_in_ee_bits(hw, 8);
         if (!(spi_stat_reg & EEPROM_STATUS_RDY_SPI))
             break;
 
@@ -5013,7 +5013,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
      * acquired the EEPROM at this point, so any returns should relase it */
     if (eeprom->type == e1000_eeprom_spi) {
         uint16_t word_in;
-        uint8_t read_opcode = EEPROM_READ_OPCODE_SPI;
+        u8 read_opcode = EEPROM_READ_OPCODE_SPI;
 
         if (e1000_spi_eeprom_ready(hw)) {
             e1000_release_eeprom(hw);
@@ -5382,7 +5382,7 @@ e1000_write_eeprom_spi(struct e1000_hw *hw,
     DEBUGFUNC("e1000_write_eeprom_spi");
 
     while (widx < words) {
-        uint8_t write_opcode = EEPROM_WRITE_OPCODE_SPI;
+        u8 write_opcode = EEPROM_WRITE_OPCODE_SPI;
 
         if (e1000_spi_eeprom_ready(hw)) return -E1000_ERR_EEPROM;
 
@@ -5533,8 +5533,8 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
     int32_t error = E1000_SUCCESS;
     uint32_t old_bank_offset = 0;
     uint32_t new_bank_offset = 0;
-    uint8_t low_byte = 0;
-    uint8_t high_byte = 0;
+    u8 low_byte = 0;
+    u8 high_byte = 0;
     bool sector_write_failed = false;
 
     if (hw->mac_type == e1000_82573) {
@@ -5595,7 +5595,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
              * in the other NVM bank or a modified value stored
              * in the shadow RAM */
             if (hw->eeprom_shadow_ram[i].modified) {
-                low_byte = (uint8_t)hw->eeprom_shadow_ram[i].eeprom_word;
+                low_byte = (u8)hw->eeprom_shadow_ram[i].eeprom_word;
                 udelay(100);
                 error = e1000_verify_write_ich8_byte(hw,
                             (i << 1) + new_bank_offset, low_byte);
@@ -5604,7 +5604,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
                     sector_write_failed = true;
                 else {
                     high_byte =
-                        (uint8_t)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
+                        (u8)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
                     udelay(100);
                 }
             } else {
@@ -5701,8 +5701,8 @@ e1000_read_mac_addr(struct e1000_hw * hw)
             DEBUGOUT("EEPROM Read Error\n");
             return -E1000_ERR_EEPROM;
         }
-        hw->perm_mac_addr[i] = (uint8_t) (eeprom_data & 0x00FF);
-        hw->perm_mac_addr[i+1] = (uint8_t) (eeprom_data >> 8);
+        hw->perm_mac_addr[i] = (u8) (eeprom_data & 0x00FF);
+        hw->perm_mac_addr[i+1] = (u8) (eeprom_data >> 8);
     }
 
     switch (hw->mac_type) {
@@ -5772,7 +5772,7 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
  *****************************************************************************/
 uint32_t
 e1000_hash_mc_addr(struct e1000_hw *hw,
-                   uint8_t *mc_addr)
+                   u8 *mc_addr)
 {
     uint32_t hash_value = 0;
 
@@ -5886,7 +5886,7 @@ e1000_mta_set(struct e1000_hw *hw,
  *****************************************************************************/
 void
 e1000_rar_set(struct e1000_hw *hw,
-              uint8_t *addr,
+              u8 *addr,
               uint32_t index)
 {
     uint32_t rar_low, rar_high;
@@ -6496,7 +6496,7 @@ void
 e1000_tbi_adjust_stats(struct e1000_hw *hw,
                        struct e1000_hw_stats *stats,
                        uint32_t frame_len,
-                       uint8_t *mac_addr)
+                       u8 *mac_addr)
 {
     uint64_t carry_bit;
 
@@ -6527,7 +6527,7 @@ e1000_tbi_adjust_stats(struct e1000_hw *hw,
      * since the test for a multicast frame will test positive on
      * a broadcast frame.
      */
-    if ((mac_addr[0] == (uint8_t) 0xff) && (mac_addr[1] == (uint8_t) 0xff))
+    if ((mac_addr[0] == (u8) 0xff) && (mac_addr[1] == (u8) 0xff))
         /* Broadcast packet */
         stats->bprc++;
     else if (*mac_addr & 0x01)
@@ -7504,11 +7504,11 @@ e1000_set_vco_speed(struct e1000_hw *hw)
  * returns: - E1000_SUCCESS .
  ****************************************************************************/
 static int32_t
-e1000_host_if_read_cookie(struct e1000_hw * hw, uint8_t *buffer)
+e1000_host_if_read_cookie(struct e1000_hw * hw, u8 *buffer)
 {
-    uint8_t i;
+    u8 i;
     uint32_t offset = E1000_MNG_DHCP_COOKIE_OFFSET;
-    uint8_t length = E1000_MNG_DHCP_COOKIE_LENGTH;
+    u8 length = E1000_MNG_DHCP_COOKIE_LENGTH;
 
     length = (length >> 2);
     offset = (offset >> 2);
@@ -7534,7 +7534,7 @@ static int32_t
 e1000_mng_enable_host_if(struct e1000_hw * hw)
 {
     uint32_t hicr;
-    uint8_t i;
+    u8 i;
 
     /* Check that the host interface is enabled. */
     hicr = E1000_READ_REG(hw, HICR);
@@ -7565,11 +7565,11 @@ e1000_mng_enable_host_if(struct e1000_hw * hw)
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
 static int32_t
-e1000_mng_host_if_write(struct e1000_hw * hw, uint8_t *buffer,
-                        uint16_t length, uint16_t offset, uint8_t *sum)
+e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
+                        uint16_t length, uint16_t offset, u8 *sum)
 {
-    uint8_t *tmp;
-    uint8_t *bufptr = buffer;
+    u8 *tmp;
+    u8 *bufptr = buffer;
     uint32_t data = 0;
     uint16_t remaining, i, j, prev_bytes;
 
@@ -7579,7 +7579,7 @@ e1000_mng_host_if_write(struct e1000_hw * hw, uint8_t *buffer,
         return -E1000_ERR_PARAM;
     }
 
-    tmp = (uint8_t *)&data;
+    tmp = (u8 *)&data;
     prev_bytes = offset & 0x3;
     offset &= 0xFFFC;
     offset >>= 2;
@@ -7637,8 +7637,8 @@ e1000_mng_write_cmd_header(struct e1000_hw * hw,
                            struct e1000_host_mng_command_header * hdr)
 {
     uint16_t i;
-    uint8_t sum;
-    uint8_t *buffer;
+    u8 sum;
+    u8 *buffer;
 
     /* Write the whole command header structure which includes sum of
      * the buffer */
@@ -7648,7 +7648,7 @@ e1000_mng_write_cmd_header(struct e1000_hw * hw,
     sum = hdr->checksum;
     hdr->checksum = 0;
 
-    buffer = (uint8_t *) hdr;
+    buffer = (u8 *) hdr;
     i = length;
     while (i--)
         sum += buffer[i];
@@ -7713,7 +7713,7 @@ e1000_check_mng_mode(struct e1000_hw *hw)
  * This function writes the dhcp info .
  ****************************************************************************/
 int32_t
-e1000_mng_write_dhcp_info(struct e1000_hw * hw, uint8_t *buffer,
+e1000_mng_write_dhcp_info(struct e1000_hw * hw, u8 *buffer,
                           uint16_t length)
 {
     int32_t ret_val;
@@ -7744,10 +7744,10 @@ e1000_mng_write_dhcp_info(struct e1000_hw * hw, uint8_t *buffer,
  *
  * returns  - checksum of buffer contents.
  ****************************************************************************/
-static uint8_t
+static u8
 e1000_calculate_mng_checksum(char *buffer, uint32_t length)
 {
-    uint8_t sum = 0;
+    u8 sum = 0;
     uint32_t i;
 
     if (!buffer)
@@ -7756,7 +7756,7 @@ e1000_calculate_mng_checksum(char *buffer, uint32_t length)
     for (i=0; i < length; i++)
         sum += buffer[i];
 
-    return (uint8_t) (0 - sum);
+    return (u8) (0 - sum);
 }
 
 /*****************************************************************************
@@ -7772,7 +7772,7 @@ e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
     int32_t ret_val, checksum;
     bool tx_filter = false;
     struct e1000_host_mng_dhcp_cookie *hdr = &(hw->mng_cookie);
-    uint8_t *buffer = (uint8_t *) &(hw->mng_cookie);
+    u8 *buffer = (u8 *) &(hw->mng_cookie);
 
     if (e1000_check_mng_mode(hw)) {
         ret_val = e1000_mng_enable_host_if(hw);
@@ -8246,7 +8246,7 @@ e1000_check_phy_reset_block(struct e1000_hw *hw)
         E1000_BLK_PHY_RESET : E1000_SUCCESS;
 }
 
-static uint8_t
+static u8
 e1000_arc_subsystem_valid(struct e1000_hw *hw)
 {
     uint32_t fwsm;
@@ -8640,7 +8640,7 @@ e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
         if (error == E1000_SUCCESS) {
             flash_data = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_FDATA0);
             if (size == 1) {
-                *data = (uint8_t)(flash_data & 0x000000FF);
+                *data = (u8)(flash_data & 0x000000FF);
             } else if (size == 2) {
                 *data = (uint16_t)(flash_data & 0x0000FFFF);
             }
@@ -8748,14 +8748,14 @@ e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
  * data - Pointer to a byte to store the value read.
  *****************************************************************************/
 static int32_t
-e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t* data)
+e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, u8* data)
 {
     int32_t status = E1000_SUCCESS;
     uint16_t word = 0;
 
     status = e1000_read_ich8_data(hw, index, 1, &word);
     if (status == E1000_SUCCESS) {
-        *data = (uint8_t)word;
+        *data = (u8)word;
     }
 
     return status;
@@ -8771,7 +8771,7 @@ e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t* data)
  * byte - The byte to write to the NVM.
  *****************************************************************************/
 static int32_t
-e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte)
+e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 byte)
 {
     int32_t error = E1000_SUCCESS;
     int32_t program_retries = 0;
@@ -8804,7 +8804,7 @@ e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte)
  * data - The byte to write to the NVM.
  *****************************************************************************/
 static int32_t
-e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t data)
+e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 data)
 {
     int32_t status = E1000_SUCCESS;
     uint16_t word = (uint16_t)data;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 572a7b6..4d02ac9 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -354,8 +354,8 @@ uint32_t e1000_enable_mng_pass_thru(struct e1000_hw *hw);
 #define E1000_VFTA_ENTRY_BIT_SHIFT_MASK              0x1F
 
 struct e1000_host_mng_command_header {
-    uint8_t command_id;
-    uint8_t checksum;
+    u8 command_id;
+    u8 checksum;
     uint16_t reserved1;
     uint16_t reserved2;
     uint16_t command_length;
@@ -363,33 +363,33 @@ struct e1000_host_mng_command_header {
 
 struct e1000_host_mng_command_info {
     struct e1000_host_mng_command_header command_header;  /* Command Head/Command Result Head has 4 bytes */
-    uint8_t command_data[E1000_HI_MAX_MNG_DATA_LENGTH];   /* Command data can length 0..0x658*/
+    u8 command_data[E1000_HI_MAX_MNG_DATA_LENGTH];   /* Command data can length 0..0x658*/
 };
 #ifdef __BIG_ENDIAN
 struct e1000_host_mng_dhcp_cookie{
     uint32_t signature;
     uint16_t vlan_id;
-    uint8_t reserved0;
-    uint8_t status;
+    u8 reserved0;
+    u8 status;
     uint32_t reserved1;
-    uint8_t checksum;
-    uint8_t reserved3;
+    u8 checksum;
+    u8 reserved3;
     uint16_t reserved2;
 };
 #else
 struct e1000_host_mng_dhcp_cookie{
     uint32_t signature;
-    uint8_t status;
-    uint8_t reserved0;
+    u8 status;
+    u8 reserved0;
     uint16_t vlan_id;
     uint32_t reserved1;
     uint16_t reserved2;
-    uint8_t reserved3;
-    uint8_t checksum;
+    u8 reserved3;
+    u8 checksum;
 };
 #endif
 
-int32_t e1000_mng_write_dhcp_info(struct e1000_hw *hw, uint8_t *buffer,
+int32_t e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer,
                                   uint16_t length);
 bool e1000_check_mng_mode(struct e1000_hw *hw);
 bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
@@ -400,9 +400,9 @@ int32_t e1000_write_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, ui
 int32_t e1000_read_mac_addr(struct e1000_hw * hw);
 
 /* Filters (multicast, vlan, receive) */
-uint32_t e1000_hash_mc_addr(struct e1000_hw *hw, uint8_t * mc_addr);
+uint32_t e1000_hash_mc_addr(struct e1000_hw *hw, u8 * mc_addr);
 void e1000_mta_set(struct e1000_hw *hw, uint32_t hash_value);
-void e1000_rar_set(struct e1000_hw *hw, uint8_t * mc_addr, uint32_t rar_index);
+void e1000_rar_set(struct e1000_hw *hw, u8 * mc_addr, uint32_t rar_index);
 void e1000_write_vfta(struct e1000_hw *hw, uint32_t offset, uint32_t value);
 
 /* LED functions */
@@ -417,7 +417,7 @@ int32_t e1000_blink_led_start(struct e1000_hw *hw);
 /* Everything else */
 void e1000_reset_adaptive(struct e1000_hw *hw);
 void e1000_update_adaptive(struct e1000_hw *hw);
-void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats, uint32_t frame_len, uint8_t * mac_addr);
+void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats, uint32_t frame_len, u8 * mac_addr);
 void e1000_get_bus_info(struct e1000_hw *hw);
 void e1000_pci_set_mwi(struct e1000_hw *hw);
 void e1000_pci_clear_mwi(struct e1000_hw *hw);
@@ -596,8 +596,8 @@ struct e1000_rx_desc {
     __le64 buffer_addr; /* Address of the descriptor's data buffer */
     __le16 length;     /* Length of data DMAed into data buffer */
     __le16 csum;       /* Packet checksum */
-    uint8_t status;      /* Descriptor status */
-    uint8_t errors;      /* Descriptor Errors */
+    u8 status;      /* Descriptor status */
+    u8 errors;      /* Descriptor Errors */
     __le16 special;
 };
 
@@ -718,15 +718,15 @@ struct e1000_tx_desc {
         __le32 data;
         struct {
             __le16 length;    /* Data buffer length */
-            uint8_t cso;        /* Checksum offset */
-            uint8_t cmd;        /* Descriptor control */
+            u8 cso;        /* Checksum offset */
+            u8 cmd;        /* Descriptor control */
         } flags;
     } lower;
     union {
         __le32 data;
         struct {
-            uint8_t status;     /* Descriptor status */
-            uint8_t css;        /* Checksum start */
+            u8 status;     /* Descriptor status */
+            u8 css;        /* Checksum start */
             __le16 special;
         } fields;
     } upper;
@@ -759,16 +759,16 @@ struct e1000_context_desc {
     union {
         __le32 ip_config;
         struct {
-            uint8_t ipcss;      /* IP checksum start */
-            uint8_t ipcso;      /* IP checksum offset */
+            u8 ipcss;      /* IP checksum start */
+            u8 ipcso;      /* IP checksum offset */
             __le16 ipcse;     /* IP checksum end */
         } ip_fields;
     } lower_setup;
     union {
         __le32 tcp_config;
         struct {
-            uint8_t tucss;      /* TCP checksum start */
-            uint8_t tucso;      /* TCP checksum offset */
+            u8 tucss;      /* TCP checksum start */
+            u8 tucso;      /* TCP checksum offset */
             __le16 tucse;     /* TCP checksum end */
         } tcp_fields;
     } upper_setup;
@@ -776,8 +776,8 @@ struct e1000_context_desc {
     union {
         __le32 data;
         struct {
-            uint8_t status;     /* Descriptor status */
-            uint8_t hdr_len;    /* Header length */
+            u8 status;     /* Descriptor status */
+            u8 hdr_len;    /* Header length */
             __le16 mss;       /* Maximum segment size */
         } fields;
     } tcp_seg_setup;
@@ -790,15 +790,15 @@ struct e1000_data_desc {
         __le32 data;
         struct {
             __le16 length;    /* Data buffer length */
-            uint8_t typ_len_ext;        /* */
-            uint8_t cmd;        /* */
+            u8 typ_len_ext;        /* */
+            u8 cmd;        /* */
         } flags;
     } lower;
     union {
         __le32 data;
         struct {
-            uint8_t status;     /* Descriptor status */
-            uint8_t popts;      /* Packet Options */
+            u8 status;     /* Descriptor status */
+            u8 popts;      /* Packet Options */
             __le16 special;   /* */
         } fields;
     } upper;
@@ -837,7 +837,7 @@ struct e1000_ipv4_at_entry {
 
 /* IPv6 Address Table Entry */
 struct e1000_ipv6_at_entry {
-    volatile uint8_t ipv6_addr[16];
+    volatile u8 ipv6_addr[16];
 };
 
 /* Flexible Filter Length Table Entry */
@@ -1382,8 +1382,8 @@ struct e1000_hw_stats {
 
 /* Structure containing variables used by the shared code (e1000_hw.c) */
 struct e1000_hw {
-	uint8_t __iomem		*hw_addr;
-	uint8_t __iomem		*flash_address;
+	u8 __iomem		*hw_addr;
+	u8 __iomem		*flash_address;
 	e1000_mac_type		mac_type;
 	e1000_phy_type		phy_type;
 	uint32_t		phy_init_script;
@@ -1437,14 +1437,14 @@ struct e1000_hw {
 	uint16_t		vendor_id;
 	uint16_t		subsystem_id;
 	uint16_t		subsystem_vendor_id;
-	uint8_t			revision_id;
-	uint8_t			autoneg;
-	uint8_t			mdix;
-	uint8_t			forced_speed_duplex;
-	uint8_t			wait_autoneg_complete;
-	uint8_t			dma_fairness;
-	uint8_t			mac_addr[NODE_ADDRESS_SIZE];
-	uint8_t			perm_mac_addr[NODE_ADDRESS_SIZE];
+	u8			revision_id;
+	u8			autoneg;
+	u8			mdix;
+	u8			forced_speed_duplex;
+	u8			wait_autoneg_complete;
+	u8			dma_fairness;
+	u8			mac_addr[NODE_ADDRESS_SIZE];
+	u8			perm_mac_addr[NODE_ADDRESS_SIZE];
 	bool			disable_polarity_correction;
 	bool			speed_downgraded;
 	e1000_smart_speed	smart_speed;
@@ -2165,14 +2165,14 @@ typedef enum {
 #define E1000_HI_COMMAND_TIMEOUT         500 /* Time in ms to process HI command */
 
 struct e1000_host_command_header {
-    uint8_t command_id;
-    uint8_t command_length;
-    uint8_t command_options;   /* I/F bits for command, status for return */
-    uint8_t checksum;
+    u8 command_id;
+    u8 command_length;
+    u8 command_options;   /* I/F bits for command, status for return */
+    u8 checksum;
 };
 struct e1000_host_command_info {
     struct e1000_host_command_header command_header;  /* Command Head/Command Result Head has 4 bytes */
-    uint8_t command_data[E1000_HI_MAX_DATA_LENGTH];   /* Command data can length 0..252 */
+    u8 command_data[E1000_HI_MAX_DATA_LENGTH];   /* Command data can length 0..252 */
 };
 
 /* Host SMB register #0 */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 757d02f..16a40ea 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2961,7 +2961,7 @@ e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 	unsigned int i;
 	uint32_t cmd_length = 0;
 	uint16_t ipcse = 0, tucse, mss;
-	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
+	u8 ipcss, ipcso, tucss, tucso, hdr_len;
 	int err;
 
 	if (skb_is_gso(skb)) {
@@ -3032,7 +3032,7 @@ e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
 	unsigned int i;
-	uint8_t css;
+	u8 css;
 
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		css = skb_transport_offset(skb);
@@ -3280,17 +3280,17 @@ e1000_transfer_dhcp_info(struct e1000_adapter *adapter, struct sk_buff *skb)
 		struct ethhdr *eth = (struct ethhdr *) skb->data;
 		if ((htons(ETH_P_IP) == eth->h_proto)) {
 			const struct iphdr *ip =
-				(struct iphdr *)((uint8_t *)skb->data+14);
+				(struct iphdr *)((u8 *)skb->data+14);
 			if (IPPROTO_UDP == ip->protocol) {
 				struct udphdr *udp =
-					(struct udphdr *)((uint8_t *)ip +
+					(struct udphdr *)((u8 *)ip +
 						(ip->ihl << 2));
 				if (ntohs(udp->dest) == 67) {
-					offset = (uint8_t *)udp + 8 - skb->data;
+					offset = (u8 *)udp + 8 - skb->data;
 					length = skb->len - offset;
 
 					return e1000_mng_write_dhcp_info(hw,
-							(uint8_t *)udp + 8,
+							(u8 *)udp + 8,
 							length);
 				}
 			}
@@ -3370,7 +3370,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	 * overrun the FIFO, adjust the max buffer len if mss
 	 * drops. */
 	if (mss) {
-		uint8_t hdr_len;
+		u8 hdr_len;
 		max_per_txd = min(mss << 2, max_per_txd);
 		max_txd_pwr = fls(max_per_txd) - 1;
 
@@ -4143,7 +4143,7 @@ e1000_rx_checksum(struct e1000_adapter *adapter,
 		  struct sk_buff *skb)
 {
 	uint16_t status = (uint16_t)status_err;
-	uint8_t errors = (uint8_t)(status_err >> 24);
+	u8 errors = (u8)(status_err >> 24);
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* 82543 or newer only */
@@ -4201,7 +4201,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 	struct e1000_buffer *buffer_info, *next_buffer;
 	unsigned long flags;
 	uint32_t length;
-	uint8_t last_byte;
+	u8 last_byte;
 	unsigned int i;
 	int cleaned_count = 0;
 	bool cleaned = false;
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
