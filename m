From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 07/52] net: bnx2: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:28:21 +0900
Message-ID: <005101ceaec0$7e5f4610$7b1dd230$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Michael Chan' <mchan@broadcom.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:33737 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab3IKH2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:28:23 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY002IUA3AKUJ0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:28:22 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index e838a3f..ff3f8cc 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8413,7 +8413,6 @@ err_out_release:
 
 err_out_disable:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 
 err_out:
 	return rc;
@@ -8546,7 +8545,6 @@ error:
 	pci_iounmap(pdev, bp->regview);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 err_free:
 	free_netdev(dev);
 	return rc;
@@ -8578,7 +8576,6 @@ bnx2_remove_one(struct pci_dev *pdev)
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static int
-- 
1.7.10.4
