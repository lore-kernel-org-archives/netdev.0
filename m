From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 4/7] net/mlx5: FPGA, Fix datatype mismatch
Date: Sun,  9 Jul 2017 15:49:14 +0300
Message-ID: <20170709124917.12852-5-saeedm@mellanox.com>
References: <20170709124917.12852-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36248 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752264AbdGIMuM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 08:50:12 -0400
In-Reply-To: <20170709124917.12852-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Fix warnings when building with -Wall:
drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c:313:36: warning: cast to restricted __be32
drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c:314:37: warning: cast to restricted __be32

Fixes: bebb23e6cb02 ("net/mlx5: Accel, Add IPSec acceleration interface")
Reported-by: Or Gerlitz <gerlitz.or@gmail.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c b/drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c
index 42970e2a05ff..35d0e33381ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c
@@ -275,7 +275,7 @@ int mlx5_fpga_ipsec_counters_read(struct mlx5_core_dev *mdev, u64 *counters,
 {
 	struct mlx5_fpga_device *fdev = mdev->fpga;
 	unsigned int i;
-	u32 *data;
+	__be32 *data;
 	u32 count;
 	u64 addr;
 	int ret;
@@ -290,7 +290,7 @@ int mlx5_fpga_ipsec_counters_read(struct mlx5_core_dev *mdev, u64 *counters,
 
 	count = mlx5_fpga_ipsec_counters_count(mdev);
 
-	data = kzalloc(sizeof(u32) * count * 2, GFP_KERNEL);
+	data = kzalloc(sizeof(*data) * count * 2, GFP_KERNEL);
 	if (!data) {
 		ret = -ENOMEM;
 		goto out;
-- 
2.11.0
