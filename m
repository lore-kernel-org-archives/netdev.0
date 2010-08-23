From: Anton Blanchard <anton@samba.org>
Subject: [patch 16/20] ibmveth: Coding style fixes
Date: Mon, 23 Aug 2010 10:09:46 +1000
Message-ID: <20100823001239.806111429@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51866 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332Ab0HWA3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:29:34 -0400
Content-Disposition: inline; filename=veth_style
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix most of the kernel coding style issues in ibmveth.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:53:23.040010330 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 09:23:11.982966815 +1000
@@ -1,31 +1,29 @@
-/**************************************************************************/
-/*                                                                        */
-/* IBM eServer i/pSeries Virtual Ethernet Device Driver                   */
-/* Copyright (C) 2003 IBM Corp.                                           */
-/*  Originally written by Dave Larson (larson1@us.ibm.com)                */
-/*  Maintained by Santiago Leon (santil@us.ibm.com)                       */
-/*                                                                        */
-/*  This program is free software; you can redistribute it and/or modify  */
-/*  it under the terms of the GNU General Public License as published by  */
-/*  the Free Software Foundation; either version 2 of the License, or     */
-/*  (at your option) any later version.                                   */
-/*                                                                        */
-/*  This program is distributed in the hope that it will be useful,       */
-/*  but WITHOUT ANY WARRANTY; without even the implied warranty of        */
-/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         */
-/*  GNU General Public License for more details.                          */
-/*                                                                        */
-/*  You should have received a copy of the GNU General Public License     */
-/*  along with this program; if not, write to the Free Software           */
-/*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  */
-/*                                                                   USA  */
-/*                                                                        */
-/* This module contains the implementation of a virtual ethernet device   */
-/* for use with IBM i/pSeries LPAR Linux.  It utilizes the logical LAN    */
-/* option of the RS/6000 Platform Architechture to interface with virtual */
-/* ethernet NICs that are presented to the partition by the hypervisor.   */
-/*                                                                        */
-/**************************************************************************/
+/*
+ * IBM eServer i/pSeries Virtual Ethernet Device Driver
+ * Copyright (C) 2003 IBM Corp.
+ *  Originally written by Dave Larson (larson1@us.ibm.com)
+ *  Maintained by Santiago Leon (santil@us.ibm.com)
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
+ *                                                                   USA
+ *
+ * This module contains the implementation of a virtual ethernet device
+ * for use with IBM i/pSeries LPAR Linux.  It utilizes the logical LAN
+ * option of the RS/6000 Platform Architechture to interface with virtual
+ * ethernet NICs that are presented to the partition by the hypervisor.
+ */
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -58,7 +56,7 @@
 
 #ifdef DEBUG
 #define ibmveth_assert(expr) \
-  if(!(expr)) {                                   \
+  if (!(expr)) {                                   \
     printk(KERN_DEBUG "assertion failed (%s:%3.3d ua:%x): %s\n", __FILE__, __LINE__, adapter->vdev->unit_address, #expr); \
     BUG(); \
   }
@@ -74,7 +72,8 @@ static struct kobj_type ktype_veth_pool;
 
 
 static const char ibmveth_driver_name[] = "ibmveth";
-static const char ibmveth_driver_string[] = "IBM i/pSeries Virtual Ethernet Driver";
+static const char ibmveth_driver_string[] = "IBM i/pSeries Virtual Ethernet "
+					    "Driver";
 #define ibmveth_driver_version "1.03"
 
 MODULE_AUTHOR("Santiago Leon <santil@us.ibm.com>");
@@ -107,8 +106,10 @@ struct ibmveth_stat {
 struct ibmveth_stat ibmveth_stats[] = {
 	{ "replenish_task_cycles", IBMVETH_STAT_OFF(replenish_task_cycles) },
 	{ "replenish_no_mem", IBMVETH_STAT_OFF(replenish_no_mem) },
-	{ "replenish_add_buff_failure", IBMVETH_STAT_OFF(replenish_add_buff_failure) },
-	{ "replenish_add_buff_success", IBMVETH_STAT_OFF(replenish_add_buff_success) },
+	{ "replenish_add_buff_failure",
+			IBMVETH_STAT_OFF(replenish_add_buff_failure) },
+	{ "replenish_add_buff_success",
+			IBMVETH_STAT_OFF(replenish_add_buff_success) },
 	{ "rx_invalid_buffer", IBMVETH_STAT_OFF(rx_invalid_buffer) },
 	{ "rx_no_buffer", IBMVETH_STAT_OFF(rx_no_buffer) },
 	{ "tx_map_failed", IBMVETH_STAT_OFF(tx_map_failed) },
@@ -123,36 +124,39 @@ static inline u32 ibmveth_rxq_flags(stru
 
 static inline int ibmveth_rxq_toggle(struct ibmveth_adapter *adapter)
 {
-	return (ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_TOGGLE) >> IBMVETH_RXQ_TOGGLE_SHIFT;
+	return (ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_TOGGLE) >>
+			IBMVETH_RXQ_TOGGLE_SHIFT;
 }
 
 static inline int ibmveth_rxq_pending_buffer(struct ibmveth_adapter *adapter)
 {
-	return (ibmveth_rxq_toggle(adapter) == adapter->rx_queue.toggle);
+	return ibmveth_rxq_toggle(adapter) == adapter->rx_queue.toggle;
 }
 
 static inline int ibmveth_rxq_buffer_valid(struct ibmveth_adapter *adapter)
 {
-	return (ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_VALID);
+	return ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_VALID;
 }
 
 static inline int ibmveth_rxq_frame_offset(struct ibmveth_adapter *adapter)
 {
-	return (ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_OFF_MASK);
+	return ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_OFF_MASK;
 }
 
 static inline int ibmveth_rxq_frame_length(struct ibmveth_adapter *adapter)
 {
-	return (adapter->rx_queue.queue_addr[adapter->rx_queue.index].length);
+	return adapter->rx_queue.queue_addr[adapter->rx_queue.index].length;
 }
 
 static inline int ibmveth_rxq_csum_good(struct ibmveth_adapter *adapter)
 {
-	return (ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_CSUM_GOOD);
+	return ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_CSUM_GOOD;
 }
 
 /* setup the initial settings for a buffer pool */
-static void ibmveth_init_buffer_pool(struct ibmveth_buff_pool *pool, u32 pool_index, u32 pool_size, u32 buff_size, u32 pool_active)
+static void ibmveth_init_buffer_pool(struct ibmveth_buff_pool *pool,
+				     u32 pool_index, u32 pool_size,
+				     u32 buff_size, u32 pool_active)
 {
 	pool->size = pool_size;
 	pool->index = pool_index;
@@ -168,12 +172,11 @@ static int ibmveth_alloc_buffer_pool(str
 
 	pool->free_map = kmalloc(sizeof(u16) * pool->size, GFP_KERNEL);
 
-	if(!pool->free_map) {
+	if (!pool->free_map)
 		return -1;
-	}
 
 	pool->dma_addr = kmalloc(sizeof(dma_addr_t) * pool->size, GFP_KERNEL);
-	if(!pool->dma_addr) {
+	if (!pool->dma_addr) {
 		kfree(pool->free_map);
 		pool->free_map = NULL;
 		return -1;
@@ -181,7 +184,7 @@ static int ibmveth_alloc_buffer_pool(str
 
 	pool->skbuff = kcalloc(pool->size, sizeof(void *), GFP_KERNEL);
 
-	if(!pool->skbuff) {
+	if (!pool->skbuff) {
 		kfree(pool->dma_addr);
 		pool->dma_addr = NULL;
 
@@ -192,9 +195,8 @@ static int ibmveth_alloc_buffer_pool(str
 
 	memset(pool->dma_addr, 0, sizeof(dma_addr_t) * pool->size);
 
-	for(i = 0; i < pool->size; ++i) {
+	for (i = 0; i < pool->size; ++i)
 		pool->free_map[i] = i;
-	}
 
 	atomic_set(&pool->available, 0);
 	pool->producer_index = 0;
@@ -214,7 +216,8 @@ static inline void ibmveth_flush_buffer(
 /* replenish the buffers for a pool.  note that we don't need to
  * skb_reserve these since they are used for incoming...
  */
-static void ibmveth_replenish_buffer_pool(struct ibmveth_adapter *adapter, struct ibmveth_buff_pool *pool)
+static void ibmveth_replenish_buffer_pool(struct ibmveth_adapter *adapter,
+					  struct ibmveth_buff_pool *pool)
 {
 	u32 i;
 	u32 count = pool->size - atomic_read(&pool->available);
@@ -227,12 +230,12 @@ static void ibmveth_replenish_buffer_poo
 
 	mb();
 
-	for(i = 0; i < count; ++i) {
+	for (i = 0; i < count; ++i) {
 		union ibmveth_buf_desc desc;
 
 		skb = netdev_alloc_skb(adapter->netdev, pool->buff_size);
 
-		if(!skb) {
+		if (!skb) {
 			netdev_dbg(adapter->netdev,
 				   "replenish: unable to allocate skb\n");
 			adapter->replenish_no_mem++;
@@ -259,7 +262,7 @@ static void ibmveth_replenish_buffer_poo
 		pool->skbuff[index] = skb;
 
 		correlator = ((u64)pool->index << 32) | index;
-		*(u64*)skb->data = correlator;
+		*(u64 *)skb->data = correlator;
 
 		desc.fields.flags_len = IBMVETH_BUF_VALID | pool->buff_size;
 		desc.fields.address = dma_addr;
@@ -270,11 +273,12 @@ static void ibmveth_replenish_buffer_poo
 						IBMVETH_BUFF_OH);
 			ibmveth_flush_buffer(skb->data, len);
 		}
-		lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address, desc.desc);
+		lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address,
+						   desc.desc);
 
-		if (lpar_rc != H_SUCCESS)
+		if (lpar_rc != H_SUCCESS) {
 			goto failure;
-		else {
+		} else {
 			buffers_added++;
 			adapter->replenish_add_buff_success++;
 		}
@@ -317,21 +321,23 @@ static void ibmveth_replenish_task(struc
 			ibmveth_replenish_buffer_pool(adapter, pool);
 	}
 
-	adapter->rx_no_buffer = *(u64*)(((char*)adapter->buffer_list_addr) + 4096 - 8);
+	adapter->rx_no_buffer = *(u64 *)(((char*)adapter->buffer_list_addr) +
+						4096 - 8);
 }
 
 /* empty and free ana buffer pool - also used to do cleanup in error paths */
-static void ibmveth_free_buffer_pool(struct ibmveth_adapter *adapter, struct ibmveth_buff_pool *pool)
+static void ibmveth_free_buffer_pool(struct ibmveth_adapter *adapter,
+				     struct ibmveth_buff_pool *pool)
 {
 	int i;
 
 	kfree(pool->free_map);
 	pool->free_map = NULL;
 
-	if(pool->skbuff && pool->dma_addr) {
-		for(i = 0; i < pool->size; ++i) {
+	if (pool->skbuff && pool->dma_addr) {
+		for (i = 0; i < pool->size; ++i) {
 			struct sk_buff *skb = pool->skbuff[i];
-			if(skb) {
+			if (skb) {
 				dma_unmap_single(&adapter->vdev->dev,
 						 pool->dma_addr[i],
 						 pool->buff_size,
@@ -342,19 +348,20 @@ static void ibmveth_free_buffer_pool(str
 		}
 	}
 
-	if(pool->dma_addr) {
+	if (pool->dma_addr) {
 		kfree(pool->dma_addr);
 		pool->dma_addr = NULL;
 	}
 
-	if(pool->skbuff) {
+	if (pool->skbuff) {
 		kfree(pool->skbuff);
 		pool->skbuff = NULL;
 	}
 }
 
 /* remove a buffer from a pool */
-static void ibmveth_remove_buffer_from_pool(struct ibmveth_adapter *adapter, u64 correlator)
+static void ibmveth_remove_buffer_from_pool(struct ibmveth_adapter *adapter,
+					    u64 correlator)
 {
 	unsigned int pool  = correlator >> 32;
 	unsigned int index = correlator & 0xffffffffUL;
@@ -413,7 +420,7 @@ static void ibmveth_rxq_recycle_buffer(s
 	ibmveth_assert(pool < IBMVETH_NUM_BUFF_POOLS);
 	ibmveth_assert(index < adapter->rx_buff_pool[pool].size);
 
-	if(!adapter->rx_buff_pool[pool].active) {
+	if (!adapter->rx_buff_pool[pool].active) {
 		ibmveth_rxq_harvest_buffer(adapter);
 		ibmveth_free_buffer_pool(adapter, &adapter->rx_buff_pool[pool]);
 		return;
@@ -425,13 +432,13 @@ static void ibmveth_rxq_recycle_buffer(s
 
 	lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address, desc.desc);
 
-	if(lpar_rc != H_SUCCESS) {
+	if (lpar_rc != H_SUCCESS) {
 		netdev_dbg(adapter->netdev, "h_add_logical_lan_buffer failed "
 			   "during recycle rc=%ld", lpar_rc);
 		ibmveth_remove_buffer_from_pool(adapter, adapter->rx_queue.queue_addr[adapter->rx_queue.index].correlator);
 	}
 
-	if(++adapter->rx_queue.index == adapter->rx_queue.num_slots) {
+	if (++adapter->rx_queue.index == adapter->rx_queue.num_slots) {
 		adapter->rx_queue.index = 0;
 		adapter->rx_queue.toggle = !adapter->rx_queue.toggle;
 	}
@@ -441,7 +448,7 @@ static void ibmveth_rxq_harvest_buffer(s
 {
 	ibmveth_remove_buffer_from_pool(adapter, adapter->rx_queue.queue_addr[adapter->rx_queue.index].correlator);
 
-	if(++adapter->rx_queue.index == adapter->rx_queue.num_slots) {
+	if (++adapter->rx_queue.index == adapter->rx_queue.num_slots) {
 		adapter->rx_queue.index = 0;
 		adapter->rx_queue.toggle = !adapter->rx_queue.toggle;
 	}
@@ -452,7 +459,7 @@ static void ibmveth_cleanup(struct ibmve
 	int i;
 	struct device *dev = &adapter->vdev->dev;
 
-	if(adapter->buffer_list_addr != NULL) {
+	if (adapter->buffer_list_addr != NULL) {
 		if (!dma_mapping_error(dev, adapter->buffer_list_dma)) {
 			dma_unmap_single(dev, adapter->buffer_list_dma, 4096,
 					DMA_BIDIRECTIONAL);
@@ -462,7 +469,7 @@ static void ibmveth_cleanup(struct ibmve
 		adapter->buffer_list_addr = NULL;
 	}
 
-	if(adapter->filter_list_addr != NULL) {
+	if (adapter->filter_list_addr != NULL) {
 		if (!dma_mapping_error(dev, adapter->filter_list_dma)) {
 			dma_unmap_single(dev, adapter->filter_list_dma, 4096,
 					DMA_BIDIRECTIONAL);
@@ -472,7 +479,7 @@ static void ibmveth_cleanup(struct ibmve
 		adapter->filter_list_addr = NULL;
 	}
 
-	if(adapter->rx_queue.queue_addr != NULL) {
+	if (adapter->rx_queue.queue_addr != NULL) {
 		if (!dma_mapping_error(dev, adapter->rx_queue.queue_dma)) {
 			dma_unmap_single(dev,
 					adapter->rx_queue.queue_dma,
@@ -484,7 +491,7 @@ static void ibmveth_cleanup(struct ibmve
 		adapter->rx_queue.queue_addr = NULL;
 	}
 
-	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
+	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
 		if (adapter->rx_buff_pool[i].active)
 			ibmveth_free_buffer_pool(adapter,
 						 &adapter->rx_buff_pool[i]);
@@ -507,9 +514,11 @@ static int ibmveth_register_logical_lan(
 {
 	int rc, try_again = 1;
 
-	/* After a kexec the adapter will still be open, so our attempt to
-	* open it will fail. So if we get a failure we free the adapter and
-	* try again, but only once. */
+	/*
+	 * After a kexec the adapter will still be open, so our attempt to
+	 * open it will fail. So if we get a failure we free the adapter and
+	 * try again, but only once.
+	 */
 retry:
 	rc = h_register_logical_lan(adapter->vdev->unit_address,
 				    adapter->buffer_list_dma, rxq_desc.desc,
@@ -542,13 +551,13 @@ static int ibmveth_open(struct net_devic
 
 	napi_enable(&adapter->napi);
 
-	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
+	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
 		rxq_entries += adapter->rx_buff_pool[i].size;
 
 	adapter->buffer_list_addr = kzalloc(4096, GFP_KERNEL);
 	adapter->filter_list_addr = kzalloc(4096, GFP_KERNEL);
 
-	if(!adapter->buffer_list_addr || !adapter->filter_list_addr) {
+	if (!adapter->buffer_list_addr || !adapter->filter_list_addr) {
 		netdev_err(netdev, "unable to allocate filter or buffer list "
 			   "pages\n");
 		ibmveth_cleanup(adapter);
@@ -556,10 +565,12 @@ static int ibmveth_open(struct net_devic
 		return -ENOMEM;
 	}
 
-	adapter->rx_queue.queue_len = sizeof(struct ibmveth_rx_q_entry) * rxq_entries;
-	adapter->rx_queue.queue_addr = kmalloc(adapter->rx_queue.queue_len, GFP_KERNEL);
+	adapter->rx_queue.queue_len = sizeof(struct ibmveth_rx_q_entry) *
+						rxq_entries;
+	adapter->rx_queue.queue_addr = kmalloc(adapter->rx_queue.queue_len,
+						GFP_KERNEL);
 
-	if(!adapter->rx_queue.queue_addr) {
+	if (!adapter->rx_queue.queue_addr) {
 		netdev_err(netdev, "unable to allocate rx queue pages\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
@@ -593,7 +604,8 @@ static int ibmveth_open(struct net_devic
 	memcpy(&mac_address, netdev->dev_addr, netdev->addr_len);
 	mac_address = mac_address >> 16;
 
-	rxq_desc.fields.flags_len = IBMVETH_BUF_VALID | adapter->rx_queue.queue_len;
+	rxq_desc.fields.flags_len = IBMVETH_BUF_VALID |
+					adapter->rx_queue.queue_len;
 	rxq_desc.fields.address = adapter->rx_queue.queue_dma;
 
 	netdev_dbg(netdev, "buffer list @ 0x%p\n", adapter->buffer_list_addr);
@@ -604,7 +616,7 @@ static int ibmveth_open(struct net_devic
 
 	lpar_rc = ibmveth_register_logical_lan(adapter, rxq_desc, mac_address);
 
-	if(lpar_rc != H_SUCCESS) {
+	if (lpar_rc != H_SUCCESS) {
 		netdev_err(netdev, "h_register_logical_lan failed with %ld\n",
 			   lpar_rc);
 		netdev_err(netdev, "buffer TCE:0x%llx filter TCE:0x%llx rxq "
@@ -618,8 +630,8 @@ static int ibmveth_open(struct net_devic
 		return -ENONET;
 	}
 
-	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
-		if(!adapter->rx_buff_pool[i].active)
+	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
+		if (!adapter->rx_buff_pool[i].active)
 			continue;
 		if (ibmveth_alloc_buffer_pool(&adapter->rx_buff_pool[i])) {
 			netdev_err(netdev, "unable to alloc pool\n");
@@ -631,7 +643,9 @@ static int ibmveth_open(struct net_devic
 	}
 
 	netdev_dbg(netdev, "registering irq 0x%x\n", netdev->irq);
-	if((rc = request_irq(netdev->irq, ibmveth_interrupt, 0, netdev->name, netdev)) != 0) {
+	rc = request_irq(netdev->irq, ibmveth_interrupt, 0, netdev->name,
+			 netdev);
+	if (rc != 0) {
 		netdev_err(netdev, "unable to request irq 0x%x, rc %d\n",
 			   netdev->irq, rc);
 		do {
@@ -689,15 +703,15 @@ static int ibmveth_close(struct net_devi
 		lpar_rc = h_free_logical_lan(adapter->vdev->unit_address);
 	} while (H_IS_LONG_BUSY(lpar_rc) || (lpar_rc == H_BUSY));
 
-	if(lpar_rc != H_SUCCESS)
-	{
+	if (lpar_rc != H_SUCCESS) {
 		netdev_err(netdev, "h_free_logical_lan failed with %lx, "
 			   "continuing with close\n", lpar_rc);
 	}
 
 	free_irq(netdev->irq, netdev);
 
-	adapter->rx_no_buffer = *(u64*)(((char*)adapter->buffer_list_addr) + 4096 - 8);
+	adapter->rx_no_buffer = *(u64 *)(((char *)adapter->buffer_list_addr) +
+						4096 - 8);
 
 	ibmveth_cleanup(adapter);
 
@@ -706,9 +720,12 @@ static int ibmveth_close(struct net_devi
 	return 0;
 }
 
-static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd) {
-	cmd->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg | SUPPORTED_FIBRE);
-	cmd->advertising = (ADVERTISED_1000baseT_Full | ADVERTISED_Autoneg | ADVERTISED_FIBRE);
+static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	cmd->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
+				SUPPORTED_FIBRE);
+	cmd->advertising = (ADVERTISED_1000baseT_Full | ADVERTISED_Autoneg |
+				ADVERTISED_FIBRE);
 	cmd->speed = SPEED_1000;
 	cmd->duplex = DUPLEX_FULL;
 	cmd->port = PORT_FIBRE;
@@ -720,12 +737,16 @@ static int netdev_get_settings(struct ne
 	return 0;
 }
 
-static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info) {
+static void netdev_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
 	strncpy(info->driver, ibmveth_driver_name, sizeof(info->driver) - 1);
-	strncpy(info->version, ibmveth_driver_version, sizeof(info->version) - 1);
+	strncpy(info->version, ibmveth_driver_version,
+		sizeof(info->version) - 1);
 }
 
-static u32 netdev_get_link(struct net_device *dev) {
+static u32 netdev_get_link(struct net_device *dev)
+{
 	return 1;
 }
 
@@ -733,15 +754,16 @@ static void ibmveth_set_rx_csum_flags(st
 {
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
-	if (data)
+	if (data) {
 		adapter->rx_csum = 1;
-	else {
+	} else {
 		/*
-		 * Since the ibmveth firmware interface does not have the concept of
-		 * separate tx/rx checksum offload enable, if rx checksum is disabled
-		 * we also have to disable tx checksum offload. Once we disable rx
-		 * checksum offload, we are no longer allowed to send tx buffers that
-		 * are not properly checksummed.
+		 * Since the ibmveth firmware interface does not have the
+		 * concept of separate tx/rx checksum offload enable, if rx
+		 * checksum is disabled we also have to disable tx checksum
+		 * offload. Once we disable rx checksum offload, we are no
+		 * longer allowed to send tx buffers that are not properly
+		 * checksummed.
 		 */
 		adapter->rx_csum = 0;
 		dev->features &= ~NETIF_F_IP_CSUM;
@@ -755,8 +777,9 @@ static void ibmveth_set_tx_csum_flags(st
 	if (data) {
 		dev->features |= NETIF_F_IP_CSUM;
 		adapter->rx_csum = 1;
-	} else
+	} else {
 		dev->features &= ~NETIF_F_IP_CSUM;
+	}
 }
 
 static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
@@ -798,8 +821,9 @@ static int ibmveth_set_csum_offload(stru
 
 			ret = h_illan_attributes(adapter->vdev->unit_address,
 						 set_attr, clr_attr, &ret_attr);
-		} else
+		} else {
 			done(dev, data);
+		}
 	} else {
 		rc1 = -EIO;
 		netdev_err(dev, "unable to change checksum offload settings."
@@ -834,7 +858,8 @@ static int ibmveth_set_tx_csum(struct ne
 		return 0;
 
 	if (data && !adapter->rx_csum)
-		rc = ibmveth_set_csum_offload(dev, data, ibmveth_set_tx_csum_flags);
+		rc = ibmveth_set_csum_offload(dev, data,
+					      ibmveth_set_tx_csum_flags);
 	else
 		ibmveth_set_tx_csum_flags(dev, data);
 
@@ -1054,12 +1079,13 @@ map_failed:
 
 static int ibmveth_poll(struct napi_struct *napi, int budget)
 {
-	struct ibmveth_adapter *adapter = container_of(napi, struct ibmveth_adapter, napi);
+	struct ibmveth_adapter *adapter =
+			container_of(napi, struct ibmveth_adapter, napi);
 	struct net_device *netdev = adapter->netdev;
 	int frames_processed = 0;
 	unsigned long lpar_rc;
 
- restart_poll:
+restart_poll:
 	do {
 		if (!ibmveth_rxq_pending_buffer(adapter))
 			break;
@@ -1160,7 +1186,7 @@ static void ibmveth_set_multicast_list(s
 					   IbmVethMcastEnableRecv |
 					   IbmVethMcastDisableFiltering,
 					   0);
-		if(lpar_rc != H_SUCCESS) {
+		if (lpar_rc != H_SUCCESS) {
 			netdev_err(netdev, "h_multicast_ctrl rc=%ld when "
 				   "entering promisc mode\n", lpar_rc);
 		}
@@ -1172,20 +1198,20 @@ static void ibmveth_set_multicast_list(s
 					   IbmVethMcastDisableFiltering |
 					   IbmVethMcastClearFilterTable,
 					   0);
-		if(lpar_rc != H_SUCCESS) {
+		if (lpar_rc != H_SUCCESS) {
 			netdev_err(netdev, "h_multicast_ctrl rc=%ld when "
 				   "attempting to clear filter table\n",
 				   lpar_rc);
 		}
 		/* add the addresses to the filter table */
 		netdev_for_each_mc_addr(ha, netdev) {
-			// add the multicast address to the filter table
+			/* add the multicast address to the filter table */
 			unsigned long mcast_addr = 0;
 			memcpy(((char *)&mcast_addr)+2, ha->addr, 6);
 			lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 						   IbmVethMcastAddFilter,
 						   mcast_addr);
-			if(lpar_rc != H_SUCCESS) {
+			if (lpar_rc != H_SUCCESS) {
 				netdev_err(netdev, "h_multicast_ctrl rc=%ld "
 					   "when adding an entry to the filter "
 					   "table\n", lpar_rc);
@@ -1196,7 +1222,7 @@ static void ibmveth_set_multicast_list(s
 		lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 					   IbmVethMcastEnableFiltering,
 					   0);
-		if(lpar_rc != H_SUCCESS) {
+		if (lpar_rc != H_SUCCESS) {
 			netdev_err(netdev, "h_multicast_ctrl rc=%ld when "
 				   "enabling filtering\n", lpar_rc);
 		}
@@ -1231,7 +1257,7 @@ static int ibmveth_change_mtu(struct net
 	}
 
 	/* Look for an active buffer pool that can hold the new MTU */
-	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
+	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		adapter->rx_buff_pool[i].active = 1;
 
 		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size) {
@@ -1314,31 +1340,30 @@ static const struct net_device_ops ibmve
 #endif
 };
 
-static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
+static int __devinit ibmveth_probe(struct vio_dev *dev,
+				   const struct vio_device_id *id)
 {
 	int rc, i;
 	long ret;
 	struct net_device *netdev;
 	struct ibmveth_adapter *adapter;
 	unsigned long set_attr, ret_attr;
-
 	unsigned char *mac_addr_p;
 	unsigned int *mcastFilterSize_p;
 
-
 	dev_dbg(&dev->dev, "entering ibmveth_probe for UA 0x%x\n",
 		dev->unit_address);
 
-	mac_addr_p = (unsigned char *) vio_get_attribute(dev,
+	mac_addr_p = (unsigned char *)vio_get_attribute(dev,
 						VETH_MAC_ADDR, NULL);
-	if(!mac_addr_p) {
+	if (!mac_addr_p) {
 		dev_err(&dev->dev, "Can't find VETH_MAC_ADDR attribute\n");
 		return 0;
 	}
 
-	mcastFilterSize_p = (unsigned int *) vio_get_attribute(dev,
+	mcastFilterSize_p = (unsigned int *)vio_get_attribute(dev,
 						VETH_MCAST_FILTER_SIZE, NULL);
-	if(!mcastFilterSize_p) {
+	if (!mcastFilterSize_p) {
 		dev_err(&dev->dev, "Can't find VETH_MCAST_FILTER_SIZE "
 			"attribute\n");
 		return 0;
@@ -1346,7 +1371,7 @@ static int __devinit ibmveth_probe(struc
 
 	netdev = alloc_etherdev(sizeof(struct ibmveth_adapter));
 
-	if(!netdev)
+	if (!netdev)
 		return -ENOMEM;
 
 	adapter = netdev_priv(netdev);
@@ -1354,19 +1379,19 @@ static int __devinit ibmveth_probe(struc
 
 	adapter->vdev = dev;
 	adapter->netdev = netdev;
-	adapter->mcastFilterSize= *mcastFilterSize_p;
+	adapter->mcastFilterSize = *mcastFilterSize_p;
 	adapter->pool_config = 0;
 
 	netif_napi_add(netdev, &adapter->napi, ibmveth_poll, 16);
 
-	/* 	Some older boxes running PHYP non-natively have an OF that
-		returns a 8-byte local-mac-address field (and the first
-		2 bytes have to be ignored) while newer boxes' OF return
-		a 6-byte field. Note that IEEE 1275 specifies that
-		local-mac-address must be a 6-byte field.
-		The RPA doc specifies that the first byte must be 10b, so
-		we'll just look for it to solve this 8 vs. 6 byte field issue */
-
+	/*
+	 * Some older boxes running PHYP non-natively have an OF that returns
+	 * a 8-byte local-mac-address field (and the first 2 bytes have to be
+	 * ignored) while newer boxes' OF return a 6-byte field. Note that
+	 * IEEE 1275 specifies that local-mac-address must be a 6-byte field.
+	 * The RPA doc specifies that the first byte must be 10b, so we'll
+	 * just look for it to solve this 8 vs. 6 byte field issue
+	 */
 	if ((*mac_addr_p & 0x3) != 0x02)
 		mac_addr_p += 2;
 
@@ -1381,7 +1406,7 @@ static int __devinit ibmveth_probe(struc
 
 	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
 
-	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
+	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		struct kobject *kobj = &adapter->rx_buff_pool[i].kobj;
 		int error;
 
@@ -1409,18 +1434,21 @@ static int __devinit ibmveth_probe(struc
 	    (ret_attr & IBMVETH_ILLAN_PADDED_PKT_CSUM)) {
 		set_attr = IBMVETH_ILLAN_IPV4_TCP_CSUM;
 
-		ret = h_illan_attributes(dev->unit_address, 0, set_attr, &ret_attr);
+		ret = h_illan_attributes(dev->unit_address, 0, set_attr,
+					 &ret_attr);
 
 		if (ret == H_SUCCESS) {
 			adapter->rx_csum = 1;
 			netdev->features |= NETIF_F_IP_CSUM;
-		} else
-			ret = h_illan_attributes(dev->unit_address, set_attr, 0, &ret_attr);
+		} else {
+			ret = h_illan_attributes(dev->unit_address, set_attr,
+						 0, &ret_attr);
+		}
 	}
 
 	rc = register_netdev(netdev);
 
-	if(rc) {
+	if (rc) {
 		netdev_dbg(netdev, "failed to register netdev rc=%d\n", rc);
 		free_netdev(netdev);
 		return rc;
@@ -1437,7 +1465,7 @@ static int __devexit ibmveth_remove(stru
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	int i;
 
-	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
+	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
 		kobject_put(&adapter->rx_buff_pool[i].kobj);
 
 	unregister_netdev(netdev);
@@ -1452,8 +1480,8 @@ static struct attribute veth_active_attr
 static struct attribute veth_num_attr;
 static struct attribute veth_size_attr;
 
-static ssize_t veth_pool_show(struct kobject * kobj,
-                              struct attribute * attr, char * buf)
+static ssize_t veth_pool_show(struct kobject *kobj,
+			      struct attribute *attr, char *buf)
 {
 	struct ibmveth_buff_pool *pool = container_of(kobj,
 						      struct ibmveth_buff_pool,
@@ -1468,8 +1496,8 @@ static ssize_t veth_pool_show(struct kob
 	return 0;
 }
 
-static ssize_t veth_pool_store(struct kobject * kobj, struct attribute * attr,
-const char * buf, size_t count)
+static ssize_t veth_pool_store(struct kobject *kobj, struct attribute *attr,
+			       const char *buf, size_t count)
 {
 	struct ibmveth_buff_pool *pool = container_of(kobj,
 						      struct ibmveth_buff_pool,
@@ -1483,7 +1511,7 @@ const char * buf, size_t count)
 	if (attr == &veth_active_attr) {
 		if (value && !pool->active) {
 			if (netif_running(netdev)) {
-				if(ibmveth_alloc_buffer_pool(pool)) {
+				if (ibmveth_alloc_buffer_pool(pool)) {
 					netdev_err(netdev,
 						   "unable to alloc pool\n");
 					return -ENOMEM;
@@ -1494,8 +1522,9 @@ const char * buf, size_t count)
 				adapter->pool_config = 0;
 				if ((rc = ibmveth_open(netdev)))
 					return rc;
-			} else
+			} else {
 				pool->active = 1;
+			}
 		} else if (!value && pool->active) {
 			int mtu = netdev->mtu + IBMVETH_BUFF_OH;
 			int i;
@@ -1526,9 +1555,9 @@ const char * buf, size_t count)
 			pool->active = 0;
 		}
 	} else if (attr == &veth_num_attr) {
-		if (value <= 0 || value > IBMVETH_MAX_POOL_COUNT)
+		if (value <= 0 || value > IBMVETH_MAX_POOL_COUNT) {
 			return -EINVAL;
-		else {
+		} else {
 			if (netif_running(netdev)) {
 				adapter->pool_config = 1;
 				ibmveth_close(netdev);
@@ -1536,13 +1565,14 @@ const char * buf, size_t count)
 				pool->size = value;
 				if ((rc = ibmveth_open(netdev)))
 					return rc;
-			} else
+			} else {
 				pool->size = value;
+			}
 		}
 	} else if (attr == &veth_size_attr) {
-		if (value <= IBMVETH_BUFF_OH || value > IBMVETH_MAX_BUF_SIZE)
+		if (value <= IBMVETH_BUFF_OH || value > IBMVETH_MAX_BUF_SIZE) {
 			return -EINVAL;
-		else {
+		} else {
 			if (netif_running(netdev)) {
 				adapter->pool_config = 1;
 				ibmveth_close(netdev);
@@ -1550,8 +1580,9 @@ const char * buf, size_t count)
 				pool->buff_size = value;
 				if ((rc = ibmveth_open(netdev)))
 					return rc;
-			} else
+			} else {
 				pool->buff_size = value;
+			}
 		}
 	}
 
@@ -1561,16 +1592,16 @@ const char * buf, size_t count)
 }
 
 
-#define ATTR(_name, _mode)      \
-        struct attribute veth_##_name##_attr = {               \
-        .name = __stringify(_name), .mode = _mode, \
-        };
+#define ATTR(_name, _mode)				\
+	struct attribute veth_##_name##_attr = {	\
+	.name = __stringify(_name), .mode = _mode,	\
+	};
 
 static ATTR(active, 0644);
 static ATTR(num, 0644);
 static ATTR(size, 0644);
 
-static struct attribute * veth_pool_attrs[] = {
+static struct attribute *veth_pool_attrs[] = {
 	&veth_active_attr,
 	&veth_num_attr,
 	&veth_size_attr,
@@ -1595,7 +1626,7 @@ static int ibmveth_resume(struct device
 	return 0;
 }
 
-static struct vio_device_id ibmveth_device_table[] __devinitdata= {
+static struct vio_device_id ibmveth_device_table[] __devinitdata = {
 	{ "network", "IBM,l-lan"},
 	{ "", "" }
 };


