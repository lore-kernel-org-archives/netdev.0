From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/2] irda: via-ircc: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:28:28 +0900
Message-ID: <000801cef48e$ba4f5de0$2eee19a0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Samuel Ortiz' <samuel@sortiz.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:40603 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760319Ab3LID2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:28:30 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00MG8SBHJDA0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:28:29 +0900 (KST)
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
index 26cb45d..2900af0 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -407,7 +407,6 @@ static int via_ircc_open(struct pci_dev *pdev, chipio_t *info, unsigned int id)
  err_out2:
 	release_region(self->io.fir_base, self->io.fir_ext);
  err_out1:
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 	return err;
 }
@@ -441,7 +440,6 @@ static void via_remove_one(struct pci_dev *pdev)
 	if (self->rx_buff.head)
 		dma_free_coherent(&pdev->dev, self->rx_buff.truesize,
 				  self->rx_buff.head, self->rx_buff_dma);
-	pci_set_drvdata(pdev, NULL);
 
 	free_netdev(self->netdev);
 
-- 
1.7.10.4
