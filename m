From: Chris Peterson <cpeterso@cpeterso.com>
Subject: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 00:11:10 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755454AbYEOHL2@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I know Jeff Garzik says he's not interested in an anti-entropy pogrom for existing net drivers, but here is the patch if anyone else is interested..? :)

Only 12 net drivers are affected, the last of the theoretically-exploitable network entropy.

drivers/net/3c523.c
drivers/net/3c527.c
drivers/net/atlx/atl1.c
drivers/net/cris/eth_v10.c
drivers/net/ibmlana.c
drivers/net/macb.c
drivers/net/mv643xx_eth.c
drivers/net/netxen/netxen_nic_main.c
drivers/net/niu.c
drivers/net/qla3xxx.c
drivers/net/tg3.c
drivers/net/xen-netfront.c

chris


Signed-off-by: Chris Peterson <cpeterso@cpeterso.com>
---
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/3c523.c linux-2.6.26-rc2-git3/drivers/net/3c523.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/3c523.c	2008-05-13 22:37:06.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/3c523.c	2008-05-13 23:11:58.000000000 -0700
@@ -289,8 +289,7 @@ static int elmc_open(struct net_device *
 
 	elmc_id_attn586();	/* disable interrupts */
 
-	ret = request_irq(dev->irq, &elmc_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
+	ret = request_irq(dev->irq, &elmc_interrupt, IRQF_SHARED, dev->name, dev);
 	if (ret) {
 		printk(KERN_ERR "%s: couldn't get irq %d\n", dev->name, dev->irq);
 		elmc_id_reset586();
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/3c527.c linux-2.6.26-rc2-git3/drivers/net/3c527.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/3c527.c	2008-05-13 22:37:06.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/3c527.c	2008-05-13 23:12:15.000000000 -0700
@@ -434,7 +434,7 @@ static int __init mc32_probe1(struct net
 	 *	Grab the IRQ
 	 */
 
-	err = request_irq(dev->irq, &mc32_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM, DRV_NAME, dev);
+	err = request_irq(dev->irq, &mc32_interrupt, IRQF_SHARED, DRV_NAME, dev);
 	if (err) {
 		release_region(dev->base_addr, MC32_IO_EXTENT);
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n", DRV_NAME, dev->irq);
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/atlx/atl1.c linux-2.6.26-rc2-git3/drivers/net/atlx/atl1.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/atlx/atl1.c	2008-05-13 22:38:11.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/atlx/atl1.c	2008-05-13 23:13:00.000000000 -0700
@@ -2614,7 +2614,7 @@ static s32 atl1_up(struct atl1_adapter *
 {
 	struct net_device *netdev = adapter->netdev;
 	int err;
-	int irq_flags = IRQF_SAMPLE_RANDOM;
+	int irq_flags = 0;
 
 	/* hardware has been reset, we need to reload some things */
 	atlx_set_multi(netdev);
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/cris/eth_v10.c linux-2.6.26-rc2-git3/drivers/net/cris/eth_v10.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/cris/eth_v10.c	2008-05-13 22:37:10.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/cris/eth_v10.c	2008-05-13 23:14:19.000000000 -0700
@@ -490,7 +490,7 @@ e100_open(struct net_device *dev)
 	/* allocate the irq corresponding to the receiving DMA */
 
 	if (request_irq(NETWORK_DMA_RX_IRQ_NBR, e100rxtx_interrupt,
-			IRQF_SAMPLE_RANDOM, cardname, (void *)dev)) {
+			0, cardname, (void *)dev)) {
 		goto grace_exit0;
 	}
 
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/ibmlana.c linux-2.6.26-rc2-git3/drivers/net/ibmlana.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/ibmlana.c	2008-05-13 22:37:29.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/ibmlana.c	2008-05-13 23:14:54.000000000 -0700
@@ -783,7 +783,7 @@ static int ibmlana_open(struct net_devic
 
 	/* register resources - only necessary for IRQ */
 
-	result = request_irq(priv->realirq, irq_handler, IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+	result = request_irq(priv->realirq, irq_handler, IRQF_SHARED, dev->name, dev);
 	if (result != 0) {
 		printk(KERN_ERR "%s: failed to register irq %d\n", dev->name, dev->irq);
 		return result;
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/macb.c linux-2.6.26-rc2-git3/drivers/net/macb.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/macb.c	2008-05-13 22:37:32.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/macb.c	2008-05-13 23:15:17.000000000 -0700
@@ -1151,8 +1151,7 @@ static int __init macb_probe(struct plat
 	}
 
 	dev->irq = platform_get_irq(pdev, 0);
-	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
+	err = request_irq(dev->irq, macb_interrupt, 0, dev->name, dev);
 	if (err) {
 		printk(KERN_ERR
 		       "%s: Unable to request IRQ %d (error %d)\n",
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/mv643xx_eth.c linux-2.6.26-rc2-git3/drivers/net/mv643xx_eth.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/mv643xx_eth.c	2008-05-13 22:37:33.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/mv643xx_eth.c	2008-05-13 23:15:37.000000000 -0700
@@ -1329,7 +1329,7 @@ static int mv643xx_eth_open(struct net_d
 	rdl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num));
 
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
-			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+			IRQF_SHARED, dev->name, dev);
 	if (err) {
 		printk(KERN_ERR "%s: Can not assign IRQ\n", dev->name);
 		return -EAGAIN;
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/netxen/netxen_nic_main.c linux-2.6.26-rc2-git3/drivers/net/netxen/netxen_nic_main.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/netxen/netxen_nic_main.c	2008-05-13 22:37:33.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/netxen/netxen_nic_main.c	2008-05-13 23:15:49.000000000 -0700
@@ -838,7 +838,7 @@ static int netxen_nic_open(struct net_de
 	int err = 0;
 	int ctx, ring;
 	irq_handler_t handler;
-	unsigned long flags = IRQF_SAMPLE_RANDOM;
+	unsigned long flags = 0;
 
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC) {
 		err = netxen_init_firmware(adapter);
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/niu.c linux-2.6.26-rc2-git3/drivers/net/niu.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/niu.c	2008-05-13 22:37:26.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/niu.c	2008-05-13 23:19:55.000000000 -0700
@@ -5605,8 +5605,7 @@ static int niu_request_irq(struct niu *n
 		struct niu_ldg *lp = &np->ldg[i];
 
 		err = request_irq(lp->irq, niu_interrupt,
-				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-				  np->dev->name, lp);
+				  IRQF_SHARED, np->dev->name, lp);
 		if (err)
 			goto out_free_irqs;
 
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/qla3xxx.c linux-2.6.26-rc2-git3/drivers/net/qla3xxx.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/qla3xxx.c	2008-05-13 22:38:09.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/qla3xxx.c	2008-05-13 23:20:09.000000000 -0700
@@ -3618,7 +3618,7 @@ static int ql_adapter_up(struct ql3_adap
 {
 	struct net_device *ndev = qdev->ndev;
 	int err;
-	unsigned long irq_flags = IRQF_SAMPLE_RANDOM | IRQF_SHARED;
+	unsigned long irq_flags = IRQF_SHARED;
 	unsigned long hw_flags;
 
 	if (ql_alloc_mem_resources(qdev)) {
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/tg3.c linux-2.6.26-rc2-git3/drivers/net/tg3.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/tg3.c	2008-05-13 22:38:12.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/tg3.c	2008-05-13 23:22:03.000000000 -0700
@@ -7496,12 +7496,12 @@ static int tg3_request_irq(struct tg3 *t
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
@@ -7519,7 +7519,7 @@ static int tg3_test_interrupt(struct tg3
 	free_irq(tp->pdev->irq, dev);
 
 	err = request_irq(tp->pdev->irq, tg3_test_isr,
-			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+			  IRQF_SHARED, dev->name, dev);
 	if (err)
 		return err;
 
diff -uprN linux-2.6.26-rc2-git3.orig/drivers/net/xen-netfront.c linux-2.6.26-rc2-git3/drivers/net/xen-netfront.c
--- linux-2.6.26-rc2-git3.orig/drivers/net/xen-netfront.c	2008-05-13 22:37:38.000000000 -0700
+++ linux-2.6.26-rc2-git3/drivers/net/xen-netfront.c	2008-05-13 23:20:47.000000000 -0700
@@ -1363,8 +1363,7 @@ static int setup_netfront(struct xenbus_
 		goto fail;
 
 	err = bind_evtchn_to_irqhandler(info->evtchn, xennet_interrupt,
-					IRQF_SAMPLE_RANDOM, netdev->name,
-					netdev);
+					0, netdev->name, netdev);
 	if (err < 0)
 		goto fail;
 	netdev->irq = err;
