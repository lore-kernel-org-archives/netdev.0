From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 14/14] e1000: Driver version number, white spaces,
 comments, device id & other changes
Date: Thu, 6 Jan 2005 17:22:18 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061537320.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_hw.c net-drivers-2.6/drivers/net/e1000.new/e1000_hw.c
--- net-drivers-2.6/drivers/net/e1000/e1000_hw.c	2004-12-03 07:24:37.090623184 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_hw.c	2004-12-03 07:24:38.466414032 -0800
@@ -270,6 +270,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82546GB_COPPER:
     case E1000_DEV_ID_82546GB_FIBER:
     case E1000_DEV_ID_82546GB_SERDES:
+    case E1000_DEV_ID_82546GB_PCIE:
         hw->mac_type = e1000_82546_rev_3;
         break;
     case E1000_DEV_ID_82541EI:
@@ -2137,7 +2138,7 @@ e1000_check_for_link(struct e1000_hw *hw
          * at gigabit speed, then TBI compatibility is not needed.  If we are
          * at gigabit speed, we turn on TBI compatibility.
          */
-	if(hw->tbi_compatibility_en) {
+        if(hw->tbi_compatibility_en) {
             uint16_t speed, duplex;
             e1000_get_speed_and_duplex(hw, &speed, &duplex);
             if(speed != SPEED_1000) {
@@ -2492,12 +2493,14 @@ e1000_read_phy_reg(struct e1000_hw *hw,
 
     DEBUGFUNC("e1000_read_phy_reg");
 
+
     if(hw->phy_type == e1000_phy_igp &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
                                          (uint16_t)reg_addr);
-        if(ret_val)
+        if(ret_val) {
             return ret_val;
+        }
     }
 
     ret_val = e1000_read_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
@@ -2596,12 +2599,14 @@ e1000_write_phy_reg(struct e1000_hw *hw,
 
     DEBUGFUNC("e1000_write_phy_reg");
 
+
     if(hw->phy_type == e1000_phy_igp &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
                                          (uint16_t)reg_addr);
-        if(ret_val)
+        if(ret_val) {
             return ret_val;
+        }
     }
 
     ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
diff -up net-drivers-2.6/drivers/net/e1000/e1000_hw.h net-drivers-2.6/drivers/net/e1000.new/e1000_hw.h
--- net-drivers-2.6/drivers/net/e1000/e1000_hw.h	2004-12-03 07:24:37.090623184 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_hw.h	2004-12-03 07:24:38.524405216 -0800
@@ -367,6 +367,7 @@ int32_t e1000_set_d3_lplu_state(struct e
 #define E1000_DEV_ID_82546GB_COPPER      0x1079
 #define E1000_DEV_ID_82546GB_FIBER       0x107A
 #define E1000_DEV_ID_82546GB_SERDES      0x107B
+#define E1000_DEV_ID_82546GB_PCIE        0x108A
 #define E1000_DEV_ID_82547EI             0x1019
 #define NODE_ADDRESS_SIZE 6
 #define ETH_LENGTH_OF_ADDRESS 6
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2004-12-03 07:24:37.090623184 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2004-12-03 07:24:38.581396552 -0800
@@ -35,10 +35,19 @@
  * - More errlogging support from Jon Mason <jonmason@us.ibm.com>
  * - Fix TSO issues on PPC64 machines -- Jon Mason <jonmason@us.ibm.com>
  *
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
+ * - Avoid filling tx_ring completely - shemminger@osdl.org
+ * - Replace schedule_timeout() with msleep()/msleep_interruptible() -
+ *   nacc@us.ibm.com
+ * - Sparse cleanup - shemminger@osdl.org
+ * - Fix tx resource cleanup logic
+ * - LLTX support - ak@suse.de and hadi@cyberus.ca
  */
 
 char e1000_driver_name[] = "e1000";
@@ -48,7 +48,7 @@ char e1000_driver_string[] = "Intel(R) P
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.5.4-k2"DRIVERNAPI;
+char e1000_driver_version[] = "5.6.10.1-k2"DRIVERNAPI;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -90,6 +99,7 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x107A),
 	INTEL_E1000_ETHERNET_DEVICE(0x107B),
 	INTEL_E1000_ETHERNET_DEVICE(0x107C),
+	INTEL_E1000_ETHERNET_DEVICE(0x108A),
 	/* required last entry */
 	{0,}
 };
@@ -128,8 +138,6 @@ static int e1000_xmit_frame(struct sk_bu
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
-static void e1000_irq_disable(struct e1000_adapter *adapter);
-static void e1000_irq_enable(struct e1000_adapter *adapter);
 static irqreturn_t e1000_intr(int irq, void *data, struct pt_regs *regs);
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter);
 #ifdef CONFIG_E1000_NAPI
@@ -146,9 +163,6 @@ static int e1000_ioctl(struct net_device
 void set_ethtool_ops(struct net_device *netdev);
 static void e1000_enter_82542_rst(struct e1000_adapter *adapter);
 static void e1000_leave_82542_rst(struct e1000_adapter *adapter);
-static void e1000_rx_checksum(struct e1000_adapter *adapter,
-				struct e1000_rx_desc *rx_desc,
-				struct sk_buff *skb);
 static void e1000_tx_timeout(struct net_device *dev);
 static void e1000_tx_timeout_task(struct net_device *dev);
 static void e1000_smartspeed(struct e1000_adapter *adapter);
@@ -242,6 +247,33 @@ e1000_exit_module(void)
 
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
+	synchronize_irq(adapter->pdev->irq);
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
@@ -1815,7 +1824,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {
+	if(unlikely(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2)) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
@@ -1912,9 +1944,9 @@ e1000_change_mtu(struct net_device *netd
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
@@ -2082,34 +2114,6 @@ e1000_update_stats(struct e1000_adapter 
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
-	synchronize_irq(adapter->pdev->irq);
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
@@ -2242,6 +2246,41 @@ e1000_clean_tx_irq(struct e1000_adapter 
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
@@ -2289,7 +2328,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		if(unlikely(!(rx_desc->status & E1000_RXD_STAT_EOP))) {
 			/* All receives must fit into a single buffer */
 			E1000_DBG("%s: Receive packet consumed multiple"
-				  " buffers\n", netdev->name);
+					" buffers\n", netdev->name);
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -2374,8 +2413,8 @@ e1000_alloc_rx_buffers(struct e1000_adap
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while(!buffer_info->skb) {
-
 		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
+
 		if(unlikely(!skb)) {
 			/* Better luck next round */
 			break;
@@ -2585,41 +2624,6 @@ e1000_mii_ioctl(struct net_device *netde
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
