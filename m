From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 14/15] net: cxgb4vf: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:24:54 +0900
Message-ID: <00bd01cecb98$77ed9710$67c8c530$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Casey Leedom' <leedom@chelsio.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:57056 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755976Ab3JRAZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:25:34 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00D3B95AYWD0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:24:55 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
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
