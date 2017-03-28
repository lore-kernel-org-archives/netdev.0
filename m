From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 2/3] net: stmmac: Always use the number of configured TX queues
Date: Tue, 28 Mar 2017 15:57:05 +0200
Message-ID: <20170328135706.7605-2-thierry.reding@gmail.com>
References: <71d841cd-b07b-2635-c2cf-f7af5f5ed2c9@axis.com>
 <20170328135706.7605-1-thierry.reding@gmail.com>
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        David Miller <davem@davemloft.net>, clabbe.montjoie@gmail.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35921 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755667AbdC1N6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:58:08 -0400
Received: by mail-lf0-f67.google.com with SMTP id n78so10593273lfi.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 06:57:14 -0700 (PDT)
In-Reply-To: <20170328135706.7605-1-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <treding@nvidia.com>

Even if hardware supports multiple queues, software can choose to only
use a subset of them. Make sure we never try to access uninitialized
queues.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 106ace3781b3..ec5bba85c529 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3423,7 +3423,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 	struct stmmac_rx_queue *rx_q =
 		container_of(napi, struct stmmac_rx_queue, napi);
 	struct stmmac_priv *priv = rx_q->priv_data;
-	u32 tx_count = priv->dma_cap.number_tx_queues;
+	u32 tx_count = priv->plat->tx_queues_to_use;
 	u32 chan = rx_q->queue_index;
 	u32 work_done = 0;
 	u32 queue = 0;
-- 
2.12.0
