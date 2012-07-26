From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1] net/mlx4_en: Limit the RFS filter IDs to be < RPS_NO_FILTER
Date: Thu, 26 Jul 2012 10:21:16 +0300
Message-ID: <1343287276-21584-1-git-send-email-ogerlitz@mellanox.com>
Cc: oren@mellanox.com, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:44319 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750742Ab2GZHVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 03:21:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

RFS filter id can't have the special value RPS_NO_FILTER,
need to skip it when allocating id's.

CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

changes from V0:

- only deal with RPS_NO_FILTER

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 8864d8b..edd9cb8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -201,7 +201,7 @@ mlx4_en_filter_alloc(struct mlx4_en_priv *priv, int rxq_index, __be32 src_ip,
 
 	filter->flow_id = flow_id;
 
-	filter->id = priv->last_filter_id++;
+	filter->id = priv->last_filter_id++ % RPS_NO_FILTER;
 
 	list_add_tail(&filter->next, &priv->filters);
 	hlist_add_head(&filter->filter_chain,
-- 
1.7.1
