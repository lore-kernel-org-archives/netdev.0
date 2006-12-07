From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 1/2] [IrDA] PXA FIR code device model conversion
Date: Thu, 7 Dec 2006 02:50:53 +0200
Message-ID: <20061207005053.GA21131@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users@lists.sourceforge.net,
	Paul Sokolovsky <pmiscml@gmail.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp10.orange.fr ([193.252.22.21]:18436 "EHLO
	smtp-msa-out10.orange.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S937864AbWLGAu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:50:58 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

pxaficp_ir.c was not converted to the device model framework.

Signed-off-by: Paul Sokolovsky <pmiscml@gmail.com>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/pxaficp_ir.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index f9a1c88..9137e23 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -704,9 +704,9 @@ static int pxa_irda_stop(struct net_devi
 	return 0;
 }
 
-static int pxa_irda_suspend(struct device *_dev, pm_message_t state)
+static int pxa_irda_suspend(struct platform_device *_dev, pm_message_t state)
 {
-	struct net_device *dev = dev_get_drvdata(_dev);
+	struct net_device *dev = platform_get_drvdata(_dev);
 	struct pxa_irda *si;
 
 	if (dev && netif_running(dev)) {
@@ -718,9 +718,9 @@ static int pxa_irda_suspend(struct devic
 	return 0;
 }
 
-static int pxa_irda_resume(struct device *_dev)
+static int pxa_irda_resume(struct platform_device *_dev)
 {
-	struct net_device *dev = dev_get_drvdata(_dev);
+	struct net_device *dev = platform_get_drvdata(_dev);
 	struct pxa_irda *si;
 
 	if (dev && netif_running(dev)) {
@@ -746,9 +746,8 @@ static int pxa_irda_init_iobuf(iobuff_t 
 	return io->head ? 0 : -ENOMEM;
 }
 
-static int pxa_irda_probe(struct device *_dev)
+static int pxa_irda_probe(struct platform_device *pdev)
 {
-	struct platform_device *pdev = to_platform_device(_dev);
 	struct net_device *dev;
 	struct pxa_irda *si;
 	unsigned int baudrate_mask;
@@ -822,9 +821,9 @@ err_mem_1:
 	return err;
 }
 
-static int pxa_irda_remove(struct device *_dev)
+static int pxa_irda_remove(struct platform_device *_dev)
 {
-	struct net_device *dev = dev_get_drvdata(_dev);
+	struct net_device *dev = platform_get_drvdata(_dev);
 
 	if (dev) {
 		struct pxa_irda *si = netdev_priv(dev);
@@ -840,9 +839,10 @@ static int pxa_irda_remove(struct device
 	return 0;
 }
 
-static struct device_driver pxa_ir_driver = {
-	.name		= "pxa2xx-ir",
-	.bus		= &platform_bus_type,
+static struct platform_driver pxa_ir_driver = {
+	.driver         = {
+		.name   = "pxa2xx-ir",
+	},
 	.probe		= pxa_irda_probe,
 	.remove		= pxa_irda_remove,
 	.suspend	= pxa_irda_suspend,
@@ -851,12 +851,12 @@ static struct device_driver pxa_ir_drive
 
 static int __init pxa_irda_init(void)
 {
-	return driver_register(&pxa_ir_driver);
+	return platform_driver_register(&pxa_ir_driver);
 }
 
 static void __exit pxa_irda_exit(void)
 {
-	driver_unregister(&pxa_ir_driver);
+	platform_driver_unregister(&pxa_ir_driver);
 }
 
 module_init(pxa_irda_init);
-- 
1.4.2.3

