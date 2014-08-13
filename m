From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 09/10] IB/mlx5: Improve debug prints in mlx5_ib_reg_user_mr
Date: Wed, 13 Aug 2014 14:39:10 +0300
Message-ID: <1407929951-16362-10-git-send-email-eli@mellanox.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:64024 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561AbaHMLj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:57 -0400
Received: by mail-wi0-f182.google.com with SMTP id d1so640960wiv.9
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:56 -0700 (PDT)
In-Reply-To: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print access flags and error code from ib_umem_get.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/mr.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 80b3c63eab5d..8ee7cb46e059 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -881,12 +881,12 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 	int order;
 	int err;
 
-	mlx5_ib_dbg(dev, "start 0x%llx, virt_addr 0x%llx, length 0x%llx\n",
-		    start, virt_addr, length);
+	mlx5_ib_dbg(dev, "start 0x%llx, virt_addr 0x%llx, length 0x%llx, access_flags 0x%x\n",
+		    start, virt_addr, length, access_flags);
 	umem = ib_umem_get(pd->uobject->context, start, length, access_flags,
 			   0);
 	if (IS_ERR(umem)) {
-		mlx5_ib_dbg(dev, "umem get failed\n");
+		mlx5_ib_dbg(dev, "umem get failed (%ld)\n", PTR_ERR(umem));
 		return (void *)umem;
 	}
 
-- 
1.9.3
