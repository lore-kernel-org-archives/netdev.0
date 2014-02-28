From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH V2 2/2] net: w5100: Use devm_ioremap_resource()
Date: Fri, 28 Feb 2014 14:48:16 +0900
Message-ID: <001601cf3448$ad6b8c30$0842a490$%han@samsung.com>
References: <001501cf3448$9bc4f660$d34ee320$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Mike Sinkovsky' <msink@permonline.ru>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:24706 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaB1FsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 00:48:20 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N1O00CA3YSJJ830@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 28 Feb 2014 14:48:19 +0900 (KST)
In-reply-to: <001501cf3448$9bc4f660$d34ee320$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use devm_ioremap_resource() in order to make the code simpler.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/wiznet/w5100.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 0df36c6..104d46f 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -641,11 +641,10 @@ static int w5100_hw_probe(struct platform_device *pdev)
 	if (!mem)
 		return -ENXIO;
 	mem_size = resource_size(mem);
-	if (!devm_request_mem_region(&pdev->dev, mem->start, mem_size, name))
-		return -EBUSY;
-	priv->base = devm_ioremap(&pdev->dev, mem->start, mem_size);
-	if (!priv->base)
-		return -EBUSY;
+
+	priv->base = devm_ioremap_resource(&pdev->dev, mem);
+	if (IS_ERR(priv->base))
+		return PTR_ERR(priv->base);
 
 	spin_lock_init(&priv->reg_lock);
 	priv->indirect = mem_size < W5100_BUS_DIRECT_SIZE;
-- 
1.7.10.4
