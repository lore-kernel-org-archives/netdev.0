From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 13/13] e1000: Driver version number, white spaces,
 comments, device id & other changes
Date: Thu, 6 Jan 2005 17:20:37 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061515300.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000.h net-drivers-2.4/drivers/net/e1000.new/e1000.h
--- net-drivers-2.4/drivers/net/e1000/e1000.h	2004-12-06 08:43:11.624383592 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000.h	2004-12-06 08:43:12.400265640 -0800
@@ -204,7 +204,7 @@ struct e1000_adapter {
 	spinlock_t stats_lock;
 	atomic_t irq_sem;
 	struct tq_struct tx_timeout_task;
-     	uint8_t fc_autoneg;
+	uint8_t fc_autoneg;
 
 	struct timer_list blink_timer;
 	unsigned long led_status;
diff -up net-drivers-2.4/drivers/net/e1000/e1000_hw.c net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c
--- net-drivers-2.4/drivers/net/e1000/e1000_hw.c	2004-12-06 08:43:11.629382832 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c	2004-12-06 08:43:12.460256520 -0800
@@ -270,6 +270,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82546GB_COPPER:
     case E1000_DEV_ID_82546GB_FIBER:
     case E1000_DEV_ID_82546GB_SERDES:
+    case E1000_DEV_ID_82546GB_PCIE:
         hw->mac_type = e1000_82546_rev_3;
         break;
     case E1000_DEV_ID_82541EI:
@@ -2138,7 +2139,7 @@ e1000_check_for_link(struct e1000_hw *hw
          * at gigabit speed, then TBI compatibility is not needed.  If we are
          * at gigabit speed, we turn on TBI compatibility.
          */
-	if(hw->tbi_compatibility_en) {
+        if(hw->tbi_compatibility_en) {
             uint16_t speed, duplex;
             e1000_get_speed_and_duplex(hw, &speed, &duplex);
             if(speed != SPEED_1000) {
@@ -2498,8 +2499,9 @@ e1000_read_phy_reg(struct e1000_hw *hw,
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
                                          (uint16_t)reg_addr);
-        if(ret_val)
+        if(ret_val) {
             return ret_val;
+        }
     }
 
     ret_val = e1000_read_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
@@ -2603,8 +2605,9 @@ e1000_write_phy_reg(struct e1000_hw *hw,
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
                                          (uint16_t)reg_addr);
-        if(ret_val)
+        if(ret_val) {
             return ret_val;
+        }
     }
 
     ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
diff -up net-drivers-2.4/drivers/net/e1000/e1000_hw.h net-drivers-2.4/drivers/net/e1000.new/e1000_hw.h
--- net-drivers-2.4/drivers/net/e1000/e1000_hw.h	2004-12-06 08:43:11.633382224 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_hw.h	2004-12-06 08:43:12.497250896 -0800
@@ -368,6 +368,7 @@ int32_t e1000_set_d3_lplu_state(struct e
 #define E1000_DEV_ID_82546GB_COPPER      0x1079
 #define E1000_DEV_ID_82546GB_FIBER       0x107A
 #define E1000_DEV_ID_82546GB_SERDES      0x107B
+#define E1000_DEV_ID_82546GB_PCIE        0x108A
 #define E1000_DEV_ID_82547EI             0x1019
 #define NODE_ADDRESS_SIZE 6
 #define ETH_LENGTH_OF_ADDRESS 6
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2004-12-06 08:43:11.635381920 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2004-12-06 08:43:12.534245272 -0800
@@ -34,11 +34,15 @@
  * - if_mii support and associated kcompat for older kernels
  * - More errlogging support from Jon Mason <jonmason@us.ibm.com>
  * - Fix TSO issues on PPC64 machines -- Jon Mason <jonmason@us.ibm.com>
- *
- * 5.3.11	6/4/04
- * - ethtool register dump reads MANC register conditionally.
- *
- * 5.3.10	6/1/04
+ * 5.6.5 	11/01/04
+ * - Enabling NETIF_F_SG without checksum offload is illegal - 
+     John Mason <jdmason@us.ibm.com>
+ * 5.6.3        10/26/04
+ * - Remove redundant initialization - Jamal Hadi
+ * - Reset buffer_info->dma in tx resource cleanup logic
+ * 5.6.2	10/12/04
+ * - Sparse cleanup - shemminger@osdl.org
+ * - Fix tx resource cleanup logic
  */
 
 char e1000_driver_name[] = "e1000";
@@ -48,7 +48,7 @@ char e1000_driver_string[] = "Intel(R) P
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.5.4-k1"DRIVERNAPI;
+char e1000_driver_version[] = "5.6.10.1-k1"DRIVERNAPI;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -90,6 +94,7 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x107A),
 	INTEL_E1000_ETHERNET_DEVICE(0x107B),
 	INTEL_E1000_ETHERNET_DEVICE(0x107C),
+	INTEL_E1000_ETHERNET_DEVICE(0x108A),
 	/* required last entry */
 	{0,}
 };
@@ -128,8 +133,6 @@ static int e1000_xmit_frame(struct sk_bu
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
-static void e1000_irq_disable(struct e1000_adapter *adapter);
-static void e1000_irq_enable(struct e1000_adapter *adapter);
 static irqreturn_t e1000_intr(int irq, void *data, struct pt_regs *regs);
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter);
 #ifdef CONFIG_E1000_NAPI
@@ -146,9 +168,6 @@ static int e1000_ioctl(struct net_device
 void set_ethtool_ops(struct net_device *netdev);
 static void e1000_enter_82542_rst(struct e1000_adapter *adapter);
 static void e1000_leave_82542_rst(struct e1000_adapter *adapter);
-static void e1000_rx_checksum(struct e1000_adapter *adapter,
-                              struct e1000_rx_desc *rx_desc,
-                              struct sk_buff *skb);
 static void e1000_tx_timeout(struct net_device *dev);
 static void e1000_tx_timeout_task(struct net_device *dev);
 static void e1000_smartspeed(struct e1000_adapter *adapter);
@@ -242,6 +242,33 @@ e1000_exit_module(void)
 
 module_exit(e1000_exit_module);
 
+/**
+ * e1000_irq_disable - Mask off interrupt generation on the NIC
+ * @adapter: board private structure
+ **/
+
+static inline void
+e1000_irq_disable(struct e1000_adapter *adapter)
+{
+	atomic_inc(&adapter->irq_sem);
+	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
+	E1000_WRITE_FLUSH(&adapter->hw);
+	synchronize_irq();
+}
+
+/**
+ * e1000_irq_enable - Enable default interrupt generation settings
+ * @adapter: board private structure
+ **/
+
+static inline void
+e1000_irq_enable(struct e1000_adapter *adapter)
+{
+	if(likely(atomic_dec_and_test(&adapter->irq_sem))) {
+		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
+		E1000_WRITE_FLUSH(&adapter->hw);
+	}
+}
 
 int
 e1000_up(struct e1000_adapter *adapter)
@@ -1805,22 +1824,22 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {
+	if(unlikely(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2)) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return 1;
 	}
 
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-
 	if(unlikely(adapter->hw.mac_type == e1000_82547)) {
 		if(unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
 			return 1;
+			spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		}
 	}
 
+	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	if(unlikely(adapter->vlgrp && vlan_tx_tag_present(skb))) {
 		tx_flags |= E1000_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
@@ -1898,9 +1925,9 @@ e1000_change_mtu(struct net_device *netd
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
 
 	if((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
-	   (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		DPRINTK(PROBE, ERR, "Invalid MTU setting\n");
-		return -EINVAL;
+		(max_frame > MAX_JUMBO_FRAME_SIZE)) {
+			DPRINTK(PROBE, ERR, "Invalid MTU setting\n");
+			return -EINVAL;
 	}
 
 	if(max_frame <= MAXIMUM_ETHERNET_FRAME_SIZE) {
@@ -2068,34 +2095,6 @@ e1000_update_stats(struct e1000_adapter 
 }
 
 /**
- * e1000_irq_disable - Mask off interrupt generation on the NIC
- * @adapter: board private structure
- **/
-
-static void
-e1000_irq_disable(struct e1000_adapter *adapter)
-{
-	atomic_inc(&adapter->irq_sem);
-	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
-	E1000_WRITE_FLUSH(&adapter->hw);
-	synchronize_irq();
-}
-
-/**
- * e1000_irq_enable - Enable default interrupt generation settings
- * @adapter: board private structure
- **/
-
-static void
-e1000_irq_enable(struct e1000_adapter *adapter)
-{
-	if(likely(atomic_dec_and_test(&adapter->irq_sem))) {
-		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
-		E1000_WRITE_FLUSH(&adapter->hw);
-	}
-}
-
-/**
  * e1000_intr - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
@@ -2228,6 +2227,41 @@ e1000_clean_tx_irq(struct e1000_adapter 
 }
 
 /**
+ * e1000_rx_checksum - Receive Checksum Offload for 82543
+ * @adapter: board private structure
+ * @rx_desc: receive descriptor
+ * @sk_buff: socket buffer with received data
+ **/
+
+static inline void
+e1000_rx_checksum(struct e1000_adapter *adapter,
+                  struct e1000_rx_desc *rx_desc,
+                  struct sk_buff *skb)
+{
+	/* 82543 or newer only */
+	if(unlikely((adapter->hw.mac_type < e1000_82543) ||
+	/* Ignore Checksum bit is set */
+	(rx_desc->status & E1000_RXD_STAT_IXSM) ||
+	/* TCP Checksum has not been calculated */
+	(!(rx_desc->status & E1000_RXD_STAT_TCPCS)))) {
+		skb->ip_summed = CHECKSUM_NONE;
+		return;
+	}
+
+	/* At this point we know the hardware did the TCP checksum */
+	/* now look at the TCP checksum error bit */
+	if(rx_desc->errors & E1000_RXD_ERR_TCPE) {
+		/* let the stack verify checksum errors */
+		skb->ip_summed = CHECKSUM_NONE;
+		adapter->hw_csum_err++;
+	} else {
+		/* TCP checksum is good */
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		adapter->hw_csum_good++;
+	}
+}
+
+/**
  * e1000_clean_rx_irq - Send received data up the network stack
  * @adapter: board private structure
  **/
@@ -2275,7 +2309,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		if(unlikely(!(rx_desc->status & E1000_RXD_STAT_EOP))) {
 			/* All receives must fit into a single buffer */
 			E1000_DBG("%s: Receive packet consumed multiple"
-				  " buffers\n", netdev->name);
+					" buffers\n", netdev->name);
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -2573,41 +2607,6 @@ e1000_mii_ioctl(struct net_device *netde
 	return E1000_SUCCESS;
 }
 
-/**
- * e1000_rx_checksum - Receive Checksum Offload for 82543
- * @adapter: board private structure
- * @rx_desc: receive descriptor
- * @sk_buff: socket buffer with received data
- **/
-
-static void
-e1000_rx_checksum(struct e1000_adapter *adapter,
-                  struct e1000_rx_desc *rx_desc,
-                  struct sk_buff *skb)
-{
-	/* 82543 or newer only */
-	if(unlikely((adapter->hw.mac_type < e1000_82543) ||
-	/* Ignore Checksum bit is set */
-	(rx_desc->status & E1000_RXD_STAT_IXSM) ||
-	/* TCP Checksum has not been calculated */
-	(!(rx_desc->status & E1000_RXD_STAT_TCPCS)))) {
-		skb->ip_summed = CHECKSUM_NONE;
-		return;
-	}
-
-	/* At this point we know the hardware did the TCP checksum */
-	/* now look at the TCP checksum error bit */
-	if(rx_desc->errors & E1000_RXD_ERR_TCPE) {
-		/* let the stack verify checksum errors */
-		skb->ip_summed = CHECKSUM_NONE;
-		adapter->hw_csum_err++;
-	} else {
-		/* TCP checksum is good */
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		adapter->hw_csum_good++;
-	}
-}
-
 void
 e1000_pci_set_mwi(struct e1000_hw *hw)
 {
