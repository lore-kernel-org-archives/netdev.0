From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 07/26] net/mlx4_core: constify local structures
Date: Sun, 11 Sep 2016 15:05:49 +0200
Message-ID: <1473599168-30561-8-git-send-email-Julia.Lawall@lip6.fr>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: joe@perches.com, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yishai Hadas <yishaih@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For structure types defined in the same file or local header files, find
top-level static structure declarations that have the following
properties:
1. Never reassigned.
2. Address never taken
3. Not passed to a top-level macro call
4. No pointer or array-typed field passed to a function or stored in a
variable.
Declare structures having all of these properties as const.

Done using Coccinelle.
Based on a suggestion by Joe Perches <joe@perches.com>.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch seems too long for a commit log, but is in the cover
letter.

 drivers/net/ethernet/mellanox/mlx4/main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 75dd2e3..9a3c359 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -120,7 +120,7 @@ static char mlx4_version[] =
 	DRV_NAME ": Mellanox ConnectX core driver v"
 	DRV_VERSION " (" DRV_RELDATE ")\n";
 
-static struct mlx4_profile default_profile = {
+static const struct mlx4_profile default_profile = {
 	.num_qp		= 1 << 18,
 	.num_srq	= 1 << 16,
 	.rdmarc_per_qp	= 1 << 4,
@@ -130,7 +130,7 @@ static struct mlx4_profile default_profile = {
 	.num_mtt	= 1 << 20, /* It is really num mtt segements */
 };
 
-static struct mlx4_profile low_mem_profile = {
+static const struct mlx4_profile low_mem_profile = {
 	.num_qp		= 1 << 17,
 	.num_srq	= 1 << 6,
 	.rdmarc_per_qp	= 1 << 4,
