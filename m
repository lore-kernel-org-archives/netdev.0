From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 09/15] net: tg3: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:21:54 +0900
Message-ID: <00b801cecb98$0c98a180$25c9e480$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Nithin Nayak Sujir' <nsujir@broadcom.com>,
	'Michael Chan' <mchan@broadcom.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:58099 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773Ab3JRAWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:22:21 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00M2390IB3C0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:21:54 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
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
index 498569e..819d87c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17701,7 +17701,6 @@ err_out_free_res:
 err_out_disable_pdev:
 	if (pci_is_enabled(pdev))
 		pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -17733,7 +17732,6 @@ static void tg3_remove_one(struct pci_dev *pdev)
 		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4
