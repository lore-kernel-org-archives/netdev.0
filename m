From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4: Fixing bad size of event queue buffer
Date: Thu, 31 Mar 2011 11:30:17 +0200
Message-ID: <4D9449A9.9070600@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53906 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754165Ab1CaJaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 05:30:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should reduce the number of reserved completion queues from the total
number of entries. Since the queue size is power of two, not reducing the
reserved entries, caused a double queue size, which may lead to allocation
failures in some cases.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/eq.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 506cfd0..1ad1f60 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -603,7 +603,9 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 	}
 
 	for (i = 0; i < dev->caps.num_comp_vectors; ++i) {
-		err = mlx4_create_eq(dev, dev->caps.num_cqs + MLX4_NUM_SPARE_EQE,
+		err = mlx4_create_eq(dev, dev->caps.num_cqs -
+					  dev->caps.reserved_cqs +
+					  MLX4_NUM_SPARE_EQE,
 				     (dev->flags & MLX4_FLAG_MSI_X) ? i : 0,
 				     &priv->eq_table.eq[i]);
 		if (err) {
-- 
1.6.0.2



