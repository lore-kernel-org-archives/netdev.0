From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/3] net/mlx4_en: Fix double-release-range in tx-rings
Date: Thu, 25 Oct 2012 13:12:47 +0200
Message-ID: <1351163569-17132-2-git-send-email-ogerlitz@mellanox.com>
References: <1351163569-17132-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:51560 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759071Ab2JYLM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 07:12:58 -0400
In-Reply-To: <1351163569-17132-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The QP range is reserved as a single block. However, when freeing the
en resources, the tx-ring QPs are released both in mlx4_en_destroy_tx_ring
(one at a time) and in mlx4_en_free_resources (as a block release).

Fix by eliminating the one-at-a-time release in mlx4_en_destroy_tx_ring.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c10e3a6..0a51095 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -143,7 +143,6 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 		mlx4_bf_free(mdev->dev, &ring->bf);
 	mlx4_qp_remove(mdev->dev, &ring->qp);
 	mlx4_qp_free(mdev->dev, &ring->qp);
-	mlx4_qp_release_range(mdev->dev, ring->qpn, 1);
 	mlx4_en_unmap_buffer(&ring->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 	kfree(ring->bounce_buf);
-- 
1.7.1
