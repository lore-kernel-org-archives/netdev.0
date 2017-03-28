From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next] stmmac: use netif_set_real_num_{rx,tx}_queues
Date: Tue, 28 Mar 2017 11:48:21 +0200
Message-ID: <20170328094856.3457886-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        LABBE Corentin <clabbe.montjoie@gmail.com>,
        Thierry Reding <treding@nvidia.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:50017 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753702AbdC1J51 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 05:57:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A driver must not access the two fields directly but should instead use
the helper functions to set the values and keep a consistent internal
state:

ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
ethernet/stmicro/stmmac/stmmac_main.c:4083:8: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?

Fixes: a8f5102af2a7 ("net: stmmac: TX and RX queue priority configuration")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c78f444ad423..fe1d9592956f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -4080,8 +4080,8 @@ int stmmac_dvr_probe(struct device *device,
 		goto error_hw_init;
 
 	/* Configure real RX and TX queues */
-	ndev->real_num_rx_queues = priv->plat->rx_queues_to_use;
-	ndev->real_num_tx_queues = priv->plat->tx_queues_to_use;
+	netif_set_real_num_rx_queues(ndev, priv->plat->rx_queues_to_use);
+	netif_set_real_num_tx_queues(ndev, priv->plat->tx_queues_to_use);
 
 	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
 
-- 
2.9.0
