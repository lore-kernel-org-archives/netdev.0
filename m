From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 08/15] net: bnx2x: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:21:26 +0900
Message-ID: <00b701cecb97$fbdce0e0$f396a2a0$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Eilon Greenstein' <eilong@broadcom.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:58099 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755816Ab3JRAWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:22:20 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00J8U8ZNOPD0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:21:26 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e53ff1e..8fd3432 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12297,7 +12297,6 @@ err_out_release:
 
 err_out_disable:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 
 err_out:
 	return rc;
@@ -12840,7 +12839,6 @@ init_one_exit:
 		pci_release_regions(pdev);
 
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 
 	return rc;
 }
@@ -12923,7 +12921,6 @@ static void __bnx2x_remove(struct pci_dev *pdev,
 		pci_release_regions(pdev);
 
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static void bnx2x_remove_one(struct pci_dev *pdev)
-- 
1.7.10.4
