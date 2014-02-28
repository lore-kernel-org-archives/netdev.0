From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH V2 1/2] net: w5300: Use devm_ioremap_resource()
Date: Fri, 28 Feb 2014 14:47:47 +0900
Message-ID: <001501cf3448$9bc4f660$d34ee320$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Mike Sinkovsky' <msink@permonline.ru>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:24596 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaB1Fru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 00:47:50 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N1O0091ZYRNGQ80@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 28 Feb 2014 14:47:47 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use devm_ioremap_resource() in order to make the code simpler.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/wiznet/w5300.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 71c27b3..1f33c4c 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -561,11 +561,10 @@ static int w5300_hw_probe(struct platform_device *pdev)
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
 	priv->indirect = mem_size < W5300_BUS_DIRECT_SIZE;
-- 
1.7.10.4
