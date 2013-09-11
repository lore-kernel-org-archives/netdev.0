From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 25/52] net: sky2: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:49:09 +0900
Message-ID: <006301ceaec3$65fe1850$31fa48f0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Mirko Lindner' <mlindner@marvell.com>,
	'Stephen Hemminger' <stephen@networkplumber.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:38293 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042Ab3IKHtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:49:10 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY002XXB17KUK0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:49:09 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/marvell/sky2.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index e09a8c6..a7df981 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -5081,7 +5081,6 @@ err_out_free_regions:
 err_out_disable:
 	pci_disable_device(pdev);
 err_out:
-	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -5124,8 +5123,6 @@ static void sky2_remove(struct pci_dev *pdev)
 
 	iounmap(hw->regs);
 	kfree(hw);
-
-	pci_set_drvdata(pdev, NULL);
 }
 
 static int sky2_suspend(struct device *dev)
-- 
1.7.10.4
