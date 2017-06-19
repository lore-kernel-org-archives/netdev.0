From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH net-next] net: stmmac: enable TSO for IPv6
Date: Mon, 19 Jun 2017 18:36:44 +0200
Message-ID: <20170619163645.28764-1-niklas.cassel@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is nothing in the IP that prevents us from enabling TSO for IPv6.

Before patch:
ftp fe80::2aa:bbff:fecc:1336%eth0
ftp> get /dev/zero
882512708 bytes received in 00:14 (56.11 MiB/s)

After patch:
ftp fe80::2aa:bbff:fecc:1336%eth0
ftp> get /dev/zero
1203326784 bytes received in 00:12 (94.52 MiB/s)

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6a1cb59728fe..fefbf817399a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2965,7 +2965,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Manage oversized TCP frames for GMAC4 device */
 	if (skb_is_gso(skb) && priv->tso) {
-		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+		if (skb_shinfo(skb)->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))
 			return stmmac_tso_xmit(skb, dev);
 	}
 
@@ -4126,7 +4126,7 @@ int stmmac_dvr_probe(struct device *device,
 			    NETIF_F_RXCSUM;
 
 	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen)) {
-		ndev->hw_features |= NETIF_F_TSO;
+		ndev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
 		priv->tso = true;
 		dev_info(priv->device, "TSO feature enabled\n");
 	}
-- 
2.11.0
