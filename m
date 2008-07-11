From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 4/9] e1000: Remove spaces after casts and function
	names
Date: Fri, 11 Jul 2008 15:17:18 -0700
Message-ID: <20080711221718.3255.10388.stgit@localhost.localdomain>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62937 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756523AbYGKWRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:17:19 -0400
In-Reply-To: <20080711221442.3255.16180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h         |   16 ++++++-----
 drivers/net/e1000/e1000_ethtool.c |   16 ++++++-----
 drivers/net/e1000/e1000_hw.c      |   53 ++++++++++++++++++-------------------
 drivers/net/e1000/e1000_main.c    |   14 +++++-----
 drivers/net/e1000/e1000_osdep.h   |    2 +
 5 files changed, 50 insertions(+), 51 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 20188af..a1f4a76 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -287,16 +287,16 @@ struct e1000_adapter {
 
 	/* RX */
 #ifdef CONFIG_E1000_NAPI
-	bool (*clean_rx) (struct e1000_adapter *adapter,
-			  struct e1000_rx_ring *rx_ring,
-			  int *work_done, int work_to_do);
+	bool (*clean_rx)(struct e1000_adapter *adapter,
+			 struct e1000_rx_ring *rx_ring,
+			 int *work_done, int work_to_do);
 #else
-	bool (*clean_rx) (struct e1000_adapter *adapter,
-			  struct e1000_rx_ring *rx_ring);
+	bool (*clean_rx)(struct e1000_adapter *adapter,
+			 struct e1000_rx_ring *rx_ring);
 #endif
-	void (*alloc_rx_buf) (struct e1000_adapter *adapter,
-			      struct e1000_rx_ring *rx_ring,
-				int cleaned_count);
+	void (*alloc_rx_buf)(struct e1000_adapter *adapter,
+			     struct e1000_rx_ring *rx_ring,
+			     int cleaned_count);
 	struct e1000_rx_ring *rx_ring;      /* One per active queue */
 #ifdef CONFIG_E1000_NAPI
 	struct napi_struct napi;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index e262605..f9ac9a8 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -881,7 +881,7 @@ static int e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 	}
 
 	/* If Checksum is not Correct return error else test passed */
-	if ((checksum != (u16) EEPROM_SUM) && !(*data))
+	if ((checksum != (u16)EEPROM_SUM) && !(*data))
 		*data = 2;
 
 	return *data;
@@ -889,7 +889,7 @@ static int e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 
 static irqreturn_t e1000_test_intr(int irq, void *data)
 {
-	struct net_device *netdev = (struct net_device *) data;
+	struct net_device *netdev = (struct net_device *)data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
@@ -1074,8 +1074,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	memset(txdr->desc, 0, txdr->size);
 	txdr->next_to_use = txdr->next_to_clean = 0;
 
-	ew32(TDBAL, ((u64) txdr->dma & 0x00000000FFFFFFFF));
-	ew32(TDBAH, ((u64) txdr->dma >> 32));
+	ew32(TDBAL, ((u64)txdr->dma & 0x00000000FFFFFFFF));
+	ew32(TDBAH, ((u64)txdr->dma >> 32));
 	ew32(TDLEN, txdr->count * sizeof(struct e1000_tx_desc));
 	ew32(TDH, 0);
 	ew32(TDT, 0);
@@ -1128,8 +1128,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 
 	rctl = er32(RCTL);
 	ew32(RCTL, rctl & ~E1000_RCTL_EN);
-	ew32(RDBAL, ((u64) rxdr->dma & 0xFFFFFFFF));
-	ew32(RDBAH, ((u64) rxdr->dma >> 32));
+	ew32(RDBAL, ((u64)rxdr->dma & 0xFFFFFFFF));
+	ew32(RDBAH, ((u64)rxdr->dma >> 32));
 	ew32(RDLEN, rxdr->size);
 	ew32(RDH, 0);
 	ew32(RDT, 0);
@@ -1863,7 +1863,7 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function = e1000_led_blink_callback;
-			adapter->blink_timer.data = (unsigned long) adapter;
+			adapter->blink_timer.data = (unsigned long)adapter;
 		}
 		e1000_setup_led(hw);
 		mod_timer(&adapter->blink_timer, jiffies);
@@ -1873,7 +1873,7 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function = e1000_led_blink_callback;
-			adapter->blink_timer.data = (unsigned long) adapter;
+			adapter->blink_timer.data = (unsigned long)adapter;
 		}
 		mod_timer(&adapter->blink_timer, jiffies);
 		msleep_interruptible(data * 1000);
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 5d3c2bd..9d6edf3 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -3533,7 +3533,7 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
             DEBUGOUT("MDI Error\n");
             return -E1000_ERR_PHY;
         }
-        *phy_data = (u16) mdic;
+        *phy_data = (u16)mdic;
     } else {
         /* We must first send a preamble through the MDIO pin to signal the
          * beginning of an MII instruction.  This is done by sending 32
@@ -3648,7 +3648,7 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
          * for the PHY register in the MDI Control register.  The MAC will take
          * care of interfacing with the PHY to send the desired data.
          */
-        mdic = (((u32) phy_data) |
+        mdic = (((u32)phy_data) |
                 (reg_addr << E1000_MDIC_REG_SHIFT) |
                 (phy_addr << E1000_MDIC_PHY_SHIFT) |
                 (E1000_MDIC_OP_WRITE));
@@ -3682,7 +3682,7 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
         mdic = ((PHY_TURNAROUND) | (reg_addr << 2) | (phy_addr << 7) |
                 (PHY_OP_WRITE << 12) | (PHY_SOF << 14));
         mdic <<= 16;
-        mdic |= (u32) phy_data;
+        mdic |= (u32)phy_data;
 
         e1000_shift_out_mdi_bits(hw, mdic, 32);
     }
@@ -4032,14 +4032,14 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *hw)
     if (ret_val)
         return ret_val;
 
-    hw->phy_id = (u32) (phy_id_high << 16);
+    hw->phy_id = (u32)(phy_id_high << 16);
     udelay(20);
     ret_val = e1000_read_phy_reg(hw, PHY_ID2, &phy_id_low);
     if (ret_val)
         return ret_val;
 
-    hw->phy_id |= (u32) (phy_id_low & PHY_REVISION_MASK);
-    hw->phy_revision = (u32) phy_id_low & ~PHY_REVISION_MASK;
+    hw->phy_id |= (u32)(phy_id_low & PHY_REVISION_MASK);
+    hw->phy_revision = (u32)phy_id_low & ~PHY_REVISION_MASK;
 
     switch (hw->mac_type) {
     case e1000_82543:
@@ -5174,7 +5174,7 @@ s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
         checksum += eeprom_data;
     }
 
-    if (checksum == (u16) EEPROM_SUM)
+    if (checksum == (u16)EEPROM_SUM)
         return E1000_SUCCESS;
     else {
         DEBUGOUT("EEPROM Checksum Invalid\n");
@@ -5205,7 +5205,7 @@ s32 e1000_update_eeprom_checksum(struct e1000_hw *hw)
         }
         checksum += eeprom_data;
     }
-    checksum = (u16) EEPROM_SUM - checksum;
+    checksum = (u16)EEPROM_SUM - checksum;
     if (e1000_write_eeprom(hw, EEPROM_CHECKSUM_REG, 1, &checksum) < 0) {
         DEBUGOUT("EEPROM Write Error\n");
         return -E1000_ERR_EEPROM;
@@ -5610,8 +5610,8 @@ s32 e1000_read_mac_addr(struct e1000_hw *hw)
             DEBUGOUT("EEPROM Read Error\n");
             return -E1000_ERR_EEPROM;
         }
-        hw->perm_mac_addr[i] = (u8) (eeprom_data & 0x00FF);
-        hw->perm_mac_addr[i+1] = (u8) (eeprom_data >> 8);
+        hw->perm_mac_addr[i] = (u8)(eeprom_data & 0x00FF);
+        hw->perm_mac_addr[i+1] = (u8)(eeprom_data >> 8);
     }
 
     switch (hw->mac_type) {
@@ -5693,37 +5693,37 @@ u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
     case 0:
         if (hw->mac_type == e1000_ich8lan) {
             /* [47:38] i.e. 0x158 for above example address */
-            hash_value = ((mc_addr[4] >> 6) | (((u16) mc_addr[5]) << 2));
+            hash_value = ((mc_addr[4] >> 6) | (((u16)mc_addr[5]) << 2));
         } else {
             /* [47:36] i.e. 0x563 for above example address */
-            hash_value = ((mc_addr[4] >> 4) | (((u16) mc_addr[5]) << 4));
+            hash_value = ((mc_addr[4] >> 4) | (((u16)mc_addr[5]) << 4));
         }
         break;
     case 1:
         if (hw->mac_type == e1000_ich8lan) {
             /* [46:37] i.e. 0x2B1 for above example address */
-            hash_value = ((mc_addr[4] >> 5) | (((u16) mc_addr[5]) << 3));
+            hash_value = ((mc_addr[4] >> 5) | (((u16)mc_addr[5]) << 3));
         } else {
             /* [46:35] i.e. 0xAC6 for above example address */
-            hash_value = ((mc_addr[4] >> 3) | (((u16) mc_addr[5]) << 5));
+            hash_value = ((mc_addr[4] >> 3) | (((u16)mc_addr[5]) << 5));
         }
         break;
     case 2:
         if (hw->mac_type == e1000_ich8lan) {
             /*[45:36] i.e. 0x163 for above example address */
-            hash_value = ((mc_addr[4] >> 4) | (((u16) mc_addr[5]) << 4));
+            hash_value = ((mc_addr[4] >> 4) | (((u16)mc_addr[5]) << 4));
         } else {
             /* [45:34] i.e. 0x5D8 for above example address */
-            hash_value = ((mc_addr[4] >> 2) | (((u16) mc_addr[5]) << 6));
+            hash_value = ((mc_addr[4] >> 2) | (((u16)mc_addr[5]) << 6));
         }
         break;
     case 3:
         if (hw->mac_type == e1000_ich8lan) {
             /* [43:34] i.e. 0x18D for above example address */
-            hash_value = ((mc_addr[4] >> 2) | (((u16) mc_addr[5]) << 6));
+            hash_value = ((mc_addr[4] >> 2) | (((u16)mc_addr[5]) << 6));
         } else {
             /* [43:32] i.e. 0x634 for above example address */
-            hash_value = ((mc_addr[4]) | (((u16) mc_addr[5]) << 8));
+            hash_value = ((mc_addr[4]) | (((u16)mc_addr[5]) << 8));
         }
         break;
     }
@@ -5795,10 +5795,9 @@ void e1000_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
     /* HW expects these in little endian so we reverse the byte order
      * from network order (big endian) to little endian
      */
-    rar_low = ((u32) addr[0] |
-               ((u32) addr[1] << 8) |
-               ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
-    rar_high = ((u32) addr[4] | ((u32) addr[5] << 8));
+    rar_low = ((u32)addr[0] | ((u32)addr[1] << 8) |
+               ((u32)addr[2] << 16) | ((u32)addr[3] << 24));
+    rar_high = ((u32)addr[4] | ((u32)addr[5] << 8));
 
     /* Disable Rx and flush all Rx frames before enabling RSS to avoid Rx
      * unit hang.
@@ -6412,7 +6411,7 @@ void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats,
      * since the test for a multicast frame will test positive on
      * a broadcast frame.
      */
-    if ((mac_addr[0] == (u8) 0xff) && (mac_addr[1] == (u8) 0xff))
+    if ((mac_addr[0] == (u8)0xff) && (mac_addr[1] == (u8)0xff))
         /* Broadcast packet */
         stats->bprc++;
     else if (*mac_addr & 0x01)
@@ -7382,7 +7381,7 @@ static s32 e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer)
     offset = (offset >> 2);
 
     for (i = 0; i < length; i++) {
-        *((u32 *) buffer + i) =
+        *((u32 *)buffer + i) =
             E1000_READ_REG_ARRAY_DWORD(hw, HOST_IF, offset + i);
     }
     return E1000_SUCCESS;
@@ -7513,7 +7512,7 @@ static s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
     sum = hdr->checksum;
     hdr->checksum = 0;
 
-    buffer = (u8 *) hdr;
+    buffer = (u8 *)hdr;
     i = length;
     while (i--)
         sum += buffer[i];
@@ -7523,7 +7522,7 @@ static s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
     length >>= 2;
     /* The device driver writes the relevant command block into the ram area. */
     for (i = 0; i < length; i++) {
-        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, i, *((u32 *) hdr + i));
+        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, i, *((u32 *)hdr + i));
         E1000_WRITE_FLUSH();
     }
 
@@ -7616,7 +7615,7 @@ static u8 e1000_calculate_mng_checksum(char *buffer, u32 length)
     for (i=0; i < length; i++)
         sum += buffer[i];
 
-    return (u8) (0 - sum);
+    return (u8)(0 - sum);
 }
 
 /*****************************************************************************
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 404c2d4..397fe52 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1056,7 +1056,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	init_timer(&adapter->tx_fifo_stall_timer);
 	adapter->tx_fifo_stall_timer.function = &e1000_82547_tx_fifo_stall;
-	adapter->tx_fifo_stall_timer.data = (unsigned long) adapter;
+	adapter->tx_fifo_stall_timer.data = (unsigned long)adapter;
 
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &e1000_watchdog;
@@ -1064,7 +1064,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	init_timer(&adapter->phy_info_timer);
 	adapter->phy_info_timer.function = &e1000_update_phy_info;
-	adapter->phy_info_timer.data = (unsigned long) adapter;
+	adapter->phy_info_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
 
@@ -1540,7 +1540,7 @@ static bool e1000_check_64k_bound(struct e1000_adapter *adapter, void *start,
 				  unsigned long len)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	unsigned long begin = (unsigned long) start;
+	unsigned long begin = (unsigned long)start;
 	unsigned long end = begin + len;
 
 	/* First rev 82545 and 82546 need to not allow any memory
@@ -2531,7 +2531,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 
 static void e1000_update_phy_info(unsigned long data)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
 	struct e1000_hw *hw = &adapter->hw;
 	e1000_phy_get_info(hw, &adapter->phy_info);
 }
@@ -2543,7 +2543,7 @@ static void e1000_update_phy_info(unsigned long data)
 
 static void e1000_82547_tx_fifo_stall(unsigned long data)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	u32 tctl;
@@ -2576,7 +2576,7 @@ static void e1000_82547_tx_fifo_stall(unsigned long data)
  **/
 static void e1000_watchdog(unsigned long data)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
@@ -3218,7 +3218,7 @@ static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
 			return 0;
 	}
 	if (skb->len > MINIMUM_DHCP_PACKET_SIZE) {
-		struct ethhdr *eth = (struct ethhdr *) skb->data;
+		struct ethhdr *eth = (struct ethhdr *)skb->data;
 		if ((htons(ETH_P_IP) == eth->h_proto)) {
 			const struct iphdr *ip =
 				(struct iphdr *)((u8 *)skb->data+14);
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index acb5134..d929852 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -55,7 +55,7 @@
 #define DEBUGOUT7 DEBUGOUT3
 
 
-#define er32(reg)\
+#define er32(reg)							\
 	(readl(hw->hw_addr + ((hw->mac_type >= e1000_82543)		\
 			       ? E1000_##reg : E1000_82542_##reg)))
 

