From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 30/52] net: packetengines: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:53:08 +0900
Message-ID: <006801ceaec3$f4a590b0$ddf0b210$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:39213 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab3IKHxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:53:10 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY009A2B8BZDW0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:53:09 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/packetengines/hamachi.c   |    1 -
 drivers/net/ethernet/packetengines/yellowfin.c |    2 --
 2 files changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index cac33e5..b6bdeb3 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -1910,7 +1910,6 @@ static void hamachi_remove_one(struct pci_dev *pdev)
 		iounmap(hmp->base);
 		free_netdev(dev);
 		pci_release_regions(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index d28593b..07a890e 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -513,7 +513,6 @@ err_out_unmap_rx:
 err_out_unmap_tx:
         pci_free_consistent(pdev, TX_TOTAL_SIZE, np->tx_ring, np->tx_ring_dma);
 err_out_cleardev:
-	pci_set_drvdata(pdev, NULL);
 	pci_iounmap(pdev, ioaddr);
 err_out_free_res:
 	pci_release_regions(pdev);
@@ -1392,7 +1391,6 @@ static void yellowfin_remove_one(struct pci_dev *pdev)
 	pci_release_regions (pdev);
 
 	free_netdev (dev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 
-- 
1.7.10.4
