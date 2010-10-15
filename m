From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] 3c52x: remove IRQF_SAMPLE_RANDOM from legacy MCA drivers.
Date: Thu, 14 Oct 2010 20:21:51 -0400
Message-ID: <1287102111-5482-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63277 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab0JOAVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 20:21:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you are genuinely using one of these legacy MCA drivers
then you are tragically on hardware where you really don't
have the extra CPU cycles to be wasting on this.

In addition, it makes two less cases for people to inadvertently
blindly copy flags from without explicitly thinking whether it
makes sense -- see the addition to feature-removal.txt as per
commit 9d9b8fb0e5ebf4b0398e579f6061d4451fea3242.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/3c523.c |    2 +-
 drivers/net/3c527.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 1719079..3aa9baa 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -287,7 +287,7 @@ static int elmc_open(struct net_device *dev)
 
 	elmc_id_attn586();	/* disable interrupts */
 
-	ret = request_irq(dev->irq, elmc_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM,
+	ret = request_irq(dev->irq, elmc_interrupt, IRQF_SHARED,
 			  dev->name, dev);
 	if (ret) {
 		pr_err("%s: couldn't get irq %d\n", dev->name, dev->irq);
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
-- 
1.7.2.1

