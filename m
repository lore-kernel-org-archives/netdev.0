From: Janusz Wolak <januszwolak@awokados.com.pl>
Subject: [PATCH 1/6] e1000 driver remove checkpatch errors, warnings and checks.
Date: Tue, 13 Oct 2015 23:39:17 +0200
Message-ID: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Janusz Wolak <januszvdm@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Janusz Wolak <januszvdm@gmail.com>

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 145 ++++++++++++++------------
 1 file changed, 76 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index e0c3c14..583a094 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1,5 +1,5 @@
 /*******************************************************************************
-
+*
   Intel PRO/1000 Linux driver
   Copyright(c) 1999 - 2006 Intel Corporation.
 
@@ -34,7 +34,7 @@
 #include <linux/if_vlan.h>
 
 char e1000_driver_name[] = "e1000";
-static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
+static const char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
 #define DRV_VERSION "7.3.21-k8-NAPI"
 const char e1000_driver_version[] = DRV_VERSION;
 static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
@@ -149,6 +149,7 @@ static void e1000_alloc_dummy_rx_buffers(struct e1000_adapter *adapter,
 					 int cleaned_count)
 {
 }
+
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 				   struct e1000_rx_ring *rx_ring,
 				   int cleaned_count);
@@ -185,14 +186,14 @@ static void e1000_shutdown(struct pci_dev *pdev);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* for netdump / net console */
-static void e1000_netpoll (struct net_device *netdev);
+static void e1000_netpoll(struct net_device *netdev);
 #endif
 
 #define COPYBREAK_DEFAULT 256
 static unsigned int copybreak __read_mostly = COPYBREAK_DEFAULT;
 module_param(copybreak, uint, 0644);
 MODULE_PARM_DESC(copybreak,
-	"Maximum size of packet that is copied to a new buffer on receive");
+		 "Maximum size of packet that is copied to a new buffer on receive");
 
 static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
 						pci_channel_state_t state);
@@ -224,7 +225,7 @@ MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
@@ -237,6 +238,7 @@ MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 struct net_device *e1000_get_hw_dev(struct e1000_hw *hw)
 {
 	struct e1000_adapter *adapter = hw->back;
+
 	return adapter->netdev;
 }
 
@@ -249,6 +251,7 @@ struct net_device *e1000_get_hw_dev(struct e1000_hw *hw)
 static int __init e1000_init_module(void)
 {
 	int ret;
+
 	pr_info("%s - version %s\n", e1000_driver_string, e1000_driver_version);
 
 	pr_info("%s\n", e1000_copyright);
@@ -258,8 +261,7 @@ static int __init e1000_init_module(void)
 		if (copybreak == 0)
 			pr_info("copybreak disabled\n");
 		else
-			pr_info("copybreak enabled for "
-				   "packets <= %u bytes\n", copybreak);
+			pr_info("copybreak enabled for packets <= %u bytes\n", copybreak);
 	}
 	return ret;
 }
@@ -288,9 +290,8 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 
 	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
 			  netdev);
-	if (err) {
+	if (err)
 		e_err(probe, "Unable to allocate interrupt Error: %d\n", err);
-	}
 
 	return err;
 }
@@ -406,6 +407,7 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	 */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct e1000_rx_ring *ring = &adapter->rx_ring[i];
+
 		adapter->alloc_rx_buf(adapter, ring,
 				      E1000_DESC_UNUSED(ring));
 	}
@@ -466,7 +468,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 	 * (c) SoL/IDER session is active
 	 */
 	if (!adapter->wol && hw->mac_type >= e1000_82540 &&
-	   hw->media_type == e1000_media_type_copper) {
+	    hw->media_type == e1000_media_type_copper) {
 		u16 mii_reg = 0;
 
 		switch (hw->mac_type) {
@@ -501,8 +503,7 @@ static void e1000_down_and_stop(struct e1000_adapter *adapter)
 
 	cancel_delayed_work_sync(&adapter->watchdog_task);
 
-	/*
-	 * Since the watchdog task can reschedule other tasks, we should cancel
+	/* Since the watchdog task can reschedule other tasks, we should cancel
 	 * it first, otherwise we can run into the situation when a work is
 	 * still running after the adapter has been turned down.
 	 */
@@ -806,7 +807,7 @@ static int e1000_is_need_ioport(struct pci_dev *pdev)
 }
 
 static netdev_features_t e1000_fix_features(struct net_device *netdev,
-	netdev_features_t features)
+					    netdev_features_t features)
 {
 	/* Since there is no support for separate Rx/Tx vlan accel
 	 * enable/disable make sure Tx flag is always in same state as Rx.
@@ -820,7 +821,7 @@ static netdev_features_t e1000_fix_features(struct net_device *netdev,
 }
 
 static int e1000_set_features(struct net_device *netdev,
-	netdev_features_t features)
+			      netdev_features_t features)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	netdev_features_t changed = features ^ netdev->features;
@@ -1061,7 +1062,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	if ((hw->mac_type >= e1000_82544) &&
-	   (hw->mac_type != e1000_82547))
+	    (hw->mac_type != e1000_82547))
 		netdev->hw_features |= NETIF_F_TSO;
 
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
@@ -1122,7 +1123,6 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!is_valid_ether_addr(netdev->dev_addr))
 		e_err(probe, "Invalid MAC Address\n");
 
-
 	INIT_DELAYED_WORK(&adapter->watchdog_task, e1000_watchdog);
 	INIT_DELAYED_WORK(&adapter->fifo_stall_task,
 			  e1000_82547_tx_fifo_stall_task);
@@ -1143,20 +1143,20 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	case e1000_82544:
 		e1000_read_eeprom(hw,
-			EEPROM_INIT_CONTROL2_REG, 1, &eeprom_data);
-		eeprom_apme_mask = E1000_EEPROM_82544_APM;
+				  EEPROM_INIT_CONTROL2_REG, 1, &eeprom_data);
+			eeprom_apme_mask = E1000_EEPROM_82544_APM;
 		break;
 	case e1000_82546:
 	case e1000_82546_rev_3:
 		if (er32(STATUS) & E1000_STATUS_FUNC_1) {
 			e1000_read_eeprom(hw,
-				EEPROM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
+					  EEPROM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
 			break;
 		}
 		/* Fall Through */
 	default:
 		e1000_read_eeprom(hw,
-			EEPROM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
+				  EEPROM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
 		break;
 	}
 	if (eeprom_data & eeprom_apme_mask)
@@ -1527,6 +1527,7 @@ setup_tx_desc_die:
 	if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
 		void *olddesc = txdr->desc;
 		dma_addr_t olddma = txdr->dma;
+
 		e_err(tx_err, "txdr align check failed: %u bytes at %p\n",
 		      txdr->size, txdr->desc);
 		/* Try again, without freeing the previous */
@@ -1565,7 +1566,7 @@ setup_tx_desc_die:
 
 /**
  * e1000_setup_all_tx_resources - wrapper to allocate Tx resources
- * 				  (Descriptors) for all queues
+ *				  (Descriptors) for all queues
  * @adapter: board private structure
  *
  * Return 0 on success, negative on failure
@@ -1679,7 +1680,6 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		adapter->pcix_82544 = true;
 
 	ew32(TCTL, tctl);
-
 }
 
 /**
@@ -1719,6 +1719,7 @@ setup_rx_desc_die:
 	if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
 		void *olddesc = rxdr->desc;
 		dma_addr_t olddma = rxdr->dma;
+
 		e_err(rx_err, "rxdr align check failed: %u bytes at %p\n",
 		      rxdr->size, rxdr->desc);
 		/* Try again, without freeing the previous */
@@ -1757,7 +1758,7 @@ setup_rx_desc_die:
 
 /**
  * e1000_setup_all_rx_resources - wrapper to allocate Rx resources
- * 				  (Descriptors) for all queues
+ *				  (Descriptors) for all queues
  * @adapter: board private structure
  *
  * Return 0 on success, negative on failure
@@ -2187,6 +2188,7 @@ static void e1000_leave_82542_rst(struct e1000_adapter *adapter)
 	if (netif_running(netdev)) {
 		/* No need to loop, because 82542 supports only 1 queue */
 		struct e1000_rx_ring *ring = &adapter->rx_ring[0];
+
 		e1000_configure_rx(adapter);
 		adapter->alloc_rx_buf(adapter, ring, E1000_DESC_UNUSED(ring));
 	}
@@ -2298,6 +2300,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 		if (i == rar_entries) {
 			/* load any remaining addresses into the hash table */
 			u32 hash_reg, hash_bit, mta;
+
 			hash_value = e1000_hash_mc_addr(hw, ha->addr);
 			hash_reg = (hash_value >> 5) & 0x7F;
 			hash_bit = hash_value & 0x1F;
@@ -2365,8 +2368,8 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 
 	if (atomic_read(&adapter->tx_fifo_stall)) {
 		if ((er32(TDT) == er32(TDH)) &&
-		   (er32(TDFT) == er32(TDFH)) &&
-		   (er32(TDFTS) == er32(TDFHS))) {
+		    (er32(TDFT) == er32(TDFH)) &&
+		    (er32(TDFTS) == er32(TDFHS))) {
 			tctl = er32(TCTL);
 			ew32(TCTL, tctl & ~E1000_TCTL_EN);
 			ew32(TDFT, adapter->tx_head_addr);
@@ -2450,8 +2453,7 @@ static void e1000_watchdog(struct work_struct *work)
 						   &adapter->link_duplex);
 
 			ctrl = er32(CTRL);
-			pr_info("%s NIC Link is Up %d Mbps %s, "
-				"Flow Control: %s\n",
+			pr_info("%s NIC Link is Up %d Mbps %s, Flow Control: %s\n",
 				netdev->name,
 				adapter->link_speed,
 				adapter->link_duplex == FULL_DUPLEX ?
@@ -2595,7 +2597,7 @@ static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 	switch (itr_setting) {
 	case lowest_latency:
 		/* jumbo frames get bulk treatment*/
-		if (bytes/packets > 8000)
+		if (bytes / packets > 8000)
 			retval = bulk_latency;
 		else if ((packets < 5) && (bytes > 512))
 			retval = low_latency;
@@ -2603,13 +2605,13 @@ static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 	case low_latency:  /* 50 usec aka 20000 ints/s */
 		if (bytes > 10000) {
 			/* jumbo frames need bulk latency setting */
-			if (bytes/packets > 8000)
+			if (bytes / packets > 8000)
 				retval = bulk_latency;
-			else if ((packets < 10) || ((bytes/packets) > 1200))
+			else if ((packets < 10) || ((bytes / packets) > 1200))
 				retval = bulk_latency;
 			else if ((packets > 35))
 				retval = lowest_latency;
-		} else if (bytes/packets > 2000)
+		} else if (bytes / packets > 2000)
 			retval = bulk_latency;
 		else if (packets <= 2 && bytes < 512)
 			retval = lowest_latency;
@@ -2719,6 +2721,7 @@ static int e1000_tso(struct e1000_adapter *adapter,
 		mss = skb_shinfo(skb)->gso_size;
 		if (protocol == htons(ETH_P_IP)) {
 			struct iphdr *iph = ip_hdr(skb);
+
 			iph->tot_len = 0;
 			iph->check = 0;
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
@@ -2827,7 +2830,7 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter,
 }
 
 #define E1000_MAX_TXD_PWR	12
-#define E1000_MAX_DATA_PER_TXD	(1<<E1000_MAX_TXD_PWR)
+#define E1000_MAX_DATA_PER_TXD	(1 << E1000_MAX_TXD_PWR)
 
 static int e1000_tx_map(struct e1000_adapter *adapter,
 			struct e1000_tx_ring *tx_ring,
@@ -2876,8 +2879,8 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		 * terminating buffers within evenly-aligned dwords.
 		 */
 		if (unlikely(adapter->pcix_82544 &&
-		   !((unsigned long)(skb->data + offset + size - 1) & 4) &&
-		   size > 4))
+			     !((unsigned long)(skb->data + offset + size - 1) & 4) &&
+			     size > 4))
 			size -= 4;
 
 		buffer_info->length = size;
@@ -2910,6 +2913,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		while (len) {
 			unsigned long bufend;
+
 			i++;
 			if (unlikely(i == tx_ring->count))
 				i = 0;
@@ -2919,8 +2923,8 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			/* Workaround for premature desc write-backs
 			 * in TSO mode.  Append 4-byte sentinel desc
 			 */
-			if (unlikely(mss && f == (nr_frags-1) &&
-			    size == len && size > 8))
+			if (unlikely(mss && f == (nr_frags - 1) &&
+				     size == len && size > 8))
 				size -= 4;
 			/* Workaround for potential 82544 hang in PCI-X.
 			 * Avoid terminating buffers within evenly-aligned
@@ -3148,6 +3152,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	 */
 	if (mss) {
 		u8 hdr_len;
+
 		max_per_txd = min(mss << 2, max_per_txd);
 		max_txd_pwr = fls(max_per_txd) - 1;
 
@@ -3169,8 +3174,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				/* fall through */
 				pull_size = min((unsigned int)4, skb->data_len);
 				if (!__pskb_pull_tail(skb, pull_size)) {
-					e_err(drv, "__pskb_pull_tail "
-					      "failed.\n");
+					e_err(drv, "__pskb_pull_tail failed.\n");
 					dev_kfree_skb_any(skb);
 					return NETDEV_TX_OK;
 				}
@@ -3201,7 +3205,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	 * in PCI-X mode, so add one more descriptor to the count
 	 */
 	if (unlikely((hw->bus_type == e1000_bus_type_pcix) &&
-			(len > 2015)))
+		     (len > 2015)))
 		count++;
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
@@ -3348,8 +3352,7 @@ static void e1000_regdump(struct e1000_adapter *adapter)
 		pr_info("%-15s  %08x\n", reg_name[i], regs_buff[i]);
 }
 
-/*
- * e1000_dump: Print registers, tx ring and rx ring
+/* e1000_dump: Print registers, tx ring and rx ring
  */
 static void e1000_dump(struct e1000_adapter *adapter)
 {
@@ -3417,7 +3420,7 @@ static void e1000_dump(struct e1000_adapter *adapter)
 			type = "";
 
 		pr_info("T%c[0x%03X]    %016llX %016llX %016llX %04X  %3X %016llX %p %s\n",
-			((le64_to_cpu(u->b) & (1<<20)) ? 'd' : 'c'), i,
+			((le64_to_cpu(u->b) & (1 << 20)) ? 'd' : 'c'), i,
 			le64_to_cpu(u->a), le64_to_cpu(u->b),
 			(u64)buffer_info->dma, buffer_info->length,
 			buffer_info->next_to_watch,
@@ -3467,20 +3470,20 @@ rx_ring_summary:
 	for (i = 0x6000; i <= 0x63FF ; i += 0x10) {
 		pr_info("R%04X: %08X|%08X %08X|%08X\n",
 			i,
-			readl(adapter->hw.hw_addr + i+4),
+			readl(adapter->hw.hw_addr + i + 4),
 			readl(adapter->hw.hw_addr + i),
-			readl(adapter->hw.hw_addr + i+12),
-			readl(adapter->hw.hw_addr + i+8));
+			readl(adapter->hw.hw_addr + i + 12),
+			readl(adapter->hw.hw_addr + i + 8));
 	}
 	/* tx */
 	pr_info("Tx descriptor cache in 64bit format\n");
 	for (i = 0x7000; i <= 0x73FF ; i += 0x10) {
 		pr_info("T%04X: %08X|%08X %08X|%08X\n",
 			i,
-			readl(adapter->hw.hw_addr + i+4),
+			readl(adapter->hw.hw_addr + i + 4),
 			readl(adapter->hw.hw_addr + i),
-			readl(adapter->hw.hw_addr + i+12),
-			readl(adapter->hw.hw_addr + i+8));
+			readl(adapter->hw.hw_addr + i + 12),
+			readl(adapter->hw.hw_addr + i + 8));
 	}
 exit:
 	return;
@@ -3733,14 +3736,14 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 	/* Phy Stats */
 	if (hw->media_type == e1000_media_type_copper) {
 		if ((adapter->link_speed == SPEED_1000) &&
-		   (!e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
+		    (!e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
 			phy_tmp &= PHY_IDLE_ERROR_COUNT_MASK;
 			adapter->phy_stats.idle_errors += phy_tmp;
 		}
 
 		if ((hw->mac_type <= e1000_82546) &&
-		   (hw->phy_type == e1000_phy_m88) &&
-		   !e1000_read_phy_reg(hw, M88E1000_RX_ERR_CNTR, &phy_tmp))
+		    (hw->phy_type == e1000_phy_m88) &&
+		    !e1000_read_phy_reg(hw, M88E1000_RX_ERR_CNTR, &phy_tmp))
 			adapter->phy_stats.receive_errors += phy_tmp;
 	}
 
@@ -3856,6 +3859,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
 		bool cleaned = false;
+
 		dma_rmb();	/* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
@@ -3869,7 +3873,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 					bytes_compl += buffer_info->skb->len;
 					pkts_compl++;
 				}
-
 			}
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->upper.data = 0;
@@ -3910,7 +3913,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
 			       (adapter->tx_timeout_factor * HZ)) &&
 		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
-
 			/* detected Tx unit hang */
 			e_err(drv, "Detected Tx Unit Hang\n"
 			      "  Tx Queue             <%lu>\n"
@@ -4179,7 +4181,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((status & E1000_RXD_STAT_EOP) &&
-		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
+			     (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
 			u8 *mapped = page_address(buffer_info->rxbuf.page);
 
 			if (e1000_tbi_should_accept(adapter, status,
@@ -4215,8 +4217,8 @@ process_skb:
 			} else {
 				/* this is the middle of a chain */
 				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->rxbuf.page, 0, length);
+						   skb_shinfo(rxtop)->nr_frags,
+						   buffer_info->rxbuf.page, 0, length);
 			}
 			e1000_consume_page(buffer_info, rxtop, length);
 			goto next_desc;
@@ -4224,8 +4226,8 @@ process_skb:
 			if (rxtop) {
 				/* end of the chain */
 				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->rxbuf.page, 0, length);
+						   skb_shinfo(rxtop)->nr_frags,
+						   buffer_info->rxbuf.page, 0, length);
 				skb = rxtop;
 				rxtop = NULL;
 				e1000_consume_page(buffer_info, skb, length);
@@ -4457,7 +4459,7 @@ process_skb:
 			 */
 			length -= 4;
 
-		if (buffer_info->rxbuf.data == NULL)
+		if (!buffer_info->rxbuf.data)
 			skb_put(skb, length);
 		else /* copybreak skb */
 			skb_trim(skb, length);
@@ -4595,8 +4597,9 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter, data, bufsz)) {
 			void *olddata = data;
-			e_err(rx_err, "skb align check failed: %u bytes at "
-			      "%p\n", bufsz, data);
+
+			e_err(rx_err, "skb align check failed: %u bytes at %p\n",
+			      bufsz, data);
 			/* Try again, without freeing the previous */
 			data = e1000_alloc_frag(adapter);
 			/* Failed allocation, critical failure */
@@ -4634,10 +4637,10 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter,
-					(void *)(unsigned long)buffer_info->dma,
-					adapter->rx_buffer_len)) {
-			e_err(rx_err, "dma align check failed: %u bytes at "
-			      "%p\n", adapter->rx_buffer_len,
+					   (void *)(unsigned long)buffer_info->dma,
+					   adapter->rx_buffer_len)) {
+			e_err(rx_err, "dma align check failed: %u bytes at %p\n",
+			      adapter->rx_buffer_len,
 			      (void *)(unsigned long)buffer_info->dma);
 
 			dma_unmap_single(&pdev->dev, buffer_info->dma,
@@ -4687,7 +4690,7 @@ static void e1000_smartspeed(struct e1000_adapter *adapter)
 	u16 phy_ctrl;
 
 	if ((hw->phy_type != e1000_phy_igp) || !hw->autoneg ||
-	   !(hw->autoneg_advertised & ADVERTISE_1000_FULL))
+	    !(hw->autoneg_advertised & ADVERTISE_1000_FULL))
 		return;
 
 	if (adapter->smartspeed == 0) {
@@ -4707,7 +4710,7 @@ static void e1000_smartspeed(struct e1000_adapter *adapter)
 					    phy_ctrl);
 			adapter->smartspeed++;
 			if (!e1000_phy_setup_autoneg(hw) &&
-			   !e1000_read_phy_reg(hw, PHY_CTRL,
+			    !e1000_read_phy_reg(hw, PHY_CTRL,
 					       &phy_ctrl)) {
 				phy_ctrl |= (MII_CR_AUTO_NEG_EN |
 					     MII_CR_RESTART_AUTO_NEG);
@@ -4722,7 +4725,7 @@ static void e1000_smartspeed(struct e1000_adapter *adapter)
 		phy_ctrl |= CR_1000T_MS_ENABLE;
 		e1000_write_phy_reg(hw, PHY_1000T_CTRL, phy_ctrl);
 		if (!e1000_phy_setup_autoneg(hw) &&
-		   !e1000_read_phy_reg(hw, PHY_CTRL, &phy_ctrl)) {
+		    !e1000_read_phy_reg(hw, PHY_CTRL, &phy_ctrl)) {
 			phy_ctrl |= (MII_CR_AUTO_NEG_EN |
 				     MII_CR_RESTART_AUTO_NEG);
 			e1000_write_phy_reg(hw, PHY_CTRL, phy_ctrl);
@@ -4777,7 +4780,7 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	case SIOCGMIIREG:
 		spin_lock_irqsave(&adapter->stats_lock, flags);
 		if (e1000_read_phy_reg(hw, data->reg_num & 0x1F,
-				   &data->val_out)) {
+				       &data->val_out)) {
 			spin_unlock_irqrestore(&adapter->stats_lock, flags);
 			return -EIO;
 		}
@@ -4804,6 +4807,7 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 					hw->autoneg_advertised = 0x2F;
 				} else {
 					u32 speed;
+
 					if (mii_reg & 0x40)
 						speed = SPEED_1000;
 					else if (mii_reg & 0x2000)
@@ -4867,12 +4871,14 @@ void e1000_pci_clear_mwi(struct e1000_hw *hw)
 int e1000_pcix_get_mmrbc(struct e1000_hw *hw)
 {
 	struct e1000_adapter *adapter = hw->back;
+
 	return pcix_get_mmrbc(adapter->pdev);
 }
 
 void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
 {
 	struct e1000_adapter *adapter = hw->back;
+
 	pcix_set_mmrbc(adapter->pdev, mmrbc);
 }
 
@@ -4906,6 +4912,7 @@ static void __e1000_vlan_mode(struct e1000_adapter *adapter,
 	}
 	ew32(CTRL, ctrl);
 }
+
 static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 				     bool filter_on)
 {
-- 
1.9.1
