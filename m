From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 15/15] via-rhine: add helper (reduce type-unsafe void * assignments).
Date: Mon, 31 Dec 2012 16:25:49 +0100
Message-ID: <1356967549-5056-16-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54069 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab2LaPen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:43 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 051bb95..dd4fd04 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2411,10 +2411,17 @@ static int rhine_close(struct net_device *dev)
 	return 0;
 }
 
+/* Cast-only helper (try to minimize type-unsafe void * assignments). */
+/* TODO: could be doing the same thing for netdev_priv() use. */
+static inline struct net_device *
+rhine_to_net_device(struct pci_dev *pdev)
+{
+	return pci_get_drvdata(pdev);
+}
 
 static void rhine_remove_one(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = rhine_to_net_device(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
 
 	unregister_netdev(dev);
@@ -2430,7 +2437,7 @@ static void rhine_remove_one(struct pci_dev *pdev)
 static void
 rhine_shutdown_and_keep_wol(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = rhine_to_net_device(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
@@ -2489,7 +2496,7 @@ rhine_shutdown_and_keep_wol(struct pci_dev *pdev)
 static int rhine_suspend(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = rhine_to_net_device(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
 
 	if (!netif_running(dev))
@@ -2509,7 +2516,7 @@ static int rhine_suspend(struct device *device)
 static int rhine_resume(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = rhine_to_net_device(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
 
 	/*
-- 
1.7.2.5
