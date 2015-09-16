From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net/mlx4_en:
Date: Tue, 15 Sep 2015 18:26:28 -0700
Message-ID: <1442366788.4116.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33754 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbbIPB0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:26:30 -0400
Received: by pacex6 with SMTP id ex6so192622983pac.0
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 18:26:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When changing rss key, we do not want to overwrite user provided key
by the one provided by netdev_rss_key_fill(), which is the host random
key generated at boot time.

Fixes: 947cbb0ac242 ("net/mlx4_en: Support for configurable RSS hash function")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eyal Perry <eyalpe@mellanox.com>
CC: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 4402a1e48c9b..0ce6ffe73ca8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1268,8 +1268,6 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 		rss_context->hash_fn = MLX4_RSS_HASH_TOP;
 		memcpy(rss_context->rss_key, priv->rss_key,
 		       MLX4_EN_RSS_KEY_SIZE);
-		netdev_rss_key_fill(rss_context->rss_key,
-				    MLX4_EN_RSS_KEY_SIZE);
 	} else {
 		en_err(priv, "Unknown RSS hash function requested\n");
 		err = -EINVAL;
