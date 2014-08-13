From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 08/10] IB/mlx5: Clear umr resources after ib_unregister_device
Date: Wed, 13 Aug 2014 14:39:09 +0300
Message-ID: <1407929951-16362-9-git-send-email-eli@mellanox.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:41360 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbaHMLj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:56 -0400
Received: by mail-wg0-f49.google.com with SMTP id k14so11018433wgh.8
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:54 -0700 (PDT)
In-Reply-To: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some ULPs may make use of resources created in create_umr_res so make sure to
call destroy_umrc_res after returning from ib_unregister_device which makes
sure all ULPs have closed their resources.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 0cc07d521ab5..94cc476cc713 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1486,8 +1486,8 @@ err_dealloc:
 static void mlx5_ib_remove(struct mlx5_core_dev *mdev, void *context)
 {
 	struct mlx5_ib_dev *dev = context;
-	destroy_umrc_res(dev);
 	ib_unregister_device(&dev->ib_dev);
+	destroy_umrc_res(dev);
 	destroy_dev_resources(&dev->devr);
 	free_comp_eqs(dev);
 	ib_dealloc_device(&dev->ib_dev);
-- 
1.9.3
