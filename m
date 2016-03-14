From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/3] net: mediatek: check device_reset return code
Date: Mon, 14 Mar 2016 15:07:12 +0100
Message-ID: <1457964435-2945038-3-git-send-email-arnd@arndb.de>
References: <1457964435-2945038-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Felix Fietkau <nbd@openwrt.org>,
	John Crispin <blogic@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457964435-2945038-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device_reset() function may fail, so we have to check
its return value, e.g. to make deferred probing work correctly.
gcc warns about it because of the warn_unused_result attribute:

drivers/net/ethernet/mediatek/mtk_eth_soc.c: In function 'mtk_probe':
drivers/net/ethernet/mediatek/mtk_eth_soc.c:1679:2: error: ignoring return value of 'device_reset', declared with attribute warn_unused_result [-Werror=unused-result]

This adds the trivial error check to propagate the return value
to the generic platform device probe code.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 87f417712da0..1e6c5498bba9 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1676,7 +1676,9 @@ static int mtk_probe(struct platform_device *pdev)
 	struct mtk_eth *eth;
 	int err;
 
-	device_reset(&pdev->dev);
+	err = device_reset(&pdev->dev);
+	if (err)
+		return err;
 
 	match = of_match_device(of_mtk_match, &pdev->dev);
 	soc = (struct mtk_soc_data *)match->data;
-- 
2.7.0
