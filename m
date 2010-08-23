From: Anton Blanchard <anton@samba.org>
Subject: [patch 15/20] ibmveth: Some formatting fixes
Date: Mon, 23 Aug 2010 10:09:45 +1000
Message-ID: <20100823001239.707974995@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51863 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332Ab0HWA3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:29:25 -0400
Content-Disposition: inline; filename=veth_min_mtu
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IbmVethNumBufferPools -> IBMVETH_NUM_BUFF_POOLS

Also change IBMVETH_MAX_MTU -> IBMVETH_MIN_MTU, it refers to the minimum
size not the maximum.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:33.000000000 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:53:23.040010330 +1000
@@ -309,7 +309,7 @@ static void ibmveth_replenish_task(struc
 
 	adapter->replenish_task_cycles++;
 
-	for (i = (IbmVethNumBufferPools - 1); i >= 0; i--) {
+	for (i = (IBMVETH_NUM_BUFF_POOLS - 1); i >= 0; i--) {
 		struct ibmveth_buff_pool *pool = &adapter->rx_buff_pool[i];
 
 		if (pool->active &&
@@ -361,7 +361,7 @@ static void ibmveth_remove_buffer_from_p
 	unsigned int free_index;
 	struct sk_buff *skb;
 
-	ibmveth_assert(pool < IbmVethNumBufferPools);
+	ibmveth_assert(pool < IBMVETH_NUM_BUFF_POOLS);
 	ibmveth_assert(index < adapter->rx_buff_pool[pool].size);
 
 	skb = adapter->rx_buff_pool[pool].skbuff[index];
@@ -394,7 +394,7 @@ static inline struct sk_buff *ibmveth_rx
 	unsigned int pool = correlator >> 32;
 	unsigned int index = correlator & 0xffffffffUL;
 
-	ibmveth_assert(pool < IbmVethNumBufferPools);
+	ibmveth_assert(pool < IBMVETH_NUM_BUFF_POOLS);
 	ibmveth_assert(index < adapter->rx_buff_pool[pool].size);
 
 	return adapter->rx_buff_pool[pool].skbuff[index];
@@ -410,7 +410,7 @@ static void ibmveth_rxq_recycle_buffer(s
 	union ibmveth_buf_desc desc;
 	unsigned long lpar_rc;
 
-	ibmveth_assert(pool < IbmVethNumBufferPools);
+	ibmveth_assert(pool < IBMVETH_NUM_BUFF_POOLS);
 	ibmveth_assert(index < adapter->rx_buff_pool[pool].size);
 
 	if(!adapter->rx_buff_pool[pool].active) {
@@ -484,7 +484,7 @@ static void ibmveth_cleanup(struct ibmve
 		adapter->rx_queue.queue_addr = NULL;
 	}
 
-	for(i = 0; i<IbmVethNumBufferPools; i++)
+	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
 		if (adapter->rx_buff_pool[i].active)
 			ibmveth_free_buffer_pool(adapter,
 						 &adapter->rx_buff_pool[i]);
@@ -542,7 +542,7 @@ static int ibmveth_open(struct net_devic
 
 	napi_enable(&adapter->napi);
 
-	for(i = 0; i<IbmVethNumBufferPools; i++)
+	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
 		rxq_entries += adapter->rx_buff_pool[i].size;
 
 	adapter->buffer_list_addr = kzalloc(4096, GFP_KERNEL);
@@ -618,7 +618,7 @@ static int ibmveth_open(struct net_devic
 		return -ENONET;
 	}
 
-	for(i = 0; i<IbmVethNumBufferPools; i++) {
+	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		if(!adapter->rx_buff_pool[i].active)
 			continue;
 		if (ibmveth_alloc_buffer_pool(&adapter->rx_buff_pool[i])) {
@@ -1211,14 +1211,14 @@ static int ibmveth_change_mtu(struct net
 	int i, rc;
 	int need_restart = 0;
 
-	if (new_mtu < IBMVETH_MAX_MTU)
+	if (new_mtu < IBMVETH_MIN_MTU)
 		return -EINVAL;
 
-	for (i = 0; i < IbmVethNumBufferPools; i++)
+	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
 		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size)
 			break;
 
-	if (i == IbmVethNumBufferPools)
+	if (i == IBMVETH_NUM_BUFF_POOLS)
 		return -EINVAL;
 
 	/* Deactivate all the buffer pools so that the next loop can activate
@@ -1231,7 +1231,7 @@ static int ibmveth_change_mtu(struct net
 	}
 
 	/* Look for an active buffer pool that can hold the new MTU */
-	for(i = 0; i<IbmVethNumBufferPools; i++) {
+	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		adapter->rx_buff_pool[i].active = 1;
 
 		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size) {
@@ -1285,7 +1285,7 @@ static unsigned long ibmveth_get_desired
 	ret = IBMVETH_BUFF_LIST_SIZE + IBMVETH_FILT_LIST_SIZE;
 	ret += IOMMU_PAGE_ALIGN(netdev->mtu);
 
-	for (i = 0; i < IbmVethNumBufferPools; i++) {
+	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		/* add the size of the active receive buffers */
 		if (adapter->rx_buff_pool[i].active)
 			ret +=
@@ -1381,7 +1381,7 @@ static int __devinit ibmveth_probe(struc
 
 	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
 
-	for(i = 0; i<IbmVethNumBufferPools; i++) {
+	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		struct kobject *kobj = &adapter->rx_buff_pool[i].kobj;
 		int error;
 
@@ -1437,7 +1437,7 @@ static int __devexit ibmveth_remove(stru
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	int i;
 
-	for(i = 0; i<IbmVethNumBufferPools; i++)
+	for(i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
 		kobject_put(&adapter->rx_buff_pool[i].kobj);
 
 	unregister_netdev(netdev);
@@ -1501,7 +1501,7 @@ const char * buf, size_t count)
 			int i;
 			/* Make sure there is a buffer pool with buffers that
 			   can hold a packet of the size of the MTU */
-			for (i = 0; i < IbmVethNumBufferPools; i++) {
+			for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 				if (pool == &adapter->rx_buff_pool[i])
 					continue;
 				if (!adapter->rx_buff_pool[i].active)
@@ -1510,7 +1510,7 @@ const char * buf, size_t count)
 					break;
 			}
 
-			if (i == IbmVethNumBufferPools) {
+			if (i == IBMVETH_NUM_BUFF_POOLS) {
 				netdev_err(netdev, "no active pool >= MTU\n");
 				return -EPERM;
 			}
Index: net-next-2.6/drivers/net/ibmveth.h
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.h	2010-08-23 08:52:28.000000000 +1000
+++ net-next-2.6/drivers/net/ibmveth.h	2010-08-23 08:52:52.492178650 +1000
@@ -92,10 +92,10 @@ static inline long h_illan_attributes(un
 #define h_change_logical_lan_mac(ua, mac) \
   plpar_hcall_norets(H_CHANGE_LOGICAL_LAN_MAC, ua, mac)
 
-#define IbmVethNumBufferPools 5
+#define IBMVETH_NUM_BUFF_POOLS 5
 #define IBMVETH_IO_ENTITLEMENT_DEFAULT 4243456 /* MTU of 1500 needs 4.2Mb */
 #define IBMVETH_BUFF_OH 22 /* Overhead: 14 ethernet header + 8 opaque handle */
-#define IBMVETH_MAX_MTU 68
+#define IBMVETH_MIN_MTU 68
 #define IBMVETH_MAX_POOL_COUNT 4096
 #define IBMVETH_BUFF_LIST_SIZE 4096
 #define IBMVETH_FILT_LIST_SIZE 4096
@@ -142,7 +142,7 @@ struct ibmveth_adapter {
     void * filter_list_addr;
     dma_addr_t buffer_list_dma;
     dma_addr_t filter_list_dma;
-    struct ibmveth_buff_pool rx_buff_pool[IbmVethNumBufferPools];
+    struct ibmveth_buff_pool rx_buff_pool[IBMVETH_NUM_BUFF_POOLS];
     struct ibmveth_rx_q rx_queue;
     int pool_config;
     int rx_csum;


