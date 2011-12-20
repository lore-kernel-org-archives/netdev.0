From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next] mlx4_en: FIX: Setting default_qpn before using it
Date: Tue, 20 Dec 2011 09:53:38 +0200
Message-ID: <4EF03F02.4010904@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:55081 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752053Ab1LTKG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 05:06:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

When UDP RSS is enabled, we use same QPN for TCP and UDP ranges
The bug is that the default_qpn was used base UDP qpn before it
was set.
Fixes bug introduced in commit: 1202d460b1df3a77fda66f4ba5f90ae3527dd42f

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 630a7c1..e8d6ad2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -898,11 +898,11 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	rss_context = ptr;
 	rss_context->base_qpn = cpu_to_be32(ilog2(priv->rx_ring_num) << 24 |
 					    (rss_map->base_qpn));
+	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
 	if (priv->mdev->profile.udp_rss) {
 		rss_mask |=  MLX4_RSS_UDP_IPV4 | MLX4_RSS_UDP_IPV6;
 		rss_context->base_qpn_udp = rss_context->default_qpn;
 	}
-	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
 	rss_context->flags = rss_mask;
 	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
 	for (i = 0; i < 10; i++)
-- 
1.7.7
