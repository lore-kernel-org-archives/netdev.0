From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/2] irda: via-ircc: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 10:54:31 +0900
Message-ID: <000901cee981$483ca4f0$d8b5eed0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Samuel Ortiz' <samuel@sortiz.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:49028 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303Ab3KYByc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 20:54:32 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS003OCQMVPOC0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 10:54:31 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/irda/via-ircc.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 9abaec2..b0e8207 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -408,7 +408,6 @@ static int via_ircc_open(struct pci_dev *pdev, chipio_t *info, unsigned int id)
  err_out2:
 	release_region(self->io.fir_base, self->io.fir_ext);
  err_out1:
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 	return err;
 }
@@ -442,7 +441,6 @@ static void via_remove_one(struct pci_dev *pdev)
 	if (self->rx_buff.head)
 		dma_free_coherent(&pdev->dev, self->rx_buff.truesize,
 				  self->rx_buff.head, self->rx_buff_dma);
-	pci_set_drvdata(pdev, NULL);
 
 	free_netdev(self->netdev);
 
-- 
1.7.10.4
