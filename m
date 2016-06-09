From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 02/13] net/mlx5: Fix masking of reserved bits in XRCD number
Date: Fri, 10 Jun 2016 00:07:29 +0300
Message-ID: <1465506460-1854-3-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34403 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752086AbcFIVI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:08:29 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Mask the reserved bits when reading the number of newly
created XRCD.

Fixes: e126ba97dba9 ('mlx5: Add driver for Mellanox Connect-IB adapters')
Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/qp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index b720a27..b82d658 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -418,7 +418,7 @@ int mlx5_core_xrcd_alloc(struct mlx5_core_dev *dev, u32 *xrcdn)
 	if (out.hdr.status)
 		err = mlx5_cmd_status_to_err(&out.hdr);
 	else
-		*xrcdn = be32_to_cpu(out.xrcdn);
+		*xrcdn = be32_to_cpu(out.xrcdn) & 0xffffff;
 
 	return err;
 }
-- 
2.8.0
