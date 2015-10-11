From: Janusz Wolak <januszvdm@gmail.com>
Subject: e1000_driver_checkpatch_remove_errors_warnings_checks
Date: Sun, 11 Oct 2015 21:11:30 +0200
Message-ID: <561AB462.5080701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36268 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbbJKTLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 15:11:36 -0400
Received: by lbcao8 with SMTP id ao8so124813147lbc.3
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 12:11:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From daf0a1f5100c21f10b9e08829433258267748c44 Mon Sep 17 00:00:00 2001
From: Janusz Wolak <januszvdm@gmail.com>
Date: Tue, 6 Oct 2015 21:03:19 +0200
Subject: [PATCH 1/6] Remove checkpatch warnings and checks.

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
  drivers/net/ethernet/intel/e1000/e1000_main.c | 145 
++++++++++++++------------
  1 file changed, 76 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c 
b/drivers/net/ethernet/intel/e1000/e1000_main.c
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
+static const char e1000_driver_string[] = "Intel(R) PRO/1000 Network 
Driver";
  #define DRV_VERSION "7.3.21-k8-NAPI"
  const char e1000_driver_version[] = DRV_VERSION;
  static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel 
Corporation.";
@@ -149,6 +149,7 @@ static void e1000_alloc_dummy_rx_buffers(struct 
e1000_adapter *adapter,
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
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | 
NETIF_MSG_LINK)
  static int debug = -1;
  module_param(debug, int, 0);
  MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
@@ -237,6 +238,7 @@ MODULE_PARM_DESC(debug, "Debug level 
(0=none,...,16=all)");
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
@@ -288,9 +290,8 @@ static int e1000_request_irq(struct e1000_adapter 
*adapter)

  	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
  			  netdev);
-	if (err) {
+	if (err)
  		e_err(probe, "Unable to allocate interrupt Error: %d\n", err);
-	}

  	return err;
  }
@@ -406,6 +407,7 @@ static void e1000_configure(struct e1000_adapter 
*adapter)
  	 */
  	for (i = 0; i < adapter->num_rx_queues; i++) {
  		struct e1000_rx_ring *ring = &adapter->rx_ring[i];
+
  		adapter->alloc_rx_buf(adapter, ring,
  				      E1000_DESC_UNUSED(ring));
  	}
@@ -466,7 +468,7 @@ static void e1000_power_down_phy(struct 
e1000_adapter *adapter)
  	 * (c) SoL/IDER session is active
  	 */
  	if (!adapter->wol && hw->mac_type >= e1000_82540 &&
-	   hw->media_type == e1000_media_type_copper) {
+	    hw->media_type == e1000_media_type_copper) {
  		u16 mii_reg = 0;

  		switch (hw->mac_type) {
@@ -501,8 +503,7 @@ static void e1000_down_and_stop(struct e1000_adapter 
*adapter)

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
@@ -820,7 +821,7 @@ static netdev_features_t e1000_fix_features(struct 
net_device *netdev,
  }

  static int e1000_set_features(struct net_device *netdev,
-	netdev_features_t features)
+			      netdev_features_t features)
  {
  	struct e1000_adapter *adapter = netdev_priv(netdev);
  	netdev_features_t changed = features ^ netdev->features;
@@ -1061,7 +1062,7 @@ static int e1000_probe(struct pci_dev *pdev, const 
struct pci_device_id *ent)
  	}

  	if ((hw->mac_type >= e1000_82544) &&
-	   (hw->mac_type != e1000_82547))
+	    (hw->mac_type != e1000_82547))
  		netdev->hw_features |= NETIF_F_TSO;

  	netdev->priv_flags |= IFF_SUPP_NOFCS;
@@ -1122,7 +1123,6 @@ static int e1000_probe(struct pci_dev *pdev, const 
struct pci_device_id *ent)
  	if (!is_valid_ether_addr(netdev->dev_addr))
  		e_err(probe, "Invalid MAC Address\n");

-
  	INIT_DELAYED_WORK(&adapter->watchdog_task, e1000_watchdog);
  	INIT_DELAYED_WORK(&adapter->fifo_stall_task,
  			  e1000_82547_tx_fifo_stall_task);
@@ -1143,20 +1143,20 @@ static int e1000_probe(struct pci_dev *pdev, 
const struct pci_device_id *ent)
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
@@ -1679,7 +1680,6 @@ static void e1000_configure_tx(struct 
e1000_adapter *adapter)
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
@@ -2187,6 +2188,7 @@ static void e1000_leave_82542_rst(struct 
e1000_adapter *adapter)
  	if (netif_running(netdev)) {
  		/* No need to loop, because 82542 supports only 1 queue */
  		struct e1000_rx_ring *ring = &adapter->rx_ring[0];
+
  		e1000_configure_rx(adapter);
  		adapter->alloc_rx_buf(adapter, ring, E1000_DESC_UNUSED(ring));
  	}
@@ -2298,6 +2300,7 @@ static void e1000_set_rx_mode(struct net_device 
*netdev)
  		if (i == rar_entries) {
  			/* load any remaining addresses into the hash table */
  			u32 hash_reg, hash_bit, mta;
+
  			hash_value = e1000_hash_mc_addr(hw, ha->addr);
  			hash_reg = (hash_value >> 5) & 0x7F;
  			hash_bit = hash_value & 0x1F;
@@ -2365,8 +2368,8 @@ static void e1000_82547_tx_fifo_stall_task(struct 
work_struct *work)

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
@@ -2595,7 +2597,7 @@ static unsigned int e1000_update_itr(struct 
e1000_adapter *adapter,
  	switch (itr_setting) {
  	case lowest_latency:
  		/* jumbo frames get bulk treatment*/
-		if (bytes/packets > 8000)
+		if (bytes / packets > 8000)
  			retval = bulk_latency;
  		else if ((packets < 5) && (bytes > 512))
  			retval = low_latency;
@@ -2603,13 +2605,13 @@ static unsigned int e1000_update_itr(struct 
e1000_adapter *adapter,
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
@@ -2827,7 +2830,7 @@ static bool e1000_tx_csum(struct e1000_adapter 
*adapter,
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
@@ -3148,6 +3152,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff 
*skb,
  	 */
  	if (mss) {
  		u8 hdr_len;
+
  		max_per_txd = min(mss << 2, max_per_txd);
  		max_txd_pwr = fls(max_per_txd) - 1;

@@ -3169,8 +3174,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff 
*skb,
  				/* fall through */
  				pull_size = min((unsigned int)4, skb->data_len);
  				if (!__pskb_pull_tail(skb, pull_size)) {
-					e_err(drv, "__pskb_pull_tail "
-					      "failed.\n");
+					e_err(drv, "__pskb_pull_tail failed.\n");
  					dev_kfree_skb_any(skb);
  					return NETDEV_TX_OK;
  				}
@@ -3201,7 +3205,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff 
*skb,
  	 * in PCI-X mode, so add one more descriptor to the count
  	 */
  	if (unlikely((hw->bus_type == e1000_bus_type_pcix) &&
-			(len > 2015)))
+		     (len > 2015)))
  		count++;

  	nr_frags = skb_shinfo(skb)->nr_frags;
@@ -3348,8 +3352,7 @@ static void e1000_regdump(struct e1000_adapter 
*adapter)
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

  		pr_info("T%c[0x%03X]    %016llX %016llX %016llX %04X  %3X %016llX %p 
%s\n",
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
@@ -3733,14 +3736,14 @@ void e1000_update_stats(struct e1000_adapter 
*adapter)
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

@@ -3856,6 +3859,7 @@ static bool e1000_clean_tx_irq(struct 
e1000_adapter *adapter,
  	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
  	       (count < tx_ring->count)) {
  		bool cleaned = false;
+
  		dma_rmb();	/* read buffer_info after eop_desc */
  		for ( ; !cleaned; count++) {
  			tx_desc = E1000_TX_DESC(*tx_ring, i);
@@ -3869,7 +3873,6 @@ static bool e1000_clean_tx_irq(struct 
e1000_adapter *adapter,
  					bytes_compl += buffer_info->skb->len;
  					pkts_compl++;
  				}
-
  			}
  			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
  			tx_desc->upper.data = 0;
@@ -3910,7 +3913,6 @@ static bool e1000_clean_tx_irq(struct 
e1000_adapter *adapter,
  		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
  			       (adapter->tx_timeout_factor * HZ)) &&
  		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
-
  			/* detected Tx unit hang */
  			e_err(drv, "Detected Tx Unit Hang\n"
  			      "  Tx Queue             <%lu>\n"
@@ -4179,7 +4181,7 @@ static bool e1000_clean_jumbo_rx_irq(struct 
e1000_adapter *adapter,

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
@@ -4595,8 +4597,9 @@ static void e1000_alloc_rx_buffers(struct 
e1000_adapter *adapter,
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
@@ -4634,10 +4637,10 @@ static void e1000_alloc_rx_buffers(struct 
e1000_adapter *adapter,

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
@@ -4687,7 +4690,7 @@ static void e1000_smartspeed(struct e1000_adapter 
*adapter)
  	u16 phy_ctrl;

  	if ((hw->phy_type != e1000_phy_igp) || !hw->autoneg ||
-	   !(hw->autoneg_advertised & ADVERTISE_1000_FULL))
+	    !(hw->autoneg_advertised & ADVERTISE_1000_FULL))
  		return;

  	if (adapter->smartspeed == 0) {
@@ -4707,7 +4710,7 @@ static void e1000_smartspeed(struct e1000_adapter 
*adapter)
  					    phy_ctrl);
  			adapter->smartspeed++;
  			if (!e1000_phy_setup_autoneg(hw) &&
-			   !e1000_read_phy_reg(hw, PHY_CTRL,
+			    !e1000_read_phy_reg(hw, PHY_CTRL,
  					       &phy_ctrl)) {
  				phy_ctrl |= (MII_CR_AUTO_NEG_EN |
  					     MII_CR_RESTART_AUTO_NEG);
@@ -4722,7 +4725,7 @@ static void e1000_smartspeed(struct e1000_adapter 
*adapter)
  		phy_ctrl |= CR_1000T_MS_ENABLE;
  		e1000_write_phy_reg(hw, PHY_1000T_CTRL, phy_ctrl);
  		if (!e1000_phy_setup_autoneg(hw) &&
-		   !e1000_read_phy_reg(hw, PHY_CTRL, &phy_ctrl)) {
+		    !e1000_read_phy_reg(hw, PHY_CTRL, &phy_ctrl)) {
  			phy_ctrl |= (MII_CR_AUTO_NEG_EN |
  				     MII_CR_RESTART_AUTO_NEG);
  			e1000_write_phy_reg(hw, PHY_CTRL, phy_ctrl);
@@ -4777,7 +4780,7 @@ static int e1000_mii_ioctl(struct net_device 
*netdev, struct ifreq *ifr,
  	case SIOCGMIIREG:
  		spin_lock_irqsave(&adapter->stats_lock, flags);
  		if (e1000_read_phy_reg(hw, data->reg_num & 0x1F,
-				   &data->val_out)) {
+				       &data->val_out)) {
  			spin_unlock_irqrestore(&adapter->stats_lock, flags);
  			return -EIO;
  		}
@@ -4804,6 +4807,7 @@ static int e1000_mii_ioctl(struct net_device 
*netdev, struct ifreq *ifr,
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

@@ -4906,6 +4912,7 @@ static void __e1000_vlan_mode(struct e1000_adapter 
*adapter,
  	}
  	ew32(CTRL, ctrl);
  }
+
  static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
  				     bool filter_on)
  {
-- 
1.9.1


 From 40c55c64a19e920a0db8bcc0cd4cd5cac19ba451 Mon Sep 17 00:00:00 2001
From: Janusz Wolak <januszvdm@gmail.com>
Date: Tue, 6 Oct 2015 22:23:31 +0200
Subject: [PATCH 2/6] Remove checkpatch errors, warnings, ckecks.

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
  drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 31 
++++++++++++++----------
  1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c 
b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 4270ad2..c4ffab4 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -36,12 +36,12 @@ struct e1000_stats {
  	int stat_offset;
  };

-#define E1000_STAT(m)		E1000_STATS, \
+#define E1000_STAT(m)		(E1000_STATS, \
  				sizeof(((struct e1000_adapter *)0)->m), \
-				offsetof(struct e1000_adapter, m)
-#define E1000_NETDEV_STAT(m)	NETDEV_STATS, \
+				offsetof(struct e1000_adapter, m))
+#define E1000_NETDEV_STAT(m)	(NETDEV_STATS, \
  				sizeof(((struct net_device *)0)->m), \
-				offsetof(struct net_device, m)
+				offsetof(struct net_device, m))

  static const struct e1000_stats e1000_gstrings_stats[] = {
  	{ "rx_packets", E1000_STAT(stats.gprc) },
@@ -114,7 +114,7 @@ static int e1000_get_settings(struct net_device *netdev,
  				   SUPPORTED_10baseT_Full |
  				   SUPPORTED_100baseT_Half |
  				   SUPPORTED_100baseT_Full |
-				   SUPPORTED_1000baseT_Full|
+				   SUPPORTED_1000baseT_Full |
  				   SUPPORTED_Autoneg |
  				   SUPPORTED_TP);
  		ecmd->advertising = ADVERTISED_TP;
@@ -708,8 +708,7 @@ static bool reg_set_and_check(struct e1000_adapter 
*adapter, u64 *data, int reg,
  	writel(write & mask, address);
  	read = readl(address);
  	if ((read & mask) != (write & mask)) {
-		e_err(drv, "set/check reg %04X test failed: "
-		      "got 0x%08X expected 0x%08X\n",
+		e_err(drv, "set/check reg %04X test failed: got 0x%08X expected 
0x%08X\n",
  		      reg, (read & mask), (write & mask));
  		*data = reg;
  		return true;
@@ -1021,7 +1020,8 @@ static int e1000_setup_desc_rings(struct 
e1000_adapter *adapter)
  		ret_val = 2;
  		goto err_nomem;
  	}
-	txdr->next_to_use = txdr->next_to_clean = 0;
+	txdr->next_to_use = 0;
+	txdr->next_to_clean = 0;

  	ew32(TDBAL, ((u64)txdr->dma & 0x00000000FFFFFFFF));
  	ew32(TDBAH, ((u64)txdr->dma >> 32));
@@ -1079,7 +1079,8 @@ static int e1000_setup_desc_rings(struct 
e1000_adapter *adapter)
  		ret_val = 6;
  		goto err_nomem;
  	}
-	rxdr->next_to_use = rxdr->next_to_clean = 0;
+	rxdr->next_to_use = 0;
+	rxdr->next_to_clean = 0;

  	rctl = er32(RCTL);
  	ew32(RCTL, rctl & ~E1000_RCTL_EN);
@@ -1251,7 +1252,7 @@ static int e1000_integrated_phy_loopback(struct 
e1000_adapter *adapter)
  	ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
  	ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
  			E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
-			E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
+			E1000_CTRL_SPD_1000 | /* Force Speed to 1000 */
  			E1000_CTRL_FD); /* Force Duplex to FULL */

  	if (hw->media_type == e1000_media_type_copper &&
@@ -1293,7 +1294,8 @@ static int e1000_set_phy_loopback(struct 
e1000_adapter *adapter)
  			 * attempt this 10 times.
  			 */
  			while (e1000_nonintegrated_phy_loopback(adapter) &&
-			       count++ < 10);
+			       count++ < 10)
+				;
  			if (count < 11)
  				return 0;
  		}
@@ -1420,7 +1422,9 @@ static int e1000_run_loopback_test(struct 
e1000_adapter *adapter)
  	else
  		lc = ((rxdr->count / 64) * 2) + 1;

-	k = l = 0;
+	k = 0;
+	l = 0;
+
  	for (j = 0; j <= lc; j++) { /* loop count loop */
  		for (i = 0; i < 64; i++) { /* send the packets */
  			e1000_create_lbtest_frame(txdr->buffer_info[i].skb,
@@ -1796,7 +1800,8 @@ static int e1000_set_coalesce(struct net_device 
*netdev,
  		return -EINVAL;

  	if (ec->rx_coalesce_usecs == 4) {
-		adapter->itr = adapter->itr_setting = 4;
+		adapter->itr = 4;
+		adapter->itr_setting = 4;
  	} else if (ec->rx_coalesce_usecs <= 3) {
  		adapter->itr = 20000;
  		adapter->itr_setting = ec->rx_coalesce_usecs;
-- 
1.9.1

 From 4f87c1a56fdbc431bb061857f7accc0671464caa Mon Sep 17 00:00:00 2001
From: Janusz Wolak <januszvdm@gmail.com>
Date: Thu, 8 Oct 2015 22:13:12 +0200
Subject: [PATCH 3/6] Remove checkpatch errors, warnings, ckecks.

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
  drivers/net/ethernet/intel/e1000/e1000.h | 8 +++-----
  1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h 
b/drivers/net/ethernet/intel/e1000/e1000.h
index 6970710..ec82b2d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -1,5 +1,5 @@
 
/*******************************************************************************
-
+*
    Intel PRO/1000 Linux driver
    Copyright(c) 1999 - 2006 Intel Corporation.

@@ -26,7 +26,6 @@

 
*******************************************************************************/

-
  /* Linux PRO/1000 Ethernet Driver main header file */

  #ifndef _E1000_H_
@@ -53,7 +52,7 @@
  #include <linux/pagemap.h>
  #include <linux/dma-mapping.h>
  #include <linux/bitops.h>
-#include <asm/io.h>
+#include <linux/io.h>
  #include <asm/irq.h>
  #include <linux/capability.h>
  #include <linux/in.h>
@@ -82,8 +81,7 @@ struct e1000_adapter;

  #define E1000_MAX_INTR			10

-/*
- * Count for polling __E1000_RESET condition every 10-20msec.
+/* Count for polling __E1000_RESET condition every 10-20msec.
   */
  #define E1000_CHECK_RESET_COUNT	50

-- 
1.9.1


 From 3cbe87d4e9b0cf579c25f746cba38038b920119c Mon Sep 17 00:00:00 2001
From: Janusz Wolak <januszvdm@gmail.com>
Date: Sun, 11 Oct 2015 15:47:24 +0200
Subject: [PATCH 4/6] Remove checkpatch errors, warnings, ckecks.

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
  drivers/net/ethernet/intel/e1000/e1000_hw.h | 154 
+++++++++++++++-------------
  1 file changed, 80 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.h 
b/drivers/net/ethernet/intel/e1000/e1000_hw.h
index 5cf7268c..65a9640 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.h
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.h
@@ -1,5 +1,5 @@
 
/*******************************************************************************
-
+*
    Intel PRO/1000 Linux driver
    Copyright(c) 1999 - 2006 Intel Corporation.

@@ -285,7 +285,7 @@ typedef enum {
  #define E1000_BLK_PHY_RESET   12

  #define E1000_BYTE_SWAP_WORD(_value) ((((_value) & 0x00ff) << 8) | \
-                                     (((_value) & 0xff00) >> 8))
+				     (((_value) & 0xff00) >> 8))

  /* Function prototypes */
  /* Initialization */
@@ -299,11 +299,11 @@ s32 e1000_setup_link(struct e1000_hw *hw);
  s32 e1000_phy_setup_autoneg(struct e1000_hw *hw);
  void e1000_config_collision_dist(struct e1000_hw *hw);
  s32 e1000_check_for_link(struct e1000_hw *hw);
-s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 * speed, u16 * 
duplex);
+s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 
*duplex);
  s32 e1000_force_mac_fc(struct e1000_hw *hw);

  /* PHY */
-s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 * phy_data);
+s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data);
  s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
  s32 e1000_phy_hw_reset(struct e1000_hw *hw);
  s32 e1000_phy_reset(struct e1000_hw *hw);
@@ -344,6 +344,7 @@ struct e1000_host_mng_command_info {
  	struct e1000_host_mng_command_header command_header;	/* Command 
Head/Command Result Head has 4 bytes */
  	u8 command_data[E1000_HI_MAX_MNG_DATA_LENGTH];	/* Command data can 
length 0..0x658 */
  };
+
  #ifdef __BIG_ENDIAN
  struct e1000_host_mng_dhcp_cookie {
  	u32 signature;
@@ -369,16 +370,16 @@ struct e1000_host_mng_dhcp_cookie {
  #endif

  bool e1000_check_mng_mode(struct e1000_hw *hw);
-s32 e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 * data);
+s32 e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
  s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw);
  s32 e1000_update_eeprom_checksum(struct e1000_hw *hw);
-s32 e1000_write_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 * 
data);
+s32 e1000_write_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
  s32 e1000_read_mac_addr(struct e1000_hw *hw);

  /* Filters (multicast, vlan, receive) */
-u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 * mc_addr);
+u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
  void e1000_mta_set(struct e1000_hw *hw, u32 hash_value);
-void e1000_rar_set(struct e1000_hw *hw, u8 * mc_addr, u32 rar_index);
+void e1000_rar_set(struct e1000_hw *hw, u8 *mc_addr, u32 rar_index);
  void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);

  /* LED functions */
@@ -401,10 +402,8 @@ int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
  /* Port I/O is only supported on 82544 and newer */
  void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);

-#define E1000_READ_REG_IO(a, reg) \
-    e1000_read_reg_io((a), E1000_##reg)
-#define E1000_WRITE_REG_IO(a, reg, val) \
-    e1000_write_reg_io((a), E1000_##reg, val)
+#define E1000_READ_REG_IO(a, reg) e1000_read_reg_io((a), E1000_##reg)
+#define E1000_WRITE_REG_IO(a, reg, val) e1000_write_reg_io((a), 
E1000_##reg, val)

  /* PCI Device IDs */
  #define E1000_DEV_ID_82542               0x1000
@@ -467,8 +466,7 @@ void e1000_io_write(struct e1000_hw *hw, unsigned 
long port, u32 value);
  #define ENET_HEADER_SIZE             14
  #define MINIMUM_ETHERNET_FRAME_SIZE  64	/* With FCS */
  #define ETHERNET_FCS_SIZE            4
-#define MINIMUM_ETHERNET_PACKET_SIZE \
-    (MINIMUM_ETHERNET_FRAME_SIZE - ETHERNET_FCS_SIZE)
+#define MINIMUM_ETHERNET_PACKET_SIZE (MINIMUM_ETHERNET_FRAME_SIZE - 
ETHERNET_FCS_SIZE)
  #define CRC_LENGTH                   ETHERNET_FCS_SIZE
  #define MAX_JUMBO_FRAME_SIZE         0x3F00

@@ -489,9 +487,7 @@ void e1000_io_write(struct e1000_hw *hw, unsigned 
long port, u32 value);
   *   o RXDMT0 = Receive Descriptor Minimum Threshold hit (ring 0)
   *   o RXSEQ  = Receive Sequence Error
   */
-#define POLL_IMS_ENABLE_MASK ( \
-    E1000_IMS_RXDMT0 |         \
-    E1000_IMS_RXSEQ)
+#define POLL_IMS_ENABLE_MASK (E1000_IMS_RXDMT0 | E1000_IMS_RXSEQ)

  /* This defines the bits that are set in the Interrupt Mask
   * Set/Read Register.  Each bit is documented below:
@@ -501,12 +497,8 @@ void e1000_io_write(struct e1000_hw *hw, unsigned 
long port, u32 value);
   *   o RXSEQ  = Receive Sequence Error
   *   o LSC    = Link Status Change
   */
-#define IMS_ENABLE_MASK ( \
-    E1000_IMS_RXT0   |    \
-    E1000_IMS_TXDW   |    \
-    E1000_IMS_RXDMT0 |    \
-    E1000_IMS_RXSEQ  |    \
-    E1000_IMS_LSC)
+#define IMS_ENABLE_MASK (E1000_IMS_RXT0 | E1000_IMS_TXDW | 
E1000_IMS_RXDMT0 | \
+			 E1000_IMS_RXSEQ | E1000_IMS_LSC)

  /* Number of high/low register pairs in the RAR. The RAR (Receive Address
   * Registers) holds the directed and multicast addresses that we 
monitor. We
@@ -621,20 +613,16 @@ union e1000_rx_desc_packet_split {
  #define E1000_RXDPS_HDRSTAT_HDRLEN_MASK  0x000003FF

  /* mask to determine if packets should be dropped due to frame errors */
-#define E1000_RXD_ERR_FRAME_ERR_MASK ( \
-    E1000_RXD_ERR_CE  |                \
-    E1000_RXD_ERR_SE  |                \
-    E1000_RXD_ERR_SEQ |                \
-    E1000_RXD_ERR_CXE |                \
-    E1000_RXD_ERR_RXE)
+#define E1000_RXD_ERR_FRAME_ERR_MASK (E1000_RXD_ERR_CE | 
E1000_RXD_ERR_SE | \
+				      E1000_RXD_ERR_SEQ | E1000_RXD_ERR_CXE | \
+				      E1000_RXD_ERR_RXE)

  /* Same mask, but for extended and packet split descriptors */
-#define E1000_RXDEXT_ERR_FRAME_ERR_MASK ( \
-    E1000_RXDEXT_STATERR_CE  |            \
-    E1000_RXDEXT_STATERR_SE  |            \
-    E1000_RXDEXT_STATERR_SEQ |            \
-    E1000_RXDEXT_STATERR_CXE |            \
-    E1000_RXDEXT_STATERR_RXE)
+#define E1000_RXDEXT_ERR_FRAME_ERR_MASK (E1000_RXDEXT_STATERR_CE | \
+					 E1000_RXDEXT_STATERR_SE | \
+					 E1000_RXDEXT_STATERR_SEQ | \
+					 E1000_RXDEXT_STATERR_CXE | \
+					 E1000_RXDEXT_STATERR_RXE)

  /* Transmit Descriptor */
  struct e1000_tx_desc {
@@ -1094,7 +1082,8 @@ struct e1000_ffvt_entry {
  #define E1000_82542_RDH0     E1000_82542_RDH
  #define E1000_82542_RDT0     E1000_82542_RDT
  #define E1000_82542_SRRCTL(_n) (0x280C + ((_n) << 8))	/* Split and 
Replication
-							 * RX Control - RW */
+							 * RX Control - RW
+							 */
  #define E1000_82542_DCA_RXCTRL(_n) (0x02814 + ((_n) << 8))
  #define E1000_82542_RDBAH3   0x02B04	/* RX Desc Base High Queue 3 - RW */
  #define E1000_82542_RDBAL3   0x02B00	/* RX Desc Low Queue 3 - RW */
@@ -1494,7 +1483,8 @@ struct e1000_hw {
  #define E1000_STATUS_SPEED_100  0x00000040	/* Speed 100Mb/s */
  #define E1000_STATUS_SPEED_1000 0x00000080	/* Speed 1000Mb/s */
  #define E1000_STATUS_LAN_INIT_DONE 0x00000200	/* Lan Init Completion
-						   by EEPROM/Flash */
+						 * by EEPROM/Flash
+						 */
  #define E1000_STATUS_ASDV       0x00000300	/* Auto speed detect value */
  #define E1000_STATUS_DOCK_CI    0x00000800	/* Change in Dock/Undock 
state. Clear on write '0'. */
  #define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000	/* Status of Master 
requests. */
@@ -1533,7 +1523,8 @@ struct e1000_hw {
  #define E1000_EECD_PRES      0x00000100	/* EEPROM Present */
  #define E1000_EECD_SIZE      0x00000200	/* EEPROM Size (0=64 word 
1=256 word) */
  #define E1000_EECD_ADDR_BITS 0x00000400	/* EEPROM Addressing bits 
based on type
-					 * (0-small, 1-large) */
+					 * (0-small, 1-large)
+					 */
  #define E1000_EECD_TYPE      0x00002000	/* EEPROM Type (1-SPI, 
0-Microwire) */
  #ifndef E1000_EEPROM_GRANT_ATTEMPTS
  #define E1000_EEPROM_GRANT_ATTEMPTS 1000	/* EEPROM # attempts to gain 
grant */
@@ -1949,7 +1940,8 @@ struct e1000_hw {
  #define E1000_TXDCTL_LWTHRESH 0xFE000000	/* TXDCTL Low Threshold */
  #define E1000_TXDCTL_FULL_TX_DESC_WB 0x01010000	/* GRAN=1, WTHRESH=1 */
  #define E1000_TXDCTL_COUNT_DESC 0x00400000	/* Enable the counting of desc.
-						   still to be processed. */
+						 * still to be processed.
+						 */
  /* Transmit Configuration Word */
  #define E1000_TXCW_FD         0x00000020	/* TXCW full duplex */
  #define E1000_TXCW_HD         0x00000040	/* TXCW half duplex */
@@ -2059,7 +2051,8 @@ struct e1000_hw {
  #define E1000_MANC_SNAP_EN       0x00001000	/* Accept LLC/SNAP */
  #define E1000_MANC_ARP_EN        0x00002000	/* Enable ARP Request 
Filtering */
  #define E1000_MANC_NEIGHBOR_EN   0x00004000	/* Enable Neighbor Discovery
-						 * Filtering */
+						 * Filtering
+						 */
  #define E1000_MANC_ARP_RES_EN    0x00008000	/* Enable ARP response 
Filtering */
  #define E1000_MANC_TCO_RESET     0x00010000	/* TCO Reset Occurred */
  #define E1000_MANC_RCV_TCO_EN    0x00020000	/* Receive TCO Packets 
Enabled */
@@ -2067,11 +2060,14 @@ struct e1000_hw {
  #define E1000_MANC_RCV_ALL       0x00080000	/* Receive All Enabled */
  #define E1000_MANC_BLK_PHY_RST_ON_IDE   0x00040000	/* Block phy resets */
  #define E1000_MANC_EN_MAC_ADDR_FILTER   0x00100000	/* Enable MAC address
-							 * filtering */
+							 * filtering
+							 */
  #define E1000_MANC_EN_MNG2HOST   0x00200000	/* Enable MNG packets to host
-						 * memory */
+						 * memory
+						 */
  #define E1000_MANC_EN_IP_ADDR_FILTER    0x00400000	/* Enable IP address
-							 * filtering */
+							 * filtering
+							 */
  #define E1000_MANC_EN_XSUM_FILTER   0x00800000	/* Enable checksum 
filtering */
  #define E1000_MANC_BR_EN         0x01000000	/* Enable broadcast 
filtering */
  #define E1000_MANC_SMB_REQ       0x01000000	/* SMBus Request */
@@ -2118,7 +2114,8 @@ typedef enum {
  /* Host Interface Control Register */
  #define E1000_HICR_EN           0x00000001	/* Enable Bit - RO */
  #define E1000_HICR_C            0x00000002	/* Driver sets this bit 
when done
-						 * to put command in RAM */
+						 * to put command in RAM
+						 */
  #define E1000_HICR_SV           0x00000004	/* Status Validity */
  #define E1000_HICR_FWR          0x00000080	/* FW reset. Set by the Host */

@@ -2134,6 +2131,7 @@ struct e1000_host_command_header {
  	u8 command_options;	/* I/F bits for command, status for return */
  	u8 checksum;
  };
+
  struct e1000_host_command_info {
  	struct e1000_host_command_header command_header;	/* Command 
Head/Command Result Head has 4 bytes */
  	u8 command_data[E1000_HI_MAX_DATA_LENGTH];	/* Command data can length 
0..252 */
@@ -2170,11 +2168,11 @@ struct e1000_host_command_info {
  #define E1000_GCR_TXDSCR_NO_SNOOP       0x00000020

  #define PCI_EX_NO_SNOOP_ALL (E1000_GCR_RXD_NO_SNOOP         | \
-                             E1000_GCR_RXDSCW_NO_SNOOP      | \
-                             E1000_GCR_RXDSCR_NO_SNOOP      | \
-                             E1000_GCR_TXD_NO_SNOOP         | \
-                             E1000_GCR_TXDSCW_NO_SNOOP      | \
-                             E1000_GCR_TXDSCR_NO_SNOOP)
+			     E1000_GCR_RXDSCW_NO_SNOOP      | \
+			     E1000_GCR_RXDSCR_NO_SNOOP      | \
+			     E1000_GCR_TXD_NO_SNOOP         | \
+			     E1000_GCR_TXDSCW_NO_SNOOP      | \
+			     E1000_GCR_TXDSCR_NO_SNOOP)

  #define PCI_EX_82566_SNOOP_ALL PCI_EX_NO_SNOOP_ALL

@@ -2257,9 +2255,9 @@ struct e1000_host_command_info {
  #define ID_LED_RESERVED_0000 0x0000
  #define ID_LED_RESERVED_FFFF 0xFFFF
  #define ID_LED_DEFAULT       ((ID_LED_OFF1_ON2 << 12) | \
-                              (ID_LED_OFF1_OFF2 << 8) | \
-                              (ID_LED_DEF1_DEF2 << 4) | \
-                              (ID_LED_DEF1_DEF2))
+			      (ID_LED_OFF1_OFF2 << 8) | \
+			      (ID_LED_DEF1_DEF2 << 4) | \
+			      (ID_LED_DEF1_DEF2))
  #define ID_LED_DEF1_DEF2     0x1
  #define ID_LED_DEF1_ON2      0x2
  #define ID_LED_DEF1_OFF2     0x3
@@ -2318,7 +2316,8 @@ struct e1000_host_command_info {
  #define E1000_COLLISION_THRESHOLD       15
  #define E1000_CT_SHIFT                  4
  /* Collision distance is a 0-based value that applies to
- * half-duplex-capable hardware only. */
+ * half-duplex-capable hardware only.
+ */
  #define E1000_COLLISION_DISTANCE        63
  #define E1000_COLLISION_DISTANCE_82542  64
  #define E1000_FDX_COLLISION_DISTANCE    E1000_COLLISION_DISTANCE
@@ -2482,10 +2481,10 @@ struct e1000_host_command_info {
       (((errors) & E1000_RXD_ERR_FRAME_ERR_MASK) == E1000_RXD_ERR_CE) && \
       ((last_byte) == CARRIER_EXTENSION) && \
       (((status) & E1000_RXD_STAT_VP) ? \
-          (((length) > ((adapter)->min_frame_size - VLAN_TAG_SIZE)) && \
-           ((length) <= ((adapter)->max_frame_size + 1))) : \
-          (((length) > (adapter)->min_frame_size) && \
-           ((length) <= ((adapter)->max_frame_size + VLAN_TAG_SIZE + 1)))))
+	  (((length) > ((adapter)->min_frame_size - VLAN_TAG_SIZE)) && \
+	   ((length) <= ((adapter)->max_frame_size + 1))) : \
+	  (((length) > (adapter)->min_frame_size) && \
+	   ((length) <= ((adapter)->max_frame_size + VLAN_TAG_SIZE + 1)))))

  /* Structures, enums, and macros for the PHY */

@@ -2582,7 +2581,8 @@ struct e1000_host_command_info {

  #define IGP01E1000_PHY_DSP_FFE_DEFAULT      0x002A
  /* IGP01E1000 PCS Initialization register - stores the polarity status 
when
- * speed = 1000 Mbps. */
+ * speed = 1000 Mbps.
+ */
  #define IGP01E1000_PHY_PCS_INIT_REG  0x00B4
  #define IGP01E1000_PHY_PCS_CTRL_REG  0x00B5

@@ -2739,10 +2739,12 @@ struct e1000_host_command_info {
  #define M88E1000_PSCR_10BT_EXT_DIST_ENABLE 0x0080
  					/* 1=Enable Extended 10BASE-T distance
  					 * (Lower 10BASE-T RX Threshold)
-					 * 0=Normal 10BASE-T RX Threshold */
+					 * 0=Normal 10BASE-T RX Threshold
+					 */
  #define M88E1000_PSCR_MII_5BIT_ENABLE      0x0100
  					/* 1=5-Bit interface in 100BASE-TX
-					 * 0=MII interface in 100BASE-TX */
+					 * 0=MII interface in 100BASE-TX
+					 */
  #define M88E1000_PSCR_SCRAMBLER_DISABLE    0x0200	/* 1=Scrambler 
disable */
  #define M88E1000_PSCR_FORCE_LINK_GOOD      0x0400	/* 1=Force link good */
  #define M88E1000_PSCR_ASSERT_CRS_ON_TX     0x0800	/* 1=Assert CRS on 
Transmit */
@@ -2757,7 +2759,8 @@ struct e1000_host_command_info {
  #define M88E1000_PSSR_DOWNSHIFT          0x0020	/* 1=Downshifted */
  #define M88E1000_PSSR_MDIX               0x0040	/* 1=MDIX; 0=MDI */
  #define M88E1000_PSSR_CABLE_LENGTH       0x0380	/* 
0=<50M;1=50-80M;2=80-110M;
-						 * 3=110-140M;4=>140M */
+						 * 3=110-140M;4=>140M
+						 */
  #define M88E1000_PSSR_LINK               0x0400	/* 1=Link up, 0=Link 
down */
  #define M88E1000_PSSR_SPD_DPLX_RESOLVED  0x0800	/* 1=Speed & Duplex 
resolved */
  #define M88E1000_PSSR_PAGE_RCVD          0x1000	/* 1=Page received */
@@ -2780,14 +2783,16 @@ struct e1000_host_command_info {
  						 * within 1ms in 1000BASE-T
  						 */
  /* Number of times we will attempt to autonegotiate before 
downshifting if we
- * are the master */
+ * are the master
+ */
  #define M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK 0x0C00
  #define M88E1000_EPSCR_MASTER_DOWNSHIFT_1X   0x0000
  #define M88E1000_EPSCR_MASTER_DOWNSHIFT_2X   0x0400
  #define M88E1000_EPSCR_MASTER_DOWNSHIFT_3X   0x0800
  #define M88E1000_EPSCR_MASTER_DOWNSHIFT_4X   0x0C00
  /* Number of times we will attempt to autonegotiate before 
downshifting if we
- * are the slave */
+ * are the slave
+ */
  #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_MASK  0x0300
  #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_DIS   0x0000
  #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X    0x0100
@@ -2891,7 +2896,8 @@ struct e1000_host_command_info {

  /* IGP01E1000 GMII FIFO Register */
  #define IGP01E1000_GMII_FLEX_SPD               0x10	/* Enable flexible 
speed
-							 * on Link-Up */
+							 * on Link-Up
+							 */
  #define IGP01E1000_GMII_SPD                    0x20	/* Enable SPD */

  /* IGP01E1000 Analog Register */
@@ -2938,32 +2944,32 @@ struct e1000_host_command_info {
   */
  #define PHY_PAGE_SHIFT        5
  #define PHY_REG(page, reg)    \
-        (((page) << PHY_PAGE_SHIFT) | ((reg) & MAX_PHY_REG_ADDRESS))
+	(((page) << PHY_PAGE_SHIFT) | ((reg) & MAX_PHY_REG_ADDRESS))

  #define IGP3_PHY_PORT_CTRL           \
-        PHY_REG(769, 17)	/* Port General Configuration */
+	PHY_REG(769, 17)	/* Port General Configuration */
  #define IGP3_PHY_RATE_ADAPT_CTRL \
-        PHY_REG(769, 25)	/* Rate Adapter Control Register */
+	PHY_REG(769, 25)	/* Rate Adapter Control Register */

  #define IGP3_KMRN_FIFO_CTRL_STATS \
-        PHY_REG(770, 16)	/* KMRN FIFO's control/status register */
+	PHY_REG(770, 16)	/* KMRN FIFO's control/status register */
  #define IGP3_KMRN_POWER_MNG_CTRL \
-        PHY_REG(770, 17)	/* KMRN Power Management Control Register */
+	PHY_REG(770, 17)	/* KMRN Power Management Control Register */
  #define IGP3_KMRN_INBAND_CTRL \
-        PHY_REG(770, 18)	/* KMRN Inband Control Register */
+	PHY_REG(770, 18)	/* KMRN Inband Control Register */
  #define IGP3_KMRN_DIAG \
-        PHY_REG(770, 19)	/* KMRN Diagnostic register */
+	PHY_REG(770, 19)	/* KMRN Diagnostic register */
  #define IGP3_KMRN_DIAG_PCS_LOCK_LOSS 0x0002	/* RX PCS is not synced */
  #define IGP3_KMRN_ACK_TIMEOUT \
-        PHY_REG(770, 20)	/* KMRN Acknowledge Timeouts register */
+	PHY_REG(770, 20)	/* KMRN Acknowledge Timeouts register */

  #define IGP3_VR_CTRL \
-        PHY_REG(776, 18)	/* Voltage regulator control register */
+	PHY_REG(776, 18)	/* Voltage regulator control register */
  #define IGP3_VR_CTRL_MODE_SHUT       0x0200	/* Enter powerdown, 
shutdown VRs */
  #define IGP3_VR_CTRL_MODE_MASK       0x0300	/* Shutdown VR Mask */

  #define IGP3_CAPABILITY \
-        PHY_REG(776, 19)	/* IGP3 Capability Register */
+	PHY_REG(776, 19)	/* IGP3 Capability Register */

  /* Capabilities for SKU Control  */
  #define IGP3_CAP_INITIATE_TEAM       0x0001	/* Able to initiate a team */
-- 
1.9.1


 From acdfc51648a79bb73e0afa03b9b3001dce6731ec Mon Sep 17 00:00:00 2001
From: Janusz Wolak <januszvdm@gmail.com>
Date: Sun, 11 Oct 2015 16:37:58 +0200
Subject: [PATCH 5/6] Remove checkpatch errors, warnings, ckecks.

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
  drivers/net/ethernet/intel/e1000/e1000_param.c | 114 
++++++++++++++++++-------
  1 file changed, 82 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c 
b/drivers/net/ethernet/intel/e1000/e1000_param.c
index c9cde35..9ec730e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_param.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
@@ -1,5 +1,5 @@
 
/*******************************************************************************
-
+*
    Intel PRO/1000 Linux driver
    Copyright(c) 1999 - 2006 Intel Corporation.

@@ -45,10 +45,10 @@

  #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
  #define E1000_PARAM(X, desc) \
-	static int X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
+	static int X[E1000_MAX_NIC + 1] = E1000_PARAM_INIT; \
  	static unsigned int num_##X; \
  	module_param_array_named(X, X, int, &num_##X, 0); \
-	MODULE_PARM_DESC(X, desc);
+	MODULE_PARM_DESC(X, desc)

  /* Transmit Descriptor Count
   *
@@ -200,6 +200,7 @@ struct e1000_option {
  		} r;
  		struct { /* list_option info */
  			int nr;
+
  			const struct e1000_opt_list { int i; char *str; } *p;
  		} l;
  	} arg;
@@ -250,7 +251,7 @@ static int e1000_validate_option(unsigned int *value,
  	}

  	e_dev_info("Invalid %s value specified (%i) %s\n",
-	       opt->name, *value, opt->err);
+		   opt->name, *value, opt->err);
  	*value = opt->def;
  	return -1;
  }
@@ -291,7 +292,8 @@ void e1000_check_options(struct e1000_adapter *adapter)
  			.arg  = { .r = {
  				.min = E1000_MIN_TXD,
  				.max = mac_type < e1000_82544 ? E1000_MAX_TXD : E1000_MAX_82544_TXD
-				}}
+				       }
+				}
  		};

  		if (num_TxDescriptors > bd) {
@@ -320,7 +322,8 @@ void e1000_check_options(struct e1000_adapter *adapter)
  				.min = E1000_MIN_RXD,
  				.max = mac_type < e1000_82544 ? E1000_MAX_RXD :
  				       E1000_MAX_82544_RXD
-			}}
+				       }
+				}
  		};

  		if (num_RxDescriptors > bd) {
@@ -344,6 +347,7 @@ void e1000_check_options(struct e1000_adapter *adapter)

  		if (num_XsumRX > bd) {
  			unsigned int rx_csum = XsumRX[bd];
+
  			e1000_validate_option(&rx_csum, &opt, adapter);
  			adapter->rx_csum = rx_csum;
  		} else {
@@ -366,15 +370,20 @@ void e1000_check_options(struct e1000_adapter 
*adapter)
  			.err  = "reading default settings from EEPROM",
  			.def  = E1000_FC_DEFAULT,
  			.arg  = { .l = { .nr = ARRAY_SIZE(fc_list),
-					 .p = fc_list }}
+					 .p = fc_list
+				       }
+				}
  		};

  		if (num_FlowControl > bd) {
  			unsigned int fc = FlowControl[bd];
+
  			e1000_validate_option(&fc, &opt, adapter);
-			adapter->hw.fc = adapter->hw.original_fc = fc;
+			adapter->hw.fc = fc;
+			adapter->hw.original_fc = fc;
  		} else {
-			adapter->hw.fc = adapter->hw.original_fc = opt.def;
+			adapter->hw.fc = opt.def;
+			adapter->hw.original_fc = opt.def;
  		}
  	}
  	{ /* Transmit Interrupt Delay */
@@ -384,13 +393,15 @@ void e1000_check_options(struct e1000_adapter 
*adapter)
  			.err  = "using default of " __MODULE_STRING(DEFAULT_TIDV),
  			.def  = DEFAULT_TIDV,
  			.arg  = { .r = { .min = MIN_TXDELAY,
-					 .max = MAX_TXDELAY }}
+					 .max = MAX_TXDELAY
+				       }
+				}
  		};

  		if (num_TxIntDelay > bd) {
  			adapter->tx_int_delay = TxIntDelay[bd];
  			e1000_validate_option(&adapter->tx_int_delay, &opt,
-			                      adapter);
+					      adapter);
  		} else {
  			adapter->tx_int_delay = opt.def;
  		}
@@ -402,7 +413,9 @@ void e1000_check_options(struct e1000_adapter *adapter)
  			.err  = "using default of " __MODULE_STRING(DEFAULT_TADV),
  			.def  = DEFAULT_TADV,
  			.arg  = { .r = { .min = MIN_TXABSDELAY,
-					 .max = MAX_TXABSDELAY }}
+					 .max = MAX_TXABSDELAY
+				       }
+				}
  		};

  		if (num_TxAbsIntDelay > bd) {
@@ -420,7 +433,9 @@ void e1000_check_options(struct e1000_adapter *adapter)
  			.err  = "using default of " __MODULE_STRING(DEFAULT_RDTR),
  			.def  = DEFAULT_RDTR,
  			.arg  = { .r = { .min = MIN_RXDELAY,
-					 .max = MAX_RXDELAY }}
+					 .max = MAX_RXDELAY
+				       }
+				}
  		};

  		if (num_RxIntDelay > bd) {
@@ -438,7 +453,9 @@ void e1000_check_options(struct e1000_adapter *adapter)
  			.err  = "using default of " __MODULE_STRING(DEFAULT_RADV),
  			.def  = DEFAULT_RADV,
  			.arg  = { .r = { .min = MIN_RXABSDELAY,
-					 .max = MAX_RXABSDELAY }}
+					 .max = MAX_RXABSDELAY
+				       }
+				}
  		};

  		if (num_RxAbsIntDelay > bd) {
@@ -456,7 +473,9 @@ void e1000_check_options(struct e1000_adapter *adapter)
  			.err  = "using default of " __MODULE_STRING(DEFAULT_ITR),
  			.def  = DEFAULT_ITR,
  			.arg  = { .r = { .min = MIN_ITR,
-					 .max = MAX_ITR }}
+					 .max = MAX_ITR
+				       }
+				}
  		};

  		if (num_InterruptThrottleRate > bd) {
@@ -508,6 +527,7 @@ void e1000_check_options(struct e1000_adapter *adapter)

  		if (num_SmartPowerDownEnable > bd) {
  			unsigned int spd = SmartPowerDownEnable[bd];
+
  			e1000_validate_option(&spd, &opt, adapter);
  			adapter->smart_power_down = spd;
  		} else {
@@ -537,6 +557,7 @@ void e1000_check_options(struct e1000_adapter *adapter)
  static void e1000_check_fiber_options(struct e1000_adapter *adapter)
  {
  	int bd = adapter->bd_number;
+
  	if (num_Speed > bd) {
  		e_dev_info("Speed not valid for fiber adapters, parameter "
  			   "ignored\n");
@@ -570,7 +591,8 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)
  			{          0, "" },
  			{   SPEED_10, "" },
  			{  SPEED_100, "" },
-			{ SPEED_1000, "" }};
+			{ SPEED_1000, "" }
+								  };

  		opt = (struct e1000_option) {
  			.type = list_option,
@@ -578,7 +600,9 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)
  			.err  = "parameter ignored",
  			.def  = 0,
  			.arg  = { .l = { .nr = ARRAY_SIZE(speed_list),
-					 .p = speed_list }}
+					 .p = speed_list
+				       }
+				}
  		};

  		if (num_Speed > bd) {
@@ -592,7 +616,8 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)
  		static const struct e1000_opt_list dplx_list[] = {
  			{           0, "" },
  			{ HALF_DUPLEX, "" },
-			{ FULL_DUPLEX, "" }};
+			{ FULL_DUPLEX, "" }
+								 };

  		opt = (struct e1000_option) {
  			.type = list_option,
@@ -600,7 +625,9 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)
  			.err  = "parameter ignored",
  			.def  = 0,
  			.arg  = { .l = { .nr = ARRAY_SIZE(dplx_list),
-					 .p = dplx_list }}
+					 .p = dplx_list
+				       }
+				}
  		};

  		if (num_Duplex > bd) {
@@ -648,7 +675,8 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)
  			 { 0x2c, AA "1000/FD, 100/FD, 100/HD" },
  			 { 0x2d, AA "1000/FD, 100/FD, 100/HD, 10/HD" },
  			 { 0x2e, AA "1000/FD, 100/FD, 100/HD, 10/FD" },
-			 { 0x2f, AA "1000/FD, 100/FD, 100/HD, 10/FD, 10/HD" }};
+			 { 0x2f, AA "1000/FD, 100/FD, 100/HD, 10/FD, 10/HD" }
+			};

  		opt = (struct e1000_option) {
  			.type = list_option,
@@ -656,7 +684,9 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)
  			.err  = "parameter ignored",
  			.def  = AUTONEG_ADV_DEFAULT,
  			.arg  = { .l = { .nr = ARRAY_SIZE(an_list),
-					 .p = an_list }}
+					 .p = an_list
+				       }
+				}
  		};

  		if (num_AutoNeg > bd) {
@@ -670,7 +700,9 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)

  	switch (speed + dplx) {
  	case 0:
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
  		if ((num_Speed > bd) && (speed != 0 || dplx != 0))
  			e_dev_info("Speed and duplex autonegotiation "
  				   "enabled\n");
@@ -678,14 +710,18 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)
  	case HALF_DUPLEX:
  		e_dev_info("Half Duplex specified without Speed\n");
  		e_dev_info("Using Autonegotiation at Half Duplex only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
  		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
  						 ADVERTISE_100_HALF;
  		break;
  	case FULL_DUPLEX:
  		e_dev_info("Full Duplex specified without Speed\n");
  		e_dev_info("Using Autonegotiation at Full Duplex only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
  		adapter->hw.autoneg_advertised = ADVERTISE_10_FULL |
  						 ADVERTISE_100_FULL |
  						 ADVERTISE_1000_FULL;
@@ -693,38 +729,50 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)
  	case SPEED_10:
  		e_dev_info("10 Mbps Speed specified without Duplex\n");
  		e_dev_info("Using Autonegotiation at 10 Mbps only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
  		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
  						 ADVERTISE_10_FULL;
  		break;
  	case SPEED_10 + HALF_DUPLEX:
  		e_dev_info("Forcing to 10 Mbps Half Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
+		adapter->hw.autoneg = 0;
+		adapter->fc_autoneg = 0;
+
  		adapter->hw.forced_speed_duplex = e1000_10_half;
  		adapter->hw.autoneg_advertised = 0;
  		break;
  	case SPEED_10 + FULL_DUPLEX:
  		e_dev_info("Forcing to 10 Mbps Full Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
+		adapter->hw.autoneg = 0;
+		adapter->fc_autoneg = 0;
+
  		adapter->hw.forced_speed_duplex = e1000_10_full;
  		adapter->hw.autoneg_advertised = 0;
  		break;
  	case SPEED_100:
  		e_dev_info("100 Mbps Speed specified without Duplex\n");
  		e_dev_info("Using Autonegotiation at 100 Mbps only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
  		adapter->hw.autoneg_advertised = ADVERTISE_100_HALF |
  						 ADVERTISE_100_FULL;
  		break;
  	case SPEED_100 + HALF_DUPLEX:
  		e_dev_info("Forcing to 100 Mbps Half Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
+		adapter->hw.autoneg = 0;
+		adapter->fc_autoneg = 0;
+
  		adapter->hw.forced_speed_duplex = e1000_100_half;
  		adapter->hw.autoneg_advertised = 0;
  		break;
  	case SPEED_100 + FULL_DUPLEX:
  		e_dev_info("Forcing to 100 Mbps Full Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
+		adapter->hw.autoneg = 0;
+		adapter->fc_autoneg = 0;
+
  		adapter->hw.forced_speed_duplex = e1000_100_full;
  		adapter->hw.autoneg_advertised = 0;
  		break;
@@ -738,7 +786,9 @@ static void e1000_check_copper_options(struct 
e1000_adapter *adapter)
  full_duplex_only:
  		e_dev_info("Using Autonegotiation at 1000 Mbps Full Duplex "
  			   "only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		adapter->hw.autoneg = 1;
+		adapter->fc_autoneg = 1;
+
  		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
  		break;
  	default:
@@ -746,7 +796,7 @@ full_duplex_only:
  	}

  	/* Speed, AutoNeg and MDI/MDI-X must all play nice */
-	if (e1000_validate_mdi_setting(&(adapter->hw)) < 0) {
+	if (e1000_validate_mdi_setting(&adapter->hw) < 0) {
  		e_dev_info("Speed, AutoNeg and MDI-X specs are incompatible. "
  			   "Setting MDI-X to a compatible value.\n");
  	}
-- 
1.9.1


 From a80d62b8f2181d9bbada6646cd641fe084ebe225 Mon Sep 17 00:00:00 2001
From: Janusz Wolak <januszvdm@gmail.com>
Date: Sun, 11 Oct 2015 17:08:54 +0200
Subject: [PATCH 6/6] Remove checkpatch errors, warnings, ckecks.

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
  drivers/net/ethernet/intel/e1000/e1000_osdep.h | 49 
+++++++++++++-------------
  1 file changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_osdep.h 
b/drivers/net/ethernet/intel/e1000/e1000_osdep.h
index 33e7c45a..aeb3b95 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_osdep.h
+++ b/drivers/net/ethernet/intel/e1000/e1000_osdep.h
@@ -1,5 +1,5 @@
 
/*******************************************************************************
-
+*
    Intel PRO/1000 Linux driver
    Copyright(c) 1999 - 2006 Intel Corporation.

@@ -26,7 +26,6 @@

 
*******************************************************************************/

-
  /* glue for the OS independent part of e1000
   * includes register access macros
   */
@@ -34,7 +33,7 @@
  #ifndef _E1000_OSDEP_H_
  #define _E1000_OSDEP_H_

-#include <asm/io.h>
+#include <linux/io.h>

  #define CONFIG_RAM_BASE         0x60000
  #define GBE_CONFIG_OFFSET       0x0
@@ -60,50 +59,50 @@
  					 ? E1000_##reg : E1000_82542_##reg))))

  #define E1000_WRITE_REG_ARRAY(a, reg, offset, value) ( \
-    writel((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : 
E1000_82542_##reg) + \
-        ((offset) << 2))))
+			      writel((value), ((a)->hw_addr + \
+	(((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
+	((offset) << 2))))

  #define E1000_READ_REG_ARRAY(a, reg, offset) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : 
E1000_82542_##reg) + \
-        ((offset) << 2)))
+			     readl((a)->hw_addr + \
+	(((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
+	((offset) << 2)))

  #define E1000_READ_REG_ARRAY_DWORD E1000_READ_REG_ARRAY
  #define E1000_WRITE_REG_ARRAY_DWORD E1000_WRITE_REG_ARRAY

  #define E1000_WRITE_REG_ARRAY_WORD(a, reg, offset, value) ( \
-    writew((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : 
E1000_82542_##reg) + \
-        ((offset) << 1))))
+				   writew((value), ((a)->hw_addr + \
+	(((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
+	((offset) << 1))))

  #define E1000_READ_REG_ARRAY_WORD(a, reg, offset) ( \
-    readw((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : 
E1000_82542_##reg) + \
-        ((offset) << 1)))
+				  readw((a)->hw_addr + \
+	(((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
+	((offset) << 1)))

  #define E1000_WRITE_REG_ARRAY_BYTE(a, reg, offset, value) ( \
-    writeb((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : 
E1000_82542_##reg) + \
-        (offset))))
+				   writeb((value), ((a)->hw_addr + \
+	(((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
+	(offset))))

  #define E1000_READ_REG_ARRAY_BYTE(a, reg, offset) ( \
-    readb((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : 
E1000_82542_##reg) + \
-        (offset)))
+				  readb((a)->hw_addr + \
+	(((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
+	(offset)))

  #define E1000_WRITE_FLUSH() er32(STATUS)

  #define E1000_WRITE_ICH_FLASH_REG(a, reg, value) ( \
-    writel((value), ((a)->flash_address + reg)))
+				  writel((value), ((a)->flash_address + reg)))

  #define E1000_READ_ICH_FLASH_REG(a, reg) ( \
-    readl((a)->flash_address + reg))
+				 readl((a)->flash_address + reg))

  #define E1000_WRITE_ICH_FLASH_REG16(a, reg, value) ( \
-    writew((value), ((a)->flash_address + reg)))
+				    writew((value), ((a)->flash_address + reg)))

  #define E1000_READ_ICH_FLASH_REG16(a, reg) ( \
-    readw((a)->flash_address + reg))
+				   readw((a)->flash_address + reg))

  #endif /* _E1000_OSDEP_H_ */
-- 
1.9.1
