From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v3 4/5] net-next: ethernet: mediatek: add device_node of GMAC pointing into the netdev instance
Date: Wed, 29 Mar 2017 17:38:22 +0800
Message-ID: <1490780303-18598-5-git-send-email-sean.wang@mediatek.com>
References: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <davem@davemloft.net>,
        <sean.wang@mediatek.com>, <Landen.Chao@mediatek.com>,
        <keyhaede@gmail.com>, <objelf@gmail.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <matthias.bgg@gmail.com>,
        <robh+dt@kernel.org>, <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

the patch adds the setup of the corresponding device node of GMAC into the
netdev instance which could allow other modules such as DSA to find the
instance through the node in dt-bindings using of_find_net_device_by_node()
call.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index c21ed99..84b09a4 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2323,6 +2323,8 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 	eth->netdev[id]->ethtool_ops = &mtk_ethtool_ops;
 
 	eth->netdev[id]->irq = eth->irq[0];
+	eth->netdev[id]->dev.of_node = np;
+
 	return 0;
 
 free_netdev:
-- 
1.9.1
