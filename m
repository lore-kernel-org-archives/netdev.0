From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH] Fix sparse errors in drivers/net/ibmveth.c
Date: Tue, 17 Apr 2007 13:12:55 +1000
Message-ID: <20070417031314.BC404DDED4@ozlabs.org>
Cc: Andrew Morton <akpm@osdl.org>, <netdev@vger.kernel.org>,
	<santil@us.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50082 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031053AbXDQDNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 23:13:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/ibmveth.c:96:46: error: marked inline, but without a definition
drivers/net/ibmveth.c:96: warning: 'ibmveth_rxq_harvest_buffer' declared inline after being called
drivers/net/ibmveth.c:96: warning: previous declaration of 'ibmveth_rxq_harvest_buffer' was here

Just let the compiler decide, as it happens gcc 4.~ inlines it anyway.

drivers/net/ibmveth.c:957:71: warning: Using plain integer as NULL pointer
drivers/net/ibmveth.c:964:85: warning: Using plain integer as NULL pointer

Split the long lines as well, ugly, but < 80 columns.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---

 drivers/net/ibmveth.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: powerpc/drivers/net/ibmveth.c
===================================================================
--- powerpc.orig/drivers/net/ibmveth.c
+++ powerpc/drivers/net/ibmveth.c
@@ -93,7 +93,7 @@ static void ibmveth_proc_unregister_driv
 static void ibmveth_proc_register_adapter(struct ibmveth_adapter *adapter);
 static void ibmveth_proc_unregister_adapter(struct ibmveth_adapter *adapter);
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance);
-static inline void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter);
+static void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter);
 static struct kobj_type ktype_veth_pool;
 
 #ifdef CONFIG_PROC_FS
@@ -389,7 +389,7 @@ static void ibmveth_rxq_recycle_buffer(s
 	}
 }
 
-static inline void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter)
+static void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter)
 {
 	ibmveth_remove_buffer_from_pool(adapter, adapter->rx_queue.queue_addr[adapter->rx_queue.index].correlator);
 
@@ -954,14 +954,16 @@ static int __devinit ibmveth_probe(struc
 	ibmveth_debug_printk_no_adapter("entering ibmveth_probe for UA 0x%x\n",
 					dev->unit_address);
 
-	mac_addr_p = (unsigned char *) vio_get_attribute(dev, VETH_MAC_ADDR, 0);
+	mac_addr_p = (unsigned char *) vio_get_attribute(dev,
+						VETH_MAC_ADDR, NULL);
 	if(!mac_addr_p) {
 		printk(KERN_ERR "(%s:%3.3d) ERROR: Can't find VETH_MAC_ADDR "
 				"attribute\n", __FILE__, __LINE__);
 		return 0;
 	}
 
-	mcastFilterSize_p= (unsigned int *) vio_get_attribute(dev, VETH_MCAST_FILTER_SIZE, 0);
+	mcastFilterSize_p = (unsigned int *) vio_get_attribute(dev,
+						VETH_MCAST_FILTER_SIZE, NULL);
 	if(!mcastFilterSize_p) {
 		printk(KERN_ERR "(%s:%3.3d) ERROR: Can't find "
 				"VETH_MCAST_FILTER_SIZE attribute\n",
