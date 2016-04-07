From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V3 3/8] net: mediatek: remove superfluous reset call
Date: Fri,  8 Apr 2016 00:54:06 +0200
Message-ID: <1460069651-1234-4-git-send-email-blogic@openwrt.org>
References: <1460069651-1234-1-git-send-email-blogic@openwrt.org>
Cc: Felix Fietkau <nbd@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	=?UTF-8?q?Sean=20Wang=20=28=E7=8E=8B=E5=BF=97=E4=BA=98=29?=
	<sean.wang@mediatek.com>, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caladan.dune.hu ([78.24.191.180]:36284 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753462AbcDHHus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 03:50:48 -0400
In-Reply-To: <1460069651-1234-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW reset is triggered in the mtk_hw_init() function. There is no need to
also reset the core during probe.

Signed-off-by: John Crispin <blogic@openwrt.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 94cceb8..a4982e4 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1679,10 +1679,6 @@ static int mtk_probe(struct platform_device *pdev)
 	struct mtk_eth *eth;
 	int err;
 
-	err = device_reset(&pdev->dev);
-	if (err)
-		return err;
-
 	match = of_match_device(of_mtk_match, &pdev->dev);
 	soc = (struct mtk_soc_data *)match->data;
 
-- 
1.7.10.4
