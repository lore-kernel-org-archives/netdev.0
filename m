From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 1/3] mlx4: fix buffer overrun
Date: Wed, 15 Feb 2012 18:22:49 +0200
Message-ID: <4F3BDBD9.3010501@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:38914 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751648Ab2BOQZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 11:25:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

When passing MLX4_UC_STEER=1 it was translated to value 2
after mlx4_QP_ATTACH_wrapper. Therefore in new_steering_entry()
unicast steer entries were added to index 2 of array of size 2.
Fixing this bug by shift right to one position.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index dcd819b..1420dbc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2538,7 +2538,7 @@ int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 	int attach = vhcr->op_modifier;
 	int block_loopback = vhcr->in_modifier >> 31;
 	u8 steer_type_mask = 2;
-	enum mlx4_steer_type type = gid[7] & steer_type_mask;
+	enum mlx4_steer_type type = (gid[7] & steer_type_mask) >> 1;
 
 	qpn = vhcr->in_modifier & 0xffffff;
 	err = get_res(dev, slave, qpn, RES_QP, &rqp);
-- 
1.5.4.3
