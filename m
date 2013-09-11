From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 32/52] net: netxen: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:55:06 +0900
Message-ID: <006a01ceaec4$3aef7e00$b0ce7a00$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Manish Chopra' <manish.chopra@qlogic.com>,
	'Sony Chacko' <sony.chacko@qlogic.com>,
	'Rajesh Borundia' <rajesh.borundia@qlogic.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:57210 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab3IKHzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:55:08 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY001V4BBJJUE0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:55:07 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index cbd75f9..76b8e35 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1602,7 +1602,6 @@ err_out_free_res:
 	pci_release_regions(pdev);
 
 err_out_disable_pdev:
-	pci_set_drvdata(pdev, NULL);
 	pci_disable_device(pdev);
 	return err;
 }
@@ -1661,7 +1660,6 @@ static void netxen_nic_remove(struct pci_dev *pdev)
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 
 	free_netdev(netdev);
 }
-- 
1.7.10.4
