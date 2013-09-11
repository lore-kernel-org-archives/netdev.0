From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 26/52] net: ksz884x: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:49:39 +0900
Message-ID: <006401ceaec3$77c97430$675c5c90$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:30646 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab3IKHtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:49:40 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00A9WB29WVV0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:49:39 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/micrel/ksz884x.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 8ebc352..6462dc5 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -7150,8 +7150,6 @@ static void pcidev_exit(struct pci_dev *pdev)
 	struct platform_info *info = pci_get_drvdata(pdev);
 	struct dev_info *hw_priv = &info->dev_info;
 
-	pci_set_drvdata(pdev, NULL);
-
 	release_mem_region(pci_resource_start(pdev, 0),
 		pci_resource_len(pdev, 0));
 	for (i = 0; i < hw_priv->hw.dev_count; i++) {
-- 
1.7.10.4
