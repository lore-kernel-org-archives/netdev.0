From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 5/5] skfddi: convert PRINTK() to pr_debug()
Date: Sat, 16 May 2009 00:22:42 +0400
Message-ID: <1242418962-1272-5-git-send-email-a.beregalov@gmail.com>
References: <1242418962-1272-1-git-send-email-a.beregalov@gmail.com>
 <1242418962-1272-2-git-send-email-a.beregalov@gmail.com>
 <1242418962-1272-3-git-send-email-a.beregalov@gmail.com>
 <1242418962-1272-4-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:11594 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbZEOUXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 16:23:11 -0400
Received: by fg-out-1718.google.com with SMTP id d23so204368fga.17
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 13:23:11 -0700 (PDT)
In-Reply-To: <1242418962-1272-4-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/skfp/skfddi.c |  156 ++++++++++++++++++++++-----------------------
 1 files changed, 75 insertions(+), 81 deletions(-)

diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index e14aec0..19d343c 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -159,12 +159,6 @@ MODULE_AUTHOR("Mirko Lindner <mlindner@syskonnect.de>");
 
 static int num_boards;	/* total number of adapters configured */
 
-#ifdef DRIVERDEBUG
-#define PRINTK(s, args...) printk(s, ## args)
-#else
-#define PRINTK(s, args...)
-#endif				// DRIVERDEBUG
-
 static const struct net_device_ops skfp_netdev_ops = {
 	.ndo_open		= skfp_open,
 	.ndo_stop		= skfp_close,
@@ -213,7 +207,7 @@ static int skfp_init_one(struct pci_dev *pdev,
 	void __iomem *mem;
 	int err;
 
-	PRINTK(KERN_INFO "entering skfp_init_one\n");
+	pr_debug(KERN_INFO "entering skfp_init_one\n");
 
 	if (num_boards == 0) 
 		printk("%s\n", boot_msg);
@@ -389,7 +383,7 @@ static  int skfp_driver_init(struct net_device *dev)
 	skfddi_priv *bp = &smc->os;
 	int err = -EIO;
 
-	PRINTK(KERN_INFO "entering skfp_driver_init\n");
+	pr_debug(KERN_INFO "entering skfp_driver_init\n");
 
 	// set the io address in private structures
 	bp->base_addr = dev->base_addr;
@@ -409,7 +403,7 @@ static  int skfp_driver_init(struct net_device *dev)
 
 	// Determine the required size of the 'shared' memory area.
 	bp->SharedMemSize = mac_drv_check_space();
-	PRINTK(KERN_INFO "Memory for HWM: %ld\n", bp->SharedMemSize);
+	pr_debug(KERN_INFO "Memory for HWM: %ld\n", bp->SharedMemSize);
 	if (bp->SharedMemSize > 0) {
 		bp->SharedMemSize += 16;	// for descriptor alignment
 
@@ -433,13 +427,13 @@ static  int skfp_driver_init(struct net_device *dev)
 
 	card_stop(smc);		// Reset adapter.
 
-	PRINTK(KERN_INFO "mac_drv_init()..\n");
+	pr_debug(KERN_INFO "mac_drv_init()..\n");
 	if (mac_drv_init(smc) != 0) {
-		PRINTK(KERN_INFO "mac_drv_init() failed.\n");
+		pr_debug(KERN_INFO "mac_drv_init() failed.\n");
 		goto fail;
 	}
 	read_address(smc, NULL);
-	PRINTK(KERN_INFO "HW-Addr: %02x %02x %02x %02x %02x %02x\n",
+	pr_debug(KERN_INFO "HW-Addr: %02x %02x %02x %02x %02x %02x\n",
 	       smc->hw.fddi_canon_addr.a[0],
 	       smc->hw.fddi_canon_addr.a[1],
 	       smc->hw.fddi_canon_addr.a[2],
@@ -495,7 +489,7 @@ static int skfp_open(struct net_device *dev)
 	struct s_smc *smc = netdev_priv(dev);
 	int err;
 
-	PRINTK(KERN_INFO "entering skfp_open\n");
+	pr_debug(KERN_INFO "entering skfp_open\n");
 	/* Register IRQ - support shared interrupts by passing device ptr */
 	err = request_irq(dev->irq, skfp_interrupt, IRQF_SHARED,
 			  dev->name, dev);
@@ -868,12 +862,12 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 	/* Enable promiscuous mode, if necessary */
 	if (dev->flags & IFF_PROMISC) {
 		mac_drv_rx_mode(smc, RX_ENABLE_PROMISC);
-		PRINTK(KERN_INFO "PROMISCUOUS MODE ENABLED\n");
+		pr_debug(KERN_INFO "PROMISCUOUS MODE ENABLED\n");
 	}
 	/* Else, update multicast address table */
 	else {
 		mac_drv_rx_mode(smc, RX_DISABLE_PROMISC);
-		PRINTK(KERN_INFO "PROMISCUOUS MODE DISABLED\n");
+		pr_debug(KERN_INFO "PROMISCUOUS MODE DISABLED\n");
 
 		// Reset all MC addresses
 		mac_clear_multicast(smc);
@@ -881,7 +875,7 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 
 		if (dev->flags & IFF_ALLMULTI) {
 			mac_drv_rx_mode(smc, RX_ENABLE_ALLMULTI);
-			PRINTK(KERN_INFO "ENABLE ALL MC ADDRESSES\n");
+			pr_debug(KERN_INFO "ENABLE ALL MC ADDRESSES\n");
 		} else if (dev->mc_count > 0) {
 			if (dev->mc_count <= FPMAX_MULTICAST) {
 				/* use exact filtering */
@@ -894,12 +888,12 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 							  (struct fddi_addr *)dmi->dmi_addr, 
 							  1);
 
-					PRINTK(KERN_INFO "ENABLE MC ADDRESS:");
-					PRINTK(" %02x %02x %02x ",
+					pr_debug(KERN_INFO "ENABLE MC ADDRESS:");
+					pr_debug(" %02x %02x %02x ",
 					       dmi->dmi_addr[0],
 					       dmi->dmi_addr[1],
 					       dmi->dmi_addr[2]);
-					PRINTK("%02x %02x %02x\n",
+					pr_debug("%02x %02x %02x\n",
 					       dmi->dmi_addr[3],
 					       dmi->dmi_addr[4],
 					       dmi->dmi_addr[5]);
@@ -909,11 +903,11 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 			} else {	// more MC addresses than HW supports
 
 				mac_drv_rx_mode(smc, RX_ENABLE_ALLMULTI);
-				PRINTK(KERN_INFO "ENABLE ALL MC ADDRESSES\n");
+				pr_debug(KERN_INFO "ENABLE ALL MC ADDRESSES\n");
 			}
 		} else {	// no MC addresses
 
-			PRINTK(KERN_INFO "DISABLE ALL MC ADDRESSES\n");
+			pr_debug(KERN_INFO "DISABLE ALL MC ADDRESSES\n");
 		}
 
 		/* Update adapter filters */
@@ -1067,7 +1061,7 @@ static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
 	struct s_smc *smc = netdev_priv(dev);
 	skfddi_priv *bp = &smc->os;
 
-	PRINTK(KERN_INFO "skfp_send_pkt\n");
+	pr_debug(KERN_INFO "skfp_send_pkt\n");
 
 	/*
 	 * Verify that incoming transmit request is OK
@@ -1137,13 +1131,13 @@ static void send_queued_packets(struct s_smc *smc)
 
 	int frame_status;	// HWM tx frame status.
 
-	PRINTK(KERN_INFO "send queued packets\n");
+	pr_debug(KERN_INFO "send queued packets\n");
 	for (;;) {
 		// send first buffer from queue
 		skb = skb_dequeue(&bp->SendSkbQueue);
 
 		if (!skb) {
-			PRINTK(KERN_INFO "queue empty\n");
+			pr_debug(KERN_INFO "queue empty\n");
 			return;
 		}		// queue empty !
 
@@ -1174,11 +1168,11 @@ static void send_queued_packets(struct s_smc *smc)
 
 			if ((frame_status & RING_DOWN) != 0) {
 				// Ring is down.
-				PRINTK("Tx attempt while ring down.\n");
+				pr_debug("Tx attempt while ring down.\n");
 			} else if ((frame_status & OUT_OF_TXD) != 0) {
-				PRINTK("%s: out of TXDs.\n", bp->dev->name);
+				pr_debug("%s: out of TXDs.\n", bp->dev->name);
 			} else {
-				PRINTK("%s: out of transmit resources",
+				pr_debug("%s: out of transmit resources",
 					bp->dev->name);
 			}
 
@@ -1255,7 +1249,7 @@ static void CheckSourceAddress(unsigned char *frame, unsigned char *hw_addr)
 static void ResetAdapter(struct s_smc *smc)
 {
 
-	PRINTK(KERN_INFO "[fddi: ResetAdapter]\n");
+	pr_debug(KERN_INFO "[fddi: ResetAdapter]\n");
 
 	// Stop the adapter.
 
@@ -1301,7 +1295,7 @@ void llc_restart_tx(struct s_smc *smc)
 {
 	skfddi_priv *bp = &smc->os;
 
-	PRINTK(KERN_INFO "[llc_restart_tx]\n");
+	pr_debug(KERN_INFO "[llc_restart_tx]\n");
 
 	// Try to send queued packets
 	spin_unlock(&bp->DriverLock);
@@ -1331,7 +1325,7 @@ void *mac_drv_get_space(struct s_smc *smc, unsigned int size)
 {
 	void *virt;
 
-	PRINTK(KERN_INFO "mac_drv_get_space (%d bytes), ", size);
+	pr_debug(KERN_INFO "mac_drv_get_space (%d bytes), ", size);
 	virt = (void *) (smc->os.SharedMemAddr + smc->os.SharedMemHeap);
 
 	if ((smc->os.SharedMemHeap + size) > smc->os.SharedMemSize) {
@@ -1340,9 +1334,9 @@ void *mac_drv_get_space(struct s_smc *smc, unsigned int size)
 	}
 	smc->os.SharedMemHeap += size;	// Move heap pointer.
 
-	PRINTK(KERN_INFO "mac_drv_get_space end\n");
-	PRINTK(KERN_INFO "virt addr: %lx\n", (ulong) virt);
-	PRINTK(KERN_INFO "bus  addr: %lx\n", (ulong)
+	pr_debug(KERN_INFO "mac_drv_get_space end\n");
+	pr_debug(KERN_INFO "virt addr: %lx\n", (ulong) virt);
+	pr_debug(KERN_INFO "bus  addr: %lx\n", (ulong)
 	       (smc->os.SharedMemDMA +
 		((char *) virt - (char *)smc->os.SharedMemAddr)));
 	return (virt);
@@ -1372,7 +1366,7 @@ void *mac_drv_get_desc_mem(struct s_smc *smc, unsigned int size)
 
 	char *virt;
 
-	PRINTK(KERN_INFO "mac_drv_get_desc_mem\n");
+	pr_debug(KERN_INFO "mac_drv_get_desc_mem\n");
 
 	// Descriptor memory must be aligned on 16-byte boundary.
 
@@ -1381,8 +1375,8 @@ void *mac_drv_get_desc_mem(struct s_smc *smc, unsigned int size)
 	size = (u_int) (16 - (((unsigned long) virt) & 15UL));
 	size = size % 16;
 
-	PRINTK("Allocate %u bytes alignment gap ", size);
-	PRINTK("for descriptor memory.\n");
+	pr_debug("Allocate %u bytes alignment gap ", size);
+	pr_debug("for descriptor memory.\n");
 
 	if (!mac_drv_get_space(smc, size)) {
 		printk("fddi: Unable to align descriptor memory.\n");
@@ -1516,11 +1510,11 @@ void mac_drv_tx_complete(struct s_smc *smc, volatile struct s_smt_fp_txd *txd)
 {
 	struct sk_buff *skb;
 
-	PRINTK(KERN_INFO "entering mac_drv_tx_complete\n");
+	pr_debug(KERN_INFO "entering mac_drv_tx_complete\n");
 	// Check if this TxD points to a skb
 
 	if (!(skb = txd->txd_os.skb)) {
-		PRINTK("TXD with no skb assigned.\n");
+		pr_debug("TXD with no skb assigned.\n");
 		return;
 	}
 	txd->txd_os.skb = NULL;
@@ -1536,7 +1530,7 @@ void mac_drv_tx_complete(struct s_smc *smc, volatile struct s_smt_fp_txd *txd)
 	// free the skb
 	dev_kfree_skb_irq(skb);
 
-	PRINTK(KERN_INFO "leaving mac_drv_tx_complete\n");
+	pr_debug(KERN_INFO "leaving mac_drv_tx_complete\n");
 }				// mac_drv_tx_complete
 
 
@@ -1603,7 +1597,7 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 	unsigned short ri;
 	u_int RifLength;
 
-	PRINTK(KERN_INFO "entering mac_drv_rx_complete (len=%d)\n", len);
+	pr_debug(KERN_INFO "entering mac_drv_rx_complete (len=%d)\n", len);
 	if (frag_count != 1) {	// This is not allowed to happen.
 
 		printk("fddi: Multi-fragment receive!\n");
@@ -1612,7 +1606,7 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 	}
 	skb = rxd->rxd_os.skb;
 	if (!skb) {
-		PRINTK(KERN_INFO "No skb in rxd\n");
+		pr_debug(KERN_INFO "No skb in rxd\n");
 		smc->os.MacStat.gen.rx_errors++;
 		goto RequeueRxd;
 	}
@@ -1642,7 +1636,7 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 	else {
 		int n;
 // goos: RIF removal has still to be tested
-		PRINTK(KERN_INFO "RIF found\n");
+		pr_debug(KERN_INFO "RIF found\n");
 		// Get RIF length from Routing Control (RC) field.
 		cp = virt + FDDI_MAC_HDR_LEN;	// Point behind MAC header.
 
@@ -1687,7 +1681,7 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 	return;
 
       RequeueRxd:
-	PRINTK(KERN_INFO "Rx: re-queue RXD.\n");
+	pr_debug(KERN_INFO "Rx: re-queue RXD.\n");
 	mac_drv_requeue_rxd(smc, rxd, frag_count);
 	smc->os.MacStat.gen.rx_errors++;	// Count receive packets
 						// not indicated.
@@ -1736,7 +1730,7 @@ void mac_drv_requeue_rxd(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 		skb = src_rxd->rxd_os.skb;
 		if (skb == NULL) {	// this should not happen
 
-			PRINTK("Requeue with no skb in rxd!\n");
+			pr_debug("Requeue with no skb in rxd!\n");
 			skb = alloc_skb(MaxFrameSize + 3, GFP_ATOMIC);
 			if (skb) {
 				// we got a skb
@@ -1751,7 +1745,7 @@ void mac_drv_requeue_rxd(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 				rxd->rxd_os.dma_addr = b_addr;
 			} else {
 				// no skb available, use local buffer
-				PRINTK("Queueing invalid buffer!\n");
+				pr_debug("Queueing invalid buffer!\n");
 				rxd->rxd_os.skb = NULL;
 				v_addr = smc->os.LocalRxBuffer;
 				b_addr = smc->os.LocalRxBufferDMA;
@@ -1798,7 +1792,7 @@ void mac_drv_fill_rxd(struct s_smc *smc)
 	struct sk_buff *skb;
 	volatile struct s_smt_fp_rxd *rxd;
 
-	PRINTK(KERN_INFO "entering mac_drv_fill_rxd\n");
+	pr_debug(KERN_INFO "entering mac_drv_fill_rxd\n");
 
 	// Walk through the list of free receive buffers, passing receive
 	// buffers to the HWM as long as RXDs are available.
@@ -1806,7 +1800,7 @@ void mac_drv_fill_rxd(struct s_smc *smc)
 	MaxFrameSize = smc->os.MaxFrameSize;
 	// Check if there is any RXD left.
 	while (HWM_GET_RX_FREE(smc) > 0) {
-		PRINTK(KERN_INFO ".\n");
+		pr_debug(KERN_INFO ".\n");
 
 		rxd = HWM_GET_CURR_RXD(smc);
 		skb = alloc_skb(MaxFrameSize + 3, GFP_ATOMIC);
@@ -1826,7 +1820,7 @@ void mac_drv_fill_rxd(struct s_smc *smc)
 			// keep the receiver running in hope of better times.
 			// Multiple descriptors may point to this local buffer,
 			// so data in it must be considered invalid.
-			PRINTK("Queueing invalid buffer!\n");
+			pr_debug("Queueing invalid buffer!\n");
 			v_addr = smc->os.LocalRxBuffer;
 			b_addr = smc->os.LocalRxBufferDMA;
 		}
@@ -1837,7 +1831,7 @@ void mac_drv_fill_rxd(struct s_smc *smc)
 		hwm_rx_frag(smc, v_addr, b_addr, MaxFrameSize,
 			    FIRST_FRAG | LAST_FRAG);
 	}
-	PRINTK(KERN_INFO "leaving mac_drv_fill_rxd\n");
+	pr_debug(KERN_INFO "leaving mac_drv_fill_rxd\n");
 }				// mac_drv_fill_rxd
 
 
@@ -1863,7 +1857,7 @@ void mac_drv_clear_rxd(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 
 	struct sk_buff *skb;
 
-	PRINTK("entering mac_drv_clear_rxd\n");
+	pr_debug("entering mac_drv_clear_rxd\n");
 
 	if (frag_count != 1)	// This is not allowed to happen.
 
@@ -1919,19 +1913,19 @@ int mac_drv_rx_init(struct s_smc *smc, int len, int fc,
 {
 	struct sk_buff *skb;
 
-	PRINTK("entering mac_drv_rx_init(len=%d)\n", len);
+	pr_debug("entering mac_drv_rx_init(len=%d)\n", len);
 
 	// "Received" a SMT or NSA frame of the local SMT.
 
 	if (len != la_len || len < FDDI_MAC_HDR_LEN || !look_ahead) {
-		PRINTK("fddi: Discard invalid local SMT frame\n");
-		PRINTK("  len=%d, la_len=%d, (ULONG) look_ahead=%08lXh.\n",
+		pr_debug("fddi: Discard invalid local SMT frame\n");
+		pr_debug("  len=%d, la_len=%d, (ULONG) look_ahead=%08lXh.\n",
 		       len, la_len, (unsigned long) look_ahead);
 		return (0);
 	}
 	skb = alloc_skb(len + 3, GFP_ATOMIC);
 	if (!skb) {
-		PRINTK("fddi: Local SMT: skb memory exhausted.\n");
+		pr_debug("fddi: Local SMT: skb memory exhausted.\n");
 		return (0);
 	}
 	skb_reserve(skb, 3);
@@ -1981,40 +1975,40 @@ void smt_timer_poll(struct s_smc *smc)
  ************************/
 void ring_status_indication(struct s_smc *smc, u_long status)
 {
-	PRINTK("ring_status_indication( ");
+	pr_debug("ring_status_indication( ");
 	if (status & RS_RES15)
-		PRINTK("RS_RES15 ");
+		pr_debug("RS_RES15 ");
 	if (status & RS_HARDERROR)
-		PRINTK("RS_HARDERROR ");
+		pr_debug("RS_HARDERROR ");
 	if (status & RS_SOFTERROR)
-		PRINTK("RS_SOFTERROR ");
+		pr_debug("RS_SOFTERROR ");
 	if (status & RS_BEACON)
-		PRINTK("RS_BEACON ");
+		pr_debug("RS_BEACON ");
 	if (status & RS_PATHTEST)
-		PRINTK("RS_PATHTEST ");
+		pr_debug("RS_PATHTEST ");
 	if (status & RS_SELFTEST)
-		PRINTK("RS_SELFTEST ");
+		pr_debug("RS_SELFTEST ");
 	if (status & RS_RES9)
-		PRINTK("RS_RES9 ");
+		pr_debug("RS_RES9 ");
 	if (status & RS_DISCONNECT)
-		PRINTK("RS_DISCONNECT ");
+		pr_debug("RS_DISCONNECT ");
 	if (status & RS_RES7)
-		PRINTK("RS_RES7 ");
+		pr_debug("RS_RES7 ");
 	if (status & RS_DUPADDR)
-		PRINTK("RS_DUPADDR ");
+		pr_debug("RS_DUPADDR ");
 	if (status & RS_NORINGOP)
-		PRINTK("RS_NORINGOP ");
+		pr_debug("RS_NORINGOP ");
 	if (status & RS_VERSION)
-		PRINTK("RS_VERSION ");
+		pr_debug("RS_VERSION ");
 	if (status & RS_STUCKBYPASSS)
-		PRINTK("RS_STUCKBYPASSS ");
+		pr_debug("RS_STUCKBYPASSS ");
 	if (status & RS_EVENT)
-		PRINTK("RS_EVENT ");
+		pr_debug("RS_EVENT ");
 	if (status & RS_RINGOPCHANGE)
-		PRINTK("RS_RINGOPCHANGE ");
+		pr_debug("RS_RINGOPCHANGE ");
 	if (status & RS_RES0)
-		PRINTK("RS_RES0 ");
-	PRINTK("]\n");
+		pr_debug("RS_RES0 ");
+	pr_debug("]\n");
 }				// ring_status_indication
 
 
@@ -2057,17 +2051,17 @@ void smt_stat_counter(struct s_smc *smc, int stat)
 {
 //      BOOLEAN RingIsUp ;
 
-	PRINTK(KERN_INFO "smt_stat_counter\n");
+	pr_debug(KERN_INFO "smt_stat_counter\n");
 	switch (stat) {
 	case 0:
-		PRINTK(KERN_INFO "Ring operational change.\n");
+		pr_debug(KERN_INFO "Ring operational change.\n");
 		break;
 	case 1:
-		PRINTK(KERN_INFO "Receive fifo overflow.\n");
+		pr_debug(KERN_INFO "Receive fifo overflow.\n");
 		smc->os.MacStat.gen.rx_errors++;
 		break;
 	default:
-		PRINTK(KERN_INFO "Unknown status (%d).\n", stat);
+		pr_debug(KERN_INFO "Unknown status (%d).\n", stat);
 		break;
 	}
 }				// smt_stat_counter
@@ -2123,10 +2117,10 @@ void cfm_state_change(struct s_smc *smc, int c_state)
 		s = "SC11_C_WRAP_S";
 		break;
 	default:
-		PRINTK(KERN_INFO "cfm_state_change: unknown %d\n", c_state);
+		pr_debug(KERN_INFO "cfm_state_change: unknown %d\n", c_state);
 		return;
 	}
-	PRINTK(KERN_INFO "cfm_state_change: %s\n", s);
+	pr_debug(KERN_INFO "cfm_state_change: %s\n", s);
 #endif				// DRIVERDEBUG
 }				// cfm_state_change
 
@@ -2181,7 +2175,7 @@ void ecm_state_change(struct s_smc *smc, int e_state)
 		s = "unknown";
 		break;
 	}
-	PRINTK(KERN_INFO "ecm_state_change: %s\n", s);
+	pr_debug(KERN_INFO "ecm_state_change: %s\n", s);
 #endif				//DRIVERDEBUG
 }				// ecm_state_change
 
@@ -2236,7 +2230,7 @@ void rmt_state_change(struct s_smc *smc, int r_state)
 		s = "unknown";
 		break;
 	}
-	PRINTK(KERN_INFO "[rmt_state_change: %s]\n", s);
+	pr_debug(KERN_INFO "[rmt_state_change: %s]\n", s);
 #endif				// DRIVERDEBUG
 }				// rmt_state_change
 
@@ -2256,7 +2250,7 @@ void rmt_state_change(struct s_smc *smc, int r_state)
  ************************/
 void drv_reset_indication(struct s_smc *smc)
 {
-	PRINTK(KERN_INFO "entering drv_reset_indication\n");
+	pr_debug(KERN_INFO "entering drv_reset_indication\n");
 
 	smc->os.ResetRequested = TRUE;	// Set flag.
 
-- 
1.6.3

