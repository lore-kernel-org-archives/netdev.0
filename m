From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 19/36] net: ethernet: netx: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:41:33 +0900
Message-ID: <002301ce4add$264de4f0$72e9aed0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:52418 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760515Ab3EGEle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:41:34 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME006EQVOD1L80@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:41:33 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/netx-eth.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index cb9e638..987889c 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -422,7 +422,6 @@ exit_free_pfifo:
 exit_free_xc:
 	free_xc(priv->xc);
 exit_free_netdev:
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
 exit:
 	return ret;
@@ -433,8 +432,6 @@ static int netx_eth_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev = dev_get_drvdata(&pdev->dev);
 	struct netx_eth_priv *priv = netdev_priv(ndev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	unregister_netdev(ndev);
 	xc_stop(priv->xc);
 	free_xc(priv->xc);
-- 
1.7.2.5
