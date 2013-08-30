From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 24/31] net: davinci_emac: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:05:27 +0900
Message-ID: <004801cea53e$8a839e40$9f8adac0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:15764 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab3H3FF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:05:27 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00LNVVGQ86L0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:05:26 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 829c7a4846b68ee49beb465db2caa1127cca38cc Mon Sep 17 00:00:00 2001
From: Jingoo Han <jg1.han@samsung.com>
Date: Fri, 30 Aug 2013 12:29:57 +0900
Subject: [PATCH 24/31] net: davinci_emac: use dev_get_platdata()

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 1a222bce..67df09e 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1761,7 +1761,7 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 	const u8 *mac_addr;
 
 	if (!IS_ENABLED(CONFIG_OF) || !pdev->dev.of_node)
-		return pdev->dev.platform_data;
+		return dev_get_platdata(&pdev->dev);
 
 	pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
 	if (!pdata)
-- 
1.7.10.4
