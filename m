From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 03/12] net/mlx5e: TC ipv4 tunnel encap offload cosmetic changes
Date: Tue, 24 Jan 2017 22:16:43 +0200
Message-ID: <20170124201652.2920-4-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54284 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750977AbdAXURZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:25 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Move around some settings of variables as pre-step to make things
more robust and clear for the ipv6 case in down-stream patch.
This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index e9f0854e9509..a515444d2489 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -689,7 +689,6 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 {
 	struct rtable *rt;
 	struct neighbour *n = NULL;
-	int ttl;
 
 #if IS_ENABLED(CONFIG_INET)
 	int ret;
@@ -708,7 +707,7 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 		return -EOPNOTSUPP;
 	}
 
-	ttl = ip4_dst_hoplimit(&rt->dst);
+	*out_ttl = ip4_dst_hoplimit(&rt->dst);
 	n = dst_neigh_lookup(&rt->dst, &fl4->daddr);
 	ip_rt_put(rt);
 	if (!n)
@@ -716,7 +715,6 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 
 	*out_n = n;
 	*saddr = fl4->saddr;
-	*out_ttl = ttl;
 	*out_dev = rt->dst.dev;
 
 	return 0;
@@ -792,15 +790,15 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	if (err)
 		goto out;
 
-	e->n = n;
-	e->out_dev = *out_dev;
-
 	if (!(n->nud_state & NUD_VALID)) {
 		pr_warn("%s: can't offload, neighbour to %pI4 invalid\n", __func__, &fl4.daddr);
 		err = -EOPNOTSUPP;
 		goto out;
 	}
 
+	e->n = n;
+	e->out_dev = *out_dev;
+
 	neigh_ha_snapshot(e->h_dest, n, *out_dev);
 
 	switch (e->tunnel_type) {
-- 
2.11.0
