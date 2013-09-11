From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 45/52] net: cassini: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:07:08 +0900
Message-ID: <007801ceaec5$e9636a40$bc2a3ec0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:34427 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab3IKIHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:07:10 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00AC1BV8JCW0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:07:09 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sun/cassini.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 759441b..817611d 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -5168,7 +5168,6 @@ err_out_free_netdev:
 
 err_out_disable_pdev:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	return -ENODEV;
 }
 
@@ -5206,7 +5205,6 @@ static void cas_remove_one(struct pci_dev *pdev)
 	free_netdev(dev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 #ifdef CONFIG_PM
-- 
1.7.10.4
