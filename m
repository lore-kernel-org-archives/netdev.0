From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/7] net: hippi: remove unnecessary pci_set_drvdata()
Date: Tue, 10 Dec 2013 12:48:38 +0900
Message-ID: <000601cef55a$b605fab0$2211f010$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hippi@sunsite.dk,
	'Jes Sorensen' <jes@trained-monkey.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:11601 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707Ab3LJDsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 22:48:45 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXK005BGNX3XW80@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 10 Dec 2013 12:48:39 +0900 (KST)
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
