From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 47/52] net: niu: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:08:07 +0900
Message-ID: <007a01ceaec6$0c9a4ec0$25ceec40$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:42772 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab3IKIII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:08:08 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY001JZBVQP0N0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:08:08 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sun/niu.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index f28460c..388540f 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9875,7 +9875,6 @@ err_out_free_res:
 
 err_out_disable_pdev:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 
 	return err;
 }
@@ -9900,7 +9899,6 @@ static void niu_pci_remove_one(struct pci_dev *pdev)
 		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4
