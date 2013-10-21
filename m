From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 05/15] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:12:15 +0900
Message-ID: <003d01cece02$f5e3b340$e1ab19c0$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:36115 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab3JUCMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:12:16 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00A7KY46D3F0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:12:15 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
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
