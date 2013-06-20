From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx_en: Timestamping is not supported in slave mode
Date: Thu, 20 Jun 2013 14:58:10 +0300
Message-ID: <1371729490-10491-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33182 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S935353Ab3FTL6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 07:58:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Old hypervisors don't mask out timestamp capability for slave. Till slave
support will be added, need to disable capability by slave.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2f4a260..8a43499 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -632,6 +632,9 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		dev->caps.cqe_size   = 32;
 	}
 
+	dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_TS;
+	mlx4_warn(dev, "Timestamping is not supported in slave mode.\n");
+
 	slave_adjust_steering_mode(dev, &dev_cap, &hca_param);
 
 	return 0;
-- 
1.8.3.251.g1462b67
