From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 07/11] net/mlx4_core: Set CQE/EQE size to 64B by default
Date: Tue, 17 Dec 2013 09:01:56 +0200
Message-ID: <1387263720-31222-8-git-send-email-amirv@mellanox.com>
References: <1387263720-31222-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40380 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752592Ab3LQHCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 02:02:12 -0500
In-Reply-To: <1387263720-31222-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

To achieve out of the box performance default is to use 64 byte CQE/EQE.
In tests that we conduct in our labs, we achieved a performance
improvement of twice the message rate. For older VF/libmlx4 support,
enable_64b_cqe_eqe must be set to 0 (disabled).


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 6b13a15..fbebfb0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -96,10 +96,10 @@ MODULE_PARM_DESC(log_num_mgm_entry_size, "log mgm size, that defines the num"
 					 " To activate device managed"
 					 " flow steering when available, set to -1");
 
-static bool enable_64b_cqe_eqe;
+static bool enable_64b_cqe_eqe = true;
 module_param(enable_64b_cqe_eqe, bool, 0444);
 MODULE_PARM_DESC(enable_64b_cqe_eqe,
-		 "Enable 64 byte CQEs/EQEs when the FW supports this");
+		 "Enable 64 byte CQEs/EQEs when the FW supports this (default: True)");
 
 #define HCA_GLOBAL_CAP_MASK            0
 
-- 
1.8.3.4
