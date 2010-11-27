From: Szymon Janc <szymon@janc.net.pl>
Subject: [PATCH 4/6] forcedeth: do not use assignment in if conditions
Date: Sat, 27 Nov 2010 19:39:46 +0100
Message-ID: <1290883188-2078-5-git-send-email-szymon@janc.net.pl>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Cc: Szymon Janc <szymon@janc.net.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cox.rootnode.net ([89.248.165.14]:56867 "EHLO cox.rootnode.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284Ab0K0SvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 13:51:02 -0500
Received: from DSPAM-Daemon (localhost [127.0.0.1])
	by cox.rootnode.net (Postfix) with SMTP id 692E98041C9E
	for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 19:41:51 +0100 (CET)
In-Reply-To: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Szymon Janc <szymon@janc.net.pl>
---
 drivers/net/forcedeth.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 8deae90..2f092d7 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3789,7 +3789,8 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 	if (np->msi_flags & NV_MSI_X_CAPABLE) {
 		for (i = 0; i < (np->msi_flags & NV_MSI_X_VECTORS_MASK); i++)
 			np->msi_x_entry[i].entry = i;
-		if ((ret = pci_enable_msix(np->pci_dev, np->msi_x_entry, (np->msi_flags & NV_MSI_X_VECTORS_MASK))) == 0) {
+		ret = pci_enable_msix(np->pci_dev, np->msi_x_entry, (np->msi_flags & NV_MSI_X_VECTORS_MASK));
+		if (ret == 0) {
 			np->msi_flags |= NV_MSI_X_ENABLED;
 			if (optimization_mode == NV_OPTIMIZATION_MODE_THROUGHPUT && !intr_test) {
 				/* Request irq for rx handling */
@@ -3841,7 +3842,8 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 		}
 	}
 	if (ret != 0 && np->msi_flags & NV_MSI_CAPABLE) {
-		if ((ret = pci_enable_msi(np->pci_dev)) == 0) {
+		ret = pci_enable_msi(np->pci_dev);
+		if (ret == 0) {
 			np->msi_flags |= NV_MSI_ENABLED;
 			dev->irq = np->pci_dev->irq;
 			if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0) {
-- 
1.7.2.3


