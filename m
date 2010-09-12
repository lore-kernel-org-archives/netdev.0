From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/11] drivers/net/skfp: Remove pr_<level> uses of KERN_<level>
Date: Sat, 11 Sep 2010 22:10:56 -0700
Message-ID: <fc7fcc49a05ef1c1df45a60130ede87583dbecad.1284267142.git.joe@perches.com>
References: <cover.1284267142.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1284267142.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/skfp/skfddi.c |   84 ++++++++++++++++++++++----------------------
 1 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 31b2dab..8a12bd9 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -209,7 +209,7 @@ static int skfp_init_one(struct pci_dev *pdev,
 	void __iomem *mem;
 	int err;
 
-	pr_debug(KERN_INFO "entering skfp_init_one\n");
+	pr_debug("entering skfp_init_one\n");
 
 	if (num_boards == 0) 
 		printk("%s\n", boot_msg);
@@ -385,7 +385,7 @@ static  int skfp_driver_init(struct net_device *dev)
 	skfddi_priv *bp = &smc->os;
 	int err = -EIO;
 
-	pr_debug(KERN_INFO "entering skfp_driver_init\n");
+	pr_debug("entering skfp_driver_init\n");
 
 	// set the io address in private structures
 	bp->base_addr = dev->base_addr;
@@ -405,7 +405,7 @@ static  int skfp_driver_init(struct net_device *dev)
 
 	// Determine the required size of the 'shared' memory area.
 	bp->SharedMemSize = mac_drv_check_space();
-	pr_debug(KERN_INFO "Memory for HWM: %ld\n", bp->SharedMemSize);
+	pr_debug("Memory for HWM: %ld\n", bp->SharedMemSize);
 	if (bp->SharedMemSize > 0) {
 		bp->SharedMemSize += 16;	// for descriptor alignment
 
@@ -429,13 +429,13 @@ static  int skfp_driver_init(struct net_device *dev)
 
 	card_stop(smc);		// Reset adapter.
 
-	pr_debug(KERN_INFO "mac_drv_init()..\n");
+	pr_debug("mac_drv_init()..\n");
 	if (mac_drv_init(smc) != 0) {
-		pr_debug(KERN_INFO "mac_drv_init() failed.\n");
+		pr_debug("mac_drv_init() failed\n");
 		goto fail;
 	}
 	read_address(smc, NULL);
-	pr_debug(KERN_INFO "HW-Addr: %pMF\n", smc->hw.fddi_canon_addr.a);
+	pr_debug("HW-Addr: %pMF\n", smc->hw.fddi_canon_addr.a);
 	memcpy(dev->dev_addr, smc->hw.fddi_canon_addr.a, 6);
 
 	smt_reset_defaults(smc, 0);
@@ -485,7 +485,7 @@ static int skfp_open(struct net_device *dev)
 	struct s_smc *smc = netdev_priv(dev);
 	int err;
 
-	pr_debug(KERN_INFO "entering skfp_open\n");
+	pr_debug("entering skfp_open\n");
 	/* Register IRQ - support shared interrupts by passing device ptr */
 	err = request_irq(dev->irq, skfp_interrupt, IRQF_SHARED,
 			  dev->name, dev);
@@ -856,12 +856,12 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 	/* Enable promiscuous mode, if necessary */
 	if (dev->flags & IFF_PROMISC) {
 		mac_drv_rx_mode(smc, RX_ENABLE_PROMISC);
-		pr_debug(KERN_INFO "PROMISCUOUS MODE ENABLED\n");
+		pr_debug("PROMISCUOUS MODE ENABLED\n");
 	}
 	/* Else, update multicast address table */
 	else {
 		mac_drv_rx_mode(smc, RX_DISABLE_PROMISC);
-		pr_debug(KERN_INFO "PROMISCUOUS MODE DISABLED\n");
+		pr_debug("PROMISCUOUS MODE DISABLED\n");
 
 		// Reset all MC addresses
 		mac_clear_multicast(smc);
@@ -869,7 +869,7 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 
 		if (dev->flags & IFF_ALLMULTI) {
 			mac_drv_rx_mode(smc, RX_ENABLE_ALLMULTI);
-			pr_debug(KERN_INFO "ENABLE ALL MC ADDRESSES\n");
+			pr_debug("ENABLE ALL MC ADDRESSES\n");
 		} else if (!netdev_mc_empty(dev)) {
 			if (netdev_mc_count(dev) <= FPMAX_MULTICAST) {
 				/* use exact filtering */
@@ -880,18 +880,18 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 						(struct fddi_addr *)ha->addr,
 						1);
 
-					pr_debug(KERN_INFO "ENABLE MC ADDRESS: %pMF\n",
-						ha->addr);
+					pr_debug("ENABLE MC ADDRESS: %pMF\n",
+						 ha->addr);
 				}
 
 			} else {	// more MC addresses than HW supports
 
 				mac_drv_rx_mode(smc, RX_ENABLE_ALLMULTI);
-				pr_debug(KERN_INFO "ENABLE ALL MC ADDRESSES\n");
+				pr_debug("ENABLE ALL MC ADDRESSES\n");
 			}
 		} else {	// no MC addresses
 
-			pr_debug(KERN_INFO "DISABLE ALL MC ADDRESSES\n");
+			pr_debug("DISABLE ALL MC ADDRESSES\n");
 		}
 
 		/* Update adapter filters */
@@ -1045,7 +1045,7 @@ static netdev_tx_t skfp_send_pkt(struct sk_buff *skb,
 	struct s_smc *smc = netdev_priv(dev);
 	skfddi_priv *bp = &smc->os;
 
-	pr_debug(KERN_INFO "skfp_send_pkt\n");
+	pr_debug("skfp_send_pkt\n");
 
 	/*
 	 * Verify that incoming transmit request is OK
@@ -1114,13 +1114,13 @@ static void send_queued_packets(struct s_smc *smc)
 
 	int frame_status;	// HWM tx frame status.
 
-	pr_debug(KERN_INFO "send queued packets\n");
+	pr_debug("send queued packets\n");
 	for (;;) {
 		// send first buffer from queue
 		skb = skb_dequeue(&bp->SendSkbQueue);
 
 		if (!skb) {
-			pr_debug(KERN_INFO "queue empty\n");
+			pr_debug("queue empty\n");
 			return;
 		}		// queue empty !
 
@@ -1232,7 +1232,7 @@ static void CheckSourceAddress(unsigned char *frame, unsigned char *hw_addr)
 static void ResetAdapter(struct s_smc *smc)
 {
 
-	pr_debug(KERN_INFO "[fddi: ResetAdapter]\n");
+	pr_debug("[fddi: ResetAdapter]\n");
 
 	// Stop the adapter.
 
@@ -1278,7 +1278,7 @@ void llc_restart_tx(struct s_smc *smc)
 {
 	skfddi_priv *bp = &smc->os;
 
-	pr_debug(KERN_INFO "[llc_restart_tx]\n");
+	pr_debug("[llc_restart_tx]\n");
 
 	// Try to send queued packets
 	spin_unlock(&bp->DriverLock);
@@ -1308,7 +1308,7 @@ void *mac_drv_get_space(struct s_smc *smc, unsigned int size)
 {
 	void *virt;
 
-	pr_debug(KERN_INFO "mac_drv_get_space (%d bytes), ", size);
+	pr_debug("mac_drv_get_space (%d bytes), ", size);
 	virt = (void *) (smc->os.SharedMemAddr + smc->os.SharedMemHeap);
 
 	if ((smc->os.SharedMemHeap + size) > smc->os.SharedMemSize) {
@@ -1317,9 +1317,9 @@ void *mac_drv_get_space(struct s_smc *smc, unsigned int size)
 	}
 	smc->os.SharedMemHeap += size;	// Move heap pointer.
 
-	pr_debug(KERN_INFO "mac_drv_get_space end\n");
-	pr_debug(KERN_INFO "virt addr: %lx\n", (ulong) virt);
-	pr_debug(KERN_INFO "bus  addr: %lx\n", (ulong)
+	pr_debug("mac_drv_get_space end\n");
+	pr_debug("virt addr: %lx\n", (ulong) virt);
+	pr_debug("bus  addr: %lx\n", (ulong)
 	       (smc->os.SharedMemDMA +
 		((char *) virt - (char *)smc->os.SharedMemAddr)));
 	return (virt);
@@ -1349,7 +1349,7 @@ void *mac_drv_get_desc_mem(struct s_smc *smc, unsigned int size)
 
 	char *virt;
 
-	pr_debug(KERN_INFO "mac_drv_get_desc_mem\n");
+	pr_debug("mac_drv_get_desc_mem\n");
 
 	// Descriptor memory must be aligned on 16-byte boundary.
 
@@ -1493,7 +1493,7 @@ void mac_drv_tx_complete(struct s_smc *smc, volatile struct s_smt_fp_txd *txd)
 {
 	struct sk_buff *skb;
 
-	pr_debug(KERN_INFO "entering mac_drv_tx_complete\n");
+	pr_debug("entering mac_drv_tx_complete\n");
 	// Check if this TxD points to a skb
 
 	if (!(skb = txd->txd_os.skb)) {
@@ -1513,7 +1513,7 @@ void mac_drv_tx_complete(struct s_smc *smc, volatile struct s_smt_fp_txd *txd)
 	// free the skb
 	dev_kfree_skb_irq(skb);
 
-	pr_debug(KERN_INFO "leaving mac_drv_tx_complete\n");
+	pr_debug("leaving mac_drv_tx_complete\n");
 }				// mac_drv_tx_complete
 
 
@@ -1580,7 +1580,7 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 	unsigned short ri;
 	u_int RifLength;
 
-	pr_debug(KERN_INFO "entering mac_drv_rx_complete (len=%d)\n", len);
+	pr_debug("entering mac_drv_rx_complete (len=%d)\n", len);
 	if (frag_count != 1) {	// This is not allowed to happen.
 
 		printk("fddi: Multi-fragment receive!\n");
@@ -1589,7 +1589,7 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 	}
 	skb = rxd->rxd_os.skb;
 	if (!skb) {
-		pr_debug(KERN_INFO "No skb in rxd\n");
+		pr_debug("No skb in rxd\n");
 		smc->os.MacStat.gen.rx_errors++;
 		goto RequeueRxd;
 	}
@@ -1619,7 +1619,7 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 	else {
 		int n;
 // goos: RIF removal has still to be tested
-		pr_debug(KERN_INFO "RIF found\n");
+		pr_debug("RIF found\n");
 		// Get RIF length from Routing Control (RC) field.
 		cp = virt + FDDI_MAC_HDR_LEN;	// Point behind MAC header.
 
@@ -1664,7 +1664,7 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 	return;
 
       RequeueRxd:
-	pr_debug(KERN_INFO "Rx: re-queue RXD.\n");
+	pr_debug("Rx: re-queue RXD.\n");
 	mac_drv_requeue_rxd(smc, rxd, frag_count);
 	smc->os.MacStat.gen.rx_errors++;	// Count receive packets
 						// not indicated.
@@ -1775,7 +1775,7 @@ void mac_drv_fill_rxd(struct s_smc *smc)
 	struct sk_buff *skb;
 	volatile struct s_smt_fp_rxd *rxd;
 
-	pr_debug(KERN_INFO "entering mac_drv_fill_rxd\n");
+	pr_debug("entering mac_drv_fill_rxd\n");
 
 	// Walk through the list of free receive buffers, passing receive
 	// buffers to the HWM as long as RXDs are available.
@@ -1783,7 +1783,7 @@ void mac_drv_fill_rxd(struct s_smc *smc)
 	MaxFrameSize = smc->os.MaxFrameSize;
 	// Check if there is any RXD left.
 	while (HWM_GET_RX_FREE(smc) > 0) {
-		pr_debug(KERN_INFO ".\n");
+		pr_debug(".\n");
 
 		rxd = HWM_GET_CURR_RXD(smc);
 		skb = alloc_skb(MaxFrameSize + 3, GFP_ATOMIC);
@@ -1814,7 +1814,7 @@ void mac_drv_fill_rxd(struct s_smc *smc)
 		hwm_rx_frag(smc, v_addr, b_addr, MaxFrameSize,
 			    FIRST_FRAG | LAST_FRAG);
 	}
-	pr_debug(KERN_INFO "leaving mac_drv_fill_rxd\n");
+	pr_debug("leaving mac_drv_fill_rxd\n");
 }				// mac_drv_fill_rxd
 
 
@@ -2034,17 +2034,17 @@ void smt_stat_counter(struct s_smc *smc, int stat)
 {
 //      BOOLEAN RingIsUp ;
 
-	pr_debug(KERN_INFO "smt_stat_counter\n");
+	pr_debug("smt_stat_counter\n");
 	switch (stat) {
 	case 0:
-		pr_debug(KERN_INFO "Ring operational change.\n");
+		pr_debug("Ring operational change.\n");
 		break;
 	case 1:
-		pr_debug(KERN_INFO "Receive fifo overflow.\n");
+		pr_debug("Receive fifo overflow.\n");
 		smc->os.MacStat.gen.rx_errors++;
 		break;
 	default:
-		pr_debug(KERN_INFO "Unknown status (%d).\n", stat);
+		pr_debug("Unknown status (%d).\n", stat);
 		break;
 	}
 }				// smt_stat_counter
@@ -2100,10 +2100,10 @@ void cfm_state_change(struct s_smc *smc, int c_state)
 		s = "SC11_C_WRAP_S";
 		break;
 	default:
-		pr_debug(KERN_INFO "cfm_state_change: unknown %d\n", c_state);
+		pr_debug("cfm_state_change: unknown %d\n", c_state);
 		return;
 	}
-	pr_debug(KERN_INFO "cfm_state_change: %s\n", s);
+	pr_debug("cfm_state_change: %s\n", s);
 #endif				// DRIVERDEBUG
 }				// cfm_state_change
 
@@ -2158,7 +2158,7 @@ void ecm_state_change(struct s_smc *smc, int e_state)
 		s = "unknown";
 		break;
 	}
-	pr_debug(KERN_INFO "ecm_state_change: %s\n", s);
+	pr_debug("ecm_state_change: %s\n", s);
 #endif				//DRIVERDEBUG
 }				// ecm_state_change
 
@@ -2213,7 +2213,7 @@ void rmt_state_change(struct s_smc *smc, int r_state)
 		s = "unknown";
 		break;
 	}
-	pr_debug(KERN_INFO "[rmt_state_change: %s]\n", s);
+	pr_debug("[rmt_state_change: %s]\n", s);
 #endif				// DRIVERDEBUG
 }				// rmt_state_change
 
@@ -2233,7 +2233,7 @@ void rmt_state_change(struct s_smc *smc, int r_state)
  ************************/
 void drv_reset_indication(struct s_smc *smc)
 {
-	pr_debug(KERN_INFO "entering drv_reset_indication\n");
+	pr_debug("entering drv_reset_indication\n");
 
 	smc->os.ResetRequested = TRUE;	// Set flag.
 
-- 
1.7.3.rc1
