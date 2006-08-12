From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] CONFIG_PM=n slim: drivers/net/*
Date: Sat, 12 Aug 2006 04:46:23 +0400
Message-ID: <20060812004623.GM6847@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:6007 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S964804AbWHLAqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 20:46:24 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1025525ugc
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2006 17:46:22 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compile out dead code for CONFIG_PM=n users.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/amd8111e.c |   10 +++++++++-
 drivers/net/b44.c      |    4 ++++
 drivers/net/bnx2.c     |    4 ++++
 drivers/net/tg3.c      |    4 ++++
 4 files changed, 21 insertions(+), 1 deletion(-)

--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1769,6 +1769,8 @@ static void amd8111e_vlan_rx_kill_vid(st
 	spin_unlock_irq(&lp->lock);
 }
 #endif
+
+#ifdef CONFIG_PM
 static int amd8111e_enable_magicpkt(struct amd8111e_priv* lp)
 {
 	writel( VAL1|MPPLBA, lp->mmio + CMD3);
@@ -1789,6 +1791,8 @@ static int amd8111e_enable_link_change(s
 	readl(lp->mmio + CMD7);
 	return 0;
 }	
+#endif
+
 /* This function is called when a packet transmission fails to complete within a  resonable period, on the assumption that an interrupts have been failed or the  interface is locked up. This function will reinitialize the hardware */
 
 static void amd8111e_tx_timeout(struct net_device *dev)
@@ -1804,6 +1808,8 @@ static void amd8111e_tx_timeout(struct n
 	if(!err)
 		netif_wake_queue(dev);
 }
+
+#ifdef CONFIG_PM
 static int amd8111e_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {	
 	struct net_device *dev = pci_get_drvdata(pci_dev);
@@ -1873,7 +1879,7 @@ static int amd8111e_resume(struct pci_de
 
 	return 0;
 }
-
+#endif
 
 static void __devexit amd8111e_remove_one(struct pci_dev *pdev)
 {
@@ -2152,8 +2158,10 @@ static struct pci_driver amd8111e_driver
 	.id_table	= amd8111e_pci_tbl,
 	.probe		= amd8111e_probe_one,
 	.remove		= __devexit_p(amd8111e_remove_one),
+#ifdef CONFIG_PM
 	.suspend	= amd8111e_suspend,
 	.resume		= amd8111e_resume
+#endif
 };
 
 static int __init amd8111e_init(void)
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2279,6 +2279,7 @@ static void __devexit b44_remove_one(str
 	pci_set_drvdata(pdev, NULL);
 }
 
+#ifdef CONFIG_PM
 static int b44_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
@@ -2336,14 +2337,17 @@ static int b44_resume(struct pci_dev *pd
 	netif_wake_queue(dev);
 	return 0;
 }
+#endif
 
 static struct pci_driver b44_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= b44_pci_tbl,
 	.probe		= b44_init_one,
 	.remove		= __devexit_p(b44_remove_one),
+#ifdef CONFIG_PM
         .suspend        = b44_suspend,
         .resume         = b44_resume,
+#endif
 };
 
 static int __init b44_init(void)
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5962,6 +5962,7 @@ bnx2_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
+#ifdef CONFIG_PM
 static int
 bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
 {
@@ -6003,14 +6004,17 @@ bnx2_resume(struct pci_dev *pdev)
 	bnx2_netif_start(bp);
 	return 0;
 }
+#endif
 
 static struct pci_driver bnx2_pci_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= bnx2_pci_tbl,
 	.probe		= bnx2_init_one,
 	.remove		= __devexit_p(bnx2_remove_one),
+#ifdef CONFIG_PM
 	.suspend	= bnx2_suspend,
 	.resume		= bnx2_resume,
+#endif
 };
 
 static int __init bnx2_init(void)
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11722,6 +11722,7 @@ static void __devexit tg3_remove_one(str
 	}
 }
 
+#ifdef CONFIG_PM
 static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
@@ -11802,14 +11803,17 @@ out:
 
 	return err;
 }
+#endif
 
 static struct pci_driver tg3_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= tg3_pci_tbl,
 	.probe		= tg3_init_one,
 	.remove		= __devexit_p(tg3_remove_one),
+#ifdef CONFIG_PM
 	.suspend	= tg3_suspend,
 	.resume		= tg3_resume
+#endif
 };
 
 static int __init tg3_init(void)

