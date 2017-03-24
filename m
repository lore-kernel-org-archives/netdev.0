From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next 2/2] net: stmmac: fix number of tx queues in stmmac_poll
Date: Fri, 24 Mar 2017 17:16:45 +0000
Message-ID: <b6f44c16abea1693dcc1333517778bd7a3e0b0f5.1490375512.git.jpinto@synopsys.com>
References: <cover.1490375512.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        clabbe.montjoie@gmail.com, thierry.reding@gmail.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:48773 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966906AbdCXRQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:16:57 -0400
In-Reply-To: <cover.1490375512.git.jpinto@synopsys.com>
In-Reply-To: <cover.1490375512.git.jpinto@synopsys.com>
References: <cover.1490375512.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For cores that have more than 1 TX queue configured, the kernel would crash,
since only one TX queue is permitted by default.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3827952..1eab084 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3429,7 +3429,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 	struct stmmac_rx_queue *rx_q =
 		container_of(napi, struct stmmac_rx_queue, napi);
 	struct stmmac_priv *priv = rx_q->priv_data;
-	u32 tx_count = priv->dma_cap.number_tx_queues;
+	u32 tx_count = priv->plat->tx_queues_to_use;
 	u32 chan = rx_q->queue_index;
 	u32 work_done = 0;
 	u32 queue = 0;
-- 
2.9.3
