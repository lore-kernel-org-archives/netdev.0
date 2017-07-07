From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: ethernet: mediatek: remove useless code in mtk_probe()
Date: Fri, 7 Jul 2017 15:23:34 -0500
Message-ID: <20170707202333.GA5114@embeddedgus>
References: <20170707150831.Horde.MYtEbXeqxGS-hTg2bUv3DWt@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Andrew Lunn <andrew@lunn.ch>, Felix Fietkau <nbd@openwrt.org>,
        John Crispin <blogic@openwrt.org>,
        Matthias Brugger <matthias.bgg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170707150831.Horde.MYtEbXeqxGS-hTg2bUv3DWt@gator4166.hostgator.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove useless local variables _match_, _soc_ and the code related.

Notice that

const struct of_device_id of_mtk_match[] = {
        { .compatible = "mediatek,mt2701-eth" },
        {},
};

So match->data is NULL.

Suggested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index adaaafc..b9a5a65 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2401,15 +2401,10 @@ static int mtk_probe(struct platform_device *pdev)
 {
 	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	struct device_node *mac_np;
-	const struct of_device_id *match;
-	struct mtk_soc_data *soc;
 	struct mtk_eth *eth;
 	int err;
 	int i;
 
-	match = of_match_device(of_mtk_match, &pdev->dev);
-	soc = (struct mtk_soc_data *)match->data;
-
 	eth = devm_kzalloc(&pdev->dev, sizeof(*eth), GFP_KERNEL);
 	if (!eth)
 		return -ENOMEM;
-- 
2.5.0
