From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 1/5] sc92031: more useful banner in kernel log
Date: Mon, 12 Jan 2009 21:21:47 -0200
Message-ID: <1231802511-14825-1-git-send-email-cesarb@cesarb.net>
References: <496BD04F.2050502@cesarb.net>
Cc: netdev@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-01.mandic.com.br ([200.225.81.132]:58013 "EHLO
	smtp-01.mandic.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbZALX3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 18:29:15 -0500
In-Reply-To: <496BD04F.2050502@cesarb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The banner currently printed when loading the module is mostly useless.

Replace it with a more informative one, printed after probing the device.

Output format copied from 8139cp/8139too.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/sc92031.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 42fd312..40b39af 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1422,6 +1422,7 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,
 	struct net_device *dev;
 	struct sc92031_priv *priv;
 	u32 mac0, mac1;
+	unsigned long base_addr;
 
 	err = pci_enable_device(pdev);
 	if (unlikely(err < 0))
@@ -1496,6 +1497,14 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,
 	if (err < 0)
 		goto out_register_netdev;
 
+#if SC92031_USE_BAR == 0
+	base_addr = dev->mem_start;
+#elif SC92031_USE_BAR == 1
+	base_addr = dev->base_addr;
+#endif
+	printk(KERN_INFO "%s: SC92031 at 0x%lx, %pM, IRQ %d\n", dev->name,
+			base_addr, dev->dev_addr, dev->irq);
+
 	return 0;
 
 out_register_netdev:
@@ -1602,7 +1611,6 @@ static struct pci_driver sc92031_pci_driver = {
 
 static int __init sc92031_init(void)
 {
-	printk(KERN_INFO SC92031_DESCRIPTION " " SC92031_VERSION "\n");
 	return pci_register_driver(&sc92031_pci_driver);
 }
 
-- 
1.6.1.dirty

