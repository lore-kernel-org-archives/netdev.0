From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 10/31] net: fec: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:56:26 +0900
Message-ID: <003a01cea53d$486e7670$d94b6350$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:59306 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264Ab3H3E41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:56:27 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00B23V1V9MO0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:56:26 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index fdf9307..7b81195 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1060,7 +1060,7 @@ static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
 static void fec_get_mac(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
+	struct fec_platform_data *pdata = dev_get_platdata(&fep->pdev->dev);
 	unsigned char *iap, tmpaddr[ETH_ALEN];
 
 	/*
@@ -2089,7 +2089,7 @@ fec_probe(struct platform_device *pdev)
 
 	ret = of_get_phy_mode(pdev->dev.of_node);
 	if (ret < 0) {
-		pdata = pdev->dev.platform_data;
+		pdata = dev_get_platdata(&pdev->dev);
 		if (pdata)
 			fep->phy_interface = pdata->phy;
 		else
-- 
1.7.10.4
