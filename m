From: John Crispin <john@phrozen.org>
Subject: [PATCH 1/4] net-next: mediatek: print phy status changes for non DSA GMACs
Date: Mon, 19 Jun 2017 15:37:03 +0200
Message-ID: <20170619133706.3415-2-john@phrozen.org>
References: <20170619133706.3415-1-john@phrozen.org>
Cc: linux-mediatek@lists.infradead.org, netdev@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Sean Wang <sean.wang@mediatek.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:57331 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751093AbdFSNhY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 09:37:24 -0400
In-Reply-To: <20170619133706.3415-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently PHY status changes are only printed for DSA ports. This patch
adds code to also print status changes for non-fixed links.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 962975d192d1..24d5f1cad7f4 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -221,6 +221,9 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 		netif_carrier_on(dev);
 	else
 		netif_carrier_off(dev);
+
+	if (!of_phy_is_fixed_link(mac->of_node))
+		phy_print_status(dev->phydev);
 }
 
 static int mtk_phy_connect_node(struct mtk_eth *eth, struct mtk_mac *mac,
-- 
2.11.0
