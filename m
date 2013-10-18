From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 10/15] net: bna: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:22:22 +0900
Message-ID: <00b901cecb98$1cf37d70$56da7850$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Rasesh Mody' <rmody@brocade.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:12933 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773Ab3JRAW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:22:26 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00K3190DQ5H0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:22:22 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index b78e69e..f276433 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3212,7 +3212,6 @@ bnad_init(struct bnad *bnad,
 	bnad->bar0 = ioremap_nocache(bnad->mmio_start, bnad->mmio_len);
 	if (!bnad->bar0) {
 		dev_err(&pdev->dev, "ioremap for bar0 failed\n");
-		pci_set_drvdata(pdev, NULL);
 		return -ENOMEM;
 	}
 	pr_info("bar0 mapped to %p, len %llu\n", bnad->bar0,
-- 
1.7.10.4
