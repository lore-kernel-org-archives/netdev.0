From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: mediatek: remove unnecessary platform_set_drvdata()
Date: Mon, 15 Aug 2016 22:51:48 +0000
Message-ID: <1471301508-24970-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org
To: Felix Fietkau <nbd@openwrt.org>, John Crispin <blogic@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36738 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbcHOWv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 18:51:56 -0400
Received: by mail-pf0-f195.google.com with SMTP id y134so4374984pfg.3
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 15:51:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 88b04dd..65986a0 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1895,7 +1895,6 @@ static int mtk_remove(struct platform_device *pdev)
 	netif_napi_del(&eth->tx_napi);
 	netif_napi_del(&eth->rx_napi);
 	mtk_cleanup(eth);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
