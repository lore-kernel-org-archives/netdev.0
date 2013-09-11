From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 34/52] net: qlcnic: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:57:44 +0900
Message-ID: <006c01ceaec4$98df5800$ca9e0800$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Himanshu Madhani' <himanshu.madhani@qlogic.com>,
	'Rajesh Borundia' <rajesh.borundia@qlogic.com>,
	'Shahed Shaikh' <shahed.shaikh@qlogic.com>,
	'Jitendra Kalsaria' <jitendra.kalsaria@qlogic.com>,
	'Sony Chacko' <sony.chacko@qlogic.com>,
	'Sucheta Chakraborty' <sucheta.chakraborty@qlogic.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:32157 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab3IKH5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:57:45 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00K0RBG7AQ00@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:57:44 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index c4c5023..00cc337 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2405,7 +2405,6 @@ err_out_free_res:
 	pci_release_regions(pdev);
 
 err_out_disable_pdev:
-	pci_set_drvdata(pdev, NULL);
 	pci_disable_device(pdev);
 	return err;
 }
@@ -2465,7 +2464,6 @@ static void qlcnic_remove(struct pci_dev *pdev)
 	pci_disable_pcie_error_reporting(pdev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 
 	if (adapter->qlcnic_wq) {
 		destroy_workqueue(adapter->qlcnic_wq);
-- 
1.7.10.4
