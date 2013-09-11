From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 24/52] net: skge: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:48:01 +0900
Message-ID: <006201ceaec3$3de16340$b9a429c0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Mirko Lindner' <mlindner@marvell.com>,
	'Stephen Hemminger' <stephen@networkplumber.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:30348 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380Ab3IKHsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:48:03 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00A7FB02WVV0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:48:02 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/marvell/skge.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index ef94a59..8b3696f 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -4042,7 +4042,6 @@ err_out_free_regions:
 	pci_release_regions(pdev);
 err_out_disable_pdev:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 err_out:
 	return err;
 }
@@ -4086,7 +4085,6 @@ static void skge_remove(struct pci_dev *pdev)
 
 	iounmap(hw->regs);
 	kfree(hw);
-	pci_set_drvdata(pdev, NULL);
 }
 
 #ifdef CONFIG_PM_SLEEP
-- 
1.7.10.4
