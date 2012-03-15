From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 06/34] hamachi: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:03 +0100
Message-ID: <87fefb4f9987c8a8282d1cae8d05894f8a9d171d.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51808 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752752Ab2CON7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:39 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/packetengines/hamachi.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 0d29f5f..c236715 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -683,8 +683,6 @@ static int __devinit hamachi_init_one (struct pci_dev *pdev,
 	}
 
 	hmp->base = ioaddr;
-	dev->base_addr = (unsigned long)ioaddr;
-	dev->irq = irq;
 	pci_set_drvdata(pdev, dev);
 
 	hmp->chip_id = chip_id;
@@ -859,14 +857,11 @@ static int hamachi_open(struct net_device *dev)
 	u32 rx_int_var, tx_int_var;
 	u16 fifo_info;
 
-	i = request_irq(dev->irq, hamachi_interrupt, IRQF_SHARED, dev->name, dev);
+	i = request_irq(hmp->pci_dev->irq, hamachi_interrupt, IRQF_SHARED,
+			dev->name, dev);
 	if (i)
 		return i;
 
-	if (hamachi_debug > 1)
-		printk(KERN_DEBUG "%s: hamachi_open() irq %d.\n",
-			   dev->name, dev->irq);
-
 	hamachi_init_ring(dev);
 
 #if ADDRLEN == 64
@@ -1705,7 +1700,7 @@ static int hamachi_close(struct net_device *dev)
 	}
 #endif /* __i386__ debugging only */
 
-	free_irq(dev->irq, dev);
+	free_irq(hmp->pci_dev->irq, dev);
 
 	del_timer_sync(&hmp->timer);
 
-- 
1.7.7.6
