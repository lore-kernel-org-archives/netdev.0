From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 5/9] net/mlx4_core: Removed unnecessary bit operation condition
Date: Mon, 12 May 2014 10:43:21 +0300
Message-ID: <1399880605-28772-6-git-send-email-amirv@mellanox.com>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59184 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751862AbaELHnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 03:43:46 -0400
In-Reply-To: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Fix the "warn: suspicious bitop condition" made by the smatch semantic
checker on:
drivers/net/ethernet/mellanox/mlx4/main.c:509 mlx4_slave_cap()


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index df2c1fb..e74847d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -104,8 +104,6 @@ module_param(enable_64b_cqe_eqe, bool, 0444);
 MODULE_PARM_DESC(enable_64b_cqe_eqe,
 		 "Enable 64 byte CQEs/EQEs when the FW supports this (default: True)");
 
-#define HCA_GLOBAL_CAP_MASK            0
-
 #define PF_CONTEXT_BEHAVIOUR_MASK	MLX4_FUNC_CAP_64B_EQE_CQE
 
 static char mlx4_version[] =
@@ -582,9 +580,10 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		return err;
 	}
 
-	/*fail if the hca has an unknown capability */
-	if ((hca_param.global_caps | HCA_GLOBAL_CAP_MASK) !=
-	    HCA_GLOBAL_CAP_MASK) {
+	/* fail if the hca has an unknown global capability
+	 * at this time global_caps should be always zeroed
+	 */
+	if (hca_param.global_caps) {
 		mlx4_err(dev, "Unknown hca global capabilities\n");
 		return -ENOSYS;
 	}
-- 
1.8.3.4
