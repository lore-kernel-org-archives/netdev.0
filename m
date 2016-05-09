From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 03/22] net-next: mediatek: add fixed-phy support
Date: Mon,  9 May 2016 12:03:55 +0200
Message-ID: <1462788254-40572-4-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47279 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbcEIKEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:04:30 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MT7623 SoC has a builtin gigabit switch. If we want to use it, GMAC1
needs to be configured using a fixed link speed and flow control settings.
The easiest way to do this is to used the fixed-phy driver, allowing us to
reuse the existing mdio polling code to setup the MAC.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index a76aec20..4d59bda 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -219,6 +219,9 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	u32 val, ge_mode;
 
 	np = of_parse_phandle(mac->of_node, "phy-handle", 0);
+	if (!np && of_phy_is_fixed_link(mac->of_node))
+		if (!of_phy_register_fixed_link(mac->of_node))
+			np = of_node_get(mac->of_node);
 	if (!np)
 		return -ENODEV;
 
-- 
1.7.10.4
