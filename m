From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 11/15] net: cxgb4: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:23:00 +0900
Message-ID: <00ba01cecb98$3397ffb0$9ac7ff10$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Dimitris Michailidis' <dm@chelsio.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:58303 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773Ab3JRAXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:23:01 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00JBP92BOPD0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:23:00 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 85d0cda..8b929ee 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6075,7 +6075,6 @@ sriov:
 	pci_disable_device(pdev);
  out_release_regions:
 	pci_release_regions(pdev);
-	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -6123,7 +6122,6 @@ static void remove_one(struct pci_dev *pdev)
 		pci_disable_pcie_error_reporting(pdev);
 		pci_disable_device(pdev);
 		pci_release_regions(pdev);
-		pci_set_drvdata(pdev, NULL);
 	} else
 		pci_release_regions(pdev);
 }
-- 
1.7.10.4
