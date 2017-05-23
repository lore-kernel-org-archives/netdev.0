From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 1/8] net/mlx5e: Use the correct delete call on offloaded TC encap entry detach
Date: Tue, 23 May 2017 17:16:03 +0300
Message-ID: <20170523141610.27833-2-saeedm@mellanox.com>
References: <20170523141610.27833-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44708 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S937257AbdEWOQf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:16:35 -0400
In-Reply-To: <20170523141610.27833-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

We wrongly direcly invoke hlist_del_rcu() and not hash_del_rcu() which
does a slightly different call now and may change later, fix that.

Fixes: a54e20b4fcae ('net/mlx5e: Add basic TC tunnel set action for SRIOV offloads')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 11c27e4fadf6..a90dd26ea51c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -384,7 +384,7 @@ static void mlx5e_detach_encap(struct mlx5e_priv *priv,
 		if (e->flags & MLX5_ENCAP_ENTRY_VALID)
 			mlx5_encap_dealloc(priv->mdev, e->encap_id);
 
-		hlist_del_rcu(&e->encap_hlist);
+		hash_del_rcu(&e->encap_hlist);
 		kfree(e->encap_header);
 		kfree(e);
 	}
-- 
2.11.0
