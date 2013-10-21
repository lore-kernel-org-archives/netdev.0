From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 02/15] net: sundance: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:10:16 +0900
Message-ID: <003a01cece02$af5765c0$0e063140$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Denis Kirjanov' <kda@linux-powerpc.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:51195 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab3JUCKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:10:18 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00LMDY13KKE0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:10:17 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/dlink/sundance.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index bf3bf6f..113cd79 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -703,7 +703,6 @@ err_out_unmap_tx:
 	dma_free_coherent(&pdev->dev, TX_TOTAL_SIZE,
 		np->tx_ring, np->tx_ring_dma);
 err_out_cleardev:
-	pci_set_drvdata(pdev, NULL);
 	pci_iounmap(pdev, ioaddr);
 err_out_res:
 	pci_release_regions(pdev);
@@ -1941,7 +1940,6 @@ static void sundance_remove1(struct pci_dev *pdev)
 	    pci_iounmap(pdev, np->base);
 	    pci_release_regions(pdev);
 	    free_netdev(dev);
-	    pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4
