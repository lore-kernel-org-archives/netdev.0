From: Sean Wang <sean.wang@mediatek.com>
Subject: [PATCH 2/2] net: ethernet: mediatek: add the missing of_node_put() after node is used done
Date: Sat, 13 Aug 2016 19:16:19 +0800
Message-ID: <1471086979-23032-2-git-send-email-sean.wang@mediatek.com>
References: <1471086979-23032-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:5770 "EHLO
	mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751566AbcHMLQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 07:16:31 -0400
In-Reply-To: <1471086979-23032-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the missing of_node_put() after finishing the usage
of of_parse_phandle() or of_node_get() used by fixed_phy.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index f5d2745..88b04dd 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -269,6 +269,8 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 				    ADVERTISED_Autoneg;
 	phy_start_aneg(mac->phy_dev);
 
+	of_node_put(np);
+
 	return 0;
 }
 
-- 
1.7.9.5
