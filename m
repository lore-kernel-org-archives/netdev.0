From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 07/10] IB/mlx4: Add extended atomic support
Date: Wed, 13 Aug 2014 14:39:08 +0300
Message-ID: <1407929951-16362-8-git-send-email-eli@mellanox.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36921 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbaHMLju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:50 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so7246579wib.15
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:49 -0700 (PDT)
In-Reply-To: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the extended masked atomic capabilities. For ConnectX devices argument size
is fixed to 8 bytes and bit boundary is 64.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 0f7027e7db13..8dc15b5eeb40 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -206,6 +206,9 @@ static int mlx4_ib_query_device(struct ib_device *ibdev,
 	props->atomic_cap	   = dev->dev->caps.flags & MLX4_DEV_CAP_FLAG_ATOMIC ?
 		IB_ATOMIC_HCA : IB_ATOMIC_NONE;
 	props->masked_atomic_cap   = props->atomic_cap;
+	props->log_atomic_arg_sizes = 8;
+	props->max_fa_bit_boundary = 64;
+	props->log_max_atomic_inline = 8;
 	props->max_pkeys	   = dev->dev->caps.pkey_table_len[1];
 	props->max_mcast_grp	   = dev->dev->caps.num_mgms + dev->dev->caps.num_amgms;
 	props->max_mcast_qp_attach = dev->dev->caps.num_qp_per_mgm;
-- 
1.9.3
