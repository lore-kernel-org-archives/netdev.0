From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/9] ixgb: convert boolean_t to bool
Date: Fri, 21 Mar 2008 11:06:37 -0700
Message-ID: <20080321180637.24164.94420.stgit@localhost.localdomain>
References: <20080321180625.24164.46137.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080321180625.24164.46137.stgit@localhost.localdomain>
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

> send me a patch for e1000 and for ixgb and I'll happily apply those :)

boolean_t to bool
TRUE to true
FALSE to false

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h         |    8 +++--
 drivers/net/ixgb/ixgb_ee.c      |   50 +++++++++++++++++-----------------
 drivers/net/ixgb/ixgb_ee.h      |    2 +
 drivers/net/ixgb/ixgb_ethtool.c |   10 +++----
 drivers/net/ixgb/ixgb_hw.c      |   57 +++++++++++++++++++--------------------
 drivers/net/ixgb/ixgb_hw.h      |   18 ++++++------
 drivers/net/ixgb/ixgb_main.c    |   44 +++++++++++++++---------------
 drivers/net/ixgb/ixgb_osdep.h   |    7 -----
 8 files changed, 94 insertions(+), 102 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 0078136..fad4e99 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -173,15 +173,15 @@ struct ixgb_adapter {
 	uint64_t hw_csum_tx_error;
 	uint32_t tx_int_delay;
 	uint32_t tx_timeout_count;
-	boolean_t tx_int_delay_enable;
-	boolean_t detect_tx_hung;
+	bool tx_int_delay_enable;
+	bool detect_tx_hung;
 
 	/* RX */
 	struct ixgb_desc_ring rx_ring;
 	uint64_t hw_csum_rx_error;
 	uint64_t hw_csum_rx_good;
 	uint32_t rx_int_delay;
-	boolean_t rx_csum;
+	bool rx_csum;
 
 	/* OS defined structs */
 	struct napi_struct napi;
@@ -194,7 +194,7 @@ struct ixgb_adapter {
 	u16 msg_enable;
 	struct ixgb_hw_stats stats;
 	uint32_t alloc_rx_buff_failed;
-	boolean_t have_msi;
+	bool have_msi;
 	unsigned long flags;
 };
 
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index e8eb0fd..8e9302f 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -36,7 +36,7 @@ static void ixgb_shift_out_bits(struct ixgb_hw *hw,
 				uint16_t count);
 static void ixgb_standby_eeprom(struct ixgb_hw *hw);
 
-static boolean_t ixgb_wait_eeprom_command(struct ixgb_hw *hw);
+static bool ixgb_wait_eeprom_command(struct ixgb_hw *hw);
 
 static void ixgb_cleanup_eeprom(struct ixgb_hw *hw);
 
@@ -279,10 +279,10 @@ ixgb_cleanup_eeprom(struct ixgb_hw *hw)
  * The command is done when the EEPROM's data out pin goes high.
  *
  * Returns:
- *      TRUE: EEPROM data pin is high before timeout.
- *      FALSE:  Time expired.
+ *      true: EEPROM data pin is high before timeout.
+ *      false:  Time expired.
  *****************************************************************************/
-static boolean_t
+static bool
 ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
@@ -301,12 +301,12 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
 		if(eecd_reg & IXGB_EECD_DO)
-			return (TRUE);
+			return (true);
 
 		udelay(50);
 	}
 	ASSERT(0);
-	return (FALSE);
+	return (false);
 }
 
 /******************************************************************************
@@ -319,10 +319,10 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
  * valid.
  *
  * Returns:
- *  TRUE: Checksum is valid
- *  FALSE: Checksum is not valid.
+ *  true: Checksum is valid
+ *  false: Checksum is not valid.
  *****************************************************************************/
-boolean_t
+bool
 ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 {
 	uint16_t checksum = 0;
@@ -332,9 +332,9 @@ ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 		checksum += ixgb_read_eeprom(hw, i);
 
 	if(checksum == (uint16_t) EEPROM_SUM)
-		return (TRUE);
+		return (true);
 	else
-		return (FALSE);
+		return (false);
 }
 
 /******************************************************************************
@@ -457,10 +457,10 @@ ixgb_read_eeprom(struct ixgb_hw *hw,
  * hw - Struct containing variables accessed by shared code
  *
  * Returns:
- *      TRUE: if eeprom read is successful
- *      FALSE: otherwise.
+ *      true: if eeprom read is successful
+ *      false: otherwise.
  *****************************************************************************/
-boolean_t
+bool
 ixgb_get_eeprom_data(struct ixgb_hw *hw)
 {
 	uint16_t i;
@@ -484,16 +484,16 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 		/* clear the init_ctrl_reg_1 to signify that the cache is
 		 * invalidated */
 		ee_map->init_ctrl_reg_1 = cpu_to_le16(EEPROM_ICW1_SIGNATURE_CLEAR);
-		return (FALSE);
+		return (false);
 	}
 
 	if ((ee_map->init_ctrl_reg_1 & cpu_to_le16(EEPROM_ICW1_SIGNATURE_MASK))
 		 != cpu_to_le16(EEPROM_ICW1_SIGNATURE_VALID)) {
 		DEBUGOUT("ixgb_ee: Signature invalid.\n");
-		return(FALSE);
+		return(false);
 	}
 
-	return(TRUE);
+	return(true);
 }
 
 /******************************************************************************
@@ -503,17 +503,17 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
  * hw - Struct containing variables accessed by shared code
  *
  * Returns:
- *      TRUE: eeprom signature was good and the eeprom read was successful
- *      FALSE: otherwise.
+ *      true: eeprom signature was good and the eeprom read was successful
+ *      false: otherwise.
  ******************************************************************************/
-static boolean_t
+static bool
 ixgb_check_and_get_eeprom_data (struct ixgb_hw* hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if ((ee_map->init_ctrl_reg_1 & cpu_to_le16(EEPROM_ICW1_SIGNATURE_MASK))
 	    == cpu_to_le16(EEPROM_ICW1_SIGNATURE_VALID)) {
-		return (TRUE);
+		return (true);
 	} else {
 		return ixgb_get_eeprom_data(hw);
 	}
@@ -533,7 +533,7 @@ ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index)
 {
 
 	if ((index < IXGB_EEPROM_SIZE) &&
-		(ixgb_check_and_get_eeprom_data(hw) == TRUE)) {
+		(ixgb_check_and_get_eeprom_data(hw) == true)) {
 	   return(hw->eeprom[index]);
 	}
 
@@ -557,7 +557,7 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
 
 	DEBUGFUNC("ixgb_get_ee_mac_addr");
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE) {
+	if (ixgb_check_and_get_eeprom_data(hw) == true) {
 		for (i = 0; i < IXGB_ETH_LENGTH_OF_ADDRESS; i++) {
 			mac_addr[i] = ee_map->mac_addr[i];
 			DEBUGOUT2("mac(%d) = %.2X\n", i, mac_addr[i]);
@@ -577,7 +577,7 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
 uint32_t
 ixgb_get_ee_pba_number(struct ixgb_hw *hw)
 {
-	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+	if (ixgb_check_and_get_eeprom_data(hw) == true)
 		return (le16_to_cpu(hw->eeprom[EEPROM_PBA_1_2_REG])
 			| (le16_to_cpu(hw->eeprom[EEPROM_PBA_3_4_REG])<<16));
 
@@ -598,7 +598,7 @@ ixgb_get_ee_device_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+	if (ixgb_check_and_get_eeprom_data(hw) == true)
 		return (le16_to_cpu(ee_map->device_id));
 
 	return (0);
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ixgb/ixgb_ee.h
index 7908bf3..da62f58 100644
--- a/drivers/net/ixgb/ixgb_ee.h
+++ b/drivers/net/ixgb/ixgb_ee.h
@@ -97,7 +97,7 @@ struct ixgb_ee_map_type {
 /* EEPROM Functions */
 uint16_t ixgb_read_eeprom(struct ixgb_hw *hw, uint16_t reg);
 
-boolean_t ixgb_validate_eeprom_checksum(struct ixgb_hw *hw);
+bool ixgb_validate_eeprom_checksum(struct ixgb_hw *hw);
 
 void ixgb_update_eeprom_checksum(struct ixgb_hw *hw);
 
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 75f3a68..5d61c2e 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -33,7 +33,7 @@
 #include <asm/uaccess.h>
 
 extern int ixgb_up(struct ixgb_adapter *adapter);
-extern void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
+extern void ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog);
 extern void ixgb_reset(struct ixgb_adapter *adapter);
 extern int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
 extern int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
@@ -136,7 +136,7 @@ ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		return -EINVAL;
 	
 	if(netif_running(adapter->netdev)) {
-		ixgb_down(adapter, TRUE);
+		ixgb_down(adapter, true);
 		ixgb_reset(adapter);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
@@ -185,7 +185,7 @@ ixgb_set_pauseparam(struct net_device *netdev,
 		hw->fc.type = ixgb_fc_none;
 
 	if(netif_running(adapter->netdev)) {
-		ixgb_down(adapter, TRUE);
+		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
 	} else
@@ -210,7 +210,7 @@ ixgb_set_rx_csum(struct net_device *netdev, uint32_t data)
 	adapter->rx_csum = data;
 
 	if(netif_running(netdev)) {
-		ixgb_down(adapter,TRUE);
+		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
 	} else
@@ -570,7 +570,7 @@ ixgb_set_ringparam(struct net_device *netdev,
 		return -EINVAL;
 
 	if(netif_running(adapter->netdev))
-		ixgb_down(adapter,TRUE);
+		ixgb_down(adapter, true);
 
 	rxdr->count = max(ring->rx_pending,(uint32_t)MIN_RXD);
 	rxdr->count = min(rxdr->count,(uint32_t)MAX_RXD);
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 80a8b98..8a04bbd 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -41,7 +41,7 @@ static void ixgb_mta_set(struct ixgb_hw *hw, uint32_t hash_value);
 
 static void ixgb_get_bus_info(struct ixgb_hw *hw);
 
-static boolean_t ixgb_link_reset(struct ixgb_hw *hw);
+static bool ixgb_link_reset(struct ixgb_hw *hw);
 
 static void ixgb_optics_reset(struct ixgb_hw *hw);
 
@@ -60,9 +60,9 @@ static uint16_t ixgb_read_phy_reg(struct ixgb_hw *hw,
 				  uint32_t phy_address,
 				  uint32_t device_type);
 
-static boolean_t ixgb_setup_fc(struct ixgb_hw *hw);
+static bool ixgb_setup_fc(struct ixgb_hw *hw);
 
-static boolean_t mac_addr_valid(uint8_t *mac_addr);
+static bool mac_addr_valid(uint8_t *mac_addr);
 
 static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
 {
@@ -114,7 +114,7 @@ static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-boolean_t
+bool
 ixgb_adapter_stop(struct ixgb_hw *hw)
 {
 	uint32_t ctrl_reg;
@@ -127,13 +127,13 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	 */
 	if(hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is already stopped!!!\n");
-		return FALSE;
+		return false;
 	}
 
 	/* Set the Adapter Stopped flag so other driver functions stop
 	 * touching the Hardware.
 	 */
-	hw->adapter_stopped = TRUE;
+	hw->adapter_stopped = true;
 
 	/* Clear interrupt mask to stop board from generating interrupts */
 	DEBUGOUT("Masking off all interrupts\n");
@@ -286,15 +286,15 @@ ixgb_identify_phy(struct ixgb_hw *hw)
  * Leaves the transmit and receive units disabled and uninitialized.
  *
  * Returns:
- *      TRUE if successful,
- *      FALSE if unrecoverable problems were encountered.
+ *      true if successful,
+ *      false if unrecoverable problems were encountered.
  *****************************************************************************/
-boolean_t
+bool
 ixgb_init_hw(struct ixgb_hw *hw)
 {
 	uint32_t i;
 	uint32_t ctrl_reg;
-	boolean_t status;
+	bool status;
 
 	DEBUGFUNC("ixgb_init_hw");
 
@@ -318,9 +318,8 @@ ixgb_init_hw(struct ixgb_hw *hw)
 	/* Delay a few ms just to allow the reset to complete */
 	msleep(IXGB_DELAY_AFTER_EE_RESET);
 
-	if (ixgb_get_eeprom_data(hw) == FALSE) {
-		return(FALSE);
-	}
+	if (!ixgb_get_eeprom_data(hw))
+		return false;
 
 	/* Use the device id to determine the type of phy/transceiver. */
 	hw->device_id = ixgb_get_ee_device_id(hw);
@@ -337,11 +336,11 @@ ixgb_init_hw(struct ixgb_hw *hw)
 	 */
 	if (!mac_addr_valid(hw->curr_mac_addr)) {
 		DEBUGOUT("MAC address invalid after ixgb_init_rx_addrs\n");
-		return(FALSE);
+		return(false);
 	}
 
 	/* tell the routines in this file they can access hardware again */
-	hw->adapter_stopped = FALSE;
+	hw->adapter_stopped = false;
 
 	/* Fill in the bus_info structure */
 	ixgb_get_bus_info(hw);
@@ -661,12 +660,12 @@ ixgb_clear_vfta(struct ixgb_hw *hw)
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
 
-static boolean_t
+static bool
 ixgb_setup_fc(struct ixgb_hw *hw)
 {
 	uint32_t ctrl_reg;
 	uint32_t pap_reg = 0;   /* by default, assume no pause time */
-	boolean_t status = TRUE;
+	bool status = true;
 
 	DEBUGFUNC("ixgb_setup_fc");
 
@@ -950,7 +949,7 @@ ixgb_check_for_link(struct ixgb_hw *hw)
 
 	if ((xpcss_reg & IXGB_XPCSS_ALIGN_STATUS) &&
 	    (status_reg & IXGB_STATUS_LU)) {
-		hw->link_up = TRUE;
+		hw->link_up = true;
 	} else if (!(xpcss_reg & IXGB_XPCSS_ALIGN_STATUS) &&
 		   (status_reg & IXGB_STATUS_LU)) {
 		DEBUGOUT("XPCSS Not Aligned while Status:LU is set.\n");
@@ -974,10 +973,10 @@ ixgb_check_for_link(struct ixgb_hw *hw)
  *
  * Called by any function that needs to check the link status of the adapter.
  *****************************************************************************/
-boolean_t ixgb_check_for_bad_link(struct ixgb_hw *hw)
+bool ixgb_check_for_bad_link(struct ixgb_hw *hw)
 {
 	uint32_t newLFC, newRFC;
-	boolean_t bad_link_returncode = FALSE;
+	bool bad_link_returncode = false;
 
 	if (hw->phy_type == ixgb_phy_type_txn17401) {
 		newLFC = IXGB_READ_REG(hw, LFC);
@@ -986,7 +985,7 @@ boolean_t ixgb_check_for_bad_link(struct ixgb_hw *hw)
 		    || (hw->lastRFC + 250 < newRFC)) {
 			DEBUGOUT
 			    ("BAD LINK! too many LFC/RFC since last check\n");
-			bad_link_returncode = TRUE;
+			bad_link_returncode = true;
 		}
 		hw->lastLFC = newLFC;
 		hw->lastRFC = newRFC;
@@ -1155,21 +1154,21 @@ ixgb_get_bus_info(struct ixgb_hw *hw)
  * mac_addr - pointer to MAC address.
  *
  *****************************************************************************/
-static boolean_t
+static bool
 mac_addr_valid(uint8_t *mac_addr)
 {
-	boolean_t is_valid = TRUE;
+	bool is_valid = true;
 	DEBUGFUNC("mac_addr_valid");
 
 	/* Make sure it is not a multicast address */
 	if (IS_MULTICAST(mac_addr)) {
 		DEBUGOUT("MAC address is multicast\n");
-		is_valid = FALSE;
+		is_valid = false;
 	}
 	/* Not a broadcast address */
 	else if (IS_BROADCAST(mac_addr)) {
 		DEBUGOUT("MAC address is broadcast\n");
-		is_valid = FALSE;
+		is_valid = false;
 	}
 	/* Reject the zero address */
 	else if (mac_addr[0] == 0 &&
@@ -1179,7 +1178,7 @@ mac_addr_valid(uint8_t *mac_addr)
 			 mac_addr[4] == 0 &&
 			 mac_addr[5] == 0) {
 		DEBUGOUT("MAC address is all zeros\n");
-		is_valid = FALSE;
+		is_valid = false;
 	}
 	return (is_valid);
 }
@@ -1190,10 +1189,10 @@ mac_addr_valid(uint8_t *mac_addr)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static boolean_t
+static bool
 ixgb_link_reset(struct ixgb_hw *hw)
 {
-	boolean_t link_status = FALSE;
+	bool link_status = false;
 	uint8_t wait_retries = MAX_RESET_ITERATIONS;
 	uint8_t lrst_retries = MAX_RESET_ITERATIONS;
 
@@ -1208,7 +1207,7 @@ ixgb_link_reset(struct ixgb_hw *hw)
 			link_status =
 			    ((IXGB_READ_REG(hw, STATUS) & IXGB_STATUS_LU)
 			     && (IXGB_READ_REG(hw, XPCSS) &
-				 IXGB_XPCSS_ALIGN_STATUS)) ? TRUE : FALSE;
+				 IXGB_XPCSS_ALIGN_STATUS)) ? true : false;
 		} while (!link_status && --wait_retries);
 
 	} while (!link_status && --lrst_retries);
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index 4f176ff..d4e9566 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -650,7 +650,7 @@ struct ixgb_flash_buffer {
  * This is a little-endian specific check.
  */
 #define IS_MULTICAST(Address) \
-    (boolean_t)(((uint8_t *)(Address))[0] & ((uint8_t)0x01))
+    (bool)(((uint8_t *)(Address))[0] & ((uint8_t)0x01))
 
 /*
  * Check whether an address is broadcast.
@@ -663,7 +663,7 @@ struct ixgb_fc {
 	uint32_t high_water;	/* Flow Control High-water          */
 	uint32_t low_water;	/* Flow Control Low-water           */
 	uint16_t pause_time;	/* Flow Control Pause timer         */
-	boolean_t send_xon;	/* Flow control send XON            */
+	bool send_xon;		/* Flow control send XON            */
 	ixgb_fc_type type;	/* Type of flow control             */
 };
 
@@ -700,8 +700,8 @@ struct ixgb_hw {
 	uint32_t num_tx_desc;	/* Number of Transmit descriptors   */
 	uint32_t num_rx_desc;	/* Number of Receive descriptors    */
 	uint32_t rx_buffer_size;	/* Size of Receive buffer           */
-	boolean_t link_up;	/* TRUE if link is valid            */
-	boolean_t adapter_stopped;	/* State of adapter                 */
+	bool link_up;		/* true if link is valid            */
+	bool adapter_stopped;	/* State of adapter                 */
 	uint16_t device_id;	/* device id from PCI configuration space */
 	uint16_t vendor_id;	/* vendor id from PCI configuration space */
 	uint8_t revision_id;	/* revision id from PCI configuration space */
@@ -783,11 +783,11 @@ struct ixgb_hw_stats {
 };
 
 /* Function Prototypes */
-extern boolean_t ixgb_adapter_stop(struct ixgb_hw *hw);
-extern boolean_t ixgb_init_hw(struct ixgb_hw *hw);
-extern boolean_t ixgb_adapter_start(struct ixgb_hw *hw);
+extern bool ixgb_adapter_stop(struct ixgb_hw *hw);
+extern bool ixgb_init_hw(struct ixgb_hw *hw);
+extern bool ixgb_adapter_start(struct ixgb_hw *hw);
 extern void ixgb_check_for_link(struct ixgb_hw *hw);
-extern boolean_t ixgb_check_for_bad_link(struct ixgb_hw *hw);
+extern bool ixgb_check_for_bad_link(struct ixgb_hw *hw);
 
 extern void ixgb_rar_set(struct ixgb_hw *hw,
 				uint8_t *addr,
@@ -809,7 +809,7 @@ extern void ixgb_write_vfta(struct ixgb_hw *hw,
 void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t *mac_addr);
 uint32_t ixgb_get_ee_pba_number(struct ixgb_hw *hw);
 uint16_t ixgb_get_ee_device_id(struct ixgb_hw *hw);
-boolean_t ixgb_get_eeprom_data(struct ixgb_hw *hw);
+bool ixgb_get_eeprom_data(struct ixgb_hw *hw);
 __le16 ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index);
 
 /* Everything else */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 548c248..d9688bb 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -67,7 +67,7 @@ MODULE_DEVICE_TABLE(pci, ixgb_pci_tbl);
 /* Local Function Prototypes */
 
 int ixgb_up(struct ixgb_adapter *adapter);
-void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
+void ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog);
 void ixgb_reset(struct ixgb_adapter *adapter);
 int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
 int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
@@ -94,14 +94,14 @@ static struct net_device_stats *ixgb_get_stats(struct net_device *netdev);
 static int ixgb_change_mtu(struct net_device *netdev, int new_mtu);
 static int ixgb_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t ixgb_intr(int irq, void *data);
-static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
+static bool ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
 
 #ifdef CONFIG_IXGB_NAPI
 static int ixgb_clean(struct napi_struct *napi, int budget);
-static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
-				   int *work_done, int work_to_do);
+static bool ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
+			      int *work_done, int work_to_do);
 #else
-static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
+static bool ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
 #endif
 static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter);
 static void ixgb_tx_timeout(struct net_device *dev);
@@ -296,7 +296,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 }
 
 void
-ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
+ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog)
 {
 	struct net_device *netdev = adapter->netdev;
 
@@ -662,7 +662,7 @@ ixgb_close(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	ixgb_down(adapter, TRUE);
+	ixgb_down(adapter, true);
 
 	ixgb_free_tx_resources(adapter);
 	ixgb_free_rx_resources(adapter);
@@ -887,7 +887,7 @@ ixgb_configure_rx(struct ixgb_adapter *adapter)
 	IXGB_WRITE_REG(hw, RXDCTL, rxdctl);
 
 	/* Enable Receive Checksum Offload for TCP and UDP */
-	if(adapter->rx_csum == TRUE) {
+	if (adapter->rx_csum) {
 		rxcsum = IXGB_READ_REG(hw, RXCSUM);
 		rxcsum |= IXGB_RXCSUM_TUOFL;
 		IXGB_WRITE_REG(hw, RXCSUM, rxcsum);
@@ -1170,7 +1170,7 @@ ixgb_watchdog(unsigned long data)
 	}
 
 	/* Force detection of hung controller every watchdog period */
-	adapter->detect_tx_hung = TRUE;
+	adapter->detect_tx_hung = true;
 
 	/* generate an interrupt to force clean up of any stragglers */
 	IXGB_WRITE_REG(&adapter->hw, ICS, IXGB_INT_TXDW);
@@ -1249,7 +1249,7 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 	return 0;
 }
 
-static boolean_t
+static bool
 ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
 	struct ixgb_context_desc *context_desc;
@@ -1281,10 +1281,10 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
-		return TRUE;
+		return true;
 	}
 
-	return FALSE;
+	return false;
 }
 
 #define IXGB_MAX_TXD_PWR	14
@@ -1558,7 +1558,7 @@ ixgb_tx_timeout_task(struct work_struct *work)
 		container_of(work, struct ixgb_adapter, tx_timeout_task);
 
 	adapter->tx_timeout_count++;
-	ixgb_down(adapter, TRUE);
+	ixgb_down(adapter, true);
 	ixgb_up(adapter);
 }
 
@@ -1605,7 +1605,7 @@ ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 	netdev->mtu = new_mtu;
 
 	if ((old_max_frame != max_frame) && netif_running(netdev)) {
-		ixgb_down(adapter, TRUE);
+		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 	}
 
@@ -1822,7 +1822,7 @@ ixgb_clean(struct napi_struct *napi, int budget)
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
@@ -1830,7 +1830,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 	struct ixgb_tx_desc *tx_desc, *eop_desc;
 	struct ixgb_buffer *buffer_info;
 	unsigned int i, eop;
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
@@ -1838,7 +1838,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 
 	while(eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
-		for(cleaned = FALSE; !cleaned; ) {
+		for (cleaned = false; !cleaned; ) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 
@@ -1872,7 +1872,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 	if(adapter->detect_tx_hung) {
 		/* detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
-		adapter->detect_tx_hung = FALSE;
+		adapter->detect_tx_hung = false;
 		if (tx_ring->buffer_info[eop].dma &&
 		   time_after(jiffies, tx_ring->buffer_info[eop].time_stamp + HZ)
 		   && !(IXGB_READ_REG(&adapter->hw, STATUS) &
@@ -1942,7 +1942,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 #ifdef CONFIG_IXGB_NAPI
 ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 #else
@@ -1956,7 +1956,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 	struct ixgb_buffer *buffer_info, *next_buffer, *next2_buffer;
 	uint32_t length;
 	unsigned int i, j;
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 
 	i = rx_ring->next_to_clean;
 	rx_desc = IXGB_RX_DESC(*rx_ring, i);
@@ -1990,7 +1990,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		next_skb = next_buffer->skb;
 		prefetch(next_skb);
 
-		cleaned = TRUE;
+		cleaned = true;
 
 		pci_unmap_single(pdev,
 				 buffer_info->dma,
@@ -2293,7 +2293,7 @@ static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
 	if(netif_running(netdev))
-		ixgb_down(adapter, TRUE);
+		ixgb_down(adapter, true);
 
 	pci_disable_device(pdev);
 
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
index 9e04a6b..4be1b27 100644
--- a/drivers/net/ixgb/ixgb_osdep.h
+++ b/drivers/net/ixgb/ixgb_osdep.h
@@ -39,13 +39,6 @@
 #include <linux/interrupt.h>
 #include <linux/sched.h>
 
-typedef enum {
-#undef FALSE
-	FALSE = 0,
-#undef TRUE
-	TRUE = 1
-} boolean_t;
-
 #undef ASSERT
 #define ASSERT(x)	if(!(x)) BUG()
 #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
