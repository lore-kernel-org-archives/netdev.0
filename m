From: Chris Peterson <cpeterso@cpeterso.com>
Subject: [PATCH] [resend] drivers/net: remove network drivers' last few uses
 of IRQF_SAMPLE_RANDOM
Date: Fri, 13 Jun 2008 22:48:58 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0806132238340.728@ikari.dreamhost.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:64658 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbYFNFtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 01:49:20 -0400
Received: by wa-out-1112.google.com with SMTP id j37so3554400waf.23
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 22:49:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Remove network drivers' last few uses of theoretically-exploitable network
entropy. Only 12 net drivers are affected. Headless boxes should use a
more secure source of entropy, such as userspace daemons like rngd, 
clrngd, audio_entropyd, and/or video_entroyd.


Signed-off-by: Chris Peterson <cpeterso@cpeterso.com>
---
diff -Naur linux-2.6.26-rc6.orig/drivers/net/3c523.c linux-2.6.26-rc6/drivers/net/3c523.c
--- linux-2.6.26-rc6.orig/drivers/net/3c523.c	2008-05-18 10:03:23.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/3c523.c	2008-06-13 22:14:54.000000000 -0700
@@ -289,8 +289,7 @@
 
 	elmc_id_attn586();	/* disable interrupts */
 
-	ret = request_irq(dev->irq, &elmc_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
+	ret = request_irq(dev->irq, &elmc_interrupt, IRQF_SHARED, dev->name, dev);
 	if (ret) {
 		printk(KERN_ERR "%s: couldn't get irq %d\n", dev->name, dev->irq);
 		elmc_id_reset586();
diff -Naur linux-2.6.26-rc6.orig/drivers/net/3c527.c linux-2.6.26-rc6/drivers/net/3c527.c
--- linux-2.6.26-rc6.orig/drivers/net/3c527.c	2008-06-12 23:51:32.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/3c527.c	2008-06-13 22:14:54.000000000 -0700
@@ -434,7 +434,7 @@
 	 *	Grab the IRQ
 	 */
 
-	err = request_irq(dev->irq, &mc32_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM, DRV_NAME, dev);
+	err = request_irq(dev->irq, &mc32_interrupt, IRQF_SHARED, DRV_NAME, dev);
 	if (err) {
 		release_region(dev->base_addr, MC32_IO_EXTENT);
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n", DRV_NAME, dev->irq);
diff -Naur linux-2.6.26-rc6.orig/drivers/net/atlx/atl1.c linux-2.6.26-rc6/drivers/net/atlx/atl1.c
--- linux-2.6.26-rc6.orig/drivers/net/atlx/atl1.c	2008-06-12 23:51:33.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/atlx/atl1.c	2008-06-13 22:14:54.000000000 -0700
@@ -2595,7 +2595,7 @@
 {
 	struct net_device *netdev = adapter->netdev;
 	int err;
-	int irq_flags = IRQF_SAMPLE_RANDOM;
+	int irq_flags = 0;
 
 	/* hardware has been reset, we need to reload some things */
 	atlx_set_multi(netdev);
diff -Naur linux-2.6.26-rc6.orig/drivers/net/cris/eth_v10.c linux-2.6.26-rc6/drivers/net/cris/eth_v10.c
--- linux-2.6.26-rc6.orig/drivers/net/cris/eth_v10.c	2008-05-18 10:03:34.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/cris/eth_v10.c	2008-06-13 22:14:54.000000000 -0700
@@ -490,7 +490,7 @@
 	/* allocate the irq corresponding to the receiving DMA */
 
 	if (request_irq(NETWORK_DMA_RX_IRQ_NBR, e100rxtx_interrupt,
-			IRQF_SAMPLE_RANDOM, cardname, (void *)dev)) {
+			0, cardname, (void *)dev)) {
 		goto grace_exit0;
 	}
 
diff -Naur linux-2.6.26-rc6.orig/drivers/net/ibmlana.c linux-2.6.26-rc6/drivers/net/ibmlana.c
--- linux-2.6.26-rc6.orig/drivers/net/ibmlana.c	2008-05-18 10:03:41.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/ibmlana.c	2008-06-13 22:14:54.000000000 -0700
@@ -783,7 +783,7 @@
 
 	/* register resources - only necessary for IRQ */
 
-	result = request_irq(priv->realirq, irq_handler, IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+	result = request_irq(priv->realirq, irq_handler, IRQF_SHARED, dev->name, dev);
 	if (result != 0) {
 		printk(KERN_ERR "%s: failed to register irq %d\n", dev->name, dev->irq);
 		return result;
diff -Naur linux-2.6.26-rc6.orig/drivers/net/macb.c linux-2.6.26-rc6/drivers/net/macb.c
--- linux-2.6.26-rc6.orig/drivers/net/macb.c	2008-06-12 23:51:45.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/macb.c	2008-06-13 22:14:54.000000000 -0700
@@ -1151,8 +1151,7 @@
 	}
 
 	dev->irq = platform_get_irq(pdev, 0);
-	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
+	err = request_irq(dev->irq, macb_interrupt, 0, dev->name, dev);
 	if (err) {
 		printk(KERN_ERR
 		       "%s: Unable to request IRQ %d (error %d)\n",
diff -Naur linux-2.6.26-rc6.orig/drivers/net/mv643xx_eth.c linux-2.6.26-rc6/drivers/net/mv643xx_eth.c
--- linux-2.6.26-rc6.orig/drivers/net/mv643xx_eth.c	2008-06-12 23:51:46.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/mv643xx_eth.c	2008-06-13 22:14:54.000000000 -0700
@@ -1329,7 +1329,7 @@
 	rdl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num));
 
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
-			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+			IRQF_SHARED, dev->name, dev);
 	if (err) {
 		printk(KERN_ERR "%s: Can not assign IRQ\n", dev->name);
 		return -EAGAIN;
diff -Naur linux-2.6.26-rc6.orig/drivers/net/netxen/netxen_nic_main.c linux-2.6.26-rc6/drivers/net/netxen/netxen_nic_main.c
--- linux-2.6.26-rc6.orig/drivers/net/netxen/netxen_nic_main.c	2008-06-12 23:51:46.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/netxen/netxen_nic_main.c	2008-06-13 22:14:54.000000000 -0700
@@ -838,7 +838,7 @@
 	int err = 0;
 	int ctx, ring;
 	irq_handler_t handler;
-	unsigned long flags = IRQF_SAMPLE_RANDOM;
+	unsigned long flags = 0;
 
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC) {
 		err = netxen_init_firmware(adapter);
diff -Naur linux-2.6.26-rc6.orig/drivers/net/niu.c linux-2.6.26-rc6/drivers/net/niu.c
--- linux-2.6.26-rc6.orig/drivers/net/niu.c	2008-06-12 23:51:47.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/niu.c	2008-06-13 22:14:54.000000000 -0700
@@ -5599,8 +5599,7 @@
 		struct niu_ldg *lp = &np->ldg[i];
 
 		err = request_irq(lp->irq, niu_interrupt,
-				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-				  np->dev->name, lp);
+				  IRQF_SHARED, np->dev->name, lp);
 		if (err)
 			goto out_free_irqs;
 
diff -Naur linux-2.6.26-rc6.orig/drivers/net/qla3xxx.c linux-2.6.26-rc6/drivers/net/qla3xxx.c
--- linux-2.6.26-rc6.orig/drivers/net/qla3xxx.c	2008-06-12 23:51:49.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/qla3xxx.c	2008-06-13 22:14:54.000000000 -0700
@@ -3618,7 +3618,7 @@
 {
 	struct net_device *ndev = qdev->ndev;
 	int err;
-	unsigned long irq_flags = IRQF_SAMPLE_RANDOM | IRQF_SHARED;
+	unsigned long irq_flags = IRQF_SHARED;
 	unsigned long hw_flags;
 
 	if (ql_alloc_mem_resources(qdev)) {
diff -Naur linux-2.6.26-rc6.orig/drivers/net/tg3.c linux-2.6.26-rc6/drivers/net/tg3.c
--- linux-2.6.26-rc6.orig/drivers/net/tg3.c	2008-06-12 23:51:57.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/tg3.c	2008-06-13 22:14:54.000000000 -0700
@@ -7510,12 +7510,12 @@
 		fn = tg3_msi;
 		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
 			fn = tg3_msi_1shot;
-		flags = IRQF_SAMPLE_RANDOM;
+		flags = 0;
 	} else {
 		fn = tg3_interrupt;
 		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
 			fn = tg3_interrupt_tagged;
-		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
+		flags = IRQF_SHARED;
 	}
 	return (request_irq(tp->pdev->irq, fn, flags, dev->name, dev));
 }
@@ -7533,7 +7533,7 @@
 	free_irq(tp->pdev->irq, dev);
 
 	err = request_irq(tp->pdev->irq, tg3_test_isr,
-			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+			  IRQF_SHARED, dev->name, dev);
 	if (err)
 		return err;
 
diff -Naur linux-2.6.26-rc6.orig/drivers/net/xen-netfront.c linux-2.6.26-rc6/drivers/net/xen-netfront.c
--- linux-2.6.26-rc6.orig/drivers/net/xen-netfront.c	2008-06-12 23:52:17.000000000 -0700
+++ linux-2.6.26-rc6/drivers/net/xen-netfront.c	2008-06-13 22:14:54.000000000 -0700
@@ -1361,8 +1361,7 @@
 		goto fail;
 
 	err = bind_evtchn_to_irqhandler(info->evtchn, xennet_interrupt,
-					IRQF_SAMPLE_RANDOM, netdev->name,
-					netdev);
+					0, netdev->name, netdev);
 	if (err < 0)
 		goto fail;
 	netdev->irq = err;
