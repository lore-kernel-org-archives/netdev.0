From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 03/11] net/mlx4_core: Fix mem leak in SRIOV mlx4_init_one error flow
Date: Tue, 27 Jan 2015 15:58:01 +0200
Message-ID: <1422367089-13419-4-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49275 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758060AbbA0N71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:59:27 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Structs allocated for the resource tracker must be freed in
the error flow.


Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 46531c2..ab990f9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2980,8 +2980,10 @@ err_free_eq:
 	mlx4_free_eq_table(dev);
 
 err_master_mfunc:
-	if (mlx4_is_master(dev))
+	if (mlx4_is_master(dev)) {
+		mlx4_free_resource_tracker(dev, RES_TR_FREE_STRUCTS_ONLY);
 		mlx4_multi_func_cleanup(dev);
+	}
 
 	if (mlx4_is_slave(dev)) {
 		kfree(dev->caps.qp0_qkey);
-- 
1.9.3
