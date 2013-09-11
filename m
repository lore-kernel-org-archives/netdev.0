From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 14/52] net: cxgb4vf: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:34:59 +0900
Message-ID: <005801ceaec1$6b8d3320$42a79960$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Casey Leedom' <leedom@chelsio.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:27549 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990Ab3IKHfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:35:01 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00AD5ADUWVU0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:35:00 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 40c22e7..43bb012 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2782,11 +2782,9 @@ err_unmap_bar:
 
 err_free_adapter:
 	kfree(adapter);
-	pci_set_drvdata(pdev, NULL);
 
 err_release_regions:
 	pci_release_regions(pdev);
-	pci_set_drvdata(pdev, NULL);
 	pci_clear_master(pdev);
 
 err_disable_device:
@@ -2851,7 +2849,6 @@ static void cxgb4vf_pci_remove(struct pci_dev *pdev)
 		}
 		iounmap(adapter->regs);
 		kfree(adapter);
-		pci_set_drvdata(pdev, NULL);
 	}
 
 	/*
-- 
1.7.10.4
