From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 09/13] tile: enable GRO in the tilegx network driver
Date: Tue, 23 Jul 2013 16:05:48 -0400
Message-ID: <1188c5613d72850983d54f3b6d0276f3a5aa98f0.1374609949.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1374609948.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index b34fd2c..9c128ff 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -458,7 +458,7 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 	/* Get RX timestamp from idesc. */
 	tile_rx_timestamp(skb, idesc);
 
-	netif_receive_skb(skb);
+	napi_gro_receive(&info->napi, skb);
 
 	/* Update stats. */
 	tile_net_stats_add(1, &dev->stats.rx_packets);
@@ -1880,6 +1880,7 @@ static void tile_net_setup(struct net_device *dev)
 	dev->features |= NETIF_F_HW_CSUM;
 	dev->features |= NETIF_F_SG;
 	dev->features |= NETIF_F_TSO;
+	dev->features |= NETIF_F_GRO;
 	dev->mtu = 1500;
 }
 
-- 
1.8.3.1
