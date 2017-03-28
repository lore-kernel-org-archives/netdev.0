From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 1/3] net: stmmac: Remove unneeded checks for NULL pointer
Date: Tue, 28 Mar 2017 15:57:04 +0200
Message-ID: <20170328135706.7605-1-thierry.reding@gmail.com>
References: <71d841cd-b07b-2635-c2cf-f7af5f5ed2c9@axis.com>
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        David Miller <davem@davemloft.net>, clabbe.montjoie@gmail.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34074 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755683AbdC1N6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:58:08 -0400
Received: by mail-wr0-f196.google.com with SMTP id w43so20143951wrb.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 06:57:27 -0700 (PDT)
In-Reply-To: <71d841cd-b07b-2635-c2cf-f7af5f5ed2c9@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <treding@nvidia.com>

Taking the address of an element within a non-NULL array will never be
zero. This condition isn't checked anywhere else, so drop it in these
two instances as well.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c78f444ad423..106ace3781b3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1332,9 +1332,6 @@ static void free_rx_dma_desc_resources(struct stmmac_priv *priv)
 	for (queue = 0; queue < rx_count; queue++) {
 		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
 
-		if (!rx_q)
-			break;
-
 		/* Release the DMA RX socket buffers */
 		dma_free_rx_skbufs(priv, queue);
 
@@ -1373,9 +1370,6 @@ static void free_tx_dma_desc_resources(struct stmmac_priv *priv)
 	for (queue = 0; queue < tx_count; queue++) {
 		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
 
-		if (!tx_q)
-			break;
-
 		/* Release the DMA TX socket buffers */
 		dma_free_tx_skbufs(priv, queue);
 
-- 
2.12.0
