From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] net/mlx4_core: use swap() in mlx4_make_profile()
Date: Wed, 10 Jun 2015 18:33:13 +0200
Message-ID: <1433953993-24623-1-git-send-email-fabf@skynet.be>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kernel.h macro definition.

Thanks to Julia Lawall for Coccinelle scripting support.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/mellanox/mlx4/profile.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/profile.c b/drivers/net/ethernet/mellanox/mlx4/profile.c
index 2bf437a..bae8b22 100644
--- a/drivers/net/ethernet/mellanox/mlx4/profile.c
+++ b/drivers/net/ethernet/mellanox/mlx4/profile.c
@@ -82,7 +82,6 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 
 	u64 total_size = 0;
 	struct mlx4_resource *profile;
-	struct mlx4_resource tmp;
 	struct sysinfo si;
 	int i, j;
 
@@ -149,11 +148,8 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 	 */
 	for (i = MLX4_RES_NUM; i > 0; --i)
 		for (j = 1; j < i; ++j) {
-			if (profile[j].size > profile[j - 1].size) {
-				tmp	       = profile[j];
-				profile[j]     = profile[j - 1];
-				profile[j - 1] = tmp;
-			}
+			if (profile[j].size > profile[j - 1].size)
+				swap(profile[j], profile[j - 1]);
 		}
 
 	for (i = 0; i < MLX4_RES_NUM; ++i) {
-- 
2.4.2
