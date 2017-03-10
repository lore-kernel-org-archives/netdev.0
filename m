From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 5/9] net: stmmac: Check for DMA mapping errors
Date: Fri, 10 Mar 2017 17:34:57 +0100
Message-ID: <20170310163501.31811-6-thierry.reding@gmail.com>
References: <20170310163501.31811-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170310163501.31811-1-thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

When DMA mapping an SKB fragment, the mapping must be checked for
errors, otherwise the DMA debug code will complain upon unmap.

Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ce6d7e791f3f..eba9088e1f61 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2079,6 +2079,8 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 		des = skb_frag_dma_map(priv->device, frag, 0,
 				       skb_frag_size(frag),
 				       DMA_TO_DEVICE);
+		if (dma_mapping_error(priv->device, des))
+			goto dma_map_err;
 
 		stmmac_tso_allocator(priv, des, skb_frag_size(frag),
 				     (i == nfrags - 1));
-- 
2.12.0
