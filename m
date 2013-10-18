From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 12/15] net: cxgb3: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:23:27 +0900
Message-ID: <00bb01cecb98$43df0580$cb9d1080$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Divy Le Ray' <divy@chelsio.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:13126 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755958Ab3JRAXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:23:33 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00DFH9385HB0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:23:32 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index b650951..45d7733 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3374,7 +3374,6 @@ out_release_regions:
 	pci_release_regions(pdev);
 out_disable_device:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 out:
 	return err;
 }
@@ -3415,7 +3414,6 @@ static void remove_one(struct pci_dev *pdev)
 		kfree(adapter);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4
