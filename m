From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 8/8] r8169: stop using net_device.{base_addr, irq}.
Date: Sat, 10 Mar 2012 23:21:07 +0100
Message-ID: <20120310222107.GI9692@electric-eye.fr.zoreil.com>
References: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41115 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752619Ab2CJWWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:22:19 -0500
Content-Disposition: inline
In-Reply-To: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver does not need this leftover of the ISA drivers era.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 390e69a..4aa4194 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5634,7 +5634,7 @@ static int rtl8169_close(struct net_device *dev)
 	rtl8169_down(dev);
 	rtl_unlock_work(tp);
 
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			  tp->RxPhyAddr);
@@ -5690,7 +5690,7 @@ static int rtl_open(struct net_device *dev)
 
 	rtl_request_firmware(tp);
 
-	retval = request_irq(dev->irq, rtl8169_interrupt,
+	retval = request_irq(pdev->irq, rtl8169_interrupt,
 			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
 			     dev->name, dev);
 	if (retval < 0)
@@ -6215,8 +6215,6 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
-	dev->irq = pdev->irq;
-	dev->base_addr = (unsigned long) ioaddr;
 
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
 
@@ -6255,9 +6253,9 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
-	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x IRQ %d\n",
-		   rtl_chip_infos[chipset].name, dev->base_addr, dev->dev_addr,
-		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
+	netif_info(tp, probe, dev, "%s at 0x%p, %pM, XID %08x IRQ %d\n",
+		   rtl_chip_infos[chipset].name, ioaddr, dev->dev_addr,
+		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), pdev->irq);
 	if (rtl_chip_infos[chipset].jumbo_max != JUMBO_1K) {
 		netif_info(tp, probe, dev, "jumbo features [frames: %d bytes, "
 			   "tx checksumming: %s]\n",
-- 
1.7.7.6
