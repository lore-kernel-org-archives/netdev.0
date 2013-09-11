From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 35/52] net: qla3xxx: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:58:42 +0900
Message-ID: <006d01ceaec4$bb7d09c0$32771d40$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Jitendra Kalsaria' <jitendra.kalsaria@qlogic.com>,
	'Ron Mercer' <ron.mercer@qlogic.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:48276 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab3IKH6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:58:44 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00M04BHUV0L0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:58:42 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/qlogic/qla3xxx.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 91a8fcd..0758b94 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3916,7 +3916,6 @@ err_out_free_regions:
 	pci_release_regions(pdev);
 err_out_disable_pdev:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 err_out:
 	return err;
 }
@@ -3939,7 +3938,6 @@ static void ql3xxx_remove(struct pci_dev *pdev)
 
 	iounmap(qdev->mem_map_registers);
 	pci_release_regions(pdev);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
 }
 
-- 
1.7.10.4
