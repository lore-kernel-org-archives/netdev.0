From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/7] net/mlx4_core: Fix misleading debug print on CQE stride support
Date: Tue,  3 Feb 2015 17:57:17 +0200
Message-ID: <1422979041-25208-4-git-send-email-amirv@mellanox.com>
References: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40283 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S966294AbbBCP6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 10:58:17 -0500
In-Reply-To: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

We do support cache line sizes of 32 and 64 bytes without activating the
CQE stride feature. Fix a misleading print saying that these cache line
sizes aren't supported.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index cc9f484..e045562 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -251,7 +251,8 @@ static void mlx4_enable_cqe_eqe_stride(struct mlx4_dev *dev)
 		if (mlx4_is_master(dev))
 			dev_cap->function_caps |= MLX4_FUNC_CAP_EQE_CQE_STRIDE;
 	} else {
-		mlx4_dbg(dev, "Disabling CQE stride cacheLine unsupported\n");
+		if (cache_line_size() != 32  && cache_line_size() != 64)
+			mlx4_dbg(dev, "Disabling CQE stride, cacheLine size unsupported\n");
 		dev_cap->flags2 &= ~MLX4_DEV_CAP_FLAG2_CQE_STRIDE;
 		dev_cap->flags2 &= ~MLX4_DEV_CAP_FLAG2_EQE_STRIDE;
 	}
-- 
1.9.3
