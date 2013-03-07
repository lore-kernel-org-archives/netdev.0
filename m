From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/6] net/mlx4_core: Disable mlx4_QP_ATTACH calls from guests if the host uses flow steering
Date: Thu,  7 Mar 2013 15:46:52 +0200
Message-ID: <1362664017-30275-2-git-send-email-ogerlitz@mellanox.com>
References: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:34621 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753454Ab3CGNrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 08:47:14 -0500
In-Reply-To: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Guests kernels may not correctly detect if DMFS (device-enabled flow steering) is
activated by the host. If DMFS is activated, the master should return error to guests
which try to use the B0-steering flow calls (mlx4_QP_ATTACH).

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 083fb48..2995687 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2990,6 +2990,9 @@ int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 	u8 steer_type_mask = 2;
 	enum mlx4_steer_type type = (gid[7] & steer_type_mask) >> 1;
 
+	if (dev->caps.steering_mode != MLX4_STEERING_MODE_B0)
+		return -EINVAL;
+
 	qpn = vhcr->in_modifier & 0xffffff;
 	err = get_res(dev, slave, qpn, RES_QP, &rqp);
 	if (err)
-- 
1.7.1
