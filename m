From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net/mlx5e: remove napi_hash_del() calls
Date: Wed, 16 Nov 2016 06:21:34 -0800
Message-ID: <1479306094.8455.181.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479304537.8455.167.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34081 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932773AbcKPOVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:21:36 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so14492278pgc.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:21:36 -0800 (PST)
In-Reply-To: <1479304537.8455.167.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Calling napi_hash_del() after netif_napi_del() is pointless.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 52b4fd53b1a74d17b7b40efc279305fdb9ed7521..00579ce0e96fb8f992d93ddfa0e5fd58df25813a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1533,7 +1533,6 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 
 err_napi_del:
 	netif_napi_del(&c->napi);
-	napi_hash_del(&c->napi);
 	kfree(c);
 
 	return err;
@@ -1554,9 +1553,6 @@ static void mlx5e_close_channel(struct mlx5e_channel *c)
 	mlx5e_close_cq(&c->icosq.cq);
 	netif_napi_del(&c->napi);
 
-	napi_hash_del(&c->napi);
-	synchronize_rcu();
-
 	kfree(c);
 }
 
