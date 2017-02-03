From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] net/mlx4_en: fix a condition
Date: Fri, 3 Feb 2017 12:54:59 +0300
Message-ID: <20170203095459.GA5704@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Yishai Hadas <yishaih@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21407 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752884AbdBCJz0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:55:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a "||" vs "|" typo here so we test 0x1 instead of 0x6.

Fixes: 1f8176f7352a ("net/mlx4_en: Check the enabling pptx/pprx flags in SET_PORT wrapper flow")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 5053c949148f..4e36e287d605 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -1395,7 +1395,7 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 							  gen_context);
 
 			if (gen_context->flags &
-			    (MLX4_FLAG_V_PPRX_MASK || MLX4_FLAG_V_PPTX_MASK))
+			    (MLX4_FLAG_V_PPRX_MASK | MLX4_FLAG_V_PPTX_MASK))
 				mlx4_en_set_port_global_pause(dev, slave,
 							      gen_context);
 
