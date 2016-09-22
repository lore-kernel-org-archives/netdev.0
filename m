From: <sean.wang@mediatek.com>
Subject: [PATCH net-next] net: ethernet: mediatek: remove superfluous local variable for phy address
Date: Thu, 22 Sep 2016 16:36:15 +0800
Message-ID: <1474533375-22423-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

remove the unused variable for parsing PHY address
and the related logic for sanity test which would
be all already handled done when of_mdiobus_register
was called

Reported-by: Nelson Chang <nelson.chang@mediatek.com>
Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 6b7acf4..1918c39 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -226,17 +226,9 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 static int mtk_phy_connect_node(struct mtk_eth *eth, struct mtk_mac *mac,
 				struct device_node *phy_node)
 {
-	const __be32 *_addr = NULL;
 	struct phy_device *phydev;
-	int phy_mode, addr;
+	int phy_mode;
 
-	_addr = of_get_property(phy_node, "reg", NULL);
-
-	if (!_addr || (be32_to_cpu(*_addr) >= 0x20)) {
-		pr_err("%s: invalid phy address\n", phy_node->name);
-		return -EINVAL;
-	}
-	addr = be32_to_cpu(*_addr);
 	phy_mode = of_get_phy_mode(phy_node);
 	if (phy_mode < 0) {
 		dev_err(eth->dev, "incorrect phy-mode %d\n", phy_mode);
-- 
1.9.1
