From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/12] net/mlx5: Use exact encap header size for the FW input buffer
Date: Tue, 24 Jan 2017 22:16:41 +0200
Message-ID: <20170124201652.2920-2-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54290 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750718AbdAXURU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:20 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The current code is allocating the max encap size supported by
the firmware and not the size requested by the caller, fix that.

Also, spare a warning when the size of the encapsulation headers
is bigger from what is supported by the firmware.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index c4478ecd8056..b5253b59e8fe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -473,10 +473,13 @@ int mlx5_encap_alloc(struct mlx5_core_dev *dev,
 	int err;
 	u32 *in;
 
-	if (size > MLX5_CAP_ESW(dev, max_encap_header_size))
+	if (size > max_encap_size) {
+		mlx5_core_warn(dev, "encap size %zd too big, max supported is %d\n",
+			       size, max_encap_size);
 		return -EINVAL;
+	}
 
-	in = kzalloc(MLX5_ST_SZ_BYTES(alloc_encap_header_in) + max_encap_size,
+	in = kzalloc(MLX5_ST_SZ_BYTES(alloc_encap_header_in) + size,
 		     GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
-- 
2.11.0
