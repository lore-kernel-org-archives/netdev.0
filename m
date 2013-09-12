From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH V2 20/52] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 14:57:13 +0900
Message-ID: <001601ceaf7c$edbac950$c9305bf0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
 <005e01ceaec2$23e32420$6ba96c60$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:26703 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab3ILF5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 01:57:25 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MT000CQF0IEAF70@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 12 Sep 2013 14:57:13 +0900 (KST)
In-reply-to: <005e01ceaec2$23e32420$6ba96c60$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
Changes since v1:
- removed coding style fix.

 drivers/net/ethernet/fealnx.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index c706b7a..4b22a95 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -699,7 +699,6 @@ static void fealnx_remove_one(struct pci_dev *pdev)
 		pci_iounmap(pdev, np->mem);
 		free_netdev(dev);
 		pci_release_regions(pdev);
-		pci_set_drvdata(pdev, NULL);
 	} else
 		printk(KERN_ERR "fealnx: remove for unknown device\n");
 }
-- 
1.7.10.4
