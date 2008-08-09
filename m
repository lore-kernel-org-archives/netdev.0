From: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
Subject: [PATCH] cs89x0: add support for i.MX31ADS ARM board
Date: Sat, 09 Aug 2008 19:13:45 +0200
Message-ID: <489DD049.6020106@xenomai.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenomai.org ([88.191.250.36]:42736 "EHLO xenomai.fsffrance.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbYHIRV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Aug 2008 13:21:26 -0400
Received: from men13-3-82-231-18-196.fbx.proxad.net ([82.231.18.196] helo=sisyphus)
	by xenomai.fsffrance.org with esmtpsa (TLS-1.0:RSA_AES_256_CBC_SHA:32)
	(Exim 4.50)
	id 1KRs0k-0000nX-J4
	for netdev@vger.kernel.org; Sat, 09 Aug 2008 19:13:50 +0200
Received: from localhost ([127.0.0.1])
	by sisyphus with esmtp (Exim 4.63)
	(envelope-from <gilles.chanteperdrix@xenomai.org>)
	id 1KRs0g-0001Sx-3p
	for netdev@vger.kernel.org; Sat, 09 Aug 2008 19:13:46 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
---
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index ea6144a..875a43d 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -194,6 +194,12 @@ static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
 #define CIRRUS_DEFAULT_IRQ	VH_INTC_INT_NUM_CASCADED_INTERRUPT_1 /* Event inputs bank 1 - ID 35/bit 3 */
 static unsigned int netcard_portlist[] __used __initdata = {CIRRUS_DEFAULT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {CIRRUS_DEFAULT_IRQ, 0, 0, 0};
+#elif defined(CONFIG_MACH_MX31ADS)
+#include <mach/board-mx31ads.h>
+static unsigned int netcard_portlist[] __used __initdata = {
+	PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
+};
+static unsigned cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
 #else
 static unsigned int netcard_portlist[] __used __initdata =
    { 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
@@ -802,7 +808,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 	} else {
 		i = lp->isa_config & INT_NO_MASK;
 		if (lp->chip_type == CS8900) {
-#if defined(CONFIG_MACH_IXDP2351) || defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_ARCH_PNX010X)
+#if defined(CONFIG_MACH_IXDP2351) || defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_ARCH_PNX010X) || defined(CONFIG_MACH_MX31ADS)
 		        i = cs8900_irq_map[0];
 #else
 			/* Translate the IRQ using the IRQ mapping table. */
@@ -1029,6 +1035,7 @@ skip_this_frame:
 
 void  __init reset_chip(struct net_device *dev)
 {
+#if !defined(CONFIG_MACH_MX31ADS)
 #if !defined(CONFIG_MACH_IXDP2351) && !defined(CONFIG_ARCH_IXDP2X01)
 	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
@@ -1057,6 +1064,7 @@ void  __init reset_chip(struct net_device *dev)
 	reset_start_time = jiffies;
 	while( (readreg(dev, PP_SelfST) & INIT_DONE) == 0 && jiffies - reset_start_time < 2)
 		;
+#endif /* !CONFIG_MACH_MX31ADS */
 }
 
 
@@ -1304,7 +1312,7 @@ net_open(struct net_device *dev)
 	else
 #endif
 	{
-#if !defined(CONFIG_MACH_IXDP2351) && !defined(CONFIG_ARCH_IXDP2X01) && !defined(CONFIG_ARCH_PNX010X)
+#if !defined(CONFIG_MACH_IXDP2351) && !defined(CONFIG_ARCH_IXDP2X01) && !defined(CONFIG_ARCH_PNX010X) && !defined(CONFIG_MACH_MX31ADS)
 		if (((1 << dev->irq) & lp->irq_map) == 0) {
 			printk(KERN_ERR "%s: IRQ %d is not in our map of allowable IRQs, which is %x\n",
                                dev->name, dev->irq, lp->irq_map);

