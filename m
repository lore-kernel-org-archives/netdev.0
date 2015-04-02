From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 02/16] net/mlx5_core: Fix call to mlx5_core_qp_modify
Date: Thu,  2 Apr 2015 17:07:20 +0300
Message-ID: <1427983654-971-3-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:38543 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbbDBOHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:07:45 -0400
Received: by wibgn9 with SMTP id gn9so106934018wib.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:07:43 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haggai Abramonvsky <hagaya@mellanox.com>

Pass 0 in the sqd_event parameter.

Signed-off-by: Haggai Abramovsky <hagaya@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/qp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index be0cd358b080..2c0f142cd3ba 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -1165,7 +1165,7 @@ static void destroy_qp_common(struct mlx5_ib_dev *dev, struct mlx5_ib_qp *qp)
 	if (qp->state != IB_QPS_RESET) {
 		mlx5_ib_qp_disable_pagefaults(qp);
 		if (mlx5_core_qp_modify(dev->mdev, to_mlx5_state(qp->state),
-					MLX5_QP_STATE_RST, in, sizeof(*in), &qp->mqp))
+					MLX5_QP_STATE_RST, in, 0, &qp->mqp))
 			mlx5_ib_warn(dev, "mlx5_ib: modify QP %06x to RESET failed\n",
 				     qp->mqp.qpn);
 	}
-- 
2.3.1
