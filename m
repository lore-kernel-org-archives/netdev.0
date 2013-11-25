From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/5] net: sis900: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 10:44:20 +0900
Message-ID: <000201cee97f$dc28c1a0$947a44e0$%han@samsung.com>
References: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Daniele Venzano' <venza@brownhat.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:46320 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421Ab3KYBoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 20:44:22 -0500
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS0037NQ5WS3B0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 10:44:20 +0900 (KST)
In-reply-to: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sis/sis900.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 975dc2d..ff57a46 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -576,7 +576,6 @@ err_unmap_tx:
 err_out_unmap:
 	pci_iounmap(pci_dev, ioaddr);
 err_out_cleardev:
-	pci_set_drvdata(pci_dev, NULL);
 	pci_release_regions(pci_dev);
  err_out:
 	free_netdev(net_dev);
@@ -2427,7 +2426,6 @@ static void sis900_remove(struct pci_dev *pci_dev)
 	pci_iounmap(pci_dev, sis_priv->ioaddr);
 	free_netdev(net_dev);
 	pci_release_regions(pci_dev);
-	pci_set_drvdata(pci_dev, NULL);
 }
 
 #ifdef CONFIG_PM
-- 
1.7.10.4
