From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [RFC] IXP4xx: Silence section mismatch warning in Ethernet driver.
Date: Sun, 21 Dec 2008 02:11:10 +0100
Message-ID: <m3vdtebadt.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:37433 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751629AbYLUBLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2008 20:11:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few patches I'm posting for review only.

Not for operational use.

    IXP4xx: Silence section mismatch warning in Ethernet driver.

--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -1232,7 +1232,7 @@ static int __devexit eth_remove_one(struct platform_device *pdev)
 	return 0;
 }
 
-static struct platform_driver drv = {
+static struct platform_driver ixp4xx_eth_driver = {
 	.driver.name	= DRV_NAME,
 	.probe		= eth_init_one,
 	.remove		= eth_remove_one,
@@ -1248,12 +1248,12 @@ static int __init eth_init_module(void)
 	mdio_regs = (struct eth_regs __iomem *)IXP4XX_EthB_BASE_VIRT;
 	__raw_writel(DEFAULT_CORE_CNTRL, &mdio_regs->core_control);
 
-	return platform_driver_register(&drv);
+	return platform_driver_register(&ixp4xx_eth_driver);
 }
 
 static void __exit eth_cleanup_module(void)
 {
-	platform_driver_unregister(&drv);
+	platform_driver_unregister(&ixp4xx_eth_driver);
 }
 
 MODULE_AUTHOR("Krzysztof Halasa");

-- 
Krzysztof Halasa
