From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net] mlx4_core: remove buggy sched_queue masking
Date: Mon, 5 Mar 2012 16:54:57 +0200
Message-ID: <4F54D3C1.8000902@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:45639 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932328Ab2CEO4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 09:56:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Fixes a bug introduced by commit fe9a2603c, where the priority bits
in the schedule queue field were masked out.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/qp.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 738f950..48ca886 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -152,9 +152,6 @@ static int __mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 	}
 
 	port = ((context->pri_path.sched_queue >> 6) & 1) + 1;
-	if (dev->caps.port_type[port] == MLX4_PORT_TYPE_ETH)
-		context->pri_path.sched_queue = (context->pri_path.sched_queue &
-						0xc3);
 
 	*(__be32 *) mailbox->buf = cpu_to_be32(optpar);
 	memcpy(mailbox->buf + 8, context, sizeof *context);
-- 
1.7.7
