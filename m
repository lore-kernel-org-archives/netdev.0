From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 5/9] net/mlx5_core: Print resource number on QP/SRQ async events
Date: Tue,  2 Dec 2014 12:26:15 +0200
Message-ID: <1417515979-22418-6-git-send-email-eli@mellanox.com>
References: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Cc: roland@kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, amirv@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:43904 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbaLBK0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 05:26:42 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so27514347wiw.13
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 02:26:41 -0800 (PST)
In-Reply-To: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Useful for debugging purposes.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index dfd3ad0a39c1..ab684463780b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -225,8 +225,8 @@ static int mlx5_eq_int(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
 		case MLX5_EVENT_TYPE_WQ_INVAL_REQ_ERROR:
 		case MLX5_EVENT_TYPE_WQ_ACCESS_ERROR:
 			rsn = be32_to_cpu(eqe->data.qp_srq.qp_srq_n) & 0xffffff;
-			mlx5_core_dbg(dev, "event %s(%d) arrived\n",
-				      eqe_type_str(eqe->type), eqe->type);
+			mlx5_core_dbg(dev, "event %s(%d) arrived on resource 0x%x\n",
+				      eqe_type_str(eqe->type), eqe->type, rsn);
 			mlx5_rsc_event(dev, rsn, eqe->type);
 			break;
 
-- 
2.1.3
