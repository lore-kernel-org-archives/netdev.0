From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 07/12] tile: enable GRO in the tilegx network driver
Date: Wed, 31 Jul 2013 11:05:04 -0400
Message-ID: <6cfd1d016086b799235c30684fed6096a36d815a.1375283106.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
	<cover.1375283104.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:31245 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932297Ab3GaPVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:21:50 -0400
In-Reply-To: <cover.1375283104.git.cmetcalf@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 58bd189..3a101b4 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -422,7 +422,7 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 	if (idesc->cs && idesc->csum_seed_val == 0xFFFF)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	netif_receive_skb(skb);
+	napi_gro_receive(&info->napi, skb);
 
 	/* Update stats. */
 	tile_net_stats_add(1, &dev->stats.rx_packets);
-- 
1.8.3.1
