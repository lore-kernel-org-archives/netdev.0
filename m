From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 03/34] forcedeth: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:00 +0100
Message-ID: <1fb6d9a85e2c348b073c52eaf0a06321e9bb7d0c.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51801 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752784Ab2CON7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:32 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 8561dd2..84952b3 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3943,13 +3943,11 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 		ret = pci_enable_msi(np->pci_dev);
 		if (ret == 0) {
 			np->msi_flags |= NV_MSI_ENABLED;
-			dev->irq = np->pci_dev->irq;
 			if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0) {
 				netdev_info(dev, "request_irq failed %d\n",
 					    ret);
 				pci_disable_msi(np->pci_dev);
 				np->msi_flags &= ~NV_MSI_ENABLED;
-				dev->irq = np->pci_dev->irq;
 				goto out_err;
 			}
 
@@ -5650,9 +5648,6 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np->base = ioremap(addr, np->register_size);
 	if (!np->base)
 		goto out_relreg;
-	dev->base_addr = (unsigned long)np->base;
-
-	dev->irq = pci_dev->irq;
 
 	np->rx_ring_size = RX_RING_DEFAULT;
 	np->tx_ring_size = TX_RING_DEFAULT;
-- 
1.7.7.6
