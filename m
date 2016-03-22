From: Vladimir Zapolskiy <vz@mleia.com>
Subject: [PATCH] net: mediatek: fix checking for NULL instead of IS_ERR() in .probe
Date: Wed, 23 Mar 2016 01:06:04 +0200
Message-ID: <1458687964-9690-1-git-send-email-vz@mleia.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@openwrt.org>,
	John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mleia.com ([178.79.152.223]:55111 "EHLO mail.mleia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752177AbcCVXGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 19:06:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource() returns ERR_PTR() value on error, it never
returns NULL, fix it and propagate the returned error upwards.

Fixes: 656e705243fd ("net-next: mediatek: add support for MT7623 ethernet")
Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 7f2126b..e0b68af 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1690,8 +1690,8 @@ static int mtk_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	eth->base = devm_ioremap_resource(&pdev->dev, res);
-	if (!eth->base)
-		return -EADDRNOTAVAIL;
+	if (IS_ERR(eth->base))
+		return PTR_ERR(eth->base);
 
 	spin_lock_init(&eth->page_lock);
 
-- 
2.1.4
