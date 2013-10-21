From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 10/15] net: sky2: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:14:23 +0900
Message-ID: <004201cece03$426cbf90$c7463eb0$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Mirko Lindner' <mlindner@marvell.com>,
	'Stephen Hemminger' <stephen@networkplumber.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:20005 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377Ab3JUCOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:14:24 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00EFQY78E9G0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:14:23 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
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
