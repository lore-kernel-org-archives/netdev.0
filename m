From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 09/11] net/ariadne: Improve debug prints
Date: Wed, 21 Mar 2012 10:51:53 +0100
Message-ID: <1332323515-7314-9-git-send-email-geert@linux-m68k.org>
References: <1332323515-7314-1-git-send-email-geert@linux-m68k.org>
Cc: linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-m68k@lists.linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332323515-7314-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove casts and use proper printf()-style format specifiers instead.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/amd/ariadne.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index eb18e1f..2e7a1c5 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -213,10 +213,10 @@ static int ariadne_rx(struct net_device *dev)
 						(const void *)priv->rx_buff[entry],
 						pkt_len);
 			skb->protocol = eth_type_trans(skb, dev);
-			netdev_dbg(dev, "RX pkt type 0x%04x from %pM to %pM data 0x%08x len %d\n",
+			netdev_dbg(dev, "RX pkt type 0x%04x from %pM to %pM data %p len %u\n",
 				   ((u_short *)skb->data)[6],
 				   skb->data + 6, skb->data,
-				   (int)skb->data, (int)skb->len);
+				   skb->data, skb->len);
 
 			netif_rx(skb);
 			dev->stats.rx_packets++;
@@ -566,10 +566,10 @@ static netdev_tx_t ariadne_start_xmit(struct sk_buff *skb,
 
 	/* Fill in a Tx ring entry */
 
-	netdev_dbg(dev, "TX pkt type 0x%04x from %pM to %pM data 0x%08x len %d\n",
+	netdev_dbg(dev, "TX pkt type 0x%04x from %pM to %pM data %p len %u\n",
 		   ((u_short *)skb->data)[6],
 		   skb->data + 6, skb->data,
-		   (int)skb->data, (int)skb->len);
+		   skb->data, skb->len);
 
 	local_irq_save(flags);
 
-- 
1.7.0.4
