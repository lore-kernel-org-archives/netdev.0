From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 08/22] net-next: mediatek: invalid buffer lookup in mtk_tx_map()
Date: Mon,  9 May 2016 12:04:00 +0200
Message-ID: <1462788254-40572-9-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47286 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346AbcEIKEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:04:35 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lookup of the tx_buffer in the error path inside mtk_tx_map() uses the
wrong descriptor pointer. This looks like a copy & paste error. Change the
code to use the correct pointer.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 49a3b7c..e61e73b 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -673,7 +673,7 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 
 err_dma:
 	do {
-		tx_buf = mtk_desc_to_tx_buf(ring, txd);
+		tx_buf = mtk_desc_to_tx_buf(ring, itxd);
 
 		/* unmap dma */
 		mtk_tx_unmap(&dev->dev, tx_buf);
-- 
1.7.10.4
