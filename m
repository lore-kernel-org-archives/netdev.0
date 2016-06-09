From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 04/13] net/mlx5: Fix root flow table update
Date: Fri, 10 Jun 2016 00:07:31 +0300
Message-ID: <1465506460-1854-5-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34420 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752255AbcFIVIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:08:31 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

When we destroy the last flow table we need to update
the root_ft to NULL.

It fixes an issue for when the last flow table is destroyed
and recreated again, root_ft pointer will not be updated,
as a result traffic will be dropped.

Fixes: 2cc43b494a6c ('net/mlx5_core: Managing root flow table')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 8b5f0b2..fa6fec1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1292,8 +1292,8 @@ static int update_root_ft_destroy(struct mlx5_flow_table *ft)
 				       ft->id);
 			return err;
 		}
-		root->root_ft = new_root_ft;
 	}
+	root->root_ft = new_root_ft;
 	return 0;
 }
 
-- 
2.8.0
