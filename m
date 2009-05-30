From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [net-next-2.6 PATCH 1/3] can: some fixes and cleanups to the initial device driver interface
Date: Sat, 30 May 2009 19:55:48 +0200
Message-ID: <20090530175547.973220489@denx.de>
References: <20090530175547.772116783@denx.de>
Cc: socketcan-core@lists.berlios.de,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:45032 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519AbZE3Rzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 13:55:48 -0400
Content-Disposition: inline; filename=misc-fixes.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a few errors sneaked into the initial version of the
device driver interface.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/dev.c             |    2 +-
 drivers/net/can/sja1000/ems_pci.c |    3 ---
 drivers/net/can/sja1000/sja1000.c |    2 +-
 3 files changed, 2 insertions(+), 5 deletions(-)

Index: net-next-2.6/drivers/net/can/dev.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/dev.c	2009-05-30 19:48:32.820720048 +0200
+++ net-next-2.6/drivers/net/can/dev.c	2009-05-30 19:48:38.044719620 +0200
@@ -477,7 +477,7 @@
 
 	return 0;
 }
-EXPORT_SYMBOL(open_candev);
+EXPORT_SYMBOL_GPL(open_candev);
 
 /*
  * Common close function for cleanup before the device gets closed.
Index: net-next-2.6/drivers/net/can/sja1000/ems_pci.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/ems_pci.c	2009-05-30 19:48:32.821720749 +0200
+++ net-next-2.6/drivers/net/can/sja1000/ems_pci.c	2009-05-30 19:48:38.045719203 +0200
@@ -218,14 +218,12 @@
 	card->conf_addr = pci_iomap(pdev, 0, EMS_PCI_MEM_SIZE);
 	if (card->conf_addr == NULL) {
 		err = -ENOMEM;
-
 		goto failure_cleanup;
 	}
 
 	card->base_addr = pci_iomap(pdev, 1, EMS_PCI_MEM_SIZE);
 	if (card->base_addr == NULL) {
 		err = -ENOMEM;
-
 		goto failure_cleanup;
 	}
 
@@ -239,7 +237,6 @@
 	    ems_pci_readb(card, 3) != 0xCB ||
 	    ems_pci_readb(card, 4) != 0x11) {
 		dev_err(&pdev->dev, "Not EMS Dr. Thomas Wuensche interface\n");
-
 		err = -ENODEV;
 		goto failure_cleanup;
 	}
Index: net-next-2.6/drivers/net/can/sja1000/sja1000.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.c	2009-05-30 19:48:32.821720749 +0200
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.c	2009-05-30 19:48:38.057718952 +0200
@@ -532,8 +532,8 @@
 		err = request_irq(dev->irq, &sja1000_interrupt, priv->irq_flags,
 				  dev->name, (void *)dev);
 		if (err) {
-			return -EAGAIN;
 			close_candev(dev);
+			return -EAGAIN;
 		}
 	}
 

