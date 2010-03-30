From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove redundant code
Date: Tue, 30 Mar 2010 17:02:15 +0200
Message-ID: <1269961335.2012.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:58443 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab0C3PCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 11:02:24 -0400
Received: by bwz1 with SMTP id 1so4448119bwz.21
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 08:02:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eth_type_trans(skb, netdev) does the "skb->dev = netdev;"
initialization, we can remove it from various network drivers.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/arm/w90p910_ether.c |    1 -
 drivers/net/atl1c/atl1c_main.c  |    1 -
 drivers/net/atl1e/atl1e_main.c  |    1 -
 drivers/net/atlx/atl2.c         |    1 -
 drivers/net/bcm63xx_enet.c      |    1 -
 drivers/net/benet/be_main.c     |    1 -
 drivers/net/fec_mpc52xx.c       |    1 -
 drivers/net/greth.c             |    1 -
 drivers/net/ibm_newemac/core.c  |    1 -
 drivers/net/ks8851_mll.c        |    1 -
 drivers/net/ksz884x.c           |    2 --
 drivers/net/s6gmac.c            |    1 -
 drivers/net/tehuti.c            |    1 -
 drivers/net/xilinx_emaclite.c   |    1 -
 14 files changed, 15 deletions(-)

diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index febd813..3302df2 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -743,7 +743,6 @@ static void netdev_rx(struct net_device *dev)
 				return;
 			}
 
-			skb->dev = dev;
 			skb_reserve(skb, 2);
 			skb_put(skb, length);
 			skb_copy_to_linear_data(skb, data, length);
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 50dc531..a5508e1 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -1817,7 +1817,6 @@ rrs_checked:
 		atl1c_clean_rfd(rfd_ring, rrs, rfd_num);
 		skb_put(skb, length - ETH_FCS_LEN);
 		skb->protocol = eth_type_trans(skb, netdev);
-		skb->dev = netdev;
 		atl1c_rx_checksum(adapter, skb, rrs);
 		if (unlikely(adapter->vlgrp) && rrs->word3 & RRS_VLAN_INS) {
 			u16 vlan;
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 73302ae..7231b57 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1428,7 +1428,6 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 					    "Memory squeeze, deferring packet\n");
 				goto skip_pkt;
 			}
-			skb->dev = netdev;
 			memcpy(skb->data, (u8 *)(prrs + 1), packet_size);
 			skb_put(skb, packet_size);
 			skb->protocol = eth_type_trans(skb, netdev);
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 7061d71..199f2c9 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -421,7 +421,6 @@ static void atl2_intr_rx(struct atl2_adapter *adapter)
 				netdev->stats.rx_dropped++;
 				break;
 			}
-			skb->dev = netdev;
 			memcpy(skb->data, rxd->packet, rx_size);
 			skb_put(skb, rx_size);
 			skb->protocol = eth_type_trans(skb, netdev);
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 8cdcab7..37eb802 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -340,7 +340,6 @@ static int bcm_enet_receive_queue(struct net_device *dev, int budget)
 		}
 
 		skb_put(skb, len);
-		skb->dev = dev;
 		skb->protocol = eth_type_trans(skb, dev);
 		priv->stats.rx_packets++;
 		priv->stats.rx_bytes += len;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 50ea056..17282df 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -826,7 +826,6 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
-	skb->dev = adapter->netdev;
 
 	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 0dbd721..704155e 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -435,7 +435,6 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 				 DMA_FROM_DEVICE);
 		length = status & BCOM_FEC_RX_BD_LEN_MASK;
 		skb_put(rskb, length - 4);	/* length without CRC32 */
-		rskb->dev = dev;
 		rskb->protocol = eth_type_trans(rskb, dev);
 		netif_rx(rskb);
 
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 2b9c1cb..c5e0d28 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -894,7 +894,6 @@ static int greth_rx_gbit(struct net_device *dev, int limit)
 				else
 					skb->ip_summed = CHECKSUM_NONE;
 
-				skb->dev = dev;
 				skb->protocol = eth_type_trans(skb, dev);
 				dev->stats.rx_packets++;
 				netif_receive_skb(skb);
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index fb0ac6d..d8533a4 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1699,7 +1699,6 @@ static int emac_poll_rx(void *param, int budget)
 
 		skb_put(skb, len);
 	push_packet:
-		skb->dev = dev->ndev;
 		skb->protocol = eth_type_trans(skb, dev->ndev);
 		emac_rx_csum(dev, skb, ctrl);
 
diff --git a/drivers/net/ks8851_mll.c b/drivers/net/ks8851_mll.c
index d3c6a77..ee3fe30 100644
--- a/drivers/net/ks8851_mll.c
+++ b/drivers/net/ks8851_mll.c
@@ -801,7 +801,6 @@ static void ks_rcv(struct ks_net *ks, struct net_device *netdev)
 			/* read data block including CRC 4 bytes */
 			ks_read_qmu(ks, (u16 *)skb->data, frame_hdr->len);
 			skb_put(skb, frame_hdr->len);
-			skb->dev = netdev;
 			skb->protocol = eth_type_trans(skb, netdev);
 			netif_rx(skb);
 		} else {
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index b47a2b3..b843bf7 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -5043,8 +5043,6 @@ static inline int rx_proc(struct net_device *dev, struct ksz_hw* hw,
 			dma_buf->skb->data, packet_len);
 	} while (0);
 
-	skb->dev = dev;
-
 	skb->protocol = eth_type_trans(skb, dev);
 
 	if (hw->rx_cfg & (DMA_RX_CSUM_UDP | DMA_RX_CSUM_TCP))
diff --git a/drivers/net/s6gmac.c b/drivers/net/s6gmac.c
index 45f2634..6b12524 100644
--- a/drivers/net/s6gmac.c
+++ b/drivers/net/s6gmac.c
@@ -396,7 +396,6 @@ static void s6gmac_rx_interrupt(struct net_device *dev)
 		} else {
 			skb_put(skb, (pfx >> S6_GMAC_BURST_POSTRD_LEN)
 				& S6_GMAC_BURST_POSTRD_LEN_MASK);
-			skb->dev = dev;
 			skb->protocol = eth_type_trans(skb, dev);
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			netif_rx(skb);
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index f549309..068a471 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1303,7 +1303,6 @@ static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, int budget)
 		priv->net_stats.rx_bytes += len;
 
 		skb_put(skb, len);
-		skb->dev = priv->ndev;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		skb->protocol = eth_type_trans(skb, priv->ndev);
 
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 1a74594..eaebba8 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -638,7 +638,6 @@ static void xemaclite_rx_handler(struct net_device *dev)
 	}
 
 	skb_put(skb, len);	/* Tell the skb how much data we got */
-	skb->dev = dev;		/* Fill out required meta-data */
 
 	skb->protocol = eth_type_trans(skb, dev);
 	skb->ip_summed = CHECKSUM_NONE;


