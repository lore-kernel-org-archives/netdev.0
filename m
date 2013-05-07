From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 14/36] net: ethernet: faraday: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:32:50 +0900
Message-ID: <001e01ce4adb$eea1fdd0$cbe5f970$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Eric Dumazet' <edumazet@google.com>,
	'Thomas Faber' <thfabba@gmx.de>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:43517 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759776Ab3EGEcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:32:51 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME0032SVADP5A0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:32:50 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c |    2 --
 drivers/net/ethernet/faraday/ftmac100.c  |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 21b85fb..934e1ae 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1311,7 +1311,6 @@ err_ioremap:
 	release_resource(priv->res);
 err_req_mem:
 	netif_napi_del(&priv->napi);
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 err_alloc_etherdev:
 	return err;
@@ -1335,7 +1334,6 @@ static int __exit ftgmac100_remove(struct platform_device *pdev)
 	release_resource(priv->res);
 
 	netif_napi_del(&priv->napi);
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 	return 0;
 }
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index a6eda8d..4658f4c 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -1149,7 +1149,6 @@ err_ioremap:
 	release_resource(priv->res);
 err_req_mem:
 	netif_napi_del(&priv->napi);
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 err_alloc_etherdev:
 	return err;
@@ -1169,7 +1168,6 @@ static int __exit ftmac100_remove(struct platform_device *pdev)
 	release_resource(priv->res);
 
 	netif_napi_del(&priv->napi);
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 	return 0;
 }
-- 
1.7.2.5
