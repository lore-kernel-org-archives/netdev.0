From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 12/13] IB/mlx5: Don't create IB instance over Ethernet ports
Date: Thu,  4 Jun 2015 19:30:47 +0300
Message-ID: <1433435448-4937-13-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47706 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932134AbbFDQba (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:30 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Since we still don't have RoCE support in mlx5, avoid
creating IB driver instance over Ethernet ports.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index a117e27..f829692 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1353,6 +1353,10 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	int err;
 	int i;
 
+	/* don't create IB instance over Eth ports, no RoCE yet! */
+	if (MLX5_CAP_GEN(mdev, port_type) == MLX5_CAP_PORT_TYPE_ETH)
+		return NULL;
+
 	printk_once(KERN_INFO "%s", mlx5_version);
 
 	dev = (struct mlx5_ib_dev *)ib_alloc_device(sizeof(*dev));
-- 
1.7.1
