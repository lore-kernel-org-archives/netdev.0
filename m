From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1] mlx4_core: remove buggy sched_queue masking
Date: Tue, 6 Mar 2012 15:05:14 +0200
Message-ID: <4F560B8A.8080508@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:48892 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750789Ab2CFNFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 08:05:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fixes a bug introduced by commit fe9a2603c, where the priority bits
in the schedule queue field were masked out.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---

Diff from V0:
  removed the port assignment, it was only used to determine the port type
  and then to decide whether to do the masking or not.

 drivers/net/ethernet/mellanox/mlx4/qp.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 738f950..fb2b367 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -151,11 +151,6 @@ static int __mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		context->log_page_size   = mtt->page_shift - MLX4_ICM_PAGE_SHIFT;
 	}
 
-	port = ((context->pri_path.sched_queue >> 6) & 1) + 1;
-	if (dev->caps.port_type[port] == MLX4_PORT_TYPE_ETH)
-		context->pri_path.sched_queue = (context->pri_path.sched_queue &
-						0xc3);
-
 	*(__be32 *) mailbox->buf = cpu_to_be32(optpar);
 	memcpy(mailbox->buf + 8, context, sizeof *context);
 
-- 
1.7.7
