From: Chris Peterson <cpeterso@cpeterso.com>
Subject: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Sat, 10 Apr 2010 01:29:40 -0400
Message-ID: <1270877380-23813-1-git-send-email-cpeterso@cpeterso.com>
Cc: linux-kernel@vger.kernel.org, mpm@selenic.com,
	Chris Peterson <cpeterso@cpeterso.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f171.google.com ([209.85.210.171]:34048 "EHLO
	mail-yx0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701Ab0DJF3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Apr 2010 01:29:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

feature-removal-schedule.txt says a new /dev/random entropy model is planned 
(for July 2009). Until then, this patch removes the few remaining uses of 
IRQF_SAMPLE_RANDOM from drivers/net/*. 12 network drivers are affected, one 
more than last year (netxen_nic_main.c). If idle servers need more entropy, 
they ought to use a hardware RNG or an entropy-gathering userspace daemon.

Signed-off-by: Chris Peterson <cpeterso@cpeterso.com>
---
 drivers/net/3c523.c                  |    3 +--
 drivers/net/3c527.c                  |    2 +-
 drivers/net/atlx/atl1.c              |    2 +-
 drivers/net/bcm63xx_enet.c           |    2 +-
 drivers/net/cris/eth_v10.c           |    2 +-
 drivers/net/ibmlana.c                |    2 +-
 drivers/net/macb.c                   |    3 +--
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 drivers/net/niu.c                    |    4 +---
 drivers/net/qla3xxx.c                |    2 +-
 drivers/net/tg3.c                    |    6 +++---
 drivers/net/xen-netfront.c           |    3 +--
 12 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 1719079..f235f7b 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -287,8 +287,7 @@ static int elmc_open(struct net_device *dev)
 
 	elmc_id_attn586();	/* disable interrupts */
 
-	ret = request_irq(dev->irq, elmc_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
+	ret = request_irq(dev->irq, elmc_interrupt, IRQF_SHARED, dev->name, dev);
 	if (ret) {
 		pr_err("%s: couldn't get irq %d\n", dev->name, dev->irq);
 		elmc_id_reset586();
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index 5c07b14..cf4cfd3 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -443,7 +443,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	 *	Grab the IRQ
 	 */
 
-	err = request_irq(dev->irq, mc32_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM, DRV_NAME, dev);
+	err = request_irq(dev->irq, mc32_interrupt, IRQF_SHARED, DRV_NAME, dev);
 	if (err) {
 		release_region(dev->base_addr, MC32_IO_EXTENT);
 		pr_err("%s: unable to get IRQ %d.\n", DRV_NAME, dev->irq);
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 0ebd820..7a3e4b6 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2565,7 +2565,7 @@ static s32 atl1_up(struct atl1_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int err;
-	int irq_flags = IRQF_SAMPLE_RANDOM;
+	int irq_flags = 0;
 
 	/* hardware has been reset, we need to reload some things */
 	atlx_set_multi(netdev);
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 17460ab..0c47602 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -843,7 +843,7 @@ static int bcm_enet_open(struct net_device *dev)
 		goto out_phy_disconnect;
 
 	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma,
-			  IRQF_SAMPLE_RANDOM | IRQF_DISABLED, dev->name, dev);
+			  IRQF_DISABLED, dev->name, dev);
 	if (ret)
 		goto out_freeirq;
 
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 61a3391..0b56b1b 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -493,7 +493,7 @@ e100_open(struct net_device *dev)
 	/* allocate the irq corresponding to the receiving DMA */
 
 	if (request_irq(NETWORK_DMA_RX_IRQ_NBR, e100rxtx_interrupt,
-			IRQF_SAMPLE_RANDOM, cardname, (void *)dev)) {
+			0, cardname, (void *)dev)) {
 		goto grace_exit0;
 	}
 
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 7d6cf33..35e668b 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -782,7 +782,7 @@ static int ibmlana_open(struct net_device *dev)
 
 	/* register resources - only necessary for IRQ */
 
-	result = request_irq(priv->realirq, irq_handler, IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+	result = request_irq(priv->realirq, irq_handler, IRQF_SHARED, dev->name, dev);
 	if (result != 0) {
 		printk(KERN_ERR "%s: failed to register irq %d\n", dev->name, dev->irq);
 		return result;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index c8a18a6..9324097 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1167,8 +1167,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	}
 
 	dev->irq = platform_get_irq(pdev, 0);
-	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
+	err = request_irq(dev->irq, macb_interrupt, dev->name, dev);
 	if (err) {
 		printk(KERN_ERR
 		       "%s: Unable to request IRQ %d (error %d)\n",
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index ce838f7..cbbbe64 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -906,7 +906,7 @@ netxen_nic_request_irq(struct netxen_adapter *adapter)
 	struct nx_host_sds_ring *sds_ring;
 	int err, ring;
 
-	unsigned long flags = IRQF_SAMPLE_RANDOM;
+	unsigned long flags = 0;
 	struct net_device *netdev = adapter->netdev;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index d5cd16b..f11a3c4 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6053,11 +6053,9 @@ static int niu_request_irq(struct niu *np)
 		struct niu_ldg *lp = &np->ldg[i];
 
 		err = request_irq(lp->irq, niu_interrupt,
-				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-				  np->irq_name[i], lp);
+				  IRQF_SHARED, np->irq_name[i], lp);
 		if (err)
 			goto out_free_irqs;
-
 	}
 
 	return 0;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 4ef0afb..961b08d 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3605,7 +3605,7 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 {
 	struct net_device *ndev = qdev->ndev;
 	int err;
-	unsigned long irq_flags = IRQF_SAMPLE_RANDOM | IRQF_SHARED;
+	unsigned long irq_flags = IRQF_SHARED;
 	unsigned long hw_flags;
 
 	if (ql_alloc_mem_resources(qdev)) {
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 22cf1c4..9ac2869 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8510,12 +8510,12 @@ static int tg3_request_irq(struct tg3 *tp, int irq_num)
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
 
 	return request_irq(tnapi->irq_vec, fn, flags, name, tnapi);
@@ -8547,7 +8547,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	}
 
 	err = request_irq(tnapi->irq_vec, tg3_test_isr,
-			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, tnapi);
+			  IRQF_SHARED, dev->name, tnapi);
 	if (err)
 		return err;
 
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d504e2b..7666dfc 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1383,8 +1383,7 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 		goto fail;
 
 	err = bind_evtchn_to_irqhandler(info->evtchn, xennet_interrupt,
-					IRQF_SAMPLE_RANDOM, netdev->name,
-					netdev);
+					0, netdev->name, netdev);
 	if (err < 0)
 		goto fail;
 	netdev->irq = err;
