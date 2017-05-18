From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] net/mlx5e: Fix possible memory leak
Date: Thu, 18 May 2017 15:34:41 +0000
Message-ID: <20170518153441.24398-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34597 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932298AbdERPey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

'encap_header' is malloced and should be freed before leaving from
the error handling cases, otherwise it will cause memory leak.

Fixes: 232c001398ae ("net/mlx5e: Add support to neighbour update flow")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 11c27e4..a72ecbc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1404,8 +1404,8 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 
 	if (!(nud_state & NUD_VALID)) {
 		neigh_event_send(n, NULL);
-		neigh_release(n);
-		return -EAGAIN;
+		err = -EAGAIN;
+		goto out;
 	}
 
 	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
@@ -1510,8 +1510,8 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 
 	if (!(nud_state & NUD_VALID)) {
 		neigh_event_send(n, NULL);
-		neigh_release(n);
-		return -EAGAIN;
+		err = -EAGAIN;
+		goto out;
 	}
 
 	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
