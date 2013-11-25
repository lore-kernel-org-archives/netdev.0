From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: hippi: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 11:01:10 +0900
Message-ID: <001001cee982$3639eff0$a2adcfd0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hippi@sunsite.dk,
	'Jes Sorensen' <jes@trained-monkey.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:12224 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352Ab3KYCBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 21:01:11 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS00374QXY7AC0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 11:01:11 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/hippi/rrunner.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 00ed751..cd85f24 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -213,10 +213,8 @@ static int rr_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 				    rrpriv->tx_ring_dma);
 	if (rrpriv->regs)
 		pci_iounmap(pdev, rrpriv->regs);
-	if (pdev) {
+	if (pdev)
 		pci_release_regions(pdev);
-		pci_set_drvdata(pdev, NULL);
-	}
  out2:
 	free_netdev(dev);
  out3:
@@ -244,7 +242,6 @@ static void rr_remove_one(struct pci_dev *pdev)
 	pci_iounmap(pdev, rr->regs);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 }
 
-- 
1.7.10.4
