From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 11/31] net: mv643xx_eth: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:57:13 +0900
Message-ID: <003b01cea53d$647aa370$2d6fea50$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Lennert Buytenhek' <buytenh@wantstofly.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:39560 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab3H3E5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:57:19 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00002V31W2M0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:57:13 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index c35db73..7fb5677 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2641,7 +2641,7 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	ret = mv643xx_eth_shared_of_probe(pdev);
 	if (ret)
 		return ret;
-	pd = pdev->dev.platform_data;
+	pd = dev_get_platdata(&pdev->dev);
 
 	msp->tx_csum_limit = (pd != NULL && pd->tx_csum_limit) ?
 					pd->tx_csum_limit : 9 * 1024;
@@ -2833,7 +2833,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	struct resource *res;
 	int err;
 
-	pd = pdev->dev.platform_data;
+	pd = dev_get_platdata(&pdev->dev);
 	if (pd == NULL) {
 		dev_err(&pdev->dev, "no mv643xx_eth_platform_data\n");
 		return -ENODEV;
-- 
1.7.10.4
