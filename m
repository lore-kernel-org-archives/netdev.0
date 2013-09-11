From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 02/52] net: 8390: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:23:16 +0900
Message-ID: <004c01ceaebf$c86f7fa0$594e7ee0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Paul Gortmaker' <paul.gortmaker@windriver.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:25475 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab3IKHXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:23:18 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00IDF9US2400@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:23:17 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/8390/ne2k-pci.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index 9220108..fc14a85 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -389,9 +389,7 @@ err_out_free_netdev:
 	free_netdev (dev);
 err_out_free_res:
 	release_region (ioaddr, NE_IO_EXTENT);
-	pci_set_drvdata (pdev, NULL);
 	return -ENODEV;
-
 }
 
 /*
@@ -655,7 +653,6 @@ static void ne2k_pci_remove_one(struct pci_dev *pdev)
 	release_region(dev->base_addr, NE_IO_EXTENT);
 	free_netdev(dev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 #ifdef CONFIG_PM
-- 
1.7.10.4
