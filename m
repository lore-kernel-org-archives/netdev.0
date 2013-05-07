From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 10/36] net: ethernet: calxeda: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:25:23 +0900
Message-ID: <001a01ce4ada$e498ace0$adca06a0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	'Rob Herring' <rob.herring@calxeda.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:59311 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757024Ab3EGEZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:25:25 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00E9UUXZZI80@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:25:24 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 4a1f2fa..7cb148c 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1790,7 +1790,6 @@ err_io:
 	free_netdev(ndev);
 err_alloc:
 	release_mem_region(res->start, resource_size(res));
-	platform_set_drvdata(pdev, NULL);
 	return ret;
 }
 
@@ -1813,7 +1812,6 @@ static int xgmac_remove(struct platform_device *pdev)
 	free_irq(ndev->irq, ndev);
 	free_irq(priv->pmt_irq, ndev);
 
-	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(ndev);
 	netif_napi_del(&priv->napi);
 
-- 
1.7.2.5
