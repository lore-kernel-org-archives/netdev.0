From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 8/8] net/mlx4: defining functions as static
Date: Tue, 6 Mar 2012 16:05:02 +0200
Message-ID: <4F56198E.2070405@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:33196 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1030359Ab2CFOFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:05:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Fixing sparse warnings, the 2 functions are only used in same
file. Defining them as static and not exporting them.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/mr.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 9f693e1..32e2b66 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -304,7 +304,7 @@ static int mlx4_HW2SW_MPT(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 			    MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 }
 
-int mlx4_mr_alloc_reserved(struct mlx4_dev *dev, u32 mridx, u32 pd,
+static int mlx4_mr_alloc_reserved(struct mlx4_dev *dev, u32 mridx, u32 pd,
 			   u64 iova, u64 size, u32 access, int npages,
 			   int page_shift, struct mlx4_mr *mr)
 {
@@ -317,7 +317,6 @@ int mlx4_mr_alloc_reserved(struct mlx4_dev *dev, u32 mridx, u32 pd,
 
 	return mlx4_mtt_init(dev, npages, page_shift, &mr->mtt);
 }
-EXPORT_SYMBOL_GPL(mlx4_mr_alloc_reserved);
 
 static int mlx4_WRITE_MTT(struct mlx4_dev *dev,
 			  struct mlx4_cmd_mailbox *mailbox,
@@ -434,7 +433,7 @@ int mlx4_mr_alloc(struct mlx4_dev *dev, u32 pd, u64 iova, u64 size, u32 access,
 }
 EXPORT_SYMBOL_GPL(mlx4_mr_alloc);
 
-void mlx4_mr_free_reserved(struct mlx4_dev *dev, struct mlx4_mr *mr)
+static void mlx4_mr_free_reserved(struct mlx4_dev *dev, struct mlx4_mr *mr)
 {
 	int err;
 
@@ -449,7 +448,6 @@ void mlx4_mr_free_reserved(struct mlx4_dev *dev, struct mlx4_mr *mr)
 	}
 	mlx4_mtt_cleanup(dev, &mr->mtt);
 }
-EXPORT_SYMBOL_GPL(mlx4_mr_free_reserved);
 
 void mlx4_mr_free(struct mlx4_dev *dev, struct mlx4_mr *mr)
 {
-- 
1.7.7
