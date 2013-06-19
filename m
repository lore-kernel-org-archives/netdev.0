From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] bcm63xx_enet: fix return value check in bcm_enet_shared_probe()
Date: Wed, 19 Jun 2013 10:32:32 +0800
Message-ID: <CAPgLHd_=CCFcpkJP_717-hLREO+DBhYKNVpupmJik0oRnLGA3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, jogo@openwrt.org, mbizon@freebox.fr,
	joe@perches.com, cernekee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:54065 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933941Ab3FSCcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 22:32:33 -0400
Received: by mail-bk0-f41.google.com with SMTP id jc3so2107434bkc.14
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 19:32:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function devm_ioremap_resource() returns ERR_PTR()
and never returns NULL. The NULL test in the return value check should
be replaced with IS_ERR().

Introduce by commit 0ae99b5fede6f3a8d252d50bb4aba29544295219
(bcm63xx_enet: split DMA channel register accesses)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 8f1ac02..b1bcd4b 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -2862,8 +2862,8 @@ static int bcm_enet_shared_probe(struct platform_device *pdev)
 	for (i = 0; i < 3; i++) {
 		res = platform_get_resource(pdev, IORESOURCE_MEM, i);
 		p[i] = devm_ioremap_resource(&pdev->dev, res);
-		if (!p[i])
-			return -ENOMEM;
+		if (IS_ERR(p[i]))
+			return PTR_ERR(p[i]);
 	}
 
 	memcpy(bcm_enet_shared_base, p, sizeof(bcm_enet_shared_base));
