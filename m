From: Anton Blanchard <anton@samba.org>
Subject: [patch 01/20] ibmveth: Remove integer divide caused by modulus
Date: Mon, 23 Aug 2010 10:09:31 +1000
Message-ID: <20100823001238.380771427@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35028 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249Ab0HWA1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:27:02 -0400
Content-Disposition: inline; filename=veth_modulus
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace some modulus operators with an increment and compare to avoid
an integer divide.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:21.104406611 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:26.774004158 +1000
@@ -252,7 +252,9 @@ static void ibmveth_replenish_buffer_poo
 		}
 
 		free_index = pool->consumer_index;
-		pool->consumer_index = (pool->consumer_index + 1) % pool->size;
+		pool->consumer_index++;
+		if (pool->consumer_index >= pool->size)
+			pool->consumer_index = 0;
 		index = pool->free_map[free_index];
 
 		ibmveth_assert(index != IBM_VETH_INVALID_MAP);
@@ -377,9 +379,10 @@ static void ibmveth_remove_buffer_from_p
 			 DMA_FROM_DEVICE);
 
 	free_index = adapter->rx_buff_pool[pool].producer_index;
-	adapter->rx_buff_pool[pool].producer_index
-		= (adapter->rx_buff_pool[pool].producer_index + 1)
-		% adapter->rx_buff_pool[pool].size;
+	adapter->rx_buff_pool[pool].producer_index++;
+	if (adapter->rx_buff_pool[pool].producer_index >=
+	    adapter->rx_buff_pool[pool].size)
+		adapter->rx_buff_pool[pool].producer_index = 0;
 	adapter->rx_buff_pool[pool].free_map[free_index] = index;
 
 	mb();


