From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 11/52] net: cxgb4: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:32:36 +0900
Message-ID: <005501ceaec1$1676d210$43647630$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Dimitris Michailidis' <dm@chelsio.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:42634 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab3IKHci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:32:38 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00MQPA9VV0J0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:32:37 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 0d0665c..4e8b13a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6074,7 +6074,6 @@ sriov:
 	pci_disable_device(pdev);
  out_release_regions:
 	pci_release_regions(pdev);
-	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -6122,9 +6121,9 @@ static void remove_one(struct pci_dev *pdev)
 		pci_disable_pcie_error_reporting(pdev);
 		pci_disable_device(pdev);
 		pci_release_regions(pdev);
-		pci_set_drvdata(pdev, NULL);
-	} else
+	} else {
 		pci_release_regions(pdev);
+	}
 }
 
 static struct pci_driver cxgb4_driver = {
-- 
1.7.10.4
