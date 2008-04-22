From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 3/6] ibm_newemac: Fix section mismatch warnings
Date: Tue, 22 Apr 2008 10:46:43 +1000
Message-ID: <20080422004759.9B727DE1C1@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43407 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761107AbYDVAsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 20:48:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Boyer <jwboyer@gmail.com>

This patch fixes several section mismatch warnings in the
ibm_newemac driver similar to:

WARNING: vmlinux.o(.devinit.text+0x3a04): Section mismatch in reference from the function emac_probe() to the function .devexit.text:tah_detach()
The function __devinit emac_probe() references
a function __devexit tah_detach().

Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 drivers/net/ibm_newemac/core.c  |    2 +-
 drivers/net/ibm_newemac/mal.c   |    4 ++--
 drivers/net/ibm_newemac/rgmii.c |    2 +-
 drivers/net/ibm_newemac/tah.c   |    2 +-
 drivers/net/ibm_newemac/zmii.c  |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

--- linux-work.orig/drivers/net/ibm_newemac/core.c	2008-04-22 10:02:32.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/core.c	2008-04-22 10:02:53.000000000 +1000
@@ -2240,7 +2240,7 @@ static int __devinit emac_of_bus_notify(
 	return 0;
 }
 
-static struct notifier_block emac_of_bus_notifier = {
+static struct notifier_block emac_of_bus_notifier __devinitdata = {
 	.notifier_call = emac_of_bus_notify
 };
 
Index: linux-work/drivers/net/ibm_newemac/mal.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/mal.c	2008-04-22 10:02:42.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/mal.c	2008-04-22 10:02:53.000000000 +1000
@@ -61,8 +61,8 @@ int __devinit mal_register_commac(struct
 	return 0;
 }
 
-void __devexit mal_unregister_commac(struct mal_instance	*mal,
-				     struct mal_commac		*commac)
+void mal_unregister_commac(struct mal_instance	*mal,
+		struct mal_commac *commac)
 {
 	unsigned long flags;
 
Index: linux-work/drivers/net/ibm_newemac/rgmii.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/rgmii.c	2008-03-19 13:52:35.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/rgmii.c	2008-04-22 10:02:53.000000000 +1000
@@ -179,7 +179,7 @@ void rgmii_put_mdio(struct of_device *of
 	mutex_unlock(&dev->lock);
 }
 
-void __devexit rgmii_detach(struct of_device *ofdev, int input)
+void rgmii_detach(struct of_device *ofdev, int input)
 {
 	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
 	struct rgmii_regs __iomem *p = dev->base;
Index: linux-work/drivers/net/ibm_newemac/tah.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/tah.c	2008-03-26 10:39:25.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/tah.c	2008-04-22 10:02:53.000000000 +1000
@@ -35,7 +35,7 @@ int __devinit tah_attach(struct of_devic
 	return 0;
 }
 
-void __devexit tah_detach(struct of_device *ofdev, int channel)
+void tah_detach(struct of_device *ofdev, int channel)
 {
 	struct tah_instance *dev = dev_get_drvdata(&ofdev->dev);
 
Index: linux-work/drivers/net/ibm_newemac/zmii.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/zmii.c	2008-03-03 11:58:49.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/zmii.c	2008-04-22 10:02:53.000000000 +1000
@@ -189,7 +189,7 @@ void zmii_set_speed(struct of_device *of
 	mutex_unlock(&dev->lock);
 }
 
-void __devexit zmii_detach(struct of_device *ofdev, int input)
+void zmii_detach(struct of_device *ofdev, int input)
 {
 	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
 
