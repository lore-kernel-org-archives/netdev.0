From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH][VIA-RHINE]: Fix CONFIG_VIA_RHINE_NAPI usage
Date: Wed, 22 Aug 2007 18:46:59 -0300
Message-ID: <20070822214659.GC23220@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:39293 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761234AbXHVVrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 17:47:10 -0400
Received: by wr-out-0506.google.com with SMTP id 36so241231wra
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 14:47:07 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

	napi is broken here, with this patch at least I can isolate this
breakage and boot the machine with a non-napi via-rhine driver.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 8f4cf82..4cecd06 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -390,7 +390,9 @@ struct rhine_private {
 	struct pci_dev *pdev;
 	long pioaddr;
 	struct net_device *dev;
+#ifdef CONFIG_VIA_RHINE_NAPI
 	struct napi_struct napi;
+#endif
 	struct net_device_stats stats;
 	spinlock_t lock;
 
@@ -1059,9 +1061,9 @@ static void init_registers(struct net_device *dev)
 	iowrite32(rp->tx_ring_dma, ioaddr + TxRingPtr);
 
 	rhine_set_rx_mode(dev);
-
+#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_enable(&rp->napi);
-
+#endif
 	/* Enable interrupts by setting the interrupt mask. */
 	iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
 	       IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
@@ -1836,8 +1838,9 @@ static int rhine_close(struct net_device *dev)
 	spin_lock_irq(&rp->lock);
 
 	netif_stop_queue(dev);
+#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_disable(&rp->napi);
-
+#endif
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard, "
 		       "status was %4.4x.\n",
