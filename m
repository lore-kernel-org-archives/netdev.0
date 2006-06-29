From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 4/9] pcnet32: Use kcalloc instead of kmalloc and memset
Date: Thu, 29 Jun 2006 13:53:48 -0700
Message-ID: <20060629205348.GA22011@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:50337 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932512AbWF2Uxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 16:53:34 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TKrWcI030394
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:53:32 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TKrW4g267286
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:53:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TKrWjO006604
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:53:32 -0400
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2006-03-08 Eric Sesterhenn wrote:
converts drivers/net to kzalloc usage.

Don Fry modified it to use netif_msg_drv.  Tested ia32 and ppc64.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>
Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-git13/drivers/net/get.pcnet32.c	Wed Jun 28 11:17:09 2006
+++ linux-2.6.17-git13/drivers/net/pcnet32.c	Wed Jun 28 11:55:52 2006
@@ -1432,7 +1432,7 @@ static int pcnet32_alloc_ring(struct net
 					   lp->tx_ring_size,
 					   &lp->tx_ring_dma_addr);
 	if (lp->tx_ring == NULL) {
-		if (pcnet32_debug & NETIF_MSG_DRV)
+		if (netif_msg_drv(lp))
 			printk("\n" KERN_ERR PFX
 			       "%s: Consistent memory allocation failed.\n",
 			       name);
@@ -1444,52 +1444,48 @@ static int pcnet32_alloc_ring(struct net
 					   lp->rx_ring_size,
 					   &lp->rx_ring_dma_addr);
 	if (lp->rx_ring == NULL) {
-		if (pcnet32_debug & NETIF_MSG_DRV)
+		if (netif_msg_drv(lp))
 			printk("\n" KERN_ERR PFX
 			       "%s: Consistent memory allocation failed.\n",
 			       name);
 		return -ENOMEM;
 	}
 
-	lp->tx_dma_addr = kmalloc(sizeof(dma_addr_t) * lp->tx_ring_size,
+	lp->tx_dma_addr = kcalloc(lp->tx_ring_size, sizeof(dma_addr_t),
 				  GFP_ATOMIC);
 	if (!lp->tx_dma_addr) {
-		if (pcnet32_debug & NETIF_MSG_DRV)
+		if (netif_msg_drv(lp))
 			printk("\n" KERN_ERR PFX
 			       "%s: Memory allocation failed.\n", name);
 		return -ENOMEM;
 	}
-	memset(lp->tx_dma_addr, 0, sizeof(dma_addr_t) * lp->tx_ring_size);
 
-	lp->rx_dma_addr = kmalloc(sizeof(dma_addr_t) * lp->rx_ring_size,
+	lp->rx_dma_addr = kcalloc(lp->rx_ring_size, sizeof(dma_addr_t),
 				  GFP_ATOMIC);
 	if (!lp->rx_dma_addr) {
-		if (pcnet32_debug & NETIF_MSG_DRV)
+		if (netif_msg_drv(lp))
 			printk("\n" KERN_ERR PFX
 			       "%s: Memory allocation failed.\n", name);
 		return -ENOMEM;
 	}
-	memset(lp->rx_dma_addr, 0, sizeof(dma_addr_t) * lp->rx_ring_size);
 
-	lp->tx_skbuff = kmalloc(sizeof(struct sk_buff *) * lp->tx_ring_size,
+	lp->tx_skbuff = kcalloc(lp->tx_ring_size, sizeof(struct sk_buff *),
 				GFP_ATOMIC);
 	if (!lp->tx_skbuff) {
-		if (pcnet32_debug & NETIF_MSG_DRV)
+		if (netif_msg_drv(lp))
 			printk("\n" KERN_ERR PFX
 			       "%s: Memory allocation failed.\n", name);
 		return -ENOMEM;
 	}
-	memset(lp->tx_skbuff, 0, sizeof(struct sk_buff *) * lp->tx_ring_size);
 
-	lp->rx_skbuff = kmalloc(sizeof(struct sk_buff *) * lp->rx_ring_size,
+	lp->rx_skbuff = kcalloc(lp->rx_ring_size, sizeof(struct sk_buff *),
 				GFP_ATOMIC);
 	if (!lp->rx_skbuff) {
-		if (pcnet32_debug & NETIF_MSG_DRV)
+		if (netif_msg_drv(lp))
 			printk("\n" KERN_ERR PFX
 			       "%s: Memory allocation failed.\n", name);
 		return -ENOMEM;
 	}
-	memset(lp->rx_skbuff, 0, sizeof(struct sk_buff *) * lp->rx_ring_size);
 
 	return 0;
 }
-- 
Don Fry
brazilnut@us.ibm.com
