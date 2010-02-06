From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 5/6] DMFE: add .shutdown
Date: Sat,  6 Feb 2010 22:19:01 +0200
Message-ID: <1265487542-4447-6-git-send-email-maximlevitsky@gmail.com>
References: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f211.google.com ([209.85.220.211]:49234 "EHLO
	mail-fx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756003Ab0BFUTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2010 15:19:19 -0500
In-Reply-To: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes all kinds of problems, for example interrupt
storms on following boot, WOL in S5, etc...

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/net/tulip/dmfe.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 44e1e5d..9cd6179 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -1956,7 +1956,6 @@ static void __devexit dmfe_remove(struct pci_dev *pdev)
 }
 
 
-#ifdef CONFIG_PM
 static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
@@ -1985,6 +1984,7 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int dmfe_resume(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
@@ -2006,6 +2006,11 @@ static int dmfe_resume(struct pci_dev *pci_dev)
 #endif
 
 
+static void dmfe_shutdown(struct pci_dev *pci_dev)
+{
+	dmfe_suspend(pci_dev, PMSG_SUSPEND);
+}
+
 static struct pci_device_id dmfe_pci_tbl[] = {
 	{ PCI_VDEVICE(DAVICOM, PCI_DEVICE_ID_DAVICOM_DM9132) },
 	{ PCI_VDEVICE(DAVICOM, PCI_DEVICE_ID_DAVICOM_DM9102) },
@@ -2023,8 +2028,9 @@ static struct pci_driver dmfe_driver = {
 	.remove		= __devexit_p(dmfe_remove),
 #ifdef CONFIG_PM
 	.suspend        = dmfe_suspend,
-	.resume         = dmfe_resume
+	.resume         = dmfe_resume,
 #endif
+	.shutdown		= dmfe_shutdown,
 };
 
 
-- 
1.6.3.3

