From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/2] net: w5300: Use devm_ioremap_resource()
Date: Thu, 27 Feb 2014 19:30:04 +0900
Message-ID: <000001cf33a6$e0a57040$a1f050c0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Mike Sinkovsky' <msink@permonline.ru>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:36759 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaB0KaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 05:30:08 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N1N006S5H66QN60@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 27 Feb 2014 19:30:06 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use devm_ioremap_resource() in order to make the code simpler,
and remove redundant return value check of platform_get_resource()
because the value is checked by devm_ioremap_resource().

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/wiznet/w5300.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 71c27b3..1c3a5a5 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -558,14 +558,11 @@ static int w5300_hw_probe(struct platform_device *pdev)
 	}
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!mem)
-		return -ENXIO;
+	priv->base = devm_ioremap_resource(&pdev->dev, mem);
+	if (IS_ERR(priv->base))
+		return PTR_ERR(priv->base);
+
 	mem_size = resource_size(mem);
-	if (!devm_request_mem_region(&pdev->dev, mem->start, mem_size, name))
-		return -EBUSY;
-	priv->base = devm_ioremap(&pdev->dev, mem->start, mem_size);
-	if (!priv->base)
-		return -EBUSY;
 
 	spin_lock_init(&priv->reg_lock);
 	priv->indirect = mem_size < W5300_BUS_DIRECT_SIZE;
-- 
1.7.10.4
