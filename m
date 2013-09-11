From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 33/52] net: qlge: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:56:13 +0900
Message-ID: <006b01ceaec4$62c5db40$285191c0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Shahed Shaikh' <shahed.shaikh@qlogic.com>,
	'Jitendra Kalsaria' <jitendra.kalsaria@qlogic.com>,
	'Ron Mercer' <ron.mercer@qlogic.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:57438 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab3IKH4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:56:15 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY005T4B8H89T0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:56:13 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 2553cf4..d22529c 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4505,7 +4505,6 @@ static void ql_release_all(struct pci_dev *pdev)
 		iounmap(qdev->doorbell_area);
 	vfree(qdev->mpi_coredump);
 	pci_release_regions(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static int ql_init_device(struct pci_dev *pdev, struct net_device *ndev,
-- 
1.7.10.4
