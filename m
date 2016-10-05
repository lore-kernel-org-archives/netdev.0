From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next v2 RESEND 2/3] net: ethernet: mediatek: get hw lro capability by the chip id instead of by the dtsi
Date: Wed, 5 Oct 2016 20:32:21 +0800
Message-ID: <1475670742-11498-3-git-send-email-nelson.chang@mediatek.com>
References: <1475670742-11498-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:1447 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752395AbcJEMca (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 08:32:30 -0400
In-Reply-To: <1475670742-11498-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because hw lro started to be supported from MT7623, the proper way to check if
the feature is capable is to judge by the chip id instead of by the dtsi.

Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 12 ++++++++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  1 +
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 0c67ab1..07f3ffa 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2348,6 +2348,14 @@ static int mtk_get_chip_id(struct mtk_eth *eth, u32 *chip_id)
 	return 0;
 }
 
+static bool mtk_is_hwlro_supported(struct mtk_eth *eth)
+{
+	if (eth->chip_id == MT7623_ETH)
+		return true;
+	else
+		return false;
+}
+
 static int mtk_probe(struct platform_device *pdev)
 {
 	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2387,8 +2395,6 @@ static int mtk_probe(struct platform_device *pdev)
 		return PTR_ERR(eth->pctl);
 	}
 
-	eth->hwlro = of_property_read_bool(pdev->dev.of_node, "mediatek,hwlro");
-
 	for (i = 0; i < 3; i++) {
 		eth->irq[i] = platform_get_irq(pdev, i);
 		if (eth->irq[i] < 0) {
@@ -2417,6 +2423,8 @@ static int mtk_probe(struct platform_device *pdev)
 	if (err)
 		return err;
 
+	eth->hwlro = mtk_is_hwlro_supported(eth);
+
 	for_each_child_of_node(pdev->dev.of_node, mac_np) {
 		if (!of_device_is_compatible(mac_np,
 					     "mediatek,eth-mac"))
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index a5b422b..99b1c8e 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -345,6 +345,7 @@
 /* ethernet subsystem chip id register */
 #define ETHSYS_CHIPID0_3	0x0
 #define ETHSYS_CHIPID4_7	0x4
+#define MT7623_ETH		7623
 
 /* ethernet subsystem config register */
 #define ETHSYS_SYSCFG0		0x14
-- 
1.9.1
