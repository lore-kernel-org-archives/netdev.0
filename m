From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 09/52] net: tg3: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:30:16 +0900
Message-ID: <005301ceaec0$c2b0bec0$48123c40$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Nithin Nayak Sujir' <nsujir@broadcom.com>,
	'Michael Chan' <mchan@broadcom.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:26706 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab3IKHaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:30:17 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00IPPA5T2400@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:30:16 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 5701f3d..29d03e4 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17685,7 +17685,6 @@ err_out_free_res:
 err_out_disable_pdev:
 	if (pci_is_enabled(pdev))
 		pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -17717,7 +17716,6 @@ static void tg3_remove_one(struct pci_dev *pdev)
 		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4
