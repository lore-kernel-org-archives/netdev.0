From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 09/15] net: skge: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:13:58 +0900
Message-ID: <004101cece03$337a9b60$9a6fd220$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Mirko Lindner' <mlindner@marvell.com>,
	'Stephen Hemminger' <stephen@networkplumber.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:19925 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab3JUCOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:14:06 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00EFQY78E9G0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:13:58 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
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
index ecc7f7b..5978461 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -4046,7 +4046,6 @@ err_out_free_regions:
 	pci_release_regions(pdev);
 err_out_disable_pdev:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 err_out:
 	return err;
 }
@@ -4090,7 +4089,6 @@ static void skge_remove(struct pci_dev *pdev)
 
 	iounmap(hw->regs);
 	kfree(hw);
-	pci_set_drvdata(pdev, NULL);
 }
 
 #ifdef CONFIG_PM_SLEEP
-- 
1.7.10.4
