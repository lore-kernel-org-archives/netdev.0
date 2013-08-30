From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 28/31] net: w5100: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:07:38 +0900
Message-ID: <004c01cea53e$d8a042e0$89e0c8a0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:41775 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478Ab3H3FHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:07:38 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB005SWVKPFMM0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:07:37 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/wiznet/w5100.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 30fed08..0df36c6 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -622,7 +622,7 @@ static const struct net_device_ops w5100_netdev_ops = {
 
 static int w5100_hw_probe(struct platform_device *pdev)
 {
-	struct wiznet_platform_data *data = pdev->dev.platform_data;
+	struct wiznet_platform_data *data = dev_get_platdata(&pdev->dev);
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct w5100_priv *priv = netdev_priv(ndev);
 	const char *name = netdev_name(ndev);
-- 
1.7.10.4
