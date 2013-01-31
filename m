From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 02/10] net/mlx4_core: Set correctly allow_loopback flag
Date: Thu, 31 Jan 2013 11:07:03 +0200
Message-ID: <1359623231-4491-3-git-send-email-amirv@mellanox.com>
References: <1359623231-4491-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:60890 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752923Ab3AaJHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 04:07:36 -0500
In-Reply-To: <1359623231-4491-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The allow_loopback flag was wrongly set using arithmetic bit operation, change
the code to use logical bit operation.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index d7c0704..5268552 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1157,7 +1157,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			.priority = MLX4_DOMAIN_NIC,
 		};
 
-		rule.allow_loopback = ~block_mcast_loopback;
+		rule.allow_loopback = !block_mcast_loopback;
 		rule.port = port;
 		rule.qpn = qp->qpn;
 		INIT_LIST_HEAD(&rule.list);
-- 
1.7.8.2
