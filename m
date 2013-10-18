From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 07/15] net: bnx2: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:21:10 +0900
Message-ID: <00b601cecb97$f2253cf0$d66fb6d0$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Michael Chan' <mchan@broadcom.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:12832 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773Ab3JRAWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:22:19 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00KZC8XCQ5G0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:21:10 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
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
index 6111870..d9980ad 100644
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
