From: weiyj_lk@163.com
Subject: [PATCH -next] net: ethernet: bgmac: Remove redundant dev_err call in bgmac_probe()
Date: Wed, 13 Jul 2016 12:46:57 +0000
Message-ID: <1468414017-2942-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:56958 "EHLO m12-18.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbcGMMrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 08:47:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

There is a error message within devm_ioremap_resource
already, so remove the dev_err call to avoid redundant
error message.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/broadcom/bgmac-platform.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 1a2d841..be52f27 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -129,10 +129,8 @@ static int bgmac_probe(struct platform_device *pdev)
 	}
 
 	bgmac->plat.base = devm_ioremap_resource(&pdev->dev, regs);
-	if (IS_ERR(bgmac->plat.base)) {
-		dev_err(&pdev->dev, "Unable to map base resource\n");
+	if (IS_ERR(bgmac->plat.base))
 		return PTR_ERR(bgmac->plat.base);
-	}
 
 	regs = platform_get_resource_byname(pdev, IORESOURCE_MEM, "idm_base");
 	if (!regs) {
@@ -141,10 +139,8 @@ static int bgmac_probe(struct platform_device *pdev)
 	}
 
 	bgmac->plat.idm_base = devm_ioremap_resource(&pdev->dev, regs);
-	if (IS_ERR(bgmac->plat.idm_base)) {
-		dev_err(&pdev->dev, "Unable to map idm resource\n");
+	if (IS_ERR(bgmac->plat.idm_base))
 		return PTR_ERR(bgmac->plat.idm_base);
-	}
 
 	bgmac->read = platform_bgmac_read;
 	bgmac->write = platform_bgmac_write;
