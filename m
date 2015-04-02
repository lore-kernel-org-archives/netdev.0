From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 04/16] net/mlx5_core: Avoid setting DC requestor/responder resources
Date: Thu,  2 Apr 2015 17:07:22 +0300
Message-ID: <1427983654-971-5-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33335 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbDBOHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:07:54 -0400
Received: by wixm2 with SMTP id m2so56725449wix.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:07:53 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PRM does not support setting these values so avoid setting them.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 350c6297fe5d..f29fd5592305 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -288,8 +288,6 @@ static void copy_rw_fields(void *to, struct mlx5_caps *from)
 	MLX5_SET(cmd_hca_cap, to, log_max_ra_req_qp, from->gen.log_max_ra_req_qp);
 	MLX5_SET(cmd_hca_cap, to, log_max_ra_res_qp, from->gen.log_max_ra_res_qp);
 	MLX5_SET(cmd_hca_cap, to, pkey_table_size, from->gen.pkey_table_size);
-	MLX5_SET(cmd_hca_cap, to, log_max_ra_req_dc, from->gen.log_max_ra_req_dc);
-	MLX5_SET(cmd_hca_cap, to, log_max_ra_res_dc, from->gen.log_max_ra_res_dc);
 	MLX5_SET(cmd_hca_cap, to, pkey_table_size, to_fw_pkey_sz(from->gen.pkey_table_size));
 	MLX5_SET(cmd_hca_cap, to, log_uar_page_sz, PAGE_SHIFT - 12);
 	v64 = from->gen.flags & MLX5_CAP_BITS_RW_MASK;
-- 
2.3.1
