From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next V3 10/10] net/mlx5: Activate support for 4K UARs
Date: Mon,  9 Jan 2017 21:00:53 +0200
Message-ID: <1483988453-28551-11-git-send-email-saeedm@mellanox.com>
References: <1483988453-28551-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Eli Cohen <eli@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51966 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1762661AbdAITBH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:01:07 -0500
In-Reply-To: <1483988453-28551-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Activate 4K UAR support for firmware versions that support it.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Reviewed-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index ff1f144..a16ee16 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -530,6 +530,10 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 	/* disable cmdif checksum */
 	MLX5_SET(cmd_hca_cap, set_hca_cap, cmdif_checksum, 0);
 
+	/* If the HCA supports 4K UARs use it */
+	if (MLX5_CAP_GEN_MAX(dev, uar_4k))
+		MLX5_SET(cmd_hca_cap, set_hca_cap, uar_4k, 1);
+
 	MLX5_SET(cmd_hca_cap, set_hca_cap, log_uar_page_sz, PAGE_SHIFT - 12);
 
 	err = set_caps(dev, set_ctx, set_sz,
-- 
2.7.4
