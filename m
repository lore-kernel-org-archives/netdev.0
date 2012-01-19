From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1 5/6]  mlx4_core: Fix mtt profile issue
Date: Thu, 19 Jan 2012 21:45:31 +0200
Message-ID: <4F1872DB.9070105@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<marcela@dev.mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:44072 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932675Ab2ASTpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 14:45:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Apfelbaum <marcela@dev.mellanox.co.il>

Num mtts from profile is really the number of mtt segments.
Thus, in make profile, to get the proper number of MTT entries,
must multiply num_mtts by mtts per segment.

Signed-off-by: Marcel Apfelbaum <marcela@dev.mellanox.co.il>
Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/profile.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 91c8bc9..678558b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -108,7 +108,7 @@ static struct mlx4_profile default_profile = {
 	.num_cq		= 1 << 16,
 	.num_mcg	= 1 << 13,
 	.num_mpt	= 1 << 19,
-	.num_mtt	= 1 << 20,
+	.num_mtt	= 1 << 20, /* It is really num mtt segements */
 };
 
 static int log_num_mac = 7;
diff --git a/drivers/net/ethernet/mellanox/mlx4/profile.c b/drivers/net/ethernet/mellanox/mlx4/profile.c
index 66f91ca..1129677 100644
--- a/drivers/net/ethernet/mellanox/mlx4/profile.c
+++ b/drivers/net/ethernet/mellanox/mlx4/profile.c
@@ -110,7 +110,7 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 	profile[MLX4_RES_EQ].num      = min_t(unsigned, dev_cap->max_eqs, MAX_MSIX);
 	profile[MLX4_RES_DMPT].num    = request->num_mpt;
 	profile[MLX4_RES_CMPT].num    = MLX4_NUM_CMPTS;
-	profile[MLX4_RES_MTT].num     = request->num_mtt;
+	profile[MLX4_RES_MTT].num     = request->num_mtt * (1 << log_mtts_per_seg);
 	profile[MLX4_RES_MCG].num     = request->num_mcg;
 
 	for (i = 0; i < MLX4_RES_NUM; ++i) {
-- 
1.5.4.3
