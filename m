From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 05/52] net: amd8111e: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:26:18 +0900
Message-ID: <004f01ceaec0$34ccbd70$9e663850$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:50961 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab3IKH0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:26:20 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY001369ZVJUD0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:26:19 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/amd/amd8111e.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 1b1429d..d042511 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1711,7 +1711,6 @@ static void amd8111e_remove_one(struct pci_dev *pdev)
 		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 static void amd8111e_config_ipg(struct net_device* dev)
@@ -1967,7 +1966,6 @@ err_free_reg:
 
 err_disable_pdev:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	return err;
 
 }
-- 
1.7.10.4
