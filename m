From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: systemport: Use devm_ioremap_resource()
Date: Wed, 14 May 2014 12:15:42 +0900
Message-ID: <001c01cf6f22$c9fe6f60$5dfb4e20$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Florian Fainelli' <f.fainelli@gmail.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:48973 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbaENDPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 23:15:44 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N5J00BWYNQ60Y10@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 14 May 2014 12:15:43 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use devm_ioremap_resource() because devm_request_and_ioremap() is
obsoleted by devm_ioremap_resource().

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 4dc8d1e..1fa5205 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1514,10 +1514,9 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 		goto err;
 	}
 
-	priv->base = devm_request_and_ioremap(&pdev->dev, r);
-	if (!priv->base) {
-		dev_err(&pdev->dev, "register remap failed\n");
-		ret = -ENOMEM;
+	priv->base = devm_ioremap_resource(&pdev->dev, r);
+	if (IS_ERR(priv->base)) {
+		ret = PTR_ERR(priv->base);
 		goto err;
 	}
 
-- 
1.7.10.4
