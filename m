From: John Crispin <john@phrozen.org>
Subject: [PATCH 4/4] net-next: mediatek: set the rx_queue to 0
Date: Mon, 19 Jun 2017 15:37:06 +0200
Message-ID: <20170619133706.3415-5-john@phrozen.org>
References: <20170619133706.3415-1-john@phrozen.org>
Cc: linux-mediatek@lists.infradead.org, netdev@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Sean Wang <sean.wang@mediatek.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:57329 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751063AbdFSNhX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 09:37:23 -0400
In-Reply-To: <20170619133706.3415-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The get_rps_cpu() function will not do any RPS on the data flow when no
queue is setup and always use the current cpu where the IRQ was handled
to also handle the backlog. As we only have one physical queue we always
set this to 0 unconditionally.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 462d1e83e254..adaaafc20532 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -992,6 +992,7 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
 		    RX_DMA_VID(trxd.rxd3))
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 					       RX_DMA_VID(trxd.rxd3));
+		skb_record_rx_queue(skb, 0);
 		napi_gro_receive(napi, skb);
 
 		ring->data[idx] = new_data;
-- 
2.11.0
