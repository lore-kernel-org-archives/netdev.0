From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 15/31] net: netx-eth: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:59:34 +0900
Message-ID: <003f01cea53d$b88030c0$29809240$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:9252 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498Ab3H3E7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:59:37 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00BQ5V6FDIP0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:59:34 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/netx-eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index dc2c6f5..235fd51 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -390,7 +390,7 @@ static int netx_eth_drv_probe(struct platform_device *pdev)
 
 	priv = netdev_priv(ndev);
 
-	pdata = (struct netxeth_platform_data *)pdev->dev.platform_data;
+	pdata = (struct netxeth_platform_data *)dev_get_platdata(&pdev->dev);
 	priv->xc = request_xc(pdata->xcno, &pdev->dev);
 	if (!priv->xc) {
 		dev_err(&pdev->dev, "unable to request xc engine\n");
-- 
1.7.10.4
