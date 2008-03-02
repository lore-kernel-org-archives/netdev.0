From: Josh Boyer <jwboyer@gmail.com>
Subject: [PATCH][NEWEMAC] Fix section mismatch warnings
Date: Sun, 2 Mar 2008 16:37:32 -0600
Message-ID: <20080302163732.7c3af536@vader.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:54476 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbYCBWhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 17:37:43 -0500
Received: by py-out-1112.google.com with SMTP id u52so8770801pyb.10
        for <netdev@vger.kernel.org>; Sun, 02 Mar 2008 14:37:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes several section mismatch warnings in the
ibm_newemac driver similar to:

WARNING: vmlinux.o(.devinit.text+0x3a04): Section mismatch in reference from the function emac_probe() to the function .devexit.text:tah_detach()
The function __devinit emac_probe() references
a function __devexit tah_detach().

Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

---
 drivers/net/ibm_newemac/core.c  |    2 +-
 drivers/net/ibm_newemac/mal.c   |    4 ++--
 drivers/net/ibm_newemac/rgmii.c |    2 +-
 drivers/net/ibm_newemac/tah.c   |    2 +-
 drivers/net/ibm_newemac/zmii.c  |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

--- linux-2.6.orig/drivers/net/ibm_newemac/core.c
+++ linux-2.6/drivers/net/ibm_newemac/core.c
@@ -2230,7 +2230,7 @@ static int __devinit emac_of_bus_notify(
 	return 0;
 }
 
-static struct notifier_block emac_of_bus_notifier = {
+static struct notifier_block emac_of_bus_notifier __devinitdata = {
 	.notifier_call = emac_of_bus_notify
 };
 
--- linux-2.6.orig/drivers/net/ibm_newemac/mal.c
+++ linux-2.6/drivers/net/ibm_newemac/mal.c
@@ -61,8 +61,8 @@ int __devinit mal_register_commac(struct
 	return 0;
 }
 
-void __devexit mal_unregister_commac(struct mal_instance	*mal,
-				     struct mal_commac		*commac)
+void mal_unregister_commac(struct mal_instance	*mal,
+		struct mal_commac *commac)
 {
 	unsigned long flags;
 
--- linux-2.6.orig/drivers/net/ibm_newemac/rgmii.c
+++ linux-2.6/drivers/net/ibm_newemac/rgmii.c
@@ -179,7 +179,7 @@ void rgmii_put_mdio(struct of_device *of
 	mutex_unlock(&dev->lock);
 }
 
-void __devexit rgmii_detach(struct of_device *ofdev, int input)
+void rgmii_detach(struct of_device *ofdev, int input)
 {
 	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
 	struct rgmii_regs __iomem *p = dev->base;
--- linux-2.6.orig/drivers/net/ibm_newemac/tah.c
+++ linux-2.6/drivers/net/ibm_newemac/tah.c
@@ -35,7 +35,7 @@ int __devinit tah_attach(struct of_devic
 	return 0;
 }
 
-void __devexit tah_detach(struct of_device *ofdev, int channel)
+void tah_detach(struct of_device *ofdev, int channel)
 {
 	struct tah_instance *dev = dev_get_drvdata(&ofdev->dev);
 
--- linux-2.6.orig/drivers/net/ibm_newemac/zmii.c
+++ linux-2.6/drivers/net/ibm_newemac/zmii.c
@@ -189,7 +189,7 @@ void zmii_set_speed(struct of_device *of
 	mutex_unlock(&dev->lock);
 }
 
-void __devexit zmii_detach(struct of_device *ofdev, int input)
+void zmii_detach(struct of_device *ofdev, int input)
 {
 	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
 
