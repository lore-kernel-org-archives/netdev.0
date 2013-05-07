From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 06/36] net: ethernet: adi: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:20:07 +0900
Message-ID: <001601ce4ada$27ce23b0$776a6b10$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Richard Cochran' <richardcochran@gmail.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:48459 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab3EGEUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:20:09 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00MHEUPJLYB0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:20:07 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index ee70577..7b8a1ee 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1718,7 +1718,6 @@ out_err_mii_probe:
 	mdiobus_unregister(lp->mii_bus);
 	mdiobus_free(lp->mii_bus);
 out_err_probe_mac:
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
 
 	return rc;
@@ -1731,8 +1730,6 @@ static int bfin_mac_remove(struct platform_device *pdev)
 
 	bfin_phc_release(lp);
 
-	platform_set_drvdata(pdev, NULL);
-
 	lp->mii_bus->priv = NULL;
 
 	unregister_netdev(ndev);
@@ -1867,7 +1864,6 @@ static int bfin_mii_bus_remove(struct platform_device *pdev)
 	struct bfin_mii_bus_platform_data *mii_bus_pd =
 		dev_get_platdata(&pdev->dev);
 
-	platform_set_drvdata(pdev, NULL);
 	mdiobus_unregister(miibus);
 	kfree(miibus->irq);
 	mdiobus_free(miibus);
-- 
1.7.2.5
