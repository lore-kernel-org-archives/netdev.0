From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.4 16/16] e1000: Driver version, white
 space, comments, deviceid
Date: Thu, 28 Apr 2005 20:18:13 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504282006570.30085-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Driver version, white space, comments, device id & other

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c
--- net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c	2005-04-12 23:00:55.000000000 -0700
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -69,6 +69,7 @@ static const struct e1000_stats e1000_gs
 	{ "rx_crc_errors", E1000_STAT(net_stats.rx_crc_errors) },
 	{ "rx_frame_errors", E1000_STAT(net_stats.rx_frame_errors) },
 	{ "rx_fifo_errors", E1000_STAT(net_stats.rx_fifo_errors) },
+	{ "rx_no_buffer_count", E1000_STAT(stats.rnbc) },
 	{ "rx_missed_errors", E1000_STAT(net_stats.rx_missed_errors) },
 	{ "tx_aborted_errors", E1000_STAT(net_stats.tx_aborted_errors) },
 	{ "tx_carrier_errors", E1000_STAT(net_stats.tx_carrier_errors) },
@@ -593,7 +594,7 @@ e1000_set_ringparam(struct net_device *n
 	tx_old = adapter->tx_ring;
 	rx_old = adapter->rx_ring;
 
-	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending)) 
+	if((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
 	if(netif_running(adapter->netdev))
@@ -784,8 +785,8 @@ e1000_intr_test(struct e1000_adapter *ad
 	/* Hook up test interrupt handler just for this test */
  	if(!request_irq(irq, &e1000_test_intr, 0, netdev->name, netdev)) {
  		shared_int = FALSE;
- 	} else if(request_irq(irq, &e1000_test_intr, SA_SHIRQ, 
-			netdev->name, netdev)){
+ 	} else if(request_irq(irq, &e1000_test_intr, SA_SHIRQ,
+			      netdev->name, netdev)){
 		*data = 1;
 		return -1;
 	}
@@ -842,10 +843,8 @@ e1000_intr_test(struct e1000_adapter *ad
 			 * test failed.
 			 */
 			adapter->test_icr = 0;
-			E1000_WRITE_REG(&adapter->hw, IMC, 
-					(~mask & 0x00007FFF));
-			E1000_WRITE_REG(&adapter->hw, ICS, 
-					(~mask & 0x00007FFF));
+			E1000_WRITE_REG(&adapter->hw, IMC, ~mask & 0x00007FFF);
+			E1000_WRITE_REG(&adapter->hw, ICS, ~mask & 0x00007FFF);
 			msec_delay(10);
 
 			if(adapter->test_icr) {
@@ -1386,13 +1385,12 @@ static int
 e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
 {
 	*data = 0;
-
 	if (adapter->hw.media_type == e1000_media_type_internal_serdes) {
 		int i = 0;
 		adapter->hw.serdes_link_down = TRUE;
 
-		/* on some blade server designs link establishment */
-		/* could take as long as 2-3 minutes.              */
+		/* On some blade server designs, link establishment
+		 * could take as long as 2-3 minutes */
 		do {
 			e1000_check_for_link(&adapter->hw);
 			if (adapter->hw.serdes_link_down == FALSE)
@@ -1400,7 +1373,7 @@ e1000_link_test(struct e1000_adapter *ad
 			msec_delay(20);
 		} while (i++ < 3750);
 
-		*data = 1; 
+		*data = 1;
 	} else {
 		e1000_check_for_link(&adapter->hw);
 		if(adapter->hw.autoneg)  /* if auto_neg is set wait for it */
diff -up net-drivers-2.4/drivers/net/e1000/e1000.h net-drivers-2.4/drivers/net/e1000.new/e1000.h
--- net-drivers-2.4/drivers/net/e1000/e1000.h	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000.h	2005-04-12 23:00:55.000000000 -0700
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -141,9 +138,9 @@ struct e1000_adapter;
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define E1000_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
-#define AUTO_ALL_MODES       0
-#define E1000_EEPROM_82544_APM 0x0004
-#define E1000_EEPROM_APME    0x0400
+#define AUTO_ALL_MODES            0
+#define E1000_EEPROM_82544_APM    0x0400
+#define E1000_EEPROM_APME         0x0400
 
 #ifndef E1000_MASTER_SLAVE
 /* Switch to override PHY master/slave setting */
diff -up net-drivers-2.4/drivers/net/e1000/e1000_hw.c net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c
--- net-drivers-2.4/drivers/net/e1000/e1000_hw.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c	2005-04-12 23:00:55.000000000 -0700
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -144,7 +144,6 @@ e1000_phy_init_script(struct e1000_hw *h
 
     DEBUGFUNC("e1000_phy_init_script");
 
-
     if(hw->phy_init_script) {
         msec_delay(20);
 
diff -up net-drivers-2.4/drivers/net/e1000/e1000_hw.h net-drivers-2.4/drivers/net/e1000.new/e1000_hw.h
--- net-drivers-2.4/drivers/net/e1000/e1000_hw.h	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_hw.h	2005-04-12 23:00:55.000000000 -0700
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2005-04-12 23:00:55.000000000 -0700
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -29,33 +29,9 @@
 #include "e1000.h"
 
 /* Change Log
- * 5.3.12	6/7/04
- * - kcompat NETIF_MSG for older kernels (2.4.9) <sean.p.mcdermott@intel.com>
- * - if_mii support and associated kcompat for older kernels
- * - More errlogging support from Jon Mason <jonmason@us.ibm.com>
- * - Fix TSO issues on PPC64 machines -- Jon Mason <jonmason@us.ibm.com>
- * 5.7.1	12/16/04
- * - Resurrect 82547EI/GI related fix in e1000_intr to avoid deadlocks. This
- *   fix was removed as it caused system instability. The suspected cause of 
- *   this is the called to e1000_irq_disable in e1000_intr. Inlined the 
- *   required piece of e1000_irq_disable into e1000_intr.
- * 5.7.0	12/10/04
- * - include fix to the condition that determines when to quit NAPI - Robert Olsson
- * - use netif_poll_{disable/enable} to synchronize between NAPI and i/f up/down
- * 5.6.5 	11/01/04
- * - Enabling NETIF_F_SG without checksum offload is illegal - 
-     John Mason <jdmason@us.ibm.com>
- * 5.6.3        10/26/04
- * - Remove redundant initialization - Jamal Hadi
- * - Reset buffer_info->dma in tx resource cleanup logic
- * 5.6.2	10/12/04
- * - Avoid filling tx_ring completely - shemminger@osdl.org
- * - Replace schedule_timeout() with msleep()/msleep_interruptible() -
- *   nacc@us.ibm.com
- * - Sparse cleanup - shemminger@osdl.org
- * - Fix tx resource cleanup logic
- * - LLTX support - ak@suse.de and hadi@cyberus.ca
- * - {set, get}_wol is now symmetric for 82545EM adapters
+ * 6.0.44+	2/15/05
+ *   o applied Anton's patch to resolve tx hang in hardware
+ *   o Applied Andrew Mortons patch - e1000 stops working after resume
  */
 
 char e1000_driver_name[] = "e1000";
@@ -65,8 +110,8 @@ char e1000_driver_string[] = "Intel(R) P
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.7.6-k1"DRIVERNAPI;
-char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
+char e1000_driver_version[] = "6.0.54-k1"DRIVERNAPI;
+char e1000_copyright[] = "Copyright (c) 1999-2005 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
  *
@@ -95,6 +71,7 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x1017),
 	INTEL_E1000_ETHERNET_DEVICE(0x1018),
 	INTEL_E1000_ETHERNET_DEVICE(0x1019),
+	INTEL_E1000_ETHERNET_DEVICE(0x101A),
 	INTEL_E1000_ETHERNET_DEVICE(0x101D),
 	INTEL_E1000_ETHERNET_DEVICE(0x101E),
 	INTEL_E1000_ETHERNET_DEVICE(0x1026),
@@ -109,6 +86,9 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x107B),
 	INTEL_E1000_ETHERNET_DEVICE(0x107C),
 	INTEL_E1000_ETHERNET_DEVICE(0x108A),
+	INTEL_E1000_ETHERNET_DEVICE(0x108B),
+	INTEL_E1000_ETHERNET_DEVICE(0x108C),
+	INTEL_E1000_ETHERNET_DEVICE(0x1099),
 	/* required last entry */
 	{0,}
 };
@@ -347,8 +351,11 @@ e1000_up(struct e1000_adapter *adapter)
 #endif
 	if((err = request_irq(adapter->pdev->irq, &e1000_intr,
 		              SA_SHIRQ | SA_SAMPLE_RANDOM,
-		              netdev->name, netdev)))
+		              netdev->name, netdev))) {
+		DPRINTK(PROBE, ERR,
+		    "Unable to allocate interrupt Error: %d\n", err);
 		return err;
+	}
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
 
@@ -630,7 +613,7 @@ e1000_probe(struct pci_dev *pdev,
 
 	/* copy the MAC address out of the EEPROM */
 
-	if (e1000_read_mac_addr(&adapter->hw))
+	if(e1000_read_mac_addr(&adapter->hw))
 		DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 
@@ -950,12 +933,10 @@ e1000_check_64k_bound(struct e1000_adapt
 	unsigned long begin = (unsigned long) start;
 	unsigned long end = begin + len;
 
-	/* first rev 82545 and 82546 need to not allow any memory
-	 * write location to cross a 64k boundary due to errata 23 */
+	/* First rev 82545 and 82546 need to not allow any memory
+	 * write location to cross 64k boundary due to errata 23 */
 	if (adapter->hw.mac_type == e1000_82545 ||
-	    adapter->hw.mac_type == e1000_82546 ) {
-
-		/* check buffer doesn't cross 64kB */
+	    adapter->hw.mac_type == e1000_82546) {
 		return ((begin ^ (end - 1)) >> 16) != 0 ? FALSE : TRUE;
 	}
 
@@ -979,8 +960,8 @@ e1000_setup_tx_resources(struct e1000_ad
 	size = sizeof(struct e1000_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
 	if(!txdr->buffer_info) {
-		DPRINTK(PROBE, ERR, 
-		"Unable to Allocate Memory for the Transmit descriptor ring\n");
+		DPRINTK(PROBE, ERR,
+		"Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -993,22 +925,22 @@ e1000_setup_tx_resources(struct e1000_ad
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
 setup_tx_desc_die:
-		DPRINTK(PROBE, ERR, 
-		"Unable to Allocate Memory for the Transmit descriptor ring\n");
 		vfree(txdr->buffer_info);
+		DPRINTK(PROBE, ERR,
+		"Unable to allocate memory for the transmit descriptor ring\n");
 		return -ENOMEM;
 	}
 
-	/* fix for errata 23, cant cross 64kB boundary */
+	/* Fix for errata 23, can't cross 64kB boundary */
 	if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
 		void *olddesc = txdr->desc;
 		dma_addr_t olddma = txdr->dma;
-		DPRINTK(TX_ERR,ERR,"txdr align check failed: %u bytes at %p\n",
-		        txdr->size, txdr->desc);
-		/* try again, without freeing the previous */
+		DPRINTK(TX_ERR, ERR, "txdr align check failed: %u bytes "
+				     "at %p\n", txdr->size, txdr->desc);
+		/* Try again, without freeing the previous */
 		txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
-		/* failed allocation, critial failure */
 		if(!txdr->desc) {
+		/* Failed allocation, critical failure */
 			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
 			goto setup_tx_desc_die;
 		}
@@ -1015,16 +925,16 @@ 
 
 		if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
 			/* give up */
-			pci_free_consistent(pdev, txdr->size,
-			     txdr->desc, txdr->dma);
+			pci_free_consistent(pdev, txdr->size, txdr->desc,
+					    txdr->dma);
 			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
 			DPRINTK(PROBE, ERR,
-			 "Unable to Allocate aligned Memory for the Transmit"
-		         " descriptor ring\n");
+				"Unable to allocate aligned memory "
+				"for the transmit descriptor ring\n");
 			vfree(txdr->buffer_info);
 			return -ENOMEM;
 		} else {
-			/* free old, move on with the new one since its okay */
+			/* Free old allocation, new allocation was successful */
 			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
 		}
 	}
@@ -1131,8 +1058,8 @@ e1000_setup_rx_resources(struct e1000_ad
 	size = sizeof(struct e1000_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
 	if(!rxdr->buffer_info) {
-		DPRINTK(PROBE, ERR, 
-		"Unable to Allocate Memory for the Recieve descriptor ring\n");
+		DPRINTK(PROBE, ERR,
+		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -1172,25 +1058,24 @@ 
 
 	if(!rxdr->desc) {
 setup_rx_desc_die:
-		DPRINTK(PROBE, ERR, 
-		"Unble to Allocate Memory for the Recieve descriptor ring\n");
 		vfree(rxdr->buffer_info);
 		kfree(rxdr->ps_page);
 		kfree(rxdr->ps_page_dma);
+		DPRINTK(PROBE, ERR,
+		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
 
-	/* fix for errata 23, cant cross 64kB boundary */
+	/* Fix for errata 23, can't cross 64kB boundary */
 	if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
 		void *olddesc = rxdr->desc;
 		dma_addr_t olddma = rxdr->dma;
-		DPRINTK(RX_ERR,ERR,
-			"rxdr align check failed: %u bytes at %p\n",
-			rxdr->size, rxdr->desc);
-		/* try again, without freeing the previous */
+		DPRINTK(RX_ERR, ERR, "rxdr align check failed: %u bytes "
+				     "at %p\n", rxdr->size, rxdr->desc);
+		/* Try again, without freeing the previous */
 		rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
-		/* failed allocation, critial failure */
 		if(!rxdr->desc) {
+		/* Failed allocation, critical failure */
 			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
 			goto setup_rx_desc_die;
 		}
@@ -1197,18 +1058,18 @@ 
 
 		if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
 			/* give up */
-			pci_free_consistent(pdev, rxdr->size,
-			     rxdr->desc, rxdr->dma);
+			pci_free_consistent(pdev, rxdr->size, rxdr->desc,
+					    rxdr->dma);
 			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
-			DPRINTK(PROBE, ERR, 
-				"Unable to Allocate aligned Memory for the"
-				" Receive descriptor ring\n");
+			DPRINTK(PROBE, ERR,
+				"Unable to allocate aligned memory "
+				"for the receive descriptor ring\n");
 			vfree(rxdr->buffer_info);
 			kfree(rxdr->ps_page);
 			kfree(rxdr->ps_page_dma);
 			return -ENOMEM;
 		} else {
-			/* free old, move on with the new one since its okay */
+			/* Free old allocation, new allocation was successful */
 			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
 		}
 	}
@@ -1221,7 +1123,7 @@ setup_rx_desc_die:
 }
 
 /**
- * e1000_setup_rctl - configure the receive control register
+ * e1000_setup_rctl - configure the receive control registers
  * @adapter: Board private structure
  **/
 
@@ -1413,13 +1393,11 @@ static inline void
 e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
 			struct e1000_buffer *buffer_info)
 {
-	struct pci_dev *pdev = adapter->pdev;
-
 	if(buffer_info->dma) {
-		pci_unmap_page(pdev,
-			       buffer_info->dma,
-			       buffer_info->length,
-			       PCI_DMA_TODEVICE);
+		pci_unmap_page(adapter->pdev,
+				buffer_info->dma,
+				buffer_info->length,
+				PCI_DMA_TODEVICE);
 		buffer_info->dma = 0;
 	}
 	if(buffer_info->skb) {
@@ -1444,7 +1422,7 @@ e1000_clean_tx_ring(struct e1000_adapter
 	/* Free all the Tx ring sk_buffs */
 
 	if (likely(adapter->previous_buffer_info.skb != NULL)) {
-		e1000_unmap_and_free_tx_resource(adapter, 
+		e1000_unmap_and_free_tx_resource(adapter,
 				&adapter->previous_buffer_info);
 	}
 
@@ -1646,15 +1624,15 @@ e1000_set_multi(struct net_device *netde
 	struct e1000_adapter *adapter = netdev->priv;
 	struct e1000_hw *hw = &adapter->hw;
 	struct dev_mc_list *mc_ptr;
+	unsigned long flags;
 	uint32_t rctl;
 	uint32_t hash_value;
 	int i;
-	unsigned long flags;
-
-	/* Check for Promiscuous and All Multicast modes */
 
 	spin_lock_irqsave(&adapter->tx_lock, flags);
 
+	/* Check for Promiscuous and All Multicast modes */
+
 	rctl = E1000_READ_REG(hw, RCTL);
 
 	if(netdev->flags & IFF_PROMISC) {
@@ -1854,7 +1832,7 @@ e1000_watchdog(unsigned long data)
 	/* Cause software interrupt to ensure rx ring is cleaned */
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_RXDMT0);
 
-	/* Force detection of hung controller every watchdog period*/
+	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung = TRUE;
 
 	/* Reset the timer */
@@ -2240,7 +2218,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	if((mss) || (skb->ip_summed == CHECKSUM_HW))
 		count++;
-	count++;	/* for sentinel desc */
+	count++;
 #else
 	if(skb->ip_summed == CHECKSUM_HW)
 		count++;
@@ -2615,7 +2315,7 @@ e1000_intr(int irq, void *data, struct p
 	*/
 	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2){
 		atomic_inc(&adapter->irq_sem);
-		E1000_WRITE_REG(&adapter->hw, IMC, ~0);
+		E1000_WRITE_REG(hw, IMC, ~0);
 	}
 
 	for(i = 0; i < E1000_MAX_INTR; i++)
@@ -2643,7 +2355,7 @@ e1000_clean(struct net_device *netdev, i
 	int work_to_do = min(*budget, netdev->quota);
 	int tx_cleaned;
 	int work_done = 0;
-	
+
 	tx_cleaned = e1000_clean_tx_irq(adapter);
 	adapter->clean_rx(adapter, &work_done, work_to_do);
 
@@ -2733,9 +2443,9 @@ e1000_clean_tx_irq(struct e1000_adapter 
 		netif_wake_queue(netdev);
 
 	spin_unlock(&adapter->tx_lock);
- 
 	if(adapter->detect_tx_hung) {
-		/* detect a transmit hang in hardware, this serializes the
+
+		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = FALSE;
 		if (tx_ring->buffer_info[i].dma &&
@@ -2880,7 +2858,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		if(unlikely(!(rx_desc->status & E1000_RXD_STAT_EOP))) {
 			/* All receives must fit into a single buffer */
 			E1000_DBG("%s: Receive packet consumed multiple"
-					" buffers\n", netdev->name);
+				  " buffers\n", netdev->name);
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -3088,32 +2619,33 @@ e1000_alloc_rx_buffers(struct e1000_adap
 	struct e1000_buffer *buffer_info;
 	struct sk_buff *skb;
 	int reserve_len = 2;
-	unsigned int i, bufsz;
+	unsigned int i;
+	unsigned int bufsz = adapter->rx_buffer_len + 2;
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while(!buffer_info->skb) {
-		bufsz = adapter->rx_buffer_len + reserve_len;
-
 		skb = dev_alloc_skb(bufsz);
+
 		if(unlikely(!skb)) {
 			/* Better luck next round */
 			break;
 		}
 
-		/* fix for errata 23, cant cross 64kB boundary */
+		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 			struct sk_buff *oldskb = skb;
-			DPRINTK(RX_ERR,ERR,
-				"skb align check failed: %u bytes at %p\n",
-				bufsz, skb->data);
-			/* try again, without freeing the previous */
+			DPRINTK(RX_ERR, ERR, "skb align check failed: %u bytes "
+					     "at %p\n", bufsz, skb->data);
+			/* Try again, without freeing the previous */
 			skb = dev_alloc_skb(bufsz);
+			/* Failed allocation, critical failure */
 			if (!skb) {
 				dev_kfree_skb(oldskb);
 				break;
 			}
+
 			if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 				/* give up */
 				dev_kfree_skb(skb);
@@ -3120,11 +2619,10 @@ 
 				dev_kfree_skb(oldskb);
 				break; /* while !buffer_info->skb */
 			} else {
-				/* move on with the new one */
+				/* Use new allocation */
 				dev_kfree_skb(oldskb);
 			}
 		}
-
 		/* Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
@@ -3140,25 +3118,23 @@ e1000_alloc_rx_buffers(struct e1000_adap
 						  adapter->rx_buffer_len,
 						  PCI_DMA_FROMDEVICE);
 
-		/* fix for errata 23, cant cross 64kB boundary */
-		if(!e1000_check_64k_bound(adapter,
-			                       (void *)(unsigned long)buffer_info->dma,
-			                       adapter->rx_buffer_len)) {
-			DPRINTK(RX_ERR,ERR,
-				"dma align check failed: %u bytes at %ld\n",
-				adapter->rx_buffer_len, (unsigned long)buffer_info->dma);
-
+		/* Fix for errata 23, can't cross 64kB boundary */
+		if (!e1000_check_64k_bound(adapter,
+					(void *)(unsigned long)buffer_info->dma,
+					adapter->rx_buffer_len)) {
+			DPRINTK(RX_ERR, ERR,
+				"dma align check failed: %u bytes at %p\n",
+				adapter->rx_buffer_len,
+				(void *)(unsigned long)buffer_info->dma);
 			dev_kfree_skb(skb);
 			buffer_info->skb = NULL;
 
-			pci_unmap_single(pdev,
-					 buffer_info->dma,
+			pci_unmap_single(pdev, buffer_info->dma,
 					 adapter->rx_buffer_len,
 					 PCI_DMA_FROMDEVICE);
 
 			break; /* while !buffer_info->skb */
 		}
-
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
 
@@ -3168,7 +3144,6 @@ e1000_alloc_rx_buffers(struct e1000_adap
 			 * applicable for weak-ordered memory model archs,
 			 * such as IA-64). */
 			wmb();
-
 			E1000_WRITE_REG(&adapter->hw, RDT, i);
 		}
 
@@ -3441,9 +3416,10 @@ void
 e1000_pci_set_mwi(struct e1000_hw *hw)
 {
 	struct e1000_adapter *adapter = hw->back;
+	int ret_val = pci_set_mwi(adapter->pdev);
 
-	int ret;
-	ret = pci_set_mwi(adapter->pdev);
+	if(ret_val)
+		DPRINTK(PROBE, ERR, "Error in setting MWI\n");
 }
 
 void
@@ -3601,8 +3577,7 @@ e1000_set_spd_dplx(struct e1000_adapter 
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		DPRINTK(PROBE, ERR, 
-			"Unsupported Speed/Duplexity configuration\n");
+		DPRINTK(PROBE, ERR, "Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -3768,7 +3743,7 @@ e1000_resume(struct pci_dev *pdev)
  * the interrupt routine is executing.
  */
 static void
-e1000_netpoll (struct net_device *netdev)
+e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev->priv;
 	disable_irq(adapter->pdev->irq);
diff -up net-drivers-2.4/drivers/net/e1000/e1000_osdep.h net-drivers-2.4/drivers/net/e1000.new/e1000_osdep.h
--- net-drivers-2.4/drivers/net/e1000/e1000_osdep.h	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_osdep.h	2005-04-12 23:00:55.000000000 -0700
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -up net-drivers-2.4/drivers/net/e1000/e1000_param.c net-drivers-2.4/drivers/net/e1000.new/e1000_param.c
--- net-drivers-2.4/drivers/net/e1000/e1000_param.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_param.c	2005-04-12 23:00:55.000000000 -0700
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -455,7 +532,6 @@ e1000_check_options(struct e1000_adapter
 				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n", 
 					opt.name);
 				break;
-			case -1:
 			default:
 				e1000_validate_option(&adapter->itr, &opt, 
 					adapter);
