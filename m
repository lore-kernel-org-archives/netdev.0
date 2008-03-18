From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/6] drivers/net/e1000 - Convert u_int16_t to
	u16
Date: Tue, 18 Mar 2008 09:13:45 -0700
Message-ID: <41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
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
In-Reply-To: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
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
 drivers/net/e1000/e1000.h         |   24 ++--
 drivers/net/e1000/e1000_ethtool.c |   36 ++--
 drivers/net/e1000/e1000_hw.c      |  394 ++++++++++++++++++------------------
 drivers/net/e1000/e1000_hw.h      |  132 ++++++------
 drivers/net/e1000/e1000_main.c    |   60 +++---
 5 files changed, 323 insertions(+), 323 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 4522896..4a0ce08 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -161,8 +161,8 @@ struct e1000_buffer {
 	struct sk_buff *skb;
 	dma_addr_t dma;
 	unsigned long time_stamp;
-	uint16_t length;
-	uint16_t next_to_watch;
+	u16 length;
+	u16 next_to_watch;
 };
 
 
@@ -186,8 +186,8 @@ struct e1000_tx_ring {
 	struct e1000_buffer *buffer_info;
 
 	spinlock_t tx_lock;
-	uint16_t tdh;
-	uint16_t tdt;
+	u16 tdh;
+	u16 tdt;
 	bool last_tx_tso;
 };
 
@@ -213,8 +213,8 @@ struct e1000_rx_ring {
 	/* cpu for rx queue */
 	int cpu;
 
-	uint16_t rdh;
-	uint16_t rdt;
+	u16 rdh;
+	u16 rdt;
 };
 
 #define E1000_DESC_UNUSED(R) \
@@ -237,14 +237,14 @@ struct e1000_adapter {
 	struct timer_list watchdog_timer;
 	struct timer_list phy_info_timer;
 	struct vlan_group *vlgrp;
-	uint16_t mng_vlan_id;
+	u16 mng_vlan_id;
 	uint32_t bd_number;
 	uint32_t rx_buffer_len;
 	uint32_t wol;
 	uint32_t smartspeed;
 	uint32_t en_mng_pt;
-	uint16_t link_speed;
-	uint16_t link_duplex;
+	u16 link_speed;
+	u16 link_duplex;
 	spinlock_t stats_lock;
 #ifdef CONFIG_E1000_NAPI
 	spinlock_t tx_queue_lock;
@@ -256,8 +256,8 @@ struct e1000_adapter {
 	/* Interrupt Throttle Rate */
 	uint32_t itr;
 	uint32_t itr_setting;
-	uint16_t tx_itr;
-	uint16_t rx_itr;
+	u16 tx_itr;
+	u16 rx_itr;
 
 	struct work_struct reset_task;
 	u8 fc_autoneg;
@@ -315,7 +315,7 @@ struct e1000_adapter {
 	unsigned int rx_ps_pages;
 	uint32_t gorcl;
 	uint64_t gorcl_old;
-	uint16_t rx_ps_bsize0;
+	u16 rx_ps_bsize0;
 
 
 	/* OS defined structs */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 20b1e1b..92d4a45 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -36,7 +36,7 @@ extern int e1000_up(struct e1000_adapter *adapter);
 extern void e1000_down(struct e1000_adapter *adapter);
 extern void e1000_reinit_locked(struct e1000_adapter *adapter);
 extern void e1000_reset(struct e1000_adapter *adapter);
-extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx);
+extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx);
 extern int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
 extern int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
 extern void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
@@ -385,7 +385,7 @@ e1000_get_regs(struct net_device *netdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	uint32_t *regs_buff = p;
-	uint16_t phy_data;
+	u16 phy_data;
 
 	memset(p, 0, E1000_REGS_LEN * sizeof(uint32_t));
 
@@ -481,10 +481,10 @@ e1000_get_eeprom(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	uint16_t *eeprom_buff;
+	u16 *eeprom_buff;
 	int first_word, last_word;
 	int ret_val = 0;
-	uint16_t i;
+	u16 i;
 
 	if (eeprom->len == 0)
 		return -EINVAL;
@@ -494,7 +494,7 @@ e1000_get_eeprom(struct net_device *netdev,
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	eeprom_buff = kmalloc(sizeof(uint16_t) *
+	eeprom_buff = kmalloc(sizeof(u16) *
 			(last_word - first_word + 1), GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
@@ -527,10 +527,10 @@ e1000_set_eeprom(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	uint16_t *eeprom_buff;
+	u16 *eeprom_buff;
 	void *ptr;
 	int max_len, first_word, last_word, ret_val = 0;
-	uint16_t i;
+	u16 i;
 
 	if (eeprom->len == 0)
 		return -EOPNOTSUPP;
@@ -590,7 +590,7 @@ e1000_get_drvinfo(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	char firmware_version[32];
-	uint16_t eeprom_data;
+	u16 eeprom_data;
 
 	strncpy(drvinfo->driver,  e1000_driver_name, 32);
 	strncpy(drvinfo->version, e1000_driver_version, 32);
@@ -886,9 +886,9 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 static int
 e1000_eeprom_test(struct e1000_adapter *adapter, uint64_t *data)
 {
-	uint16_t temp;
-	uint16_t checksum = 0;
-	uint16_t i;
+	u16 temp;
+	u16 checksum = 0;
+	u16 i;
 
 	*data = 0;
 	/* Read and add up the contents of the EEPROM */
@@ -901,7 +901,7 @@ e1000_eeprom_test(struct e1000_adapter *adapter, uint64_t *data)
 	}
 
 	/* If Checksum is not Correct return error else test passed */
-	if ((checksum != (uint16_t) EEPROM_SUM) && !(*data))
+	if ((checksum != (u16) EEPROM_SUM) && !(*data))
 		*data = 2;
 
 	return *data;
@@ -1202,7 +1202,7 @@ e1000_phy_disable_receiver(struct e1000_adapter *adapter)
 static void
 e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
 {
-	uint16_t phy_reg;
+	u16 phy_reg;
 
 	/* Because we reset the PHY above, we need to re-force TX_CLK in the
 	 * Extended PHY Specific Control Register to 25MHz clock.  This
@@ -1227,7 +1227,7 @@ static int
 e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 {
 	uint32_t ctrl_reg;
-	uint16_t phy_reg;
+	u16 phy_reg;
 
 	/* Setup the Device Control Register for PHY loopback test. */
 
@@ -1363,8 +1363,8 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 static int
 e1000_set_phy_loopback(struct e1000_adapter *adapter)
 {
-	uint16_t phy_reg = 0;
-	uint16_t count = 0;
+	u16 phy_reg = 0;
+	u16 count = 0;
 
 	switch (adapter->hw.mac_type) {
 	case e1000_82543:
@@ -1452,7 +1452,7 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	uint32_t rctl;
-	uint16_t phy_reg;
+	u16 phy_reg;
 
 	rctl = E1000_READ_REG(hw, RCTL);
 	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
@@ -1657,7 +1657,7 @@ e1000_diag_test(struct net_device *netdev,
 		/* Offline tests */
 
 		/* save speed, duplex, autoneg settings */
-		uint16_t autoneg_advertised = adapter->hw.autoneg_advertised;
+		u16 autoneg_advertised = adapter->hw.autoneg_advertised;
 		u8 forced_speed_duplex = adapter->hw.forced_speed_duplex;
 		u8 autoneg = adapter->hw.autoneg;
 
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 91ce084..6f6d79f 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -33,10 +33,10 @@
 
 #include "e1000_hw.h"
 
-static int32_t e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask);
-static void e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask);
-static int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t *data);
-static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t data);
+static int32_t e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask);
+static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask);
+static int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, u16 *data);
+static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, u16 data);
 static int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
 static void e1000_release_software_semaphore(struct e1000_hw *hw);
 
@@ -52,7 +52,7 @@ static int32_t e1000_config_fc_after_link_up(struct e1000_hw *hw);
 static int32_t e1000_detect_gig_phy(struct e1000_hw *hw);
 static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank);
 static int32_t e1000_get_auto_rd_done(struct e1000_hw *hw);
-static int32_t e1000_get_cable_length(struct e1000_hw *hw, uint16_t *min_length, uint16_t *max_length);
+static int32_t e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length, u16 *max_length);
 static int32_t e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
 static int32_t e1000_get_phy_cfg_done(struct e1000_hw *hw);
 static int32_t e1000_get_software_flag(struct e1000_hw *hw);
@@ -66,24 +66,24 @@ static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
 static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
 static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
 static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
-static int32_t e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, uint16_t length, uint16_t offset, u8 *sum);
+static int32_t e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, u16 length, u16 offset, u8 *sum);
 static int32_t e1000_mng_write_cmd_header(struct e1000_hw* hw, struct e1000_host_mng_command_header* hdr);
 static int32_t e1000_mng_write_commit(struct e1000_hw *hw);
 static int32_t e1000_phy_ife_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 static int32_t e1000_phy_igp_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
-static int32_t e1000_read_eeprom_eerd(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
-static int32_t e1000_write_eeprom_eewr(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
+static int32_t e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static int32_t e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 static int32_t e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
 static int32_t e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
 static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 *data);
 static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 byte);
 static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 byte);
-static int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data);
-static int32_t e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, uint16_t *data);
-static int32_t e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, uint16_t data);
-static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
-static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
+static int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, u16 *data);
+static int32_t e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, u16 *data);
+static int32_t e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, u16 data);
+static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 static void e1000_release_software_flag(struct e1000_hw *hw);
 static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
 static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
@@ -101,24 +101,24 @@ static int32_t e1000_config_mac_to_phy(struct e1000_hw *hw);
 static void e1000_raise_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
 static void e1000_lower_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
 static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, uint32_t data,
-                                     uint16_t count);
-static uint16_t e1000_shift_in_mdi_bits(struct e1000_hw *hw);
+                                     u16 count);
+static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw);
 static int32_t e1000_phy_reset_dsp(struct e1000_hw *hw);
-static int32_t e1000_write_eeprom_spi(struct e1000_hw *hw, uint16_t offset,
-                                      uint16_t words, uint16_t *data);
+static int32_t e1000_write_eeprom_spi(struct e1000_hw *hw, u16 offset,
+                                      u16 words, u16 *data);
 static int32_t e1000_write_eeprom_microwire(struct e1000_hw *hw,
-                                            uint16_t offset, uint16_t words,
-                                            uint16_t *data);
+                                            u16 offset, u16 words,
+                                            u16 *data);
 static int32_t e1000_spi_eeprom_ready(struct e1000_hw *hw);
 static void e1000_raise_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
 static void e1000_lower_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
-static void e1000_shift_out_ee_bits(struct e1000_hw *hw, uint16_t data,
-                                    uint16_t count);
+static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data,
+                                    u16 count);
 static int32_t e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
-                                      uint16_t phy_data);
+                                      u16 phy_data);
 static int32_t e1000_read_phy_reg_ex(struct e1000_hw *hw,uint32_t reg_addr,
-                                     uint16_t *phy_data);
-static uint16_t e1000_shift_in_ee_bits(struct e1000_hw *hw, uint16_t count);
+                                     u16 *phy_data);
+static u16 e1000_shift_in_ee_bits(struct e1000_hw *hw, u16 count);
 static int32_t e1000_acquire_eeprom(struct e1000_hw *hw);
 static void e1000_release_eeprom(struct e1000_hw *hw);
 static void e1000_standby_eeprom(struct e1000_hw *hw);
@@ -128,12 +128,12 @@ static int32_t e1000_set_phy_mode(struct e1000_hw *hw);
 static int32_t e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer);
 static u8 e1000_calculate_mng_checksum(char *buffer, uint32_t length);
 static int32_t e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
-                                               uint16_t duplex);
+                                               u16 duplex);
 static int32_t e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
 
 /* IGP cable length table */
 static const
-uint16_t e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
+u16 e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
     { 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
       5, 10, 10, 10, 10, 10, 10, 10, 20, 20, 20, 20, 20, 25, 25, 25,
       25, 25, 25, 25, 30, 30, 30, 30, 40, 40, 40, 40, 40, 40, 40, 40,
@@ -144,7 +144,7 @@ uint16_t e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
       110, 110, 110, 110, 110, 110, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120};
 
 static const
-uint16_t e1000_igp_2_cable_length_table[IGP02E1000_AGC_LENGTH_TABLE_SIZE] =
+u16 e1000_igp_2_cable_length_table[IGP02E1000_AGC_LENGTH_TABLE_SIZE] =
     { 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21,
       0, 0, 0, 3, 6, 10, 13, 16, 19, 23, 26, 29, 32, 35, 38, 41,
       6, 10, 14, 18, 22, 26, 30, 33, 37, 41, 44, 48, 51, 54, 58, 61,
@@ -214,7 +214,7 @@ static void
 e1000_phy_init_script(struct e1000_hw *hw)
 {
     uint32_t ret_val;
-    uint16_t phy_saved_data;
+    u16 phy_saved_data;
 
     DEBUGFUNC("e1000_phy_init_script");
 
@@ -272,7 +272,7 @@ e1000_phy_init_script(struct e1000_hw *hw)
         e1000_write_phy_reg(hw, 0x2F5B, phy_saved_data);
 
         if (hw->mac_type == e1000_82547) {
-            uint16_t fused, fine, coarse;
+            u16 fused, fine, coarse;
 
             /* Move to analog registers page */
             e1000_read_phy_reg(hw, IGP01E1000_ANALOG_SPARE_FUSE_STATUS, &fused);
@@ -1057,7 +1057,7 @@ e1000_init_hw(struct e1000_hw *hw)
 static int32_t
 e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
 {
-    uint16_t eeprom_data;
+    u16 eeprom_data;
     int32_t  ret_val;
 
     DEBUGFUNC("e1000_adjust_serdes_amplitude");
@@ -1105,7 +1105,7 @@ e1000_setup_link(struct e1000_hw *hw)
 {
     uint32_t ctrl_ext;
     int32_t ret_val;
-    uint16_t eeprom_data;
+    u16 eeprom_data;
 
     DEBUGFUNC("e1000_setup_link");
 
@@ -1385,7 +1385,7 @@ e1000_copper_link_preconfig(struct e1000_hw *hw)
 {
     uint32_t ctrl;
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_preconfig");
 
@@ -1445,7 +1445,7 @@ e1000_copper_link_igp_setup(struct e1000_hw *hw)
 {
     uint32_t led_ctrl;
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_igp_setup");
 
@@ -1591,7 +1591,7 @@ static int32_t
 e1000_copper_link_ggp_setup(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
     uint32_t reg_data;
 
     DEBUGFUNC("e1000_copper_link_ggp_setup");
@@ -1739,7 +1739,7 @@ static int32_t
 e1000_copper_link_mgp_setup(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_mgp_setup");
 
@@ -1843,7 +1843,7 @@ static int32_t
 e1000_copper_link_autoneg(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_autoneg");
 
@@ -1952,9 +1952,9 @@ static int32_t
 e1000_setup_copper_link(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t i;
-    uint16_t phy_data;
-    uint16_t reg_data;
+    u16 i;
+    u16 phy_data;
+    u16 reg_data;
 
     DEBUGFUNC("e1000_setup_copper_link");
 
@@ -2063,11 +2063,11 @@ e1000_setup_copper_link(struct e1000_hw *hw)
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
 static int32_t
-e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, uint16_t duplex)
+e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
 {
     int32_t ret_val = E1000_SUCCESS;
     uint32_t tipg;
-    uint16_t reg_data;
+    u16 reg_data;
 
     DEBUGFUNC("e1000_configure_kmrn_for_10_100");
 
@@ -2102,7 +2102,7 @@ static int32_t
 e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
 {
     int32_t ret_val = E1000_SUCCESS;
-    uint16_t reg_data;
+    u16 reg_data;
     uint32_t tipg;
 
     DEBUGFUNC("e1000_configure_kmrn_for_1000");
@@ -2139,8 +2139,8 @@ int32_t
 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t mii_autoneg_adv_reg;
-    uint16_t mii_1000t_ctrl_reg;
+    u16 mii_autoneg_adv_reg;
+    u16 mii_1000t_ctrl_reg;
 
     DEBUGFUNC("e1000_phy_setup_autoneg");
 
@@ -2289,10 +2289,10 @@ e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 {
     uint32_t ctrl;
     int32_t ret_val;
-    uint16_t mii_ctrl_reg;
-    uint16_t mii_status_reg;
-    uint16_t phy_data;
-    uint16_t i;
+    u16 mii_ctrl_reg;
+    u16 mii_status_reg;
+    u16 phy_data;
+    u16 i;
 
     DEBUGFUNC("e1000_phy_force_speed_duplex");
 
@@ -2570,7 +2570,7 @@ e1000_config_mac_to_phy(struct e1000_hw *hw)
 {
     uint32_t ctrl;
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_config_mac_to_phy");
 
@@ -2695,11 +2695,11 @@ static int32_t
 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t mii_status_reg;
-    uint16_t mii_nway_adv_reg;
-    uint16_t mii_nway_lp_ability_reg;
-    uint16_t speed;
-    uint16_t duplex;
+    u16 mii_status_reg;
+    u16 mii_nway_adv_reg;
+    u16 mii_nway_lp_ability_reg;
+    u16 speed;
+    u16 duplex;
 
     DEBUGFUNC("e1000_config_fc_after_link_up");
 
@@ -2906,7 +2906,7 @@ e1000_check_for_link(struct e1000_hw *hw)
     uint32_t icr;
     uint32_t signal = 0;
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_check_for_link");
 
@@ -3022,7 +3022,7 @@ e1000_check_for_link(struct e1000_hw *hw)
          * at gigabit speed, we turn on TBI compatibility.
          */
         if (hw->tbi_compatibility_en) {
-            uint16_t speed, duplex;
+            u16 speed, duplex;
             ret_val = e1000_get_speed_and_duplex(hw, &speed, &duplex);
             if (ret_val) {
                 DEBUGOUT("Error getting link speed and duplex\n");
@@ -3134,12 +3134,12 @@ e1000_check_for_link(struct e1000_hw *hw)
  *****************************************************************************/
 int32_t
 e1000_get_speed_and_duplex(struct e1000_hw *hw,
-                           uint16_t *speed,
-                           uint16_t *duplex)
+                           u16 *speed,
+                           u16 *duplex)
 {
     uint32_t status;
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_get_speed_and_duplex");
 
@@ -3218,8 +3218,8 @@ static int32_t
 e1000_wait_autoneg(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t i;
-    uint16_t phy_data;
+    u16 i;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_wait_autoneg");
     DEBUGOUT("Waiting for Auto-Neg to complete.\n");
@@ -3291,7 +3291,7 @@ e1000_lower_mdi_clk(struct e1000_hw *hw,
 static void
 e1000_shift_out_mdi_bits(struct e1000_hw *hw,
                          uint32_t data,
-                         uint16_t count)
+                         u16 count)
 {
     uint32_t ctrl;
     uint32_t mask;
@@ -3338,11 +3338,11 @@ e1000_shift_out_mdi_bits(struct e1000_hw *hw,
 *
 * Bits are shifted in in MSB to LSB order.
 ******************************************************************************/
-static uint16_t
+static u16
 e1000_shift_in_mdi_bits(struct e1000_hw *hw)
 {
     uint32_t ctrl;
-    uint16_t data = 0;
+    u16 data = 0;
     u8 i;
 
     /* In order to read a register from the PHY, we need to shift in a total
@@ -3385,7 +3385,7 @@ e1000_shift_in_mdi_bits(struct e1000_hw *hw)
 }
 
 static int32_t
-e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask)
+e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
 {
     uint32_t swfw_sync = 0;
     uint32_t swmask = mask;
@@ -3429,7 +3429,7 @@ e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask)
 }
 
 static void
-e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask)
+e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
 {
     uint32_t swfw_sync;
     uint32_t swmask = mask;
@@ -3467,10 +3467,10 @@ e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask)
 int32_t
 e1000_read_phy_reg(struct e1000_hw *hw,
                    uint32_t reg_addr,
-                   uint16_t *phy_data)
+                   u16 *phy_data)
 {
     uint32_t ret_val;
-    uint16_t swfw;
+    u16 swfw;
 
     DEBUGFUNC("e1000_read_phy_reg");
 
@@ -3488,7 +3488,7 @@ e1000_read_phy_reg(struct e1000_hw *hw,
         hw->phy_type == e1000_phy_igp_2) &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
-                                         (uint16_t)reg_addr);
+                                         (u16)reg_addr);
         if (ret_val) {
             e1000_swfw_sync_release(hw, swfw);
             return ret_val;
@@ -3499,14 +3499,14 @@ e1000_read_phy_reg(struct e1000_hw *hw,
             /* Select Configuration Page */
             if ((reg_addr & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
                 ret_val = e1000_write_phy_reg_ex(hw, GG82563_PHY_PAGE_SELECT,
-                          (uint16_t)((uint16_t)reg_addr >> GG82563_PAGE_SHIFT));
+                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
             } else {
                 /* Use Alternative Page Select register to access
                  * registers 30 and 31
                  */
                 ret_val = e1000_write_phy_reg_ex(hw,
                                                  GG82563_PHY_PAGE_SELECT_ALT,
-                          (uint16_t)((uint16_t)reg_addr >> GG82563_PAGE_SHIFT));
+                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
             }
 
             if (ret_val) {
@@ -3525,7 +3525,7 @@ e1000_read_phy_reg(struct e1000_hw *hw,
 
 static int32_t
 e1000_read_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
-                      uint16_t *phy_data)
+                      u16 *phy_data)
 {
     uint32_t i;
     uint32_t mdic = 0;
@@ -3563,7 +3563,7 @@ e1000_read_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
             DEBUGOUT("MDI Error\n");
             return -E1000_ERR_PHY;
         }
-        *phy_data = (uint16_t) mdic;
+        *phy_data = (u16) mdic;
     } else {
         /* We must first send a preamble through the MDIO pin to signal the
          * beginning of an MII instruction.  This is done by sending 32
@@ -3605,10 +3605,10 @@ e1000_read_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
 ******************************************************************************/
 int32_t
 e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
-                    uint16_t phy_data)
+                    u16 phy_data)
 {
     uint32_t ret_val;
-    uint16_t swfw;
+    u16 swfw;
 
     DEBUGFUNC("e1000_write_phy_reg");
 
@@ -3626,7 +3626,7 @@ e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
         hw->phy_type == e1000_phy_igp_2) &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
-                                         (uint16_t)reg_addr);
+                                         (u16)reg_addr);
         if (ret_val) {
             e1000_swfw_sync_release(hw, swfw);
             return ret_val;
@@ -3637,14 +3637,14 @@ e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
             /* Select Configuration Page */
             if ((reg_addr & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
                 ret_val = e1000_write_phy_reg_ex(hw, GG82563_PHY_PAGE_SELECT,
-                          (uint16_t)((uint16_t)reg_addr >> GG82563_PAGE_SHIFT));
+                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
             } else {
                 /* Use Alternative Page Select register to access
                  * registers 30 and 31
                  */
                 ret_val = e1000_write_phy_reg_ex(hw,
                                                  GG82563_PHY_PAGE_SELECT_ALT,
-                          (uint16_t)((uint16_t)reg_addr >> GG82563_PAGE_SHIFT));
+                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
             }
 
             if (ret_val) {
@@ -3663,7 +3663,7 @@ e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
 
 static int32_t
 e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
-                       uint16_t phy_data)
+                       u16 phy_data)
 {
     uint32_t i;
     uint32_t mdic = 0;
@@ -3726,10 +3726,10 @@ e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
 static int32_t
 e1000_read_kmrn_reg(struct e1000_hw *hw,
                     uint32_t reg_addr,
-                    uint16_t *data)
+                    u16 *data)
 {
     uint32_t reg_val;
-    uint16_t swfw;
+    u16 swfw;
     DEBUGFUNC("e1000_read_kmrn_reg");
 
     if ((hw->mac_type == e1000_80003es2lan) &&
@@ -3750,7 +3750,7 @@ e1000_read_kmrn_reg(struct e1000_hw *hw,
 
     /* Read the data returned */
     reg_val = E1000_READ_REG(hw, KUMCTRLSTA);
-    *data = (uint16_t)reg_val;
+    *data = (u16)reg_val;
 
     e1000_swfw_sync_release(hw, swfw);
     return E1000_SUCCESS;
@@ -3759,10 +3759,10 @@ e1000_read_kmrn_reg(struct e1000_hw *hw,
 static int32_t
 e1000_write_kmrn_reg(struct e1000_hw *hw,
                      uint32_t reg_addr,
-                     uint16_t data)
+                     u16 data)
 {
     uint32_t reg_val;
-    uint16_t swfw;
+    u16 swfw;
     DEBUGFUNC("e1000_write_kmrn_reg");
 
     if ((hw->mac_type == e1000_80003es2lan) &&
@@ -3794,7 +3794,7 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
     uint32_t ctrl, ctrl_ext;
     uint32_t led_ctrl;
     int32_t ret_val;
-    uint16_t swfw;
+    u16 swfw;
 
     DEBUGFUNC("e1000_phy_hw_reset");
 
@@ -3886,7 +3886,7 @@ int32_t
 e1000_phy_reset(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_phy_reset");
 
@@ -3938,7 +3938,7 @@ void
 e1000_phy_powerdown_workaround(struct e1000_hw *hw)
 {
     int32_t reg;
-    uint16_t phy_data;
+    u16 phy_data;
     int32_t retry = 0;
 
     DEBUGFUNC("e1000_phy_powerdown_workaround");
@@ -3993,7 +3993,7 @@ e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
     int32_t ret_val;
     int32_t reg;
     int32_t cnt;
-    uint16_t phy_data;
+    u16 phy_data;
 
     if (hw->kmrn_lock_loss_workaround_disabled)
         return E1000_SUCCESS;
@@ -4044,7 +4044,7 @@ static int32_t
 e1000_detect_gig_phy(struct e1000_hw *hw)
 {
     int32_t phy_init_status, ret_val;
-    uint16_t phy_id_high, phy_id_low;
+    u16 phy_id_high, phy_id_low;
     bool match = false;
 
     DEBUGFUNC("e1000_detect_gig_phy");
@@ -4168,7 +4168,7 @@ e1000_phy_igp_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
     int32_t ret_val;
-    uint16_t phy_data, min_length, max_length, average;
+    u16 phy_data, min_length, max_length, average;
     e1000_rev_polarity polarity;
 
     DEBUGFUNC("e1000_phy_igp_get_info");
@@ -4245,7 +4245,7 @@ e1000_phy_ife_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
     e1000_rev_polarity polarity;
 
     DEBUGFUNC("e1000_phy_ife_get_info");
@@ -4295,7 +4295,7 @@ e1000_phy_m88_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
     e1000_rev_polarity polarity;
 
     DEBUGFUNC("e1000_phy_m88_get_info");
@@ -4374,7 +4374,7 @@ e1000_phy_get_info(struct e1000_hw *hw,
                    struct e1000_phy_info *phy_info)
 {
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_phy_get_info");
 
@@ -4442,7 +4442,7 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     uint32_t eecd = E1000_READ_REG(hw, EECD);
     int32_t ret_val = E1000_SUCCESS;
-    uint16_t eeprom_size;
+    u16 eeprom_size;
 
     DEBUGFUNC("e1000_init_eeprom_params");
 
@@ -4586,7 +4586,7 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
 
         hw->flash_bank_size *= ICH_FLASH_SECTOR_SIZE;
 
-        hw->flash_bank_size /= 2 * sizeof(uint16_t);
+        hw->flash_bank_size /= 2 * sizeof(u16);
 
         break;
         }
@@ -4611,7 +4611,7 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             if (eeprom_size)
                 eeprom_size++;
         } else {
-            eeprom_size = (uint16_t)((eecd & E1000_EECD_SIZE_EX_MASK) >>
+            eeprom_size = (u16)((eecd & E1000_EECD_SIZE_EX_MASK) >>
                           E1000_EECD_SIZE_EX_SHIFT);
         }
 
@@ -4667,8 +4667,8 @@ e1000_lower_ee_clk(struct e1000_hw *hw,
  *****************************************************************************/
 static void
 e1000_shift_out_ee_bits(struct e1000_hw *hw,
-                        uint16_t data,
-                        uint16_t count)
+                        u16 data,
+                        u16 count)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     uint32_t eecd;
@@ -4718,13 +4718,13 @@ e1000_shift_out_ee_bits(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static uint16_t
+static u16
 e1000_shift_in_ee_bits(struct e1000_hw *hw,
-                       uint16_t count)
+                       u16 count)
 {
     uint32_t eecd;
     uint32_t i;
-    uint16_t data;
+    u16 data;
 
     /* In order to read a register from the EEPROM, we need to shift 'count'
      * bits in from the EEPROM. Bits are "shifted in" by raising the clock
@@ -4924,7 +4924,7 @@ e1000_release_eeprom(struct e1000_hw *hw)
 static int32_t
 e1000_spi_eeprom_ready(struct e1000_hw *hw)
 {
-    uint16_t retry_count = 0;
+    u16 retry_count = 0;
     u8 spi_stat_reg;
 
     DEBUGFUNC("e1000_spi_eeprom_ready");
@@ -4969,9 +4969,9 @@ e1000_spi_eeprom_ready(struct e1000_hw *hw)
  *****************************************************************************/
 int32_t
 e1000_read_eeprom(struct e1000_hw *hw,
-                  uint16_t offset,
-                  uint16_t words,
-                  uint16_t *data)
+                  u16 offset,
+                  u16 words,
+                  u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     uint32_t i = 0;
@@ -5012,7 +5012,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
     /* Set up the SPI or Microwire EEPROM for bit-bang reading.  We have
      * acquired the EEPROM at this point, so any returns should relase it */
     if (eeprom->type == e1000_eeprom_spi) {
-        uint16_t word_in;
+        u16 word_in;
         u8 read_opcode = EEPROM_READ_OPCODE_SPI;
 
         if (e1000_spi_eeprom_ready(hw)) {
@@ -5028,7 +5028,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
 
         /* Send the READ command (opcode + addr)  */
         e1000_shift_out_ee_bits(hw, read_opcode, eeprom->opcode_bits);
-        e1000_shift_out_ee_bits(hw, (uint16_t)(offset*2), eeprom->address_bits);
+        e1000_shift_out_ee_bits(hw, (u16)(offset*2), eeprom->address_bits);
 
         /* Read the data.  The address of the eeprom internally increments with
          * each byte (spi) being read, saving on the overhead of eeprom setup
@@ -5044,7 +5044,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
             /* Send the READ command (opcode + addr)  */
             e1000_shift_out_ee_bits(hw, EEPROM_READ_OPCODE_MICROWIRE,
                                     eeprom->opcode_bits);
-            e1000_shift_out_ee_bits(hw, (uint16_t)(offset + i),
+            e1000_shift_out_ee_bits(hw, (u16)(offset + i),
                                     eeprom->address_bits);
 
             /* Read the data.  For microwire, each word requires the overhead
@@ -5070,9 +5070,9 @@ e1000_read_eeprom(struct e1000_hw *hw,
  *****************************************************************************/
 static int32_t
 e1000_read_eeprom_eerd(struct e1000_hw *hw,
-                  uint16_t offset,
-                  uint16_t words,
-                  uint16_t *data)
+                  u16 offset,
+                  u16 words,
+                  u16 *data)
 {
     uint32_t i, eerd = 0;
     int32_t error = 0;
@@ -5104,9 +5104,9 @@ e1000_read_eeprom_eerd(struct e1000_hw *hw,
  *****************************************************************************/
 static int32_t
 e1000_write_eeprom_eewr(struct e1000_hw *hw,
-                   uint16_t offset,
-                   uint16_t words,
-                   uint16_t *data)
+                   u16 offset,
+                   u16 words,
+                   u16 *data)
 {
     uint32_t    register_value = 0;
     uint32_t    i              = 0;
@@ -5207,8 +5207,8 @@ e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
 int32_t
 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 {
-    uint16_t checksum = 0;
-    uint16_t i, eeprom_data;
+    u16 checksum = 0;
+    u16 i, eeprom_data;
 
     DEBUGFUNC("e1000_validate_eeprom_checksum");
 
@@ -5252,7 +5252,7 @@ e1000_validate_eeprom_checksum(struct e1000_hw *hw)
         checksum += eeprom_data;
     }
 
-    if (checksum == (uint16_t) EEPROM_SUM)
+    if (checksum == (u16) EEPROM_SUM)
         return E1000_SUCCESS;
     else {
         DEBUGOUT("EEPROM Checksum Invalid\n");
@@ -5272,8 +5272,8 @@ int32_t
 e1000_update_eeprom_checksum(struct e1000_hw *hw)
 {
     uint32_t ctrl_ext;
-    uint16_t checksum = 0;
-    uint16_t i, eeprom_data;
+    u16 checksum = 0;
+    u16 i, eeprom_data;
 
     DEBUGFUNC("e1000_update_eeprom_checksum");
 
@@ -5284,7 +5284,7 @@ e1000_update_eeprom_checksum(struct e1000_hw *hw)
         }
         checksum += eeprom_data;
     }
-    checksum = (uint16_t) EEPROM_SUM - checksum;
+    checksum = (u16) EEPROM_SUM - checksum;
     if (e1000_write_eeprom(hw, EEPROM_CHECKSUM_REG, 1, &checksum) < 0) {
         DEBUGOUT("EEPROM Write Error\n");
         return -E1000_ERR_EEPROM;
@@ -5315,9 +5315,9 @@ e1000_update_eeprom_checksum(struct e1000_hw *hw)
  *****************************************************************************/
 int32_t
 e1000_write_eeprom(struct e1000_hw *hw,
-                   uint16_t offset,
-                   uint16_t words,
-                   uint16_t *data)
+                   u16 offset,
+                   u16 words,
+                   u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     int32_t status = 0;
@@ -5372,12 +5372,12 @@ e1000_write_eeprom(struct e1000_hw *hw,
  *****************************************************************************/
 static int32_t
 e1000_write_eeprom_spi(struct e1000_hw *hw,
-                       uint16_t offset,
-                       uint16_t words,
-                       uint16_t *data)
+                       u16 offset,
+                       u16 words,
+                       u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint16_t widx = 0;
+    u16 widx = 0;
 
     DEBUGFUNC("e1000_write_eeprom_spi");
 
@@ -5401,14 +5401,14 @@ e1000_write_eeprom_spi(struct e1000_hw *hw,
         /* Send the Write command (8-bit opcode + addr) */
         e1000_shift_out_ee_bits(hw, write_opcode, eeprom->opcode_bits);
 
-        e1000_shift_out_ee_bits(hw, (uint16_t)((offset + widx)*2),
+        e1000_shift_out_ee_bits(hw, (u16)((offset + widx)*2),
                                 eeprom->address_bits);
 
         /* Send the data */
 
         /* Loop to allow for up to whole page write (32 bytes) of eeprom */
         while (widx < words) {
-            uint16_t word_out = data[widx];
+            u16 word_out = data[widx];
             word_out = (word_out >> 8) | (word_out << 8);
             e1000_shift_out_ee_bits(hw, word_out, 16);
             widx++;
@@ -5438,14 +5438,14 @@ e1000_write_eeprom_spi(struct e1000_hw *hw,
  *****************************************************************************/
 static int32_t
 e1000_write_eeprom_microwire(struct e1000_hw *hw,
-                             uint16_t offset,
-                             uint16_t words,
-                             uint16_t *data)
+                             u16 offset,
+                             u16 words,
+                             u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     uint32_t eecd;
-    uint16_t words_written = 0;
-    uint16_t i = 0;
+    u16 words_written = 0;
+    u16 i = 0;
 
     DEBUGFUNC("e1000_write_eeprom_microwire");
 
@@ -5456,9 +5456,9 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
      * EEPROM into write/erase mode.
      */
     e1000_shift_out_ee_bits(hw, EEPROM_EWEN_OPCODE_MICROWIRE,
-                            (uint16_t)(eeprom->opcode_bits + 2));
+                            (u16)(eeprom->opcode_bits + 2));
 
-    e1000_shift_out_ee_bits(hw, 0, (uint16_t)(eeprom->address_bits - 2));
+    e1000_shift_out_ee_bits(hw, 0, (u16)(eeprom->address_bits - 2));
 
     /* Prepare the EEPROM */
     e1000_standby_eeprom(hw);
@@ -5468,7 +5468,7 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
         e1000_shift_out_ee_bits(hw, EEPROM_WRITE_OPCODE_MICROWIRE,
                                 eeprom->opcode_bits);
 
-        e1000_shift_out_ee_bits(hw, (uint16_t)(offset + words_written),
+        e1000_shift_out_ee_bits(hw, (u16)(offset + words_written),
                                 eeprom->address_bits);
 
         /* Send the data */
@@ -5506,9 +5506,9 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
      * EEPROM out of write/erase mode.
      */
     e1000_shift_out_ee_bits(hw, EEPROM_EWDS_OPCODE_MICROWIRE,
-                            (uint16_t)(eeprom->opcode_bits + 2));
+                            (u16)(eeprom->opcode_bits + 2));
 
-    e1000_shift_out_ee_bits(hw, 0, (uint16_t)(eeprom->address_bits - 2));
+    e1000_shift_out_ee_bits(hw, 0, (u16)(eeprom->address_bits - 2));
 
     return E1000_SUCCESS;
 }
@@ -5690,8 +5690,8 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
 int32_t
 e1000_read_mac_addr(struct e1000_hw * hw)
 {
-    uint16_t offset;
-    uint16_t eeprom_data, i;
+    u16 offset;
+    u16 eeprom_data, i;
 
     DEBUGFUNC("e1000_read_mac_addr");
 
@@ -5787,37 +5787,37 @@ e1000_hash_mc_addr(struct e1000_hw *hw,
     case 0:
         if (hw->mac_type == e1000_ich8lan) {
             /* [47:38] i.e. 0x158 for above example address */
-            hash_value = ((mc_addr[4] >> 6) | (((uint16_t) mc_addr[5]) << 2));
+            hash_value = ((mc_addr[4] >> 6) | (((u16) mc_addr[5]) << 2));
         } else {
             /* [47:36] i.e. 0x563 for above example address */
-            hash_value = ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
+            hash_value = ((mc_addr[4] >> 4) | (((u16) mc_addr[5]) << 4));
         }
         break;
     case 1:
         if (hw->mac_type == e1000_ich8lan) {
             /* [46:37] i.e. 0x2B1 for above example address */
-            hash_value = ((mc_addr[4] >> 5) | (((uint16_t) mc_addr[5]) << 3));
+            hash_value = ((mc_addr[4] >> 5) | (((u16) mc_addr[5]) << 3));
         } else {
             /* [46:35] i.e. 0xAC6 for above example address */
-            hash_value = ((mc_addr[4] >> 3) | (((uint16_t) mc_addr[5]) << 5));
+            hash_value = ((mc_addr[4] >> 3) | (((u16) mc_addr[5]) << 5));
         }
         break;
     case 2:
         if (hw->mac_type == e1000_ich8lan) {
             /*[45:36] i.e. 0x163 for above example address */
-            hash_value = ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
+            hash_value = ((mc_addr[4] >> 4) | (((u16) mc_addr[5]) << 4));
         } else {
             /* [45:34] i.e. 0x5D8 for above example address */
-            hash_value = ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
+            hash_value = ((mc_addr[4] >> 2) | (((u16) mc_addr[5]) << 6));
         }
         break;
     case 3:
         if (hw->mac_type == e1000_ich8lan) {
             /* [43:34] i.e. 0x18D for above example address */
-            hash_value = ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
+            hash_value = ((mc_addr[4] >> 2) | (((u16) mc_addr[5]) << 6));
         } else {
             /* [43:32] i.e. 0x634 for above example address */
-            hash_value = ((mc_addr[4]) | (((uint16_t) mc_addr[5]) << 8));
+            hash_value = ((mc_addr[4]) | (((u16) mc_addr[5]) << 8));
         }
         break;
     }
@@ -6010,8 +6010,8 @@ e1000_id_led_init(struct e1000_hw * hw)
     const uint32_t ledctl_mask = 0x000000FF;
     const uint32_t ledctl_on = E1000_LEDCTL_MODE_LED_ON;
     const uint32_t ledctl_off = E1000_LEDCTL_MODE_LED_OFF;
-    uint16_t eeprom_data, i, temp;
-    const uint16_t led_mask = 0x0F;
+    u16 eeprom_data, i, temp;
+    const u16 led_mask = 0x0F;
 
     DEBUGFUNC("e1000_id_led_init");
 
@@ -6111,7 +6111,7 @@ e1000_setup_led(struct e1000_hw *hw)
         if (ret_val)
             return ret_val;
         ret_val = e1000_write_phy_reg(hw, IGP01E1000_GMII_FIFO,
-                                      (uint16_t)(hw->phy_spd_default &
+                                      (u16)(hw->phy_spd_default &
                                       ~IGP01E1000_GMII_SPD));
         if (ret_val)
             return ret_val;
@@ -6574,7 +6574,7 @@ void
 e1000_get_bus_info(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t pci_ex_link_status;
+    u16 pci_ex_link_status;
     uint32_t status;
 
     switch (hw->mac_type) {
@@ -6674,13 +6674,13 @@ e1000_write_reg_io(struct e1000_hw *hw,
  *****************************************************************************/
 static int32_t
 e1000_get_cable_length(struct e1000_hw *hw,
-                       uint16_t *min_length,
-                       uint16_t *max_length)
+                       u16 *min_length,
+                       u16 *max_length)
 {
     int32_t ret_val;
-    uint16_t agc_value = 0;
-    uint16_t i, phy_data;
-    uint16_t cable_length;
+    u16 agc_value = 0;
+    u16 i, phy_data;
+    u16 cable_length;
 
     DEBUGFUNC("e1000_get_cable_length");
 
@@ -6751,9 +6751,9 @@ e1000_get_cable_length(struct e1000_hw *hw,
             break;
         }
     } else if (hw->phy_type == e1000_phy_igp) { /* For IGP PHY */
-        uint16_t cur_agc_value;
-        uint16_t min_agc_value = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
-        uint16_t agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
+        u16 cur_agc_value;
+        u16 min_agc_value = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
+        u16 agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
                                                          {IGP01E1000_PHY_AGC_A,
                                                           IGP01E1000_PHY_AGC_B,
                                                           IGP01E1000_PHY_AGC_C,
@@ -6799,9 +6799,9 @@ e1000_get_cable_length(struct e1000_hw *hw,
                       IGP01E1000_AGC_RANGE;
     } else if (hw->phy_type == e1000_phy_igp_2 ||
                hw->phy_type == e1000_phy_igp_3) {
-        uint16_t cur_agc_index, max_agc_index = 0;
-        uint16_t min_agc_index = IGP02E1000_AGC_LENGTH_TABLE_SIZE - 1;
-        uint16_t agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
+        u16 cur_agc_index, max_agc_index = 0;
+        u16 min_agc_index = IGP02E1000_AGC_LENGTH_TABLE_SIZE - 1;
+        u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
                                                          {IGP02E1000_PHY_AGC_A,
                                                           IGP02E1000_PHY_AGC_B,
                                                           IGP02E1000_PHY_AGC_C,
@@ -6868,7 +6868,7 @@ e1000_check_polarity(struct e1000_hw *hw,
                      e1000_rev_polarity *polarity)
 {
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_check_polarity");
 
@@ -6943,7 +6943,7 @@ static int32_t
 e1000_check_downshift(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_check_downshift");
 
@@ -6990,13 +6990,13 @@ e1000_config_dsp_after_link_change(struct e1000_hw *hw,
                                    bool link_up)
 {
     int32_t ret_val;
-    uint16_t phy_data, phy_saved_data, speed, duplex, i;
-    uint16_t dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
+    u16 phy_data, phy_saved_data, speed, duplex, i;
+    u16 dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
                                         {IGP01E1000_PHY_AGC_PARAM_A,
                                         IGP01E1000_PHY_AGC_PARAM_B,
                                         IGP01E1000_PHY_AGC_PARAM_C,
                                         IGP01E1000_PHY_AGC_PARAM_D};
-    uint16_t min_length, max_length;
+    u16 min_length, max_length;
 
     DEBUGFUNC("e1000_config_dsp_after_link_change");
 
@@ -7038,7 +7038,7 @@ e1000_config_dsp_after_link_change(struct e1000_hw *hw,
             if ((hw->ffe_config_state == e1000_ffe_config_enabled) &&
                (min_length < e1000_igp_cable_length_50)) {
 
-                uint16_t ffe_idle_err_timeout = FFE_IDLE_ERR_COUNT_TIMEOUT_20;
+                u16 ffe_idle_err_timeout = FFE_IDLE_ERR_COUNT_TIMEOUT_20;
                 uint32_t idle_errs = 0;
 
                 /* clear previous idle error counts */
@@ -7177,7 +7177,7 @@ static int32_t
 e1000_set_phy_mode(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t eeprom_data;
+    u16 eeprom_data;
 
     DEBUGFUNC("e1000_set_phy_mode");
 
@@ -7224,7 +7224,7 @@ e1000_set_d3_lplu_state(struct e1000_hw *hw,
 {
     uint32_t phy_ctrl = 0;
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
     DEBUGFUNC("e1000_set_d3_lplu_state");
 
     if (hw->phy_type != e1000_phy_igp && hw->phy_type != e1000_phy_igp_2
@@ -7354,7 +7354,7 @@ e1000_set_d0_lplu_state(struct e1000_hw *hw,
 {
     uint32_t phy_ctrl = 0;
     int32_t ret_val;
-    uint16_t phy_data;
+    u16 phy_data;
     DEBUGFUNC("e1000_set_d0_lplu_state");
 
     if (hw->mac_type <= e1000_82547_rev_2)
@@ -7443,8 +7443,8 @@ static int32_t
 e1000_set_vco_speed(struct e1000_hw *hw)
 {
     int32_t  ret_val;
-    uint16_t default_page = 0;
-    uint16_t phy_data;
+    u16 default_page = 0;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_set_vco_speed");
 
@@ -7566,12 +7566,12 @@ e1000_mng_enable_host_if(struct e1000_hw * hw)
  ****************************************************************************/
 static int32_t
 e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
-                        uint16_t length, uint16_t offset, u8 *sum)
+                        u16 length, u16 offset, u8 *sum)
 {
     u8 *tmp;
     u8 *bufptr = buffer;
     uint32_t data = 0;
-    uint16_t remaining, i, j, prev_bytes;
+    u16 remaining, i, j, prev_bytes;
 
     /* sum = only sum of the data and it is not checksum */
 
@@ -7636,14 +7636,14 @@ static int32_t
 e1000_mng_write_cmd_header(struct e1000_hw * hw,
                            struct e1000_host_mng_command_header * hdr)
 {
-    uint16_t i;
+    u16 i;
     u8 sum;
     u8 *buffer;
 
     /* Write the whole command header structure which includes sum of
      * the buffer */
 
-    uint16_t length = sizeof(struct e1000_host_mng_command_header);
+    u16 length = sizeof(struct e1000_host_mng_command_header);
 
     sum = hdr->checksum;
     hdr->checksum = 0;
@@ -7714,7 +7714,7 @@ e1000_check_mng_mode(struct e1000_hw *hw)
  ****************************************************************************/
 int32_t
 e1000_mng_write_dhcp_info(struct e1000_hw * hw, u8 *buffer,
-                          uint16_t length)
+                          u16 length)
 {
     int32_t ret_val;
     struct e1000_host_mng_command_header hdr;
@@ -7836,8 +7836,8 @@ static int32_t
 e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 {
     int32_t ret_val;
-    uint16_t mii_status_reg;
-    uint16_t i;
+    u16 mii_status_reg;
+    u16 i;
 
     /* Polarity reversal workaround for forced 10F/10H links. */
 
@@ -8389,15 +8389,15 @@ e1000_release_software_flag(struct e1000_hw *hw)
  * words - number of words to read
  *****************************************************************************/
 static int32_t
-e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
-                       uint16_t *data)
+e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
+                       u16 *data)
 {
     int32_t  error = E1000_SUCCESS;
     uint32_t flash_bank = 0;
     uint32_t act_offset = 0;
     uint32_t bank_offset = 0;
-    uint16_t word = 0;
-    uint16_t i = 0;
+    u16 word = 0;
+    u16 i = 0;
 
     /* We need to know which is the valid flash bank.  In the event
      * that we didn't allocate eeprom_shadow_ram, we may not be
@@ -8445,8 +8445,8 @@ e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
  * data - words to write to the EEPROM
  *****************************************************************************/
 static int32_t
-e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
-                        uint16_t *data)
+e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
+                        u16 *data)
 {
     uint32_t i = 0;
     int32_t error = E1000_SUCCESS;
@@ -8595,7 +8595,7 @@ e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout)
  *****************************************************************************/
 static int32_t
 e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
-                     uint32_t size, uint16_t* data)
+                     uint32_t size, u16* data)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
@@ -8642,7 +8642,7 @@ e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
             if (size == 1) {
                 *data = (u8)(flash_data & 0x000000FF);
             } else if (size == 2) {
-                *data = (uint16_t)(flash_data & 0x0000FFFF);
+                *data = (u16)(flash_data & 0x0000FFFF);
             }
             break;
         } else {
@@ -8674,7 +8674,7 @@ e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
  *****************************************************************************/
 static int32_t
 e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
-                      uint16_t data)
+                      u16 data)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
@@ -8751,7 +8751,7 @@ static int32_t
 e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, u8* data)
 {
     int32_t status = E1000_SUCCESS;
-    uint16_t word = 0;
+    u16 word = 0;
 
     status = e1000_read_ich8_data(hw, index, 1, &word);
     if (status == E1000_SUCCESS) {
@@ -8807,7 +8807,7 @@ static int32_t
 e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 data)
 {
     int32_t status = E1000_SUCCESS;
-    uint16_t word = (uint16_t)data;
+    u16 word = (u16)data;
 
     status = e1000_write_ich8_data(hw, index, 1, word);
 
@@ -8822,7 +8822,7 @@ e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 data)
  * data - Pointer to a word to store the value read.
  *****************************************************************************/
 static int32_t
-e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data)
+e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, u16 *data)
 {
     int32_t status = E1000_SUCCESS;
     status = e1000_read_ich8_data(hw, index, 2, data);
@@ -8935,11 +8935,11 @@ e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
                                       uint32_t cnf_base_addr, uint32_t cnf_size)
 {
     uint32_t ret_val = E1000_SUCCESS;
-    uint16_t word_addr, reg_data, reg_addr;
-    uint16_t i;
+    u16 word_addr, reg_data, reg_addr;
+    u16 i;
 
     /* cnf_base_addr is in DWORD */
-    word_addr = (uint16_t)(cnf_base_addr << 1);
+    word_addr = (u16)(cnf_base_addr << 1);
 
     /* cnf_size is returned in size of dwords */
     for (i = 0; i < cnf_size; i++) {
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 4d02ac9..98d14d9 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -100,7 +100,7 @@ typedef enum {
 } e1000_fc_type;
 
 struct e1000_shadow_ram {
-    uint16_t eeprom_word;
+    u16 eeprom_word;
     bool modified;
 };
 
@@ -269,11 +269,11 @@ struct e1000_phy_stats {
 
 struct e1000_eeprom_info {
     e1000_eeprom_type type;
-    uint16_t word_size;
-    uint16_t opcode_bits;
-    uint16_t address_bits;
-    uint16_t delay_usec;
-    uint16_t page_size;
+    u16 word_size;
+    u16 opcode_bits;
+    u16 address_bits;
+    u16 delay_usec;
+    u16 page_size;
     bool use_eerd;
     bool use_eewr;
 };
@@ -318,12 +318,12 @@ int32_t e1000_setup_link(struct e1000_hw *hw);
 int32_t e1000_phy_setup_autoneg(struct e1000_hw *hw);
 void e1000_config_collision_dist(struct e1000_hw *hw);
 int32_t e1000_check_for_link(struct e1000_hw *hw);
-int32_t e1000_get_speed_and_duplex(struct e1000_hw *hw, uint16_t *speed, uint16_t *duplex);
+int32_t e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex);
 int32_t e1000_force_mac_fc(struct e1000_hw *hw);
 
 /* PHY */
-int32_t e1000_read_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t *phy_data);
-int32_t e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t data);
+int32_t e1000_read_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, u16 *phy_data);
+int32_t e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, u16 data);
 int32_t e1000_phy_hw_reset(struct e1000_hw *hw);
 int32_t e1000_phy_reset(struct e1000_hw *hw);
 int32_t e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
@@ -356,9 +356,9 @@ uint32_t e1000_enable_mng_pass_thru(struct e1000_hw *hw);
 struct e1000_host_mng_command_header {
     u8 command_id;
     u8 checksum;
-    uint16_t reserved1;
-    uint16_t reserved2;
-    uint16_t command_length;
+    u16 reserved1;
+    u16 reserved2;
+    u16 command_length;
 };
 
 struct e1000_host_mng_command_info {
@@ -368,35 +368,35 @@ struct e1000_host_mng_command_info {
 #ifdef __BIG_ENDIAN
 struct e1000_host_mng_dhcp_cookie{
     uint32_t signature;
-    uint16_t vlan_id;
+    u16 vlan_id;
     u8 reserved0;
     u8 status;
     uint32_t reserved1;
     u8 checksum;
     u8 reserved3;
-    uint16_t reserved2;
+    u16 reserved2;
 };
 #else
 struct e1000_host_mng_dhcp_cookie{
     uint32_t signature;
     u8 status;
     u8 reserved0;
-    uint16_t vlan_id;
+    u16 vlan_id;
     uint32_t reserved1;
-    uint16_t reserved2;
+    u16 reserved2;
     u8 reserved3;
     u8 checksum;
 };
 #endif
 
 int32_t e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer,
-                                  uint16_t length);
+                                  u16 length);
 bool e1000_check_mng_mode(struct e1000_hw *hw);
 bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
-int32_t e1000_read_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, uint16_t *data);
+int32_t e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
 int32_t e1000_validate_eeprom_checksum(struct e1000_hw *hw);
 int32_t e1000_update_eeprom_checksum(struct e1000_hw *hw);
-int32_t e1000_write_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, uint16_t *data);
+int32_t e1000_write_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
 int32_t e1000_read_mac_addr(struct e1000_hw * hw);
 
 /* Filters (multicast, vlan, receive) */
@@ -421,7 +421,7 @@ void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats, u
 void e1000_get_bus_info(struct e1000_hw *hw);
 void e1000_pci_set_mwi(struct e1000_hw *hw);
 void e1000_pci_clear_mwi(struct e1000_hw *hw);
-int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value);
+int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, u16 *value);
 void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc);
 int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
 /* Port I/O is only supported on 82544 and newer */
@@ -1422,21 +1422,21 @@ struct e1000_hw {
 	uint32_t		ledctl_mode2;
 	bool			tx_pkt_filtering;
 	struct e1000_host_mng_dhcp_cookie mng_cookie;
-	uint16_t		phy_spd_default;
-	uint16_t		autoneg_advertised;
-	uint16_t		pci_cmd_word;
-	uint16_t		fc_high_water;
-	uint16_t		fc_low_water;
-	uint16_t		fc_pause_time;
-	uint16_t		current_ifs_val;
-	uint16_t		ifs_min_val;
-	uint16_t		ifs_max_val;
-	uint16_t		ifs_step_size;
-	uint16_t		ifs_ratio;
-	uint16_t		device_id;
-	uint16_t		vendor_id;
-	uint16_t		subsystem_id;
-	uint16_t		subsystem_vendor_id;
+	u16		phy_spd_default;
+	u16		autoneg_advertised;
+	u16		pci_cmd_word;
+	u16		fc_high_water;
+	u16		fc_low_water;
+	u16		fc_pause_time;
+	u16		current_ifs_val;
+	u16		ifs_min_val;
+	u16		ifs_max_val;
+	u16		ifs_step_size;
+	u16		ifs_ratio;
+	u16		device_id;
+	u16		vendor_id;
+	u16		subsystem_id;
+	u16		subsystem_vendor_id;
 	u8			revision_id;
 	u8			autoneg;
 	u8			mdix;
@@ -3313,28 +3313,28 @@ struct e1000_host_command_info {
 union ich8_hws_flash_status {
     struct ich8_hsfsts {
 #ifdef E1000_BIG_ENDIAN
-        uint16_t reserved2      :6;
-        uint16_t fldesvalid     :1;
-        uint16_t flockdn        :1;
-        uint16_t flcdone        :1;
-        uint16_t flcerr         :1;
-        uint16_t dael           :1;
-        uint16_t berasesz       :2;
-        uint16_t flcinprog      :1;
-        uint16_t reserved1      :2;
+        u16 reserved2      :6;
+        u16 fldesvalid     :1;
+        u16 flockdn        :1;
+        u16 flcdone        :1;
+        u16 flcerr         :1;
+        u16 dael           :1;
+        u16 berasesz       :2;
+        u16 flcinprog      :1;
+        u16 reserved1      :2;
 #else
-        uint16_t flcdone        :1;   /* bit 0 Flash Cycle Done */
-        uint16_t flcerr         :1;   /* bit 1 Flash Cycle Error */
-        uint16_t dael           :1;   /* bit 2 Direct Access error Log */
-        uint16_t berasesz       :2;   /* bit 4:3 Block/Sector Erase Size */
-        uint16_t flcinprog      :1;   /* bit 5 flash SPI cycle in Progress */
-        uint16_t reserved1      :2;   /* bit 13:6 Reserved */
-        uint16_t reserved2      :6;   /* bit 13:6 Reserved */
-        uint16_t fldesvalid     :1;   /* bit 14 Flash Descriptor Valid */
-        uint16_t flockdn        :1;   /* bit 15 Flash Configuration Lock-Down */
+        u16 flcdone        :1;   /* bit 0 Flash Cycle Done */
+        u16 flcerr         :1;   /* bit 1 Flash Cycle Error */
+        u16 dael           :1;   /* bit 2 Direct Access error Log */
+        u16 berasesz       :2;   /* bit 4:3 Block/Sector Erase Size */
+        u16 flcinprog      :1;   /* bit 5 flash SPI cycle in Progress */
+        u16 reserved1      :2;   /* bit 13:6 Reserved */
+        u16 reserved2      :6;   /* bit 13:6 Reserved */
+        u16 fldesvalid     :1;   /* bit 14 Flash Descriptor Valid */
+        u16 flockdn        :1;   /* bit 15 Flash Configuration Lock-Down */
 #endif
     } hsf_status;
-    uint16_t regval;
+    u16 regval;
 };
 
 /* ICH8 GbE Flash Hardware Sequencing Flash control Register bit breakdown */
@@ -3342,20 +3342,20 @@ union ich8_hws_flash_status {
 union ich8_hws_flash_ctrl {
     struct ich8_hsflctl {
 #ifdef E1000_BIG_ENDIAN
-        uint16_t fldbcount      :2;
-        uint16_t flockdn        :6;
-        uint16_t flcgo          :1;
-        uint16_t flcycle        :2;
-        uint16_t reserved       :5;
+        u16 fldbcount      :2;
+        u16 flockdn        :6;
+        u16 flcgo          :1;
+        u16 flcycle        :2;
+        u16 reserved       :5;
 #else
-        uint16_t flcgo          :1;   /* 0 Flash Cycle Go */
-        uint16_t flcycle        :2;   /* 2:1 Flash Cycle */
-        uint16_t reserved       :5;   /* 7:3 Reserved  */
-        uint16_t fldbcount      :2;   /* 9:8 Flash Data Byte Count */
-        uint16_t flockdn        :6;   /* 15:10 Reserved */
+        u16 flcgo          :1;   /* 0 Flash Cycle Go */
+        u16 flcycle        :2;   /* 2:1 Flash Cycle */
+        u16 reserved       :5;   /* 7:3 Reserved  */
+        u16 fldbcount      :2;   /* 9:8 Flash Data Byte Count */
+        u16 flockdn        :6;   /* 15:10 Reserved */
 #endif
     } hsf_ctrl;
-    uint16_t regval;
+    u16 regval;
 };
 
 /* ICH8 Flash Region Access Permissions */
@@ -3373,7 +3373,7 @@ union ich8_hws_flash_regacc {
         uint32_t gmwag          :8;   /* 31:24 GbE Master Write Access Grant */
 #endif
     } hsf_flregacc;
-    uint16_t regval;
+    u16 regval;
 };
 
 /* Miscellaneous PHY bit definitions. */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 16a40ea..62f1430 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -127,7 +127,7 @@ int e1000_up(struct e1000_adapter *adapter);
 void e1000_down(struct e1000_adapter *adapter);
 void e1000_reinit_locked(struct e1000_adapter *adapter);
 void e1000_reset(struct e1000_adapter *adapter);
-int e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx);
+int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx);
 int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
 int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
 void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
@@ -203,8 +203,8 @@ static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
                                        struct sk_buff *skb);
 
 static void e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
-static void e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid);
-static void e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
+static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
+static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
 
 static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
@@ -368,8 +368,8 @@ static void
 e1000_update_mng_vlan(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint16_t vid = adapter->hw.mng_cookie.vlan_id;
-	uint16_t old_vid = adapter->mng_vlan_id;
+	u16 vid = adapter->hw.mng_cookie.vlan_id;
+	u16 old_vid = adapter->mng_vlan_id;
 	if (adapter->vlgrp) {
 		if (!vlan_group_get_device(adapter->vlgrp, vid)) {
 			if (adapter->hw.mng_cookie.status &
@@ -379,7 +379,7 @@ e1000_update_mng_vlan(struct e1000_adapter *adapter)
 			} else
 				adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 
-			if ((old_vid != (uint16_t)E1000_MNG_VLAN_NONE) &&
+			if ((old_vid != (u16)E1000_MNG_VLAN_NONE) &&
 					(vid != old_vid) &&
 			    !vlan_group_get_device(adapter->vlgrp, old_vid))
 				e1000_vlan_rx_kill_vid(netdev, old_vid);
@@ -566,7 +566,7 @@ int e1000_up(struct e1000_adapter *adapter)
 
 void e1000_power_up_phy(struct e1000_adapter *adapter)
 {
-	uint16_t mii_reg = 0;
+	u16 mii_reg = 0;
 
 	/* Just clear the power down bit to wake the phy back up */
 	if (adapter->hw.media_type == e1000_media_type_copper) {
@@ -587,7 +587,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 	 * (c) SoL/IDER session is active */
 	if (!adapter->wol && adapter->hw.mac_type >= e1000_82540 &&
 	   adapter->hw.media_type == e1000_media_type_copper) {
-		uint16_t mii_reg = 0;
+		u16 mii_reg = 0;
 
 		switch (adapter->hw.mac_type) {
 		case e1000_82540:
@@ -668,7 +668,7 @@ void
 e1000_reset(struct e1000_adapter *adapter)
 {
 	uint32_t pba = 0, tx_space, min_tx_space, min_rx_space;
-	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
+	u16 fc_high_water_mark = E1000_FC_HIGH_DIFF;
 	bool legacy_pba_adjust = false;
 
 	/* Repartition Pba for greater than 9k mtu
@@ -832,7 +832,7 @@ e1000_reset(struct e1000_adapter *adapter)
 	if (!adapter->smart_power_down &&
 	    (adapter->hw.mac_type == e1000_82571 ||
 	     adapter->hw.mac_type == e1000_82572)) {
-		uint16_t phy_data = 0;
+		u16 phy_data = 0;
 		/* speed up time to link by disabling smart power down, ignore
 		 * the return value of this function because there is nothing
 		 * different we would do if it failed */
@@ -926,8 +926,8 @@ e1000_probe(struct pci_dev *pdev,
 	static int cards_found = 0;
 	static int global_quad_port_a = 0; /* global ksp3 port a indication */
 	int i, err, pci_using_dac;
-	uint16_t eeprom_data = 0;
-	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
+	u16 eeprom_data = 0;
+	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 	DECLARE_MAC_BUF(mac);
 
 	if ((err = pci_enable_device(pdev)))
@@ -2832,7 +2832,7 @@ enum latency_range {
  * @bytes: the number of bytes during this measurement interval
  **/
 static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
-                                   uint16_t itr_setting,
+                                   u16 itr_setting,
                                    int packets,
                                    int bytes)
 {
@@ -2884,7 +2884,7 @@ update_itr_done:
 static void e1000_set_itr(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	uint16_t current_itr;
+	u16 current_itr;
 	uint32_t new_itr = adapter->itr;
 
 	if (unlikely(hw->mac_type < e1000_82540))
@@ -2960,7 +2960,7 @@ e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 	struct e1000_buffer *buffer_info;
 	unsigned int i;
 	uint32_t cmd_length = 0;
-	uint16_t ipcse = 0, tucse, mss;
+	u16 ipcse = 0, tucse, mss;
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
 	int err;
 
@@ -3269,7 +3269,7 @@ static int
 e1000_transfer_dhcp_info(struct e1000_adapter *adapter, struct sk_buff *skb)
 {
 	struct e1000_hw *hw =  &adapter->hw;
-	uint16_t length, offset;
+	u16 length, offset;
 	if (vlan_tx_tag_present(skb)) {
 		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
 			( adapter->hw.mng_cookie.status &
@@ -3557,7 +3557,7 @@ e1000_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-	uint16_t eeprom_data = 0;
+	u16 eeprom_data = 0;
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
@@ -3652,7 +3652,7 @@ e1000_update_stats(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long flags;
-	uint16_t phy_tmp;
+	u16 phy_tmp;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
@@ -4142,7 +4142,7 @@ e1000_rx_checksum(struct e1000_adapter *adapter,
 		  uint32_t status_err, uint32_t csum,
 		  struct sk_buff *skb)
 {
-	uint16_t status = (uint16_t)status_err;
+	u16 status = (u16)status_err;
 	u8 errors = (u8)(status_err >> 24);
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -4759,8 +4759,8 @@ no_buffers:
 static void
 e1000_smartspeed(struct e1000_adapter *adapter)
 {
-	uint16_t phy_status;
-	uint16_t phy_ctrl;
+	u16 phy_status;
+	u16 phy_ctrl;
 
 	if ((adapter->hw.phy_type != e1000_phy_igp) || !adapter->hw.autoneg ||
 	   !(adapter->hw.autoneg_advertised & ADVERTISE_1000_FULL))
@@ -4839,8 +4839,8 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int retval;
-	uint16_t mii_reg;
-	uint16_t spddplx;
+	u16 mii_reg;
+	u16 spddplx;
 	unsigned long flags;
 
 	if (adapter->hw.media_type != e1000_media_type_copper)
@@ -4960,10 +4960,10 @@ e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
 }
 
 int32_t
-e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
+e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, u16 *value)
 {
     struct e1000_adapter *adapter = hw->back;
-    uint16_t cap_offset;
+    u16 cap_offset;
 
     cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
     if (!cap_offset)
@@ -5016,7 +5016,7 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 			rctl &= ~E1000_RCTL_VFE;
 			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 			if (adapter->mng_vlan_id !=
-			    (uint16_t)E1000_MNG_VLAN_NONE) {
+			    (u16)E1000_MNG_VLAN_NONE) {
 				e1000_vlan_rx_kill_vid(netdev,
 				                       adapter->mng_vlan_id);
 				adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
@@ -5029,7 +5029,7 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 }
 
 static void
-e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
+e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t vfta, index;
@@ -5046,7 +5046,7 @@ e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 }
 
 static void
-e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
+e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t vfta, index;
@@ -5078,7 +5078,7 @@ e1000_restore_vlan(struct e1000_adapter *adapter)
 	e1000_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 
 	if (adapter->vlgrp) {
-		uint16_t vid;
+		u16 vid;
 		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
 			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
@@ -5088,7 +5088,7 @@ e1000_restore_vlan(struct e1000_adapter *adapter)
 }
 
 int
-e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx)
+e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 {
 	adapter->hw.autoneg = 0;
 
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
