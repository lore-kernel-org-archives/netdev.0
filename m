From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 06/15] net: r6040: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:17:11 +0900
Message-ID: <000c01cecedd$94b8b3f0$be2a1bd0$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Florian Fainelli' <florian@openwrt.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:57820 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab3JVERM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:17:12 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100AQUYK5NTL0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:17:12 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/rdc/r6040.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index e9dc849..1e49ec5 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1231,7 +1231,6 @@ err_out_mdio:
 	mdiobus_free(lp->mii_bus);
 err_out_unmap:
 	netif_napi_del(&lp->napi);
-	pci_set_drvdata(pdev, NULL);
 	pci_iounmap(pdev, ioaddr);
 err_out_free_res:
 	pci_release_regions(pdev);
@@ -1257,7 +1256,6 @@ static void r6040_remove_one(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 	free_netdev(dev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 
-- 
1.7.10.4
