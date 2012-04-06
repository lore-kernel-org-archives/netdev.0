From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 12/39] s2io: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:26 +0200
Message-ID: <6a332e692c558b86ffcb124c5b3a269de66b5e37.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>, Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43502 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756173Ab2DFKKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:50 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/neterion/s2io.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 22a8de0..eb2ab04 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -2847,6 +2847,7 @@ static int s2io_poll_inta(struct napi_struct *napi, int budget)
 static void s2io_netpoll(struct net_device *dev)
 {
 	struct s2io_nic *nic = netdev_priv(dev);
+	const int irq = nic->pdev->irq;
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
 	int i;
@@ -2856,7 +2857,7 @@ static void s2io_netpoll(struct net_device *dev)
 	if (pci_channel_offline(nic->pdev))
 		return;
 
-	disable_irq(dev->irq);
+	disable_irq(irq);
 
 	writeq(val64, &bar0->rx_traffic_int);
 	writeq(val64, &bar0->tx_traffic_int);
@@ -2885,7 +2886,7 @@ static void s2io_netpoll(struct net_device *dev)
 			break;
 		}
 	}
-	enable_irq(dev->irq);
+	enable_irq(irq);
 }
 #endif
 
@@ -3898,9 +3899,7 @@ static void remove_msix_isr(struct s2io_nic *sp)
 
 static void remove_inta_isr(struct s2io_nic *sp)
 {
-	struct net_device *dev = sp->dev;
-
-	free_irq(sp->pdev->irq, dev);
+	free_irq(sp->pdev->irq, sp->dev);
 }
 
 /* ********************************************************* *
@@ -7047,7 +7046,7 @@ static int s2io_add_isr(struct s2io_nic *sp)
 		}
 	}
 	if (sp->config.intr_type == INTA) {
-		err = request_irq((int)sp->pdev->irq, s2io_isr, IRQF_SHARED,
+		err = request_irq(sp->pdev->irq, s2io_isr, IRQF_SHARED,
 				  sp->name, dev);
 		if (err) {
 			DBG_PRINT(ERR_DBG, "%s: ISR registration failed\n",
@@ -7909,9 +7908,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto bar1_remap_failed;
 	}
 
-	dev->irq = pdev->irq;
-	dev->base_addr = (unsigned long)sp->bar0;
-
 	/* Initializing the BAR1 address as the start of the FIFO pointer. */
 	for (j = 0; j < MAX_TX_FIFOS; j++) {
 		mac_control->tx_FIFO_start[j] = sp->bar1 + (j * 0x00020000);
-- 
1.7.7.6
