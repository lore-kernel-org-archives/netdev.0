From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 11/22] net-next: mediatek: disable all interrupts during probe
Date: Mon,  9 May 2016 12:04:03 +0200
Message-ID: <1462788254-40572-12-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:51685 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253AbcEIKkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:40:25 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code only disables those IRQs that we will later use. To
ensure that we have a predefined state, we really want to disable all IRQs.
Change the code to disable all IRQs to achieve this.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 3ab7ab9..b8d8ad2 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1393,7 +1393,7 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 
 	/* disable delay and normal interrupt */
 	mtk_w32(eth, 0, MTK_QDMA_DELAY_INT);
-	mtk_irq_disable(eth, MTK_TX_DONE_INT | MTK_RX_DONE_INT);
+	mtk_irq_disable(eth, ~0);
 	mtk_w32(eth, RST_GL_PSE, MTK_RST_GL);
 	mtk_w32(eth, 0, MTK_RST_GL);
 
-- 
1.7.10.4
