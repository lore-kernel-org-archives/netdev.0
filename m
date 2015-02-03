From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/7] net/mlx4: mlx4_config_dev_retrieval() - Initialize struct config_dev before using
Date: Tue,  3 Feb 2015 17:57:16 +0200
Message-ID: <1422979041-25208-3-git-send-email-amirv@mellanox.com>
References: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40311 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S966308AbbBCP6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 10:58:32 -0500
In-Reply-To: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Add Initialization to struct config_dev before filling and using it.
Fix to warning:

warning: config_dev.rx_checksum_val may be used uninitialized in this function

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index dbabfae..241838f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -2162,7 +2162,7 @@ static const u8 config_dev_csum_flags[] = {
 int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
 			      struct mlx4_config_dev_params *params)
 {
-	struct mlx4_config_dev config_dev;
+	struct mlx4_config_dev config_dev = {0};
 	int err;
 	u8 csum_mask;
 
-- 
1.9.3
