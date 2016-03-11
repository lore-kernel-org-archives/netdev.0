From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 12/13] net/mlx5e: Remove redundant barrier
Date: Fri, 11 Mar 2016 15:39:53 +0200
Message-ID: <1457703594-9482-13-git-send-email-saeedm@mellanox.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33186 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753213AbcCKNkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 08:40:37 -0500
In-Reply-To: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

The bit-op operation one line before is an explicit barrier
by itself.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 882e42e..10f8ca5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -147,7 +147,6 @@ void mlx5e_completion_event(struct mlx5_core_cq *mcq)
 	struct mlx5e_cq *cq = container_of(mcq, struct mlx5e_cq, mcq);
 
 	set_bit(MLX5E_CHANNEL_NAPI_SCHED, &cq->channel->flags);
-	barrier();
 	napi_schedule(cq->napi);
 }
 
-- 
1.7.1
