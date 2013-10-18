From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 03/15] net: starfire: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:18:53 +0900
Message-ID: <00b201cecb97$a0d83ff0$e288bfd0$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Ion Badulescu' <ionut@badula.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:55953 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755578Ab3JRATp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:19:45 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00DSY8TKYWC0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:18:54 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/adaptec/starfire.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 8b04bfc..171d73c 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -835,7 +835,6 @@ static int starfire_init_one(struct pci_dev *pdev,
 	return 0;
 
 err_out_cleardev:
-	pci_set_drvdata(pdev, NULL);
 	iounmap(base);
 err_out_free_res:
 	pci_release_regions (pdev);
@@ -2012,7 +2011,6 @@ static void starfire_remove_one(struct pci_dev *pdev)
 	iounmap(np->base);
 	pci_release_regions(pdev);
 
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);			/* Will also free np!! */
 }
 
-- 
1.7.10.4
