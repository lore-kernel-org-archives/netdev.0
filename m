From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] moxa: drop free_irq of devm_request_irq allocated irq
Date: Wed, 25 Sep 2013 15:33:29 +0800
Message-ID: <CAPgLHd8YRP7kL_jNHi3J9jFn86f=Fv-AWWUY_aRGZQOgVTNPgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: grant.likely@linaro.org, rob.herring@calxeda.com,
	davem@davemloft.net, jg1.han@samsung.com, jonas.jensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:54724 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab3IYHda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 03:33:30 -0400
Received: by mail-bk0-f48.google.com with SMTP id my13so2077192bkb.7
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 00:33:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

irq allocated with devm_request_irq should not be freed using
free_irq, because doing so causes a dangling pointer, and a
subsequent double free.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 83c2091..9a7fcb5 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -531,7 +531,6 @@ static int moxart_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 
 	unregister_netdev(ndev);
-	free_irq(ndev->irq, ndev);
 	moxart_mac_free_memory(ndev);
 	free_netdev(ndev);
 
