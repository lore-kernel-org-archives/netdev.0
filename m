From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 3/7] net: stmmac: Check for DMA mapping errors
Date: Thu, 23 Feb 2017 18:24:34 +0100
Message-ID: <20170223172438.14770-4-thierry.reding@gmail.com>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Alexandre Courbot <gnurou@gmail.com>,
        Jon Hunter <jonathanh@nvidia.com>, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223172438.14770-1-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

When DMA mapping an SKB fragment, the mapping must be checked for
errors, otherwise the DMA debug code will complain upon unmap.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6b7a5ce19589..d7387919bdb6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2072,6 +2072,8 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 		des = skb_frag_dma_map(priv->device, frag, 0,
 				       skb_frag_size(frag),
 				       DMA_TO_DEVICE);
+		if (dma_mapping_error(priv->device, des))
+			goto dma_map_err;
 
 		stmmac_tso_allocator(priv, des, skb_frag_size(frag),
 				     (i == nfrags - 1));
-- 
2.11.1
