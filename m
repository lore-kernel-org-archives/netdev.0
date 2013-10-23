From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/7] net: sungem: remove unnecessary pci_set_drvdata()
Date: Wed, 23 Oct 2013 16:06:54 +0900
Message-ID: <000201cecfbe$748f7e60$5dae7b20$%han@samsung.com>
References: <000001cecfbe$44ce9c10$ce6bd430$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:61563 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480Ab3JWHG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 03:06:56 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV4002TY13FGNR0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Wed, 23 Oct 2013 16:06:54 +0900 (KST)
In-reply-to: <000001cecfbe$44ce9c10$ce6bd430$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sun/sungem.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index a235bd9..b5655b7 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2806,8 +2806,6 @@ static void gem_remove_one(struct pci_dev *pdev)
 		iounmap(gp->regs);
 		pci_release_regions(pdev);
 		free_netdev(dev);
-
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4
