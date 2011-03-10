From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH 2/8] macb: detect hclk presence from platform data
Date: Thu, 10 Mar 2011 11:41:37 +0000
Message-ID: <20110310114137.GC6198@pulham.picochip.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-3-git-send-email-jamie@jamieiles.com>
 <20110310101554.GD11273@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50669 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab1CJLll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 06:41:41 -0500
Received: by wwa36 with SMTP id 36so1832596wwa.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 03:41:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110310101554.GD11273@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2011 at 10:15:54AM +0000, Russell King - ARM Linux wrote:
> On Thu, Mar 10, 2011 at 10:10:37AM +0000, Jamie Iles wrote:
> > Rather than detecting whether we need to do a clk_get() and enable on
> > the "hclk" based on the kernel configuration, add an extra field to the
> > platform data.  This makes it cleaner to add more supported
> > architectures without lots of ifdeffery.
> 
> Why not have the platform provide a dummy hclk if no real hclk exists?

Yes, that would be much better.  In that case, this patch can be 
replaced with the two below.  I'll repost the series with the other 
patches refreshed, but I'd like someone with AT91 knowledge to check 
that at91_clock_associate() is doing what I think it is first.

This also means that the driver doesn't need a conditional on ARCH_AT91 
for the pclk name.

Jamie

>From 11dc6ca059e848295db8c0c534ece196e8f9ff37 Mon Sep 17 00:00:00 2001
From: Jamie Iles <jamie@jamieiles.com>
Date: Thu, 10 Mar 2011 11:11:20 +0000
Subject: [PATCH 1/2] at91: provide pclk and hclk for macb ethernet devices

AT91 has a "macb_pclk" which is used to control the clock to the
Ethernet controller, but this is a different name to the AVR32
devices that use "pclk".  Associate the clock with the names "pclk"
and "hclk" and the macb driver doesn't need to handle the two
architectures differently.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 arch/arm/mach-at91/at572d940hf_devices.c |    3 +++
 arch/arm/mach-at91/at91cap9_devices.c    |    3 +++
 arch/arm/mach-at91/at91rm9200_devices.c  |    3 +++
 arch/arm/mach-at91/at91sam9260_devices.c |    3 +++
 arch/arm/mach-at91/at91sam9263_devices.c |    3 +++
 arch/arm/mach-at91/at91sam9g45_devices.c |    3 +++
 6 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-at91/at572d940hf_devices.c b/arch/arm/mach-at91/at572d940hf_devices.c
index 6e1b9a3..9234b4e 100644
--- a/arch/arm/mach-at91/at572d940hf_devices.c
+++ b/arch/arm/mach-at91/at572d940hf_devices.c
@@ -192,6 +192,9 @@ void __init at91_add_device_eth(struct eth_platform_data *data)
 	at91_set_A_periph(AT91_PIN_PA13, 0);	/* EMDIO */
 	at91_set_A_periph(AT91_PIN_PA14, 0);	/* EMDC */
 
+	at91_clock_associate("macb_clk", &at572d940hf_eth_device.dev, "pclk");
+	at91_clock_associate("macb_clk", &at572d940hf_eth_device.dev, "hclk");
+
 	eth_data = *data;
 	platform_device_register(&at572d940hf_eth_device);
 }
diff --git a/arch/arm/mach-at91/at91cap9_devices.c b/arch/arm/mach-at91/at91cap9_devices.c
index e041743..5c57885 100644
--- a/arch/arm/mach-at91/at91cap9_devices.c
+++ b/arch/arm/mach-at91/at91cap9_devices.c
@@ -258,6 +258,9 @@ void __init at91_add_device_eth(struct eth_platform_data *data)
 		at91_set_B_periph(AT91_PIN_PC24, 0);	/* ETXER */
 	}
 
+	at91_clock_associate("macb_clk", &at91cap9_eth_device.dev, "pclk");
+	at91_clock_associate("macb_clk", &at91cap9_eth_device.dev, "hclk");
+
 	eth_data = *data;
 	platform_device_register(&at91cap9_eth_device);
 }
diff --git a/arch/arm/mach-at91/at91rm9200_devices.c b/arch/arm/mach-at91/at91rm9200_devices.c
index 5f873d5..e7b8ec3 100644
--- a/arch/arm/mach-at91/at91rm9200_devices.c
+++ b/arch/arm/mach-at91/at91rm9200_devices.c
@@ -187,6 +187,9 @@ void __init at91_add_device_eth(struct eth_platform_data *data)
 		at91_set_B_periph(AT91_PIN_PB12, 0);	/* ETX2 */
 	}
 
+	at91_clock_associate("macb_clk", &at91rm9200_eth_device.dev, "pclk");
+	at91_clock_associate("macb_clk", &at91rm9200_eth_device.dev, "hclk");
+
 	eth_data = *data;
 	platform_device_register(&at91rm9200_eth_device);
 }
diff --git a/arch/arm/mach-at91/at91sam9260_devices.c b/arch/arm/mach-at91/at91sam9260_devices.c
index e172b46..9ff8592 100644
--- a/arch/arm/mach-at91/at91sam9260_devices.c
+++ b/arch/arm/mach-at91/at91sam9260_devices.c
@@ -188,6 +188,9 @@ void __init at91_add_device_eth(struct eth_platform_data *data)
 		at91_set_B_periph(AT91_PIN_PA22, 0);	/* ETXER */
 	}
 
+	at91_clock_associate("macb_clk", &at91sam9260_eth_device.dev, "pclk");
+	at91_clock_associate("macb_clk", &at91sam9260_eth_device.dev, "hclk");
+
 	eth_data = *data;
 	platform_device_register(&at91sam9260_eth_device);
 }
diff --git a/arch/arm/mach-at91/at91sam9263_devices.c b/arch/arm/mach-at91/at91sam9263_devices.c
index 416613c..46560e9 100644
--- a/arch/arm/mach-at91/at91sam9263_devices.c
+++ b/arch/arm/mach-at91/at91sam9263_devices.c
@@ -198,6 +198,9 @@ void __init at91_add_device_eth(struct eth_platform_data *data)
 		at91_set_B_periph(AT91_PIN_PC24, 0);	/* ETXER */
 	}
 
+	at91_clock_associate("macb_clk", &at91sam9263_eth_device.dev, "pclk");
+	at91_clock_associate("macb_clk", &at91sam9263_eth_device.dev, "hclk");
+
 	eth_data = *data;
 	platform_device_register(&at91sam9263_eth_device);
 }
diff --git a/arch/arm/mach-at91/at91sam9g45_devices.c b/arch/arm/mach-at91/at91sam9g45_devices.c
index 0867343..ab46ae7 100644
--- a/arch/arm/mach-at91/at91sam9g45_devices.c
+++ b/arch/arm/mach-at91/at91sam9g45_devices.c
@@ -343,6 +343,9 @@ void __init at91_add_device_eth(struct eth_platform_data *data)
 		at91_set_B_periph(AT91_PIN_PA27, 0);	/* ETXER */
 	}
 
+	at91_clock_associate("macb_clk", &at91sam9g45_eth_device.dev, "pclk");
+	at91_clock_associate("macb_clk", &at91sam9g45_eth_device.dev, "hclk");
+
 	eth_data = *data;
 	platform_device_register(&at91sam9g45_eth_device);
 }
-- 
1.7.4

>From 7dfd4a15bbb0b5c14be44ebc54c3038423086418 Mon Sep 17 00:00:00 2001
From: Jamie Iles <jamie@jamieiles.com>
Date: Tue, 8 Mar 2011 20:19:23 +0000
Subject: [PATCH 2/2] macb: remove conditional clk handling

AT91 now provides both "pclk" and "hclk" aliases for the the macb
device so we can use the same clk handling paths for both AT91 and
AVR32.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/macb.c |   27 +++------------------------
 1 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index bfd3601..8e6d8e3 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -246,9 +246,7 @@ static int macb_mii_init(struct macb *bp)
 	bp->mii_bus->parent = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
 
-	if (pdata)
-		bp->mii_bus->phy_mask = pdata->phy_mask;
-
+	bp->mii_bus->phy_mask = pdata->phy_mask;
 	bp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (!bp->mii_bus->irq) {
 		err = -ENOMEM;
@@ -1138,28 +1136,19 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	spin_lock_init(&bp->lock);
 
-#if defined(CONFIG_ARCH_AT91)
-	bp->pclk = clk_get(&pdev->dev, "macb_clk");
+	bp->pclk = clk_get(&pdev->dev, "pclk");
 	if (IS_ERR(bp->pclk)) {
 		dev_err(&pdev->dev, "failed to get macb_clk\n");
 		goto err_out_free_dev;
 	}
 	clk_enable(bp->pclk);
-#else
-	bp->pclk = clk_get(&pdev->dev, "pclk");
-	if (IS_ERR(bp->pclk)) {
-		dev_err(&pdev->dev, "failed to get pclk\n");
-		goto err_out_free_dev;
-	}
+
 	bp->hclk = clk_get(&pdev->dev, "hclk");
 	if (IS_ERR(bp->hclk)) {
 		dev_err(&pdev->dev, "failed to get hclk\n");
 		goto err_out_put_pclk;
 	}
-
-	clk_enable(bp->pclk);
 	clk_enable(bp->hclk);
-#endif
 
 	bp->regs = ioremap(regs->start, regs->end - regs->start + 1);
 	if (!bp->regs) {
@@ -1243,14 +1232,10 @@ err_out_free_irq:
 err_out_iounmap:
 	iounmap(bp->regs);
 err_out_disable_clocks:
-#ifndef CONFIG_ARCH_AT91
 	clk_disable(bp->hclk);
 	clk_put(bp->hclk);
-#endif
 	clk_disable(bp->pclk);
-#ifndef CONFIG_ARCH_AT91
 err_out_put_pclk:
-#endif
 	clk_put(bp->pclk);
 err_out_free_dev:
 	free_netdev(dev);
@@ -1276,10 +1261,8 @@ static int __exit macb_remove(struct platform_device *pdev)
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		iounmap(bp->regs);
-#ifndef CONFIG_ARCH_AT91
 		clk_disable(bp->hclk);
 		clk_put(bp->hclk);
-#endif
 		clk_disable(bp->pclk);
 		clk_put(bp->pclk);
 		free_netdev(dev);
@@ -1297,9 +1280,7 @@ static int macb_suspend(struct platform_device *pdev, pm_message_t state)
 
 	netif_device_detach(netdev);
 
-#ifndef CONFIG_ARCH_AT91
 	clk_disable(bp->hclk);
-#endif
 	clk_disable(bp->pclk);
 
 	return 0;
@@ -1311,9 +1292,7 @@ static int macb_resume(struct platform_device *pdev)
 	struct macb *bp = netdev_priv(netdev);
 
 	clk_enable(bp->pclk);
-#ifndef CONFIG_ARCH_AT91
 	clk_enable(bp->hclk);
-#endif
 
 	netif_device_attach(netdev);
 
-- 
1.7.4

