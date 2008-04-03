From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] ixgb: convert uint16_t style integers to
	u16
Date: Thu, 03 Apr 2008 10:06:25 -0700
Message-ID: <20080403170625.22624.13870.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
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

From: Joe Perches <joe@perches.com>

Conglomerate of 4 separate patches by Joe.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h         |   32 +++--
 drivers/net/ixgb/ixgb_ee.c      |   74 ++++++------
 drivers/net/ixgb/ixgb_ee.h      |   10 +-
 drivers/net/ixgb/ixgb_ethtool.c |   50 ++++----
 drivers/net/ixgb/ixgb_hw.c      |  144 ++++++++++++------------
 drivers/net/ixgb/ixgb_hw.h      |  234 ++++++++++++++++++++-------------------
 drivers/net/ixgb/ixgb_main.c    |   60 +++++-----
 7 files changed, 302 insertions(+), 302 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index f2fff90..16f9c75 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -117,8 +117,8 @@ struct ixgb_buffer {
 	struct sk_buff *skb;
 	dma_addr_t dma;
 	unsigned long time_stamp;
-	uint16_t length;
-	uint16_t next_to_watch;
+	u16 length;
+	u16 next_to_watch;
 };
 
 struct ixgb_desc_ring {
@@ -152,11 +152,11 @@ struct ixgb_desc_ring {
 struct ixgb_adapter {
 	struct timer_list watchdog_timer;
 	struct vlan_group *vlgrp;
-	uint32_t bd_number;
-	uint32_t rx_buffer_len;
-	uint32_t part_num;
-	uint16_t link_speed;
-	uint16_t link_duplex;
+	u32 bd_number;
+	u32 rx_buffer_len;
+	u32 part_num;
+	u16 link_speed;
+	u16 link_duplex;
 	spinlock_t tx_lock;
 	struct work_struct tx_timeout_task;
 
@@ -167,19 +167,19 @@ struct ixgb_adapter {
 	struct ixgb_desc_ring tx_ring ____cacheline_aligned_in_smp;
 	unsigned int restart_queue;
 	unsigned long timeo_start;
-	uint32_t tx_cmd_type;
-	uint64_t hw_csum_tx_good;
-	uint64_t hw_csum_tx_error;
-	uint32_t tx_int_delay;
-	uint32_t tx_timeout_count;
+	u32 tx_cmd_type;
+	u64 hw_csum_tx_good;
+	u64 hw_csum_tx_error;
+	u32 tx_int_delay;
+	u32 tx_timeout_count;
 	bool tx_int_delay_enable;
 	bool detect_tx_hung;
 
 	/* RX */
 	struct ixgb_desc_ring rx_ring;
-	uint64_t hw_csum_rx_error;
-	uint64_t hw_csum_rx_good;
-	uint32_t rx_int_delay;
+	u64 hw_csum_rx_error;
+	u64 hw_csum_rx_good;
+	u32 rx_int_delay;
 	bool rx_csum;
 
 	/* OS defined structs */
@@ -192,7 +192,7 @@ struct ixgb_adapter {
 	struct ixgb_hw hw;
 	u16 msg_enable;
 	struct ixgb_hw_stats stats;
-	uint32_t alloc_rx_buff_failed;
+	u32 alloc_rx_buff_failed;
 	bool have_msi;
 	unsigned long flags;
 };
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 8e9302f..2f7ed52 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -29,11 +29,11 @@
 #include "ixgb_hw.h"
 #include "ixgb_ee.h"
 /* Local prototypes */
-static uint16_t ixgb_shift_in_bits(struct ixgb_hw *hw);
+static u16 ixgb_shift_in_bits(struct ixgb_hw *hw);
 
 static void ixgb_shift_out_bits(struct ixgb_hw *hw,
-				uint16_t data,
-				uint16_t count);
+				u16 data,
+				u16 count);
 static void ixgb_standby_eeprom(struct ixgb_hw *hw);
 
 static bool ixgb_wait_eeprom_command(struct ixgb_hw *hw);
@@ -48,7 +48,7 @@ static void ixgb_cleanup_eeprom(struct ixgb_hw *hw);
  *****************************************************************************/
 static void
 ixgb_raise_clock(struct ixgb_hw *hw,
-		  uint32_t *eecd_reg)
+		  u32 *eecd_reg)
 {
 	/* Raise the clock input to the EEPROM (by setting the SK bit), and then
 	 *  wait 50 microseconds.
@@ -67,7 +67,7 @@ ixgb_raise_clock(struct ixgb_hw *hw,
  *****************************************************************************/
 static void
 ixgb_lower_clock(struct ixgb_hw *hw,
-		  uint32_t *eecd_reg)
+		  u32 *eecd_reg)
 {
 	/* Lower the clock input to the EEPROM (by clearing the SK bit), and then
 	 * wait 50 microseconds.
@@ -87,11 +87,11 @@ ixgb_lower_clock(struct ixgb_hw *hw,
  *****************************************************************************/
 static void
 ixgb_shift_out_bits(struct ixgb_hw *hw,
-					 uint16_t data,
-					 uint16_t count)
+					 u16 data,
+					 u16 count)
 {
-	uint32_t eecd_reg;
-	uint32_t mask;
+	u32 eecd_reg;
+	u32 mask;
 
 	/* We need to shift "count" bits out to the EEPROM. So, value in the
 	 * "data" parameter will be shifted out to the EEPROM one bit at a time.
@@ -133,12 +133,12 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static uint16_t
+static u16
 ixgb_shift_in_bits(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
-	uint32_t i;
-	uint16_t data;
+	u32 eecd_reg;
+	u32 i;
+	u16 data;
 
 	/* In order to read a register from the EEPROM, we need to shift 16 bits
 	 * in from the EEPROM. Bits are "shifted in" by raising the clock input to
@@ -179,7 +179,7 @@ ixgb_shift_in_bits(struct ixgb_hw *hw)
 static void
 ixgb_setup_eeprom(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
+	u32 eecd_reg;
 
 	eecd_reg = IXGB_READ_REG(hw, EECD);
 
@@ -201,7 +201,7 @@ ixgb_setup_eeprom(struct ixgb_hw *hw)
 static void
 ixgb_standby_eeprom(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
+	u32 eecd_reg;
 
 	eecd_reg = IXGB_READ_REG(hw, EECD);
 
@@ -235,7 +235,7 @@ ixgb_standby_eeprom(struct ixgb_hw *hw)
 static void
 ixgb_clock_eeprom(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
+	u32 eecd_reg;
 
 	eecd_reg = IXGB_READ_REG(hw, EECD);
 
@@ -259,7 +259,7 @@ ixgb_clock_eeprom(struct ixgb_hw *hw)
 static void
 ixgb_cleanup_eeprom(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
+	u32 eecd_reg;
 
 	eecd_reg = IXGB_READ_REG(hw, EECD);
 
@@ -285,8 +285,8 @@ ixgb_cleanup_eeprom(struct ixgb_hw *hw)
 static bool
 ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
-	uint32_t i;
+	u32 eecd_reg;
+	u32 i;
 
 	/* Toggle the CS line.  This in effect tells to EEPROM to actually execute
 	 * the command in question.
@@ -325,13 +325,13 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 bool
 ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 {
-	uint16_t checksum = 0;
-	uint16_t i;
+	u16 checksum = 0;
+	u16 i;
 
 	for(i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
 		checksum += ixgb_read_eeprom(hw, i);
 
-	if(checksum == (uint16_t) EEPROM_SUM)
+	if(checksum == (u16) EEPROM_SUM)
 		return (true);
 	else
 		return (false);
@@ -348,13 +348,13 @@ ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 void
 ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
 {
-	uint16_t checksum = 0;
-	uint16_t i;
+	u16 checksum = 0;
+	u16 i;
 
 	for(i = 0; i < EEPROM_CHECKSUM_REG; i++)
 		checksum += ixgb_read_eeprom(hw, i);
 
-	checksum = (uint16_t) EEPROM_SUM - checksum;
+	checksum = (u16) EEPROM_SUM - checksum;
 
 	ixgb_write_eeprom(hw, EEPROM_CHECKSUM_REG, checksum);
 	return;
@@ -372,7 +372,7 @@ ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
  *
  *****************************************************************************/
 void
-ixgb_write_eeprom(struct ixgb_hw *hw, uint16_t offset, uint16_t data)
+ixgb_write_eeprom(struct ixgb_hw *hw, u16 offset, u16 data)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
@@ -425,11 +425,11 @@ ixgb_write_eeprom(struct ixgb_hw *hw, uint16_t offset, uint16_t data)
  * Returns:
  *  The 16-bit value read from the eeprom
  *****************************************************************************/
-uint16_t
+u16
 ixgb_read_eeprom(struct ixgb_hw *hw,
-		  uint16_t offset)
+		  u16 offset)
 {
-	uint16_t data;
+	u16 data;
 
 	/*  Prepare the EEPROM for reading  */
 	ixgb_setup_eeprom(hw);
@@ -463,8 +463,8 @@ ixgb_read_eeprom(struct ixgb_hw *hw,
 bool
 ixgb_get_eeprom_data(struct ixgb_hw *hw)
 {
-	uint16_t i;
-	uint16_t checksum = 0;
+	u16 i;
+	u16 checksum = 0;
 	struct ixgb_ee_map_type *ee_map;
 
 	DEBUGFUNC("ixgb_get_eeprom_data");
@@ -473,13 +473,13 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 
 	DEBUGOUT("ixgb_ee: Reading eeprom data\n");
 	for(i = 0; i < IXGB_EEPROM_SIZE ; i++) {
-		uint16_t ee_data;
+		u16 ee_data;
 		ee_data = ixgb_read_eeprom(hw, i);
 		checksum += ee_data;
 		hw->eeprom[i] = cpu_to_le16(ee_data);
 	}
 
-	if (checksum != (uint16_t) EEPROM_SUM) {
+	if (checksum != (u16) EEPROM_SUM) {
 		DEBUGOUT("ixgb_ee: Checksum invalid.\n");
 		/* clear the init_ctrl_reg_1 to signify that the cache is
 		 * invalidated */
@@ -529,7 +529,7 @@ ixgb_check_and_get_eeprom_data (struct ixgb_hw* hw)
  *          Word at indexed offset in eeprom, if valid, 0 otherwise.
  ******************************************************************************/
 __le16
-ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index)
+ixgb_get_eeprom_word(struct ixgb_hw *hw, u16 index)
 {
 
 	if ((index < IXGB_EEPROM_SIZE) &&
@@ -550,7 +550,7 @@ ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index)
  ******************************************************************************/
 void
 ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
-			uint8_t *mac_addr)
+			u8 *mac_addr)
 {
 	int i;
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
@@ -574,7 +574,7 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
  * Returns:
  *          PBA number if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint32_t
+u32
 ixgb_get_ee_pba_number(struct ixgb_hw *hw)
 {
 	if (ixgb_check_and_get_eeprom_data(hw) == true)
@@ -593,7 +593,7 @@ ixgb_get_ee_pba_number(struct ixgb_hw *hw)
  * Returns:
  *          Device Id if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t
+u16
 ixgb_get_ee_device_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ixgb/ixgb_ee.h
index da62f58..4b7bd0d 100644
--- a/drivers/net/ixgb/ixgb_ee.h
+++ b/drivers/net/ixgb/ixgb_ee.h
@@ -75,7 +75,7 @@
 
 /* EEPROM structure */
 struct ixgb_ee_map_type {
-	uint8_t mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];
+	u8 mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];
 	__le16 compatibility;
 	__le16 reserved1[4];
 	__le32 pba_number;
@@ -88,19 +88,19 @@ struct ixgb_ee_map_type {
 	__le16 oem_reserved[16];
 	__le16 swdpins_reg;
 	__le16 circuit_ctrl_reg;
-	uint8_t d3_power;
-	uint8_t d0_power;
+	u8 d3_power;
+	u8 d0_power;
 	__le16 reserved2[28];
 	__le16 checksum;
 };
 
 /* EEPROM Functions */
-uint16_t ixgb_read_eeprom(struct ixgb_hw *hw, uint16_t reg);
+u16 ixgb_read_eeprom(struct ixgb_hw *hw, u16 reg);
 
 bool ixgb_validate_eeprom_checksum(struct ixgb_hw *hw);
 
 void ixgb_update_eeprom_checksum(struct ixgb_hw *hw);
 
-void ixgb_write_eeprom(struct ixgb_hw *hw, uint16_t reg, uint16_t data);
+void ixgb_write_eeprom(struct ixgb_hw *hw, u16 reg, u16 data);
 
 #endif				/* IXGB_EE_H */
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 45ddf80..8464d8a 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -185,7 +185,7 @@ ixgb_set_pauseparam(struct net_device *netdev,
 	return 0;
 }
 
-static uint32_t
+static u32
 ixgb_get_rx_csum(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
@@ -194,7 +194,7 @@ ixgb_get_rx_csum(struct net_device *netdev)
 }
 
 static int
-ixgb_set_rx_csum(struct net_device *netdev, uint32_t data)
+ixgb_set_rx_csum(struct net_device *netdev, u32 data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
@@ -209,14 +209,14 @@ ixgb_set_rx_csum(struct net_device *netdev, uint32_t data)
 	return 0;
 }
 	
-static uint32_t
+static u32
 ixgb_get_tx_csum(struct net_device *netdev)
 {
 	return (netdev->features & NETIF_F_HW_CSUM) != 0;
 }
 
 static int
-ixgb_set_tx_csum(struct net_device *netdev, uint32_t data)
+ixgb_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	if (data)
 		netdev->features |= NETIF_F_HW_CSUM;
@@ -227,7 +227,7 @@ ixgb_set_tx_csum(struct net_device *netdev, uint32_t data)
 }
 
 static int
-ixgb_set_tso(struct net_device *netdev, uint32_t data)
+ixgb_set_tso(struct net_device *netdev, u32 data)
 {
 	if(data)
 		netdev->features |= NETIF_F_TSO;
@@ -236,7 +236,7 @@ ixgb_set_tso(struct net_device *netdev, uint32_t data)
 	return 0;
 } 
 
-static uint32_t
+static u32
 ixgb_get_msglevel(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
@@ -244,7 +244,7 @@ ixgb_get_msglevel(struct net_device *netdev)
 }
 
 static void
-ixgb_set_msglevel(struct net_device *netdev, uint32_t data)
+ixgb_set_msglevel(struct net_device *netdev, u32 data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	adapter->msg_enable = data;
@@ -254,7 +254,7 @@ ixgb_set_msglevel(struct net_device *netdev, uint32_t data)
 static int 
 ixgb_get_regs_len(struct net_device *netdev)
 {
-#define IXGB_REG_DUMP_LEN  136*sizeof(uint32_t)
+#define IXGB_REG_DUMP_LEN  136*sizeof(u32)
 	return IXGB_REG_DUMP_LEN;
 }
 
@@ -264,9 +264,9 @@ ixgb_get_regs(struct net_device *netdev,
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t *reg = p;
-	uint32_t *reg_start = reg;
-	uint8_t i;
+	u32 *reg = p;
+	u32 *reg_start = reg;
+	u8 i;
 
 	/* the 1 (one) below indicates an attempt at versioning, if the
 	 * interface in ethtool or the driver changes, this 1 should be
@@ -395,7 +395,7 @@ ixgb_get_regs(struct net_device *netdev,
 	*reg++ = IXGB_GET_STAT(adapter, xofftxc);	/* 134 */
 	*reg++ = IXGB_GET_STAT(adapter, rjc);	/* 135 */
 
-	regs->len = (reg - reg_start) * sizeof(uint32_t);
+	regs->len = (reg - reg_start) * sizeof(u32);
 }
 
 static int
@@ -407,7 +407,7 @@ ixgb_get_eeprom_len(struct net_device *netdev)
 
 static int
 ixgb_get_eeprom(struct net_device *netdev,
-		  struct ethtool_eeprom *eeprom, uint8_t *bytes)
+		  struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
@@ -445,7 +445,7 @@ ixgb_get_eeprom(struct net_device *netdev,
 		eeprom_buff[i] = ixgb_get_eeprom_word(hw, (first_word + i));
 	}
 
-	memcpy(bytes, (uint8_t *)eeprom_buff + (eeprom->offset & 1),
+	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1),
 			eeprom->len);
 	kfree(eeprom_buff);
 
@@ -455,14 +455,14 @@ geeprom_error:
 
 static int
 ixgb_set_eeprom(struct net_device *netdev,
-		  struct ethtool_eeprom *eeprom, uint8_t *bytes)
+		  struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	uint16_t *eeprom_buff;
+	u16 *eeprom_buff;
 	void *ptr;
 	int max_len, first_word, last_word;
-	uint16_t i;
+	u16 i;
 
 	if(eeprom->len == 0)
 		return -EINVAL;
@@ -563,12 +563,12 @@ ixgb_set_ringparam(struct net_device *netdev,
 	if(netif_running(adapter->netdev))
 		ixgb_down(adapter, true);
 
-	rxdr->count = max(ring->rx_pending,(uint32_t)MIN_RXD);
-	rxdr->count = min(rxdr->count,(uint32_t)MAX_RXD);
+	rxdr->count = max(ring->rx_pending,(u32)MIN_RXD);
+	rxdr->count = min(rxdr->count,(u32)MAX_RXD);
 	rxdr->count = ALIGN(rxdr->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 
-	txdr->count = max(ring->tx_pending,(uint32_t)MIN_TXD);
-	txdr->count = min(txdr->count,(uint32_t)MAX_TXD);
+	txdr->count = max(ring->tx_pending,(u32)MIN_TXD);
+	txdr->count = min(txdr->count,(u32)MAX_TXD);
 	txdr->count = ALIGN(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 
 	if(netif_running(adapter->netdev)) {
@@ -624,7 +624,7 @@ ixgb_led_blink_callback(unsigned long data)
 }
 
 static int
-ixgb_phys_id(struct net_device *netdev, uint32_t data)
+ixgb_phys_id(struct net_device *netdev, u32 data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
@@ -660,7 +660,7 @@ ixgb_get_sset_count(struct net_device *netdev, int sset)
 
 static void 
 ixgb_get_ethtool_stats(struct net_device *netdev, 
-		struct ethtool_stats *stats, uint64_t *data)
+		struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	int i;
@@ -669,12 +669,12 @@ ixgb_get_ethtool_stats(struct net_device *netdev,
 	for(i = 0; i < IXGB_STATS_LEN; i++) {
 		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;	
 		data[i] = (ixgb_gstrings_stats[i].sizeof_stat == 
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 }
 
 static void 
-ixgb_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
 	int i;
 
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 8a04bbd..04d2003 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -35,9 +35,9 @@
 
 /*  Local function prototypes */
 
-static uint32_t ixgb_hash_mc_addr(struct ixgb_hw *hw, uint8_t * mc_addr);
+static u32 ixgb_hash_mc_addr(struct ixgb_hw *hw, u8 * mc_addr);
 
-static void ixgb_mta_set(struct ixgb_hw *hw, uint32_t hash_value);
+static void ixgb_mta_set(struct ixgb_hw *hw, u32 hash_value);
 
 static void ixgb_get_bus_info(struct ixgb_hw *hw);
 
@@ -55,18 +55,18 @@ static void ixgb_clear_vfta(struct ixgb_hw *hw);
 
 static void ixgb_init_rx_addrs(struct ixgb_hw *hw);
 
-static uint16_t ixgb_read_phy_reg(struct ixgb_hw *hw,
-				  uint32_t reg_address,
-				  uint32_t phy_address,
-				  uint32_t device_type);
+static u16 ixgb_read_phy_reg(struct ixgb_hw *hw,
+				  u32 reg_address,
+				  u32 phy_address,
+				  u32 device_type);
 
 static bool ixgb_setup_fc(struct ixgb_hw *hw);
 
-static bool mac_addr_valid(uint8_t *mac_addr);
+static bool mac_addr_valid(u8 *mac_addr);
 
-static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
+static u32 ixgb_mac_reset(struct ixgb_hw *hw)
 {
-	uint32_t ctrl_reg;
+	u32 ctrl_reg;
 
 	ctrl_reg =  IXGB_CTRL0_RST |
 				IXGB_CTRL0_SDP3_DIR |   /* All pins are Output=1 */
@@ -117,8 +117,8 @@ static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
 bool
 ixgb_adapter_stop(struct ixgb_hw *hw)
 {
-	uint32_t ctrl_reg;
-	uint32_t icr_reg;
+	u32 ctrl_reg;
+	u32 icr_reg;
 
 	DEBUGFUNC("ixgb_adapter_stop");
 
@@ -179,8 +179,8 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 static ixgb_xpak_vendor
 ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
 {
-	uint32_t i;
-	uint16_t vendor_name[5];
+	u32 i;
+	u16 vendor_name[5];
 	ixgb_xpak_vendor xpak_vendor;
 
 	DEBUGFUNC("ixgb_identify_xpak_vendor");
@@ -292,8 +292,8 @@ ixgb_identify_phy(struct ixgb_hw *hw)
 bool
 ixgb_init_hw(struct ixgb_hw *hw)
 {
-	uint32_t i;
-	uint32_t ctrl_reg;
+	u32 i;
+	u32 ctrl_reg;
 	bool status;
 
 	DEBUGFUNC("ixgb_init_hw");
@@ -377,7 +377,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
 static void
 ixgb_init_rx_addrs(struct ixgb_hw *hw)
 {
-	uint32_t i;
+	u32 i;
 
 	DEBUGFUNC("ixgb_init_rx_addrs");
 
@@ -437,13 +437,13 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
  *****************************************************************************/
 void
 ixgb_mc_addr_list_update(struct ixgb_hw *hw,
-			  uint8_t *mc_addr_list,
-			  uint32_t mc_addr_count,
-			  uint32_t pad)
+			  u8 *mc_addr_list,
+			  u32 mc_addr_count,
+			  u32 pad)
 {
-	uint32_t hash_value;
-	uint32_t i;
-	uint32_t rar_used_count = 1;		/* RAR[0] is used for our MAC address */
+	u32 hash_value;
+	u32 i;
+	u32 rar_used_count = 1;		/* RAR[0] is used for our MAC address */
 
 	DEBUGFUNC("ixgb_mc_addr_list_update");
 
@@ -515,11 +515,11 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
  * Returns:
  *      The hash value
  *****************************************************************************/
-static uint32_t
+static u32
 ixgb_hash_mc_addr(struct ixgb_hw *hw,
-		   uint8_t *mc_addr)
+		   u8 *mc_addr)
 {
-	uint32_t hash_value = 0;
+	u32 hash_value = 0;
 
 	DEBUGFUNC("ixgb_hash_mc_addr");
 
@@ -533,18 +533,18 @@ ixgb_hash_mc_addr(struct ixgb_hw *hw,
 	case 0:
 		/* [47:36] i.e. 0x563 for above example address */
 		hash_value =
-		    ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
+		    ((mc_addr[4] >> 4) | (((u16) mc_addr[5]) << 4));
 		break;
 	case 1:		/* [46:35] i.e. 0xAC6 for above example address */
 		hash_value =
-		    ((mc_addr[4] >> 3) | (((uint16_t) mc_addr[5]) << 5));
+		    ((mc_addr[4] >> 3) | (((u16) mc_addr[5]) << 5));
 		break;
 	case 2:		/* [45:34] i.e. 0x5D8 for above example address */
 		hash_value =
-		    ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
+		    ((mc_addr[4] >> 2) | (((u16) mc_addr[5]) << 6));
 		break;
 	case 3:		/* [43:32] i.e. 0x634 for above example address */
-		hash_value = ((mc_addr[4]) | (((uint16_t) mc_addr[5]) << 8));
+		hash_value = ((mc_addr[4]) | (((u16) mc_addr[5]) << 8));
 		break;
 	default:
 		/* Invalid mc_filter_type, what should we do? */
@@ -565,10 +565,10 @@ ixgb_hash_mc_addr(struct ixgb_hw *hw,
  *****************************************************************************/
 static void
 ixgb_mta_set(struct ixgb_hw *hw,
-		  uint32_t hash_value)
+		  u32 hash_value)
 {
-	uint32_t hash_bit, hash_reg;
-	uint32_t mta_reg;
+	u32 hash_bit, hash_reg;
+	u32 mta_reg;
 
 	/* The MTA is a register array of 128 32-bit registers.
 	 * It is treated like an array of 4096 bits.  We want to set
@@ -599,23 +599,23 @@ ixgb_mta_set(struct ixgb_hw *hw,
  *****************************************************************************/
 void
 ixgb_rar_set(struct ixgb_hw *hw,
-		  uint8_t *addr,
-		  uint32_t index)
+		  u8 *addr,
+		  u32 index)
 {
-	uint32_t rar_low, rar_high;
+	u32 rar_low, rar_high;
 
 	DEBUGFUNC("ixgb_rar_set");
 
 	/* HW expects these in little endian so we reverse the byte order
 	 * from network order (big endian) to little endian
 	 */
-	rar_low = ((uint32_t) addr[0] |
-		   ((uint32_t)addr[1] << 8) |
-		   ((uint32_t)addr[2] << 16) |
-		   ((uint32_t)addr[3] << 24));
+	rar_low = ((u32) addr[0] |
+		   ((u32)addr[1] << 8) |
+		   ((u32)addr[2] << 16) |
+		   ((u32)addr[3] << 24));
 
-	rar_high = ((uint32_t) addr[4] |
-			((uint32_t)addr[5] << 8) |
+	rar_high = ((u32) addr[4] |
+			((u32)addr[5] << 8) |
 			IXGB_RAH_AV);
 
 	IXGB_WRITE_REG_ARRAY(hw, RA, (index << 1), rar_low);
@@ -632,8 +632,8 @@ ixgb_rar_set(struct ixgb_hw *hw,
  *****************************************************************************/
 void
 ixgb_write_vfta(struct ixgb_hw *hw,
-		 uint32_t offset,
-		 uint32_t value)
+		 u32 offset,
+		 u32 value)
 {
 	IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, value);
 	return;
@@ -647,7 +647,7 @@ ixgb_write_vfta(struct ixgb_hw *hw,
 static void
 ixgb_clear_vfta(struct ixgb_hw *hw)
 {
-	uint32_t offset;
+	u32 offset;
 
 	for(offset = 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
 		IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, 0);
@@ -663,8 +663,8 @@ ixgb_clear_vfta(struct ixgb_hw *hw)
 static bool
 ixgb_setup_fc(struct ixgb_hw *hw)
 {
-	uint32_t ctrl_reg;
-	uint32_t pap_reg = 0;   /* by default, assume no pause time */
+	u32 ctrl_reg;
+	u32 pap_reg = 0;   /* by default, assume no pause time */
 	bool status = true;
 
 	DEBUGFUNC("ixgb_setup_fc");
@@ -762,15 +762,15 @@ ixgb_setup_fc(struct ixgb_hw *hw)
  * This requires that first an address cycle command is sent, followed by a
  * read command.
  *****************************************************************************/
-static uint16_t
+static u16
 ixgb_read_phy_reg(struct ixgb_hw *hw,
-		uint32_t reg_address,
-		uint32_t phy_address,
-		uint32_t device_type)
+		u32 reg_address,
+		u32 phy_address,
+		u32 device_type)
 {
-	uint32_t i;
-	uint32_t data;
-	uint32_t command = 0;
+	u32 i;
+	u32 data;
+	u32 command = 0;
 
 	ASSERT(reg_address <= IXGB_MAX_PHY_REG_ADDRESS);
 	ASSERT(phy_address <= IXGB_MAX_PHY_ADDRESS);
@@ -835,7 +835,7 @@ ixgb_read_phy_reg(struct ixgb_hw *hw,
 	 */
 	data = IXGB_READ_REG(hw, MSRWD);
 	data >>= IXGB_MSRWD_READ_DATA_SHIFT;
-	return((uint16_t) data);
+	return((u16) data);
 }
 
 /******************************************************************************
@@ -857,20 +857,20 @@ ixgb_read_phy_reg(struct ixgb_hw *hw,
  *****************************************************************************/
 static void
 ixgb_write_phy_reg(struct ixgb_hw *hw,
-			uint32_t reg_address,
-			uint32_t phy_address,
-			uint32_t device_type,
-			uint16_t data)
+			u32 reg_address,
+			u32 phy_address,
+			u32 device_type,
+			u16 data)
 {
-	uint32_t i;
-	uint32_t command = 0;
+	u32 i;
+	u32 command = 0;
 
 	ASSERT(reg_address <= IXGB_MAX_PHY_REG_ADDRESS);
 	ASSERT(phy_address <= IXGB_MAX_PHY_ADDRESS);
 	ASSERT(device_type <= IXGB_MAX_PHY_DEV_TYPE);
 
 	/* Put the data in the MDIO Read/Write Data register */
-	IXGB_WRITE_REG(hw, MSRWD, (uint32_t)data);
+	IXGB_WRITE_REG(hw, MSRWD, (u32)data);
 
 	/* Setup and write the address cycle command */
 	command = ((reg_address << IXGB_MSCA_NP_ADDR_SHIFT)  |
@@ -939,8 +939,8 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
 void
 ixgb_check_for_link(struct ixgb_hw *hw)
 {
-	uint32_t status_reg;
-	uint32_t xpcss_reg;
+	u32 status_reg;
+	u32 xpcss_reg;
 
 	DEBUGFUNC("ixgb_check_for_link");
 
@@ -975,7 +975,7 @@ ixgb_check_for_link(struct ixgb_hw *hw)
  *****************************************************************************/
 bool ixgb_check_for_bad_link(struct ixgb_hw *hw)
 {
-	uint32_t newLFC, newRFC;
+	u32 newLFC, newRFC;
 	bool bad_link_returncode = false;
 
 	if (hw->phy_type == ixgb_phy_type_txn17401) {
@@ -1002,7 +1002,7 @@ bool ixgb_check_for_bad_link(struct ixgb_hw *hw)
 static void
 ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 {
-	volatile uint32_t temp_reg;
+	volatile u32 temp_reg;
 
 	DEBUGFUNC("ixgb_clear_hw_cntrs");
 
@@ -1083,7 +1083,7 @@ ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 void
 ixgb_led_on(struct ixgb_hw *hw)
 {
-	uint32_t ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
+	u32 ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
 
 	/* To turn on the LED, clear software-definable pin 0 (SDP0). */
 	ctrl0_reg &= ~IXGB_CTRL0_SDP0;
@@ -1099,7 +1099,7 @@ ixgb_led_on(struct ixgb_hw *hw)
 void
 ixgb_led_off(struct ixgb_hw *hw)
 {
-	uint32_t ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
+	u32 ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
 
 	/* To turn off the LED, set software-definable pin 0 (SDP0). */
 	ctrl0_reg |= IXGB_CTRL0_SDP0;
@@ -1115,7 +1115,7 @@ ixgb_led_off(struct ixgb_hw *hw)
 static void
 ixgb_get_bus_info(struct ixgb_hw *hw)
 {
-	uint32_t status_reg;
+	u32 status_reg;
 
 	status_reg = IXGB_READ_REG(hw, STATUS);
 
@@ -1155,7 +1155,7 @@ ixgb_get_bus_info(struct ixgb_hw *hw)
  *
  *****************************************************************************/
 static bool
-mac_addr_valid(uint8_t *mac_addr)
+mac_addr_valid(u8 *mac_addr)
 {
 	bool is_valid = true;
 	DEBUGFUNC("mac_addr_valid");
@@ -1193,8 +1193,8 @@ static bool
 ixgb_link_reset(struct ixgb_hw *hw)
 {
 	bool link_status = false;
-	uint8_t wait_retries = MAX_RESET_ITERATIONS;
-	uint8_t lrst_retries = MAX_RESET_ITERATIONS;
+	u8 wait_retries = MAX_RESET_ITERATIONS;
+	u8 lrst_retries = MAX_RESET_ITERATIONS;
 
 	do {
 		/* Reset the link */
@@ -1224,7 +1224,7 @@ static void
 ixgb_optics_reset(struct ixgb_hw *hw)
 {
 	if (hw->phy_type == ixgb_phy_type_txn17401) {
-		uint16_t mdio_reg;
+		u16 mdio_reg;
 
 		ixgb_write_phy_reg(hw,
 					MDIO_PMA_PMD_CR1,
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index d4e9566..39cfa47 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -538,8 +538,8 @@ struct ixgb_rx_desc {
 	__le64 buff_addr;
 	__le16 length;
 	__le16 reserved;
-	uint8_t status;
-	uint8_t errors;
+	u8 status;
+	u8 errors;
 	__le16 special;
 };
 
@@ -570,8 +570,8 @@ struct ixgb_rx_desc {
 struct ixgb_tx_desc {
 	__le64 buff_addr;
 	__le32 cmd_type_len;
-	uint8_t status;
-	uint8_t popts;
+	u8 status;
+	u8 popts;
 	__le16 vlan;
 };
 
@@ -595,15 +595,15 @@ struct ixgb_tx_desc {
 #define IXGB_TX_DESC_SPECIAL_PRI_SHIFT  IXGB_RX_DESC_SPECIAL_PRI_SHIFT	/* Priority is in upper 3 of 16 */
 
 struct ixgb_context_desc {
-	uint8_t ipcss;
-	uint8_t ipcso;
+	u8 ipcss;
+	u8 ipcso;
 	__le16 ipcse;
-	uint8_t tucss;
-	uint8_t tucso;
+	u8 tucss;
+	u8 tucso;
 	__le16 tucse;
 	__le32 cmd_type_len;
-	uint8_t status;
-	uint8_t hdr_len;
+	u8 status;
+	u8 hdr_len;
 	__le16 mss;
 };
 
@@ -637,32 +637,32 @@ struct ixgb_context_desc {
 
 /* This structure takes a 64k flash and maps it for identification commands */
 struct ixgb_flash_buffer {
-	uint8_t manufacturer_id;
-	uint8_t device_id;
-	uint8_t filler1[0x2AA8];
-	uint8_t cmd2;
-	uint8_t filler2[0x2AAA];
-	uint8_t cmd1;
-	uint8_t filler3[0xAAAA];
+	u8 manufacturer_id;
+	u8 device_id;
+	u8 filler1[0x2AA8];
+	u8 cmd2;
+	u8 filler2[0x2AAA];
+	u8 cmd1;
+	u8 filler3[0xAAAA];
 };
 
 /*
  * This is a little-endian specific check.
  */
 #define IS_MULTICAST(Address) \
-    (bool)(((uint8_t *)(Address))[0] & ((uint8_t)0x01))
+    (bool)(((u8 *)(Address))[0] & ((u8)0x01))
 
 /*
  * Check whether an address is broadcast.
  */
 #define IS_BROADCAST(Address)               \
-    ((((uint8_t *)(Address))[0] == ((uint8_t)0xff)) && (((uint8_t *)(Address))[1] == ((uint8_t)0xff)))
+    ((((u8 *)(Address))[0] == ((u8)0xff)) && (((u8 *)(Address))[1] == ((u8)0xff)))
 
 /* Flow control parameters */
 struct ixgb_fc {
-	uint32_t high_water;	/* Flow Control High-water          */
-	uint32_t low_water;	/* Flow Control Low-water           */
-	uint16_t pause_time;	/* Flow Control Pause timer         */
+	u32 high_water;	/* Flow Control High-water          */
+	u32 low_water;	/* Flow Control Low-water           */
+	u16 pause_time;	/* Flow Control Pause timer         */
 	bool send_xon;		/* Flow control send XON            */
 	ixgb_fc_type type;	/* Type of flow control             */
 };
@@ -685,101 +685,101 @@ struct ixgb_bus {
 };
 
 struct ixgb_hw {
-	uint8_t __iomem *hw_addr;/* Base Address of the hardware     */
+	u8 __iomem *hw_addr;/* Base Address of the hardware     */
 	void *back;		/* Pointer to OS-dependent struct   */
 	struct ixgb_fc fc;	/* Flow control parameters          */
 	struct ixgb_bus bus;	/* Bus parameters                   */
-	uint32_t phy_id;	/* Phy Identifier                   */
-	uint32_t phy_addr;	/* XGMII address of Phy             */
+	u32 phy_id;	/* Phy Identifier                   */
+	u32 phy_addr;	/* XGMII address of Phy             */
 	ixgb_mac_type mac_type;	/* Identifier for MAC controller    */
 	ixgb_phy_type phy_type;	/* Transceiver/phy identifier       */
-	uint32_t max_frame_size;	/* Maximum frame size supported     */
-	uint32_t mc_filter_type;	/* Multicast filter hash type       */
-	uint32_t num_mc_addrs;	/* Number of current Multicast addrs */
-	uint8_t curr_mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];	/* Individual address currently programmed in MAC */
-	uint32_t num_tx_desc;	/* Number of Transmit descriptors   */
-	uint32_t num_rx_desc;	/* Number of Receive descriptors    */
-	uint32_t rx_buffer_size;	/* Size of Receive buffer           */
+	u32 max_frame_size;	/* Maximum frame size supported     */
+	u32 mc_filter_type;	/* Multicast filter hash type       */
+	u32 num_mc_addrs;	/* Number of current Multicast addrs */
+	u8 curr_mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];	/* Individual address currently programmed in MAC */
+	u32 num_tx_desc;	/* Number of Transmit descriptors   */
+	u32 num_rx_desc;	/* Number of Receive descriptors    */
+	u32 rx_buffer_size;	/* Size of Receive buffer           */
 	bool link_up;		/* true if link is valid            */
 	bool adapter_stopped;	/* State of adapter                 */
-	uint16_t device_id;	/* device id from PCI configuration space */
-	uint16_t vendor_id;	/* vendor id from PCI configuration space */
-	uint8_t revision_id;	/* revision id from PCI configuration space */
-	uint16_t subsystem_vendor_id;	/* subsystem vendor id from PCI configuration space */
-	uint16_t subsystem_id;	/* subsystem id from PCI configuration space */
-	uint32_t bar0;		/* Base Address registers           */
-	uint32_t bar1;
-	uint32_t bar2;
-	uint32_t bar3;
-	uint16_t pci_cmd_word;	/* PCI command register id from PCI configuration space */
+	u16 device_id;	/* device id from PCI configuration space */
+	u16 vendor_id;	/* vendor id from PCI configuration space */
+	u8 revision_id;	/* revision id from PCI configuration space */
+	u16 subsystem_vendor_id;	/* subsystem vendor id from PCI configuration space */
+	u16 subsystem_id;	/* subsystem id from PCI configuration space */
+	u32 bar0;		/* Base Address registers           */
+	u32 bar1;
+	u32 bar2;
+	u32 bar3;
+	u16 pci_cmd_word;	/* PCI command register id from PCI configuration space */
 	__le16 eeprom[IXGB_EEPROM_SIZE];	/* EEPROM contents read at init time  */
 	unsigned long io_base;	/* Our I/O mapped location */
-	uint32_t lastLFC;
-	uint32_t lastRFC;
+	u32 lastLFC;
+	u32 lastRFC;
 };
 
 /* Statistics reported by the hardware */
 struct ixgb_hw_stats {
-	uint64_t tprl;
-	uint64_t tprh;
-	uint64_t gprcl;
-	uint64_t gprch;
-	uint64_t bprcl;
-	uint64_t bprch;
-	uint64_t mprcl;
-	uint64_t mprch;
-	uint64_t uprcl;
-	uint64_t uprch;
-	uint64_t vprcl;
-	uint64_t vprch;
-	uint64_t jprcl;
-	uint64_t jprch;
-	uint64_t gorcl;
-	uint64_t gorch;
-	uint64_t torl;
-	uint64_t torh;
-	uint64_t rnbc;
-	uint64_t ruc;
-	uint64_t roc;
-	uint64_t rlec;
-	uint64_t crcerrs;
-	uint64_t icbc;
-	uint64_t ecbc;
-	uint64_t mpc;
-	uint64_t tptl;
-	uint64_t tpth;
-	uint64_t gptcl;
-	uint64_t gptch;
-	uint64_t bptcl;
-	uint64_t bptch;
-	uint64_t mptcl;
-	uint64_t mptch;
-	uint64_t uptcl;
-	uint64_t uptch;
-	uint64_t vptcl;
-	uint64_t vptch;
-	uint64_t jptcl;
-	uint64_t jptch;
-	uint64_t gotcl;
-	uint64_t gotch;
-	uint64_t totl;
-	uint64_t toth;
-	uint64_t dc;
-	uint64_t plt64c;
-	uint64_t tsctc;
-	uint64_t tsctfc;
-	uint64_t ibic;
-	uint64_t rfc;
-	uint64_t lfc;
-	uint64_t pfrc;
-	uint64_t pftc;
-	uint64_t mcfrc;
-	uint64_t mcftc;
-	uint64_t xonrxc;
-	uint64_t xontxc;
-	uint64_t xoffrxc;
-	uint64_t xofftxc;
-	uint64_t rjc;
+	u64 tprl;
+	u64 tprh;
+	u64 gprcl;
+	u64 gprch;
+	u64 bprcl;
+	u64 bprch;
+	u64 mprcl;
+	u64 mprch;
+	u64 uprcl;
+	u64 uprch;
+	u64 vprcl;
+	u64 vprch;
+	u64 jprcl;
+	u64 jprch;
+	u64 gorcl;
+	u64 gorch;
+	u64 torl;
+	u64 torh;
+	u64 rnbc;
+	u64 ruc;
+	u64 roc;
+	u64 rlec;
+	u64 crcerrs;
+	u64 icbc;
+	u64 ecbc;
+	u64 mpc;
+	u64 tptl;
+	u64 tpth;
+	u64 gptcl;
+	u64 gptch;
+	u64 bptcl;
+	u64 bptch;
+	u64 mptcl;
+	u64 mptch;
+	u64 uptcl;
+	u64 uptch;
+	u64 vptcl;
+	u64 vptch;
+	u64 jptcl;
+	u64 jptch;
+	u64 gotcl;
+	u64 gotch;
+	u64 totl;
+	u64 toth;
+	u64 dc;
+	u64 plt64c;
+	u64 tsctc;
+	u64 tsctfc;
+	u64 ibic;
+	u64 rfc;
+	u64 lfc;
+	u64 pfrc;
+	u64 pftc;
+	u64 mcfrc;
+	u64 mcftc;
+	u64 xonrxc;
+	u64 xontxc;
+	u64 xoffrxc;
+	u64 xofftxc;
+	u64 rjc;
 };
 
 /* Function Prototypes */
@@ -790,34 +790,34 @@ extern void ixgb_check_for_link(struct ixgb_hw *hw);
 extern bool ixgb_check_for_bad_link(struct ixgb_hw *hw);
 
 extern void ixgb_rar_set(struct ixgb_hw *hw,
-				uint8_t *addr,
-				uint32_t index);
+				u8 *addr,
+				u32 index);
 
 
 /* Filters (multicast, vlan, receive) */
 extern void ixgb_mc_addr_list_update(struct ixgb_hw *hw,
-				   uint8_t *mc_addr_list,
-				   uint32_t mc_addr_count,
-				   uint32_t pad);
+				   u8 *mc_addr_list,
+				   u32 mc_addr_count,
+				   u32 pad);
 
 /* Vfta functions */
 extern void ixgb_write_vfta(struct ixgb_hw *hw,
-				 uint32_t offset,
-				 uint32_t value);
+				 u32 offset,
+				 u32 value);
 
 /* Access functions to eeprom data */
-void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t *mac_addr);
-uint32_t ixgb_get_ee_pba_number(struct ixgb_hw *hw);
-uint16_t ixgb_get_ee_device_id(struct ixgb_hw *hw);
+void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, u8 *mac_addr);
+u32 ixgb_get_ee_pba_number(struct ixgb_hw *hw);
+u16 ixgb_get_ee_device_id(struct ixgb_hw *hw);
 bool ixgb_get_eeprom_data(struct ixgb_hw *hw);
-__le16 ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index);
+__le16 ixgb_get_eeprom_word(struct ixgb_hw *hw, u16 index);
 
 /* Everything else */
 void ixgb_led_on(struct ixgb_hw *hw);
 void ixgb_led_off(struct ixgb_hw *hw);
 void ixgb_write_pci_cfg(struct ixgb_hw *hw,
-			 uint32_t reg,
-			 uint16_t * value);
+			 u32 reg,
+			 u16 * value);
 
 
 #endif /* _IXGB_HW_H_ */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index c68b182..cb8dadd 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -108,8 +108,8 @@ static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct work_struct *work);
 static void ixgb_vlan_rx_register(struct net_device *netdev,
 				  struct vlan_group *grp);
-static void ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid);
-static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
+static void ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
+static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void ixgb_restore_vlan(struct ixgb_adapter *adapter);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -271,7 +271,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 
 		if(hw->max_frame_size >
 		   IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
-			uint32_t ctrl0 = IXGB_READ_REG(hw, CTRL0);
+			u32 ctrl0 = IXGB_READ_REG(hw, CTRL0);
 
 			if(!(ctrl0 & IXGB_CTRL0_JFE)) {
 				ctrl0 |= IXGB_CTRL0_JFE;
@@ -718,9 +718,9 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 static void
 ixgb_configure_tx(struct ixgb_adapter *adapter)
 {
-	uint64_t tdba = adapter->tx_ring.dma;
-	uint32_t tdlen = adapter->tx_ring.count * sizeof(struct ixgb_tx_desc);
-	uint32_t tctl;
+	u64 tdba = adapter->tx_ring.dma;
+	u32 tdlen = adapter->tx_ring.count * sizeof(struct ixgb_tx_desc);
+	u32 tctl;
 	struct ixgb_hw *hw = &adapter->hw;
 
 	/* Setup the Base and Length of the Tx Descriptor Ring 
@@ -806,7 +806,7 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 static void
 ixgb_setup_rctl(struct ixgb_adapter *adapter)
 {
-	uint32_t rctl;
+	u32 rctl;
 
 	rctl = IXGB_READ_REG(&adapter->hw, RCTL);
 
@@ -841,12 +841,12 @@ ixgb_setup_rctl(struct ixgb_adapter *adapter)
 static void
 ixgb_configure_rx(struct ixgb_adapter *adapter)
 {
-	uint64_t rdba = adapter->rx_ring.dma;
-	uint32_t rdlen = adapter->rx_ring.count * sizeof(struct ixgb_rx_desc);
+	u64 rdba = adapter->rx_ring.dma;
+	u32 rdlen = adapter->rx_ring.count * sizeof(struct ixgb_rx_desc);
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t rctl;
-	uint32_t rxcsum;
-	uint32_t rxdctl;
+	u32 rctl;
+	u32 rxcsum;
+	u32 rxdctl;
 
 	/* make sure receives are disabled while setting up the descriptors */
 
@@ -1079,7 +1079,7 @@ ixgb_set_multi(struct net_device *netdev)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
 	struct dev_mc_list *mc_ptr;
-	uint32_t rctl;
+	u32 rctl;
 	int i;
 
 	/* Check for Promiscuous and All Multicast modes */
@@ -1099,7 +1099,7 @@ ixgb_set_multi(struct net_device *netdev)
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
-		uint8_t mta[IXGB_MAX_NUM_MULTICAST_ADDRESSES *
+		u8 mta[IXGB_MAX_NUM_MULTICAST_ADDRESSES *
 			    IXGB_ETH_LENGTH_OF_ADDRESS];
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
@@ -1183,8 +1183,8 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
 	struct ixgb_context_desc *context_desc;
 	unsigned int i;
-	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
-	uint16_t ipcse, tucse, mss;
+	u8 ipcss, ipcso, tucss, tucso, hdr_len;
+	u16 ipcse, tucse, mss;
 	int err;
 
 	if (likely(skb_is_gso(skb))) {
@@ -1249,7 +1249,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
 	struct ixgb_context_desc *context_desc;
 	unsigned int i;
-	uint8_t css, cso;
+	u8 css, cso;
 
 	if(likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		struct ixgb_buffer *buffer_info;
@@ -1265,7 +1265,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 		context_desc->tucso = cso;
 		context_desc->tucse = 0;
 		/* zero out any previously existing data in one instruction */
-		*(uint32_t *)&(context_desc->ipcss) = 0;
+		*(u32 *)&(context_desc->ipcss) = 0;
 		context_desc->status = 0;
 		context_desc->hdr_len = 0;
 		context_desc->mss = 0;
@@ -1372,9 +1372,9 @@ ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct ixgb_tx_desc *tx_desc = NULL;
 	struct ixgb_buffer *buffer_info;
-	uint32_t cmd_type_len = adapter->tx_cmd_type;
-	uint8_t status = 0;
-	uint8_t popts = 0;
+	u32 cmd_type_len = adapter->tx_cmd_type;
+	u8 status = 0;
+	u8 popts = 0;
 	unsigned int i;
 
 	if(tx_flags & IXGB_TX_FLAGS_TSO) {
@@ -1750,7 +1750,7 @@ ixgb_intr(int irq, void *data)
 	struct net_device *netdev = data;
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t icr = IXGB_READ_REG(hw, ICR);
+	u32 icr = IXGB_READ_REG(hw, ICR);
 #ifndef CONFIG_IXGB_NAPI
 	unsigned int i;
 #endif
@@ -1843,7 +1843,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 
 			ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
 
-			*(uint32_t *)&(tx_desc->status) = 0;
+			*(u32 *)&(tx_desc->status) = 0;
 
 			cleaned = (i == eop);
 			if(++i == tx_ring->count) i = 0;
@@ -1948,7 +1948,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	struct ixgb_rx_desc *rx_desc, *next_rxd;
 	struct ixgb_buffer *buffer_info, *next_buffer, *next2_buffer;
-	uint32_t length;
+	u32 length;
 	unsigned int i, j;
 	bool cleaned = false;
 
@@ -2166,7 +2166,7 @@ static void
 ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	uint32_t ctrl, rctl;
+	u32 ctrl, rctl;
 
 	ixgb_irq_disable(adapter);
 	adapter->vlgrp = grp;
@@ -2203,10 +2203,10 @@ ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 }
 
 static void
-ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
+ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	uint32_t vfta, index;
+	u32 vfta, index;
 
 	/* add VID to filter table */
 
@@ -2217,10 +2217,10 @@ ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 }
 
 static void
-ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
+ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	uint32_t vfta, index;
+	u32 vfta, index;
 
 	ixgb_irq_disable(adapter);
 
@@ -2244,7 +2244,7 @@ ixgb_restore_vlan(struct ixgb_adapter *adapter)
 	ixgb_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 
 	if(adapter->vlgrp) {
-		uint16_t vid;
+		u16 vid;
 		for(vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
 			if(!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
