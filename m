From: <sean.wang@mediatek.com>
Subject: [PATCH net-next] net: ethernet: mediatek: enhance with avoiding superfluous assignment inside mtk_get_ethtool_stats
Date: Tue, 20 Sep 2016 11:26:48 +0800
Message-ID: <1474342008-22496-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:43917 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751148AbcITD05 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 23:26:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

data_src is unchanged inside the loop, so this patch moves
the assignment to outside the loop to avoid unnecessarily
assignment

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 481f360..ca6b501 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2137,8 +2137,9 @@ static void mtk_get_ethtool_stats(struct net_device *dev,
 		}
 	}
 
+	data_src = (u64 *)hwstats;
+
 	do {
-		data_src = (u64 *)hwstats;
 		data_dst = data;
 		start = u64_stats_fetch_begin_irq(&hwstats->syncp);
 
-- 
1.9.1
