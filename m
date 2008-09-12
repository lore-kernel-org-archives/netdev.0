From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 27/29] ixgbe: whitespace/formatting cleanup
Date: Thu, 11 Sep 2008 20:05:39 -0700
Message-ID: <20080912030459.6234.69311.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:19077 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757131AbYILDFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:05:43 -0400
Received: by rv-out-0506.google.com with SMTP id k40so615516rvb.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:05:42 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch cleans up some whitespace items, reorders a couple of functions, and removes some outdated comments.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  125 +++++++++++++++++-----------------------
 1 files changed, 54 insertions(+), 71 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a8edbad..ca17af4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -117,19 +117,6 @@ static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
 	                ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
 }
 
-#ifdef DEBUG
-/**
- * ixgbe_get_hw_dev_name - return device name string
- * used by hardware layer to print debugging information
- **/
-char *ixgbe_get_hw_dev_name(struct ixgbe_hw *hw)
-{
-	struct ixgbe_adapter *adapter = hw->back;
-	struct net_device *netdev = adapter->netdev;
-	return netdev->name;
-}
-#endif
-
 static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, u16 int_alloc_entry,
                            u8 msix_vector)
 {
@@ -1315,7 +1302,6 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr;
 
-
 	/* for NAPI, using EIAM to auto-mask tx/rx interrupt bits on read
 	 * therefore no explict interrupt disable is necessary */
 	eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
@@ -2659,6 +2645,31 @@ err:
 }
 
 /**
+ * ixgbe_setup_all_tx_resources - allocate all queues Tx resources
+ * @adapter: board private structure
+ *
+ * If this function returns with an error, then it's possible one or
+ * more of the rings is populated (while the rest are not).  It is the
+ * callers duty to clean those orphaned rings.
+ *
+ * Return 0 on success, negative on failure
+ **/
+static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
+{
+	int i, err = 0;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		err = ixgbe_setup_tx_resources(adapter, &adapter->tx_ring[i]);
+		if (!err)
+			continue;
+		DPRINTK(PROBE, ERR, "Allocation for Tx Queue %u failed\n", i);
+		break;
+	}
+
+	return err;
+}
+
+/**
  * ixgbe_setup_rx_resources - allocate Rx resources (Descriptors)
  * @adapter: board private structure
  * @rx_ring:    rx descriptor ring (for a specific queue) to setup
@@ -2711,6 +2722,32 @@ alloc_failed:
 }
 
 /**
+ * ixgbe_setup_all_rx_resources - allocate all queues Rx resources
+ * @adapter: board private structure
+ *
+ * If this function returns with an error, then it's possible one or
+ * more of the rings is populated (while the rest are not).  It is the
+ * callers duty to clean those orphaned rings.
+ *
+ * Return 0 on success, negative on failure
+ **/
+
+static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
+{
+	int i, err = 0;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		err = ixgbe_setup_rx_resources(adapter, &adapter->rx_ring[i]);
+		if (!err)
+			continue;
+		DPRINTK(PROBE, ERR, "Allocation for Rx Queue %u failed\n", i);
+		break;
+	}
+
+	return err;
+}
+
+/**
  * ixgbe_free_tx_resources - Free Tx Resources per Queue
  * @adapter: board private structure
  * @tx_ring: Tx descriptor ring for a specific queue
@@ -2786,57 +2823,6 @@ static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_setup_all_tx_resources - allocate all queues Tx resources
- * @adapter: board private structure
- *
- * If this function returns with an error, then it's possible one or
- * more of the rings is populated (while the rest are not).  It is the
- * callers duty to clean those orphaned rings.
- *
- * Return 0 on success, negative on failure
- **/
-static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
-{
-	int i, err = 0;
-
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		err = ixgbe_setup_tx_resources(adapter, &adapter->tx_ring[i]);
-		if (!err)
-			continue;
-		DPRINTK(PROBE, ERR, "Allocation for Tx Queue %u failed\n", i);
-		break;
-	}
-
-	return err;
-}
-
-/**
- * ixgbe_setup_all_rx_resources - allocate all queues Rx resources
- * @adapter: board private structure
- *
- * If this function returns with an error, then it's possible one or
- * more of the rings is populated (while the rest are not).  It is the
- * callers duty to clean those orphaned rings.
- *
- * Return 0 on success, negative on failure
- **/
-
-static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
-{
-	int i, err = 0;
-
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		err = ixgbe_setup_rx_resources(adapter, &adapter->rx_ring[i]);
-		if (!err)
-			continue;
-		DPRINTK(PROBE, ERR, "Allocation for Rx Queue %u failed\n", i);
-		break;
-	}
-
-	return err;
-}
-
-/**
  * ixgbe_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -3001,7 +2987,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
 	pci_restore_state(pdev);
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR "ixgbe: Cannot enable PCI device from " \
+		printk(KERN_ERR "ixgbe: Cannot enable PCI device from "
 				"suspend\n");
 		return err;
 	}
@@ -3189,8 +3175,8 @@ static void ixgbe_watchdog(unsigned long data)
 }
 
 /**
- *  ixgbe_watchdog_task - worker thread to bring link up
- *  @work: pointer to work_struct containing our data
+ * ixgbe_watchdog_task - worker thread to bring link up
+ * @work: pointer to work_struct containing our data
  **/
 static void ixgbe_watchdog_task(struct work_struct *work)
 {
@@ -3526,7 +3512,6 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		tx_desc->read.cmd_type_len =
 		        cpu_to_le32(cmd_type_len | tx_buffer_info->length);
 		tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
-
 		i++;
 		if (i == tx_ring->count)
 			i = 0;
@@ -3576,7 +3561,6 @@ static int ixgbe_maybe_stop_tx(struct net_device *netdev,
 	return __ixgbe_maybe_stop_tx(netdev, tx_ring, size);
 }
 
-
 static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -4086,7 +4070,6 @@ static void ixgbe_io_resume(struct pci_dev *pdev)
 	}
 
 	netif_device_attach(netdev);
-
 }
 
 static struct pci_error_handlers ixgbe_err_handler = {

