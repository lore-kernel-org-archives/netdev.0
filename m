From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 5/5] stmmac: replace if (netif_msg_type) by their netif_xxx counterpart
Date: Thu, 10 Sep 2015 14:37:33 +0200
Message-ID: <1441888653-30535-6-git-send-email-clabbe.montjoie@gmail.com>
References: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As sugested by Joe Perches, we could replace all
if (netif_msg_type(priv)) dev_xxx(priv->devices, ...)
by the simplier macro netif_xxx(priv, hw, priv->dev, ...)

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 62 ++++++++++-------------
 1 file changed, 27 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 08778b9..477078a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -650,11 +650,13 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 	if (priv->dma_cap.atime_stamp && priv->extend_desc)
 		priv->adv_ts = 1;
 
-	if (netif_msg_hw(priv) && priv->dma_cap.time_stamp)
-		netdev_dbg(priv->dev, "IEEE 1588-2002 Time Stamp supported\n");
+	if (priv->dma_cap.time_stamp)
+		netif_dbg(priv, hw, priv->dev,
+			  "IEEE 1588-2002 Time Stamp supported\n");
 
-	if (netif_msg_hw(priv) && priv->adv_ts)
-		netdev_dbg(priv->dev, "IEEE 1588-2008 Advanced Time Stamp supported\n");
+	if (priv->adv_ts)
+		netif_dbg(priv, hw, priv->dev,
+			  "IEEE 1588-2008 Advanced Time Stamp supported\n");
 
 	priv->hw->ptp = &stmmac_ptp;
 	priv->hwts_tx_en = 0;
@@ -733,10 +735,9 @@ static void stmmac_adjust_link(struct net_device *dev)
 				stmmac_hw_fix_mac_speed(priv);
 				break;
 			default:
-				if (netif_msg_link(priv))
-					netdev_warn(priv->dev,
-						    "%s: Speed (%d) not 10/100\n",
-						    dev->name, phydev->speed);
+				netif_warn(priv, link, priv->dev,
+					   "%s: Speed (%d) not 10/100\n",
+					   dev->name, phydev->speed);
 				break;
 			}
 
@@ -1038,18 +1039,15 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 
 	priv->dma_buf_sz = bfsize;
 
-	if (netif_msg_probe(priv))
-		netdev_dbg(priv->dev, "%s: txsize %d, rxsize %d, bfsize %d\n",
-			   __func__, txsize, rxsize, bfsize);
+	netif_dbg(priv, probe, priv->dev, "%s: txsize %d, rxsize %d, bfsize %d\n",
+		  __func__, txsize, rxsize, bfsize);
 
-	if (netif_msg_probe(priv)) {
-		netdev_dbg(priv->dev, "(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n",
-			   __func__, (u32)priv->dma_rx_phy,
-			   (u32)priv->dma_tx_phy);
+	netif_dbg(priv, probe, priv->dev, "(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n",
+		  __func__, (u32)priv->dma_rx_phy, (u32)priv->dma_tx_phy);
+
+	/* RX INITIALIZATION */
+	netif_dbg(priv, probe, priv->dev, "SKB addresses:\nskb\t\tskb data\tdma data\n");
 
-		/* RX INITIALIZATION */
-		netdev_dbg(priv->dev, "SKB addresses:\nskb\t\tskb data\tdma data\n");
-	}
 	for (i = 0; i < rxsize; i++) {
 		struct dma_desc *p;
 
@@ -1062,11 +1060,9 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 		if (ret)
 			goto err_init_rx_buffers;
 
-		if (netif_msg_probe(priv))
-			netdev_dbg(priv->dev, "[%p]\t[%p]\t[%x]\n",
-				   priv->rx_skbuff[i],
-				 priv->rx_skbuff[i]->data,
-				 (unsigned int)priv->rx_skbuff_dma[i]);
+		netif_dbg(priv, probe, priv->dev, "[%p]\t[%p]\t[%x]\n",
+			  priv->rx_skbuff[i], priv->rx_skbuff[i]->data,
+			  (unsigned int)priv->rx_skbuff_dma[i]);
 	}
 	priv->cur_rx = 0;
 	priv->dirty_rx = (unsigned int)(i - rxsize);
@@ -1346,9 +1342,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 
 			stmmac_get_tx_hwtstamp(priv, entry, skb);
 		}
-		if (netif_msg_tx_done(priv))
-			netdev_dbg(priv->dev, "%s: curr %d, dirty %d\n",
-				   __func__, priv->cur_tx, priv->dirty_tx);
+		netif_dbg(priv, tx_done, priv->dev, "%s: curr %d, dirty %d\n",
+			  __func__, priv->cur_tx, priv->dirty_tx);
 
 		if (likely(priv->tx_skbuff_dma[entry].buf)) {
 			if (priv->tx_skbuff_dma[entry].map_as_page)
@@ -1385,9 +1380,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		netif_tx_lock(priv->dev);
 		if (netif_queue_stopped(priv->dev) &&
 		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)) {
-			if (netif_msg_tx_done(priv))
-				netdev_dbg(priv->dev, "%s: restart transmit\n",
-					   __func__);
+			netif_dbg(priv, tx_done, priv->dev, "%s: restart transmit\n",
+				  __func__);
 			netif_wake_queue(priv->dev);
 		}
 		netif_tx_unlock(priv->dev);
@@ -2065,9 +2059,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		print_pkt(skb->data, skb->len);
 	}
 	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
-		if (netif_msg_hw(priv))
-			netdev_dbg(priv->dev,
-				   "%s: stop transmitted packets\n", __func__);
+		netif_dbg(priv, hw, priv->dev,
+			  "%s: stop transmitted packets\n", __func__);
 		netif_stop_queue(dev);
 	}
 
@@ -2155,9 +2148,8 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
 			priv->hw->mode->refill_desc3(priv, p);
 
-			if (netif_msg_rx_status(priv))
-				netdev_dbg(priv->dev,
-					   "refill entry #%d\n", entry);
+			netif_dbg(priv, rx_status, priv->dev,
+				  "refill entry #%d\n", entry);
 		}
 		wmb();
 		priv->hw->desc->set_rx_owner(p);
-- 
2.4.6
