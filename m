From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 5/5 2.4] e1000 - white space corrections, driver version
 number update and others
Date: Fri, 17 Sep 2004 02:56:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170223590.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_hw.c linux-2.4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.4/drivers/net/e1000/e1000_hw.c	2004-09-16 08:09:07.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_hw.c	2004-09-16 08:09:08.000000000 -0700
@@ -125,6 +125,7 @@ e1000_phy_init_script(struct e1000_hw *h
 {
     DEBUGFUNC("e1000_phy_init_script");
 
+    
     if(hw->phy_init_script) {
         msec_delay(20);
 
@@ -1391,6 +1392,7 @@ e1000_phy_setup_autoneg(struct e1000_hw 
     DEBUGOUT1("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
     ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
+    
     if(ret_val)
         return ret_val;
 
@@ -2466,6 +2468,7 @@ e1000_read_phy_reg(struct e1000_hw *hw,
 
     DEBUGFUNC("e1000_read_phy_reg");
 
+
     if(hw->phy_type == e1000_phy_igp &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
@@ -2570,6 +2573,7 @@ e1000_write_phy_reg(struct e1000_hw *hw,
 
     DEBUGFUNC("e1000_write_phy_reg");
 
+
     if(hw->phy_type == e1000_phy_igp &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
@@ -3537,6 +3541,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
     return E1000_SUCCESS;
 }
 
+
 /******************************************************************************
  * Verifies that the EEPROM has a valid checksum
  *
@@ -3623,6 +3628,7 @@ e1000_write_eeprom(struct e1000_hw *hw,
 
     DEBUGFUNC("e1000_write_eeprom");
 
+
     /* A check for invalid values:  offset too large, too many words, and not
      * enough words.
      */
diff -up linux-2.4/drivers/net/e1000/e1000_hw.h linux-2.4/drivers/net/e1000.new/e1000_hw.h
--- linux-2.4/drivers/net/e1000/e1000_hw.h	2004-09-16 08:09:07.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_hw.h	2004-09-16 08:09:08.000000000 -0700
@@ -36,6 +36,7 @@
 #include "e1000_osdep.h"
 
 
+
 /* Forward declarations of structures used by the shared code */
 struct e1000_hw;
 struct e1000_hw_stats;
diff -up linux-2.4/drivers/net/e1000/e1000_main.c linux-2.4/drivers/net/e1000.new/e1000_main.c
--- linux-2.4/drivers/net/e1000/e1000_main.c	2004-09-16 08:09:07.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_main.c	2004-09-16 08:09:08.000000000 -0700
@@ -243,34 +243,6 @@ e1000_exit_module(void)
 module_exit(e1000_exit_module);
 
 
-/**
- * e1000_irq_enable - Enable default interrupt generation settings
- * @adapter: board private structure
- **/
-
-static inline void
-e1000_irq_enable(struct e1000_adapter *adapter)
-{
-	if(atomic_dec_and_test(&adapter->irq_sem)) {
-		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
-		E1000_WRITE_FLUSH(&adapter->hw);
-	}
-}
-
-/**
- * e1000_irq_disable - Mask off interrupt generation on the NIC
- * @adapter: board private structure
- **/
-
-static inline void
-e1000_irq_disable(struct e1000_adapter *adapter)
-{
-	atomic_inc(&adapter->irq_sem);
-	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
-	E1000_WRITE_FLUSH(&adapter->hw);
-	synchronize_irq();
-}
-
 int
 e1000_up(struct e1000_adapter *adapter)
 {
@@ -2087,6 +2059,34 @@ e1000_update_stats(struct e1000_adapter 
 }
 
 /**
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
+
+/**
  * e1000_intr - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
@@ -2230,42 +2230,7 @@ e1000_clean_tx_irq(struct e1000_adapter 
 }
 
 /**
- * e1000_rx_checksum - Receive Checksum Offload for 82543
- * @adapter: board private structure
- * @rx_desc: receive descriptor
- * @sk_buff: socket buffer with received data
- **/
-
-static inline void
-e1000_rx_checksum(struct e1000_adapter *adapter,
-                  struct e1000_rx_desc *rx_desc,
-                  struct sk_buff *skb)
-{
-	/* 82543 or newer only */
-	if((adapter->hw.mac_type < e1000_82543) ||
-	/* Ignore Checksum bit is set */
-	(rx_desc->status & E1000_RXD_STAT_IXSM) ||
-	/* TCP Checksum has not been calculated */
-	(!(rx_desc->status & E1000_RXD_STAT_TCPCS))) {
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
-	/* TCP checksum is good */
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		adapter->hw_csum_good++;
-	}
-}
-
-/**
- * e1000_clean_rx_irq - Send received data up the network stack,
+ * e1000_clean_rx_irq - Send received data up the network stack
  * @adapter: board private structure
  **/
 
@@ -2610,6 +2622,41 @@ e1000_mii_ioctl(struct net_device *netde
 	return E1000_SUCCESS;
 }
 
+/**
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
 void
 e1000_pci_set_mwi(struct e1000_hw *hw)
 {
@@ -2905,12 +2905,12 @@ e1000_resume(struct pci_dev *pdev)
  * without having to re-enable interrupts. It's not called while
  * the interrupt routine is executing.
  */
-
-static void e1000_netpoll (struct net_device *dev)
+static void
+e1000_netpoll (struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = dev->priv;
+	struct e1000_adapter *adapter = netdev->priv;
 	disable_irq(adapter->pdev->irq);
-	e1000_intr (adapter->pdev->irq, dev, NULL);
+	e1000_intr(adapter->pdev->irq, netdev, NULL);
 	enable_irq(adapter->pdev->irq);
 }
 #endif
