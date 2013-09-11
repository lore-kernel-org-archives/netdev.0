From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 37/52] net: 8139cp: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:59:56 +0900
Message-ID: <006f01ceaec4$e7d74170$b785c450$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:48558 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab3IKH76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:59:58 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY007NZBJP56E0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:59:57 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/realtek/8139cp.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index d2e5919..f2a2128 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -2052,7 +2052,6 @@ static void cp_remove_one (struct pci_dev *pdev)
 	pci_release_regions(pdev);
 	pci_clear_mwi(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 }
 
-- 
1.7.10.4
