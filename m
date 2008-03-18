From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/10] drivers/net/ixgb - Convert u_int16_t to
	u16
Date: Tue, 18 Mar 2008 09:13:51 -0700
Message-ID: <ce1830668a3c8a8d63f514ba26dae26dbf71f1f2.1205779120.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
	<41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
	<d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
	<84e6a8fed68d45f3271a23b7333bfd4627d646c1.1205779102.git.joe@perches.com>
	<1c1d35f8165b53f5e1e050c88cf97922b0694229.1205779102.git.joe@perches.com>
	<c18867835e6cd98fe94fa418abf7f2432a7786a5.1205779102.git.joe@perches.com>
	<cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
In-Reply-To: <cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
References: <cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
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
 drivers/net/ixgb/ixgb.h         |    8 +++---
 drivers/net/ixgb/ixgb_ee.c      |   46 +++++++++++++++++++-------------------
 drivers/net/ixgb/ixgb_ee.h      |    4 +-
 drivers/net/ixgb/ixgb_ethtool.c |    4 +-
 drivers/net/ixgb/ixgb_hw.c      |   20 ++++++++--------
 drivers/net/ixgb/ixgb_hw.h      |   18 +++++++-------
 drivers/net/ixgb/ixgb_main.c    |   12 +++++-----
 7 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index f2fff90..c975564 100644
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
@@ -155,8 +155,8 @@ struct ixgb_adapter {
 	uint32_t bd_number;
 	uint32_t rx_buffer_len;
 	uint32_t part_num;
-	uint16_t link_speed;
-	uint16_t link_duplex;
+	u16 link_speed;
+	u16 link_duplex;
 	spinlock_t tx_lock;
 	struct work_struct tx_timeout_task;
 
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index a52acbe..73403d7 100644
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
@@ -87,8 +87,8 @@ ixgb_lower_clock(struct ixgb_hw *hw,
  *****************************************************************************/
 static void
 ixgb_shift_out_bits(struct ixgb_hw *hw,
-					 uint16_t data,
-					 uint16_t count)
+					 u16 data,
+					 u16 count)
 {
 	uint32_t eecd_reg;
 	uint32_t mask;
@@ -133,12 +133,12 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static uint16_t
+static u16
 ixgb_shift_in_bits(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 	uint32_t i;
-	uint16_t data;
+	u16 data;
 
 	/* In order to read a register from the EEPROM, we need to shift 16 bits
 	 * in from the EEPROM. Bits are "shifted in" by raising the clock input to
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
index eaf5efc..4b7bd0d 100644
--- a/drivers/net/ixgb/ixgb_ee.h
+++ b/drivers/net/ixgb/ixgb_ee.h
@@ -95,12 +95,12 @@ struct ixgb_ee_map_type {
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
index bbf1a4c..3daf7b9 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -459,10 +459,10 @@ ixgb_set_eeprom(struct net_device *netdev,
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
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 618a6c6..7536eba 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -55,7 +55,7 @@ static void ixgb_clear_vfta(struct ixgb_hw *hw);
 
 static void ixgb_init_rx_addrs(struct ixgb_hw *hw);
 
-static uint16_t ixgb_read_phy_reg(struct ixgb_hw *hw,
+static u16 ixgb_read_phy_reg(struct ixgb_hw *hw,
 				  uint32_t reg_address,
 				  uint32_t phy_address,
 				  uint32_t device_type);
@@ -180,7 +180,7 @@ static ixgb_xpak_vendor
 ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
 {
 	uint32_t i;
-	uint16_t vendor_name[5];
+	u16 vendor_name[5];
 	ixgb_xpak_vendor xpak_vendor;
 
 	DEBUGFUNC("ixgb_identify_xpak_vendor");
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
@@ -762,7 +762,7 @@ ixgb_setup_fc(struct ixgb_hw *hw)
  * This requires that first an address cycle command is sent, followed by a
  * read command.
  *****************************************************************************/
-static uint16_t
+static u16
 ixgb_read_phy_reg(struct ixgb_hw *hw,
 		uint32_t reg_address,
 		uint32_t phy_address,
@@ -835,7 +835,7 @@ ixgb_read_phy_reg(struct ixgb_hw *hw,
 	 */
 	data = IXGB_READ_REG(hw, MSRWD);
 	data >>= IXGB_MSRWD_READ_DATA_SHIFT;
-	return((uint16_t) data);
+	return((u16) data);
 }
 
 /******************************************************************************
@@ -860,7 +860,7 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
 			uint32_t reg_address,
 			uint32_t phy_address,
 			uint32_t device_type,
-			uint16_t data)
+			u16 data)
 {
 	uint32_t i;
 	uint32_t command = 0;
@@ -1224,7 +1224,7 @@ static void
 ixgb_optics_reset(struct ixgb_hw *hw)
 {
 	if (hw->phy_type == ixgb_phy_type_txn17401) {
-		uint16_t mdio_reg;
+		u16 mdio_reg;
 
 		ixgb_write_phy_reg(hw,
 					MDIO_PMA_PMD_CR1,
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index 6fb202f..a4dc8df 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -662,7 +662,7 @@ struct ixgb_flash_buffer {
 struct ixgb_fc {
 	uint32_t high_water;	/* Flow Control High-water          */
 	uint32_t low_water;	/* Flow Control Low-water           */
-	uint16_t pause_time;	/* Flow Control Pause timer         */
+	u16 pause_time;	/* Flow Control Pause timer         */
 	bool send_xon;		/* Flow control send XON            */
 	ixgb_fc_type type;	/* Type of flow control             */
 };
@@ -702,16 +702,16 @@ struct ixgb_hw {
 	uint32_t rx_buffer_size;	/* Size of Receive buffer           */
 	bool link_up;		/* true if link is valid            */
 	bool adapter_stopped;	/* State of adapter                 */
-	uint16_t device_id;	/* device id from PCI configuration space */
-	uint16_t vendor_id;	/* vendor id from PCI configuration space */
+	u16 device_id;	/* device id from PCI configuration space */
+	u16 vendor_id;	/* vendor id from PCI configuration space */
 	u8 revision_id;	/* revision id from PCI configuration space */
-	uint16_t subsystem_vendor_id;	/* subsystem vendor id from PCI configuration space */
-	uint16_t subsystem_id;	/* subsystem id from PCI configuration space */
+	u16 subsystem_vendor_id;	/* subsystem vendor id from PCI configuration space */
+	u16 subsystem_id;	/* subsystem id from PCI configuration space */
 	uint32_t bar0;		/* Base Address registers           */
 	uint32_t bar1;
 	uint32_t bar2;
 	uint32_t bar3;
-	uint16_t pci_cmd_word;	/* PCI command register id from PCI configuration space */
+	u16 pci_cmd_word;	/* PCI command register id from PCI configuration space */
 	__le16 eeprom[IXGB_EEPROM_SIZE];	/* EEPROM contents read at init time  */
 	unsigned long io_base;	/* Our I/O mapped location */
 	uint32_t lastLFC;
@@ -808,16 +808,16 @@ extern void ixgb_write_vfta(struct ixgb_hw *hw,
 /* Access functions to eeprom data */
 void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, u8 *mac_addr);
 uint32_t ixgb_get_ee_pba_number(struct ixgb_hw *hw);
-uint16_t ixgb_get_ee_device_id(struct ixgb_hw *hw);
+u16 ixgb_get_ee_device_id(struct ixgb_hw *hw);
 bool ixgb_get_eeprom_data(struct ixgb_hw *hw);
-__le16 ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index);
+__le16 ixgb_get_eeprom_word(struct ixgb_hw *hw, u16 index);
 
 /* Everything else */
 void ixgb_led_on(struct ixgb_hw *hw);
 void ixgb_led_off(struct ixgb_hw *hw);
 void ixgb_write_pci_cfg(struct ixgb_hw *hw,
 			 uint32_t reg,
-			 uint16_t * value);
+			 u16 * value);
 
 
 #endif /* _IXGB_HW_H_ */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 96374d3..e5032be 100644
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
@@ -1184,7 +1184,7 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 	struct ixgb_context_desc *context_desc;
 	unsigned int i;
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
-	uint16_t ipcse, tucse, mss;
+	u16 ipcse, tucse, mss;
 	int err;
 
 	if (likely(skb_is_gso(skb))) {
@@ -2203,7 +2203,7 @@ ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 }
 
 static void
-ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
+ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	uint32_t vfta, index;
@@ -2217,7 +2217,7 @@ ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 }
 
 static void
-ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
+ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	uint32_t vfta, index;
@@ -2244,7 +2244,7 @@ ixgb_restore_vlan(struct ixgb_adapter *adapter)
 	ixgb_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 
 	if(adapter->vlgrp) {
-		uint16_t vid;
+		u16 vid;
 		for(vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
 			if(!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
