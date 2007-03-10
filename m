From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 1/2] S2io: Remove unused variables
Date: 09 Mar 2007 18:28:32 -0800
Message-ID: <1173493712.5431.233.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alicia.pena@neterion.com
To: jeff@garzik.org, santosh.rastapur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39627 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993163AbXCJChu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 21:37:50 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Remove unused variables from s2io_nic structure

- Changed the memory failure printk messages to print only in debug mode

- Updated the copyright messages

(Resending; due to patch being corrupted)
 
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
---
diff -Nurp patch/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- patch/drivers/net/s2io.c	2007-03-06 03:28:39.000000000 -0800
+++ patch1/drivers/net/s2io.c	2007-03-06 03:29:18.000000000 -0800
@@ -1,6 +1,6 @@
 /************************************************************************
  * s2io.c: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
- * Copyright(c) 2002-2005 Neterion Inc.
+ * Copyright(c) 2002-2007 Neterion Inc.
 
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.
@@ -516,7 +516,7 @@ static int init_shared_mem(struct s2io_n
 		mac_control->fifos[i].list_info = kmalloc(list_holder_size,
 							  GFP_KERNEL);
 		if (!mac_control->fifos[i].list_info) {
-			DBG_PRINT(ERR_DBG,
+			DBG_PRINT(INFO_DBG,
 				  "Malloc failed for list_info\n");
 			return -ENOMEM;
 		}
@@ -542,9 +542,9 @@ static int init_shared_mem(struct s2io_n
 			tmp_v = pci_alloc_consistent(nic->pdev,
 						     PAGE_SIZE, &tmp_p);
 			if (!tmp_v) {
-				DBG_PRINT(ERR_DBG,
+				DBG_PRINT(INFO_DBG,
 					  "pci_alloc_consistent ");
-				DBG_PRINT(ERR_DBG, "failed for TxDL\n");
+				DBG_PRINT(INFO_DBG, "failed for TxDL\n");
 				return -ENOMEM;
 			}
 			/* If we got a zero DMA address(can happen on
@@ -561,9 +561,9 @@ static int init_shared_mem(struct s2io_n
 				tmp_v = pci_alloc_consistent(nic->pdev,
 						     PAGE_SIZE, &tmp_p);
 				if (!tmp_v) {
-					DBG_PRINT(ERR_DBG,
+					DBG_PRINT(INFO_DBG,
 					  "pci_alloc_consistent ");
-					DBG_PRINT(ERR_DBG, "failed for TxDL\n");
+					DBG_PRINT(INFO_DBG, "failed for TxDL\n");
 					return -ENOMEM;
 				}
 			}
@@ -2187,7 +2187,7 @@ static int fill_rxd_3buf(struct s2io_nic
 	/* skb_shinfo(skb)->frag_list will have L4 data payload */
 	skb_shinfo(skb)->frag_list = dev_alloc_skb(dev->mtu + ALIGN_SIZE);
 	if (skb_shinfo(skb)->frag_list == NULL) {
-		DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb failed\n ", dev->name);
+		DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n ", dev->name);
 		return -ENOMEM ;
 	}
 	frag_list = skb_shinfo(skb)->frag_list;
@@ -2313,8 +2313,8 @@ static int fill_rx_buffers(struct s2io_n
 		/* allocate skb */
 		skb = dev_alloc_skb(size);
 		if(!skb) {
-			DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);
-			DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");
+			DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
+			DBG_PRINT(INFO_DBG, "memory to allocate SKBs\n");
 			if (first_rxdp) {
 				wmb();
 				first_rxdp->Control_1 |= RXD_OWN_XENA;
@@ -2573,8 +2573,8 @@ static int s2io_poll(struct net_device *
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(nic, i) == -ENOMEM) {
-			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);
-			DBG_PRINT(ERR_DBG, " in Rx Poll!!\n");
+			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
+			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
 			break;
 		}
 	}
@@ -2590,8 +2590,8 @@ no_rx:
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(nic, i) == -ENOMEM) {
-			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);
-			DBG_PRINT(ERR_DBG, " in Rx Poll!!\n");
+			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
+			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
 			break;
 		}
 	}
@@ -2640,8 +2640,8 @@ static void s2io_netpoll(struct net_devi
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(nic, i) == -ENOMEM) {
-			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);
-			DBG_PRINT(ERR_DBG, " in Rx Netpoll!!\n");
+			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
+			DBG_PRINT(INFO_DBG, " in Rx Netpoll!!\n");
 			break;
 		}
 	}
@@ -3659,7 +3659,7 @@ static int s2io_enable_msi_x(struct s2io
 	nic->entries = kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry),
 			       GFP_KERNEL);
 	if (nic->entries == NULL) {
-		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
+		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
 		return -ENOMEM;
 	}
 	memset(nic->entries, 0, MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
@@ -3668,7 +3668,7 @@ static int s2io_enable_msi_x(struct s2io
 		kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry),
 				   GFP_KERNEL);
 	if (nic->s2io_entries == NULL) {
-		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
+		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
 		kfree(nic->entries);
 		return -ENOMEM;
 	}
@@ -4019,7 +4019,7 @@ static int s2io_chk_rx_buffers(struct s2
 			DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", __FUNCTION__);
 			DBG_PRINT(INTR_DBG, "PANIC levels\n");
 			if ((ret = fill_rx_buffers(sp, rng_n)) == -ENOMEM) {
-				DBG_PRINT(ERR_DBG, "Out of memory in %s",
+				DBG_PRINT(INFO_DBG, "Out of memory in %s",
 					  __FUNCTION__);
 				clear_bit(0, (&sp->tasklet_status));
 				return -1;
@@ -4029,8 +4029,8 @@ static int s2io_chk_rx_buffers(struct s2
 			tasklet_schedule(&sp->task);
 
 	} else if (fill_rx_buffers(sp, rng_n) == -ENOMEM) {
-			DBG_PRINT(ERR_DBG, "%s:Out of memory", sp->dev->name);
-			DBG_PRINT(ERR_DBG, " in Rx Intr!!\n");
+			DBG_PRINT(INFO_DBG, "%s:Out of memory", sp->dev->name);
+			DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
 	}
 	return 0;
 }
@@ -5949,12 +5949,12 @@ static void s2io_tasklet(unsigned long d
 		for (i = 0; i < config->rx_ring_num; i++) {
 			ret = fill_rx_buffers(sp, i);
 			if (ret == -ENOMEM) {
-				DBG_PRINT(ERR_DBG, "%s: Out of ",
+				DBG_PRINT(INFO_DBG, "%s: Out of ",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, "memory in tasklet\n");
 				break;
 			} else if (ret == -EFILL) {
-				DBG_PRINT(ERR_DBG,
+				DBG_PRINT(INFO_DBG,
 					  "%s: Rx Ring %d is full\n",
 					  dev->name, i);
 				break;
@@ -6065,8 +6065,8 @@ static int set_rxd_buffer_pointer(struct
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
-				DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);
-				DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");
+				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
+				DBG_PRINT(INFO_DBG, "memory to allocate SKBs\n");
 				return -ENOMEM ;
 			}
 			/* storing the mapped addr in a temp variable
@@ -6088,7 +6088,7 @@ static int set_rxd_buffer_pointer(struct
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
-				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb failed\n",
+				DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n",
 					dev->name);
 				return -ENOMEM;
 			}
@@ -6115,7 +6115,7 @@ static int set_rxd_buffer_pointer(struct
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
-				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb failed\n",
+				DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n",
 					  dev->name);
 				return -ENOMEM;
 			}
@@ -6616,7 +6616,6 @@ static int rx_osm_handler(struct ring_in
 
 	/* Updating statistics */
 	rxdp->Host_Control = 0;
-	sp->rx_pkt_count++;
 	sp->stats.rx_packets++;
 	if (sp->rxd_mode == RXD_MODE_1) {
 		int len = RXD_GET_BUFFER0_SIZE_1(rxdp->Control_2);
@@ -7252,7 +7251,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		goto register_failed;
 	}
 	s2io_vpd_read(sp);
-	DBG_PRINT(ERR_DBG, "Copyright(c) 2002-2005 Neterion Inc.\n");
+	DBG_PRINT(ERR_DBG, "Copyright(c) 2002-2007 Neterion Inc.\n");
 	DBG_PRINT(ERR_DBG, "%s: Neterion %s (rev %d)\n",dev->name,
 		  sp->product_name, get_xena_rev_id(sp->pdev));
 	DBG_PRINT(ERR_DBG, "%s: Driver version %s\n", dev->name,
diff -Nurp patch/drivers/net/s2io.h patch1/drivers/net/s2io.h
--- patch/drivers/net/s2io.h	2007-03-06 03:28:39.000000000 -0800
+++ patch1/drivers/net/s2io.h	2007-03-06 03:29:18.000000000 -0800
@@ -1,6 +1,6 @@
 /************************************************************************
  * s2io.h: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
- * Copyright(c) 2002-2005 Neterion Inc.
+ * Copyright(c) 2002-2007 Neterion Inc.
 
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.
@@ -760,7 +760,6 @@ struct s2io_nic {
 #define MAX_SUPPORTED_MULTICASTS MAX_MAC_SUPPORTED
 
 	struct mac_addr def_mac_addr[MAX_MAC_SUPPORTED];
-	struct mac_addr pre_mac_addr[MAX_MAC_SUPPORTED];
 
 	struct net_device_stats stats;
 	int high_dma_flag;
@@ -794,11 +793,6 @@ struct s2io_nic {
 	u16 all_multi_pos;
 	u16 promisc_flg;
 
-	u16 tx_pkt_count;
-	u16 rx_pkt_count;
-	u16 tx_err_count;
-	u16 rx_err_count;
-
 	/*  Id timer, used to blink NIC to physically identify NIC. */
 	struct timer_list id_timer;
 
diff -Nurp patch/drivers/net/s2io-regs.h patch1/drivers/net/s2io-regs.h
--- patch/drivers/net/s2io-regs.h	2007-03-06 03:28:40.000000000 -0800
+++ patch1/drivers/net/s2io-regs.h	2007-03-06 03:29:18.000000000 -0800
@@ -1,6 +1,6 @@
 /************************************************************************
  * regs.h: A Linux PCI-X Ethernet driver for Neterion 10GbE Server NIC
- * Copyright(c) 2002-2005 Neterion Inc.
+ * Copyright(c) 2002-2007 Neterion Inc.
 
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.



