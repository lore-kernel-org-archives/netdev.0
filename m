From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH] uapi: fix rdma/mlx5-abi.h userspace compilation errors
Date: Fri, 24 Feb 2017 03:28:13 +0300
Message-ID: <20170224002813.GB31010@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Consistently use types from linux/types.h to fix the following
rdma/mlx5-abi.h userspace compilation errors:

/usr/include/rdma/mlx5-abi.h:69:25: error: 'u64' undeclared here (not in a function)
  MLX5_LIB_CAP_4K_UAR = (u64)1 << 0,
/usr/include/rdma/mlx5-abi.h:69:29: error: expected ',' or '}' before numeric constant
  MLX5_LIB_CAP_4K_UAR = (u64)1 << 0,

Include <linux/if_ether.h> to fix the following rdma/mlx5-abi.h
userspace compilation error:

/usr/include/rdma/mlx5-abi.h:286:12: error: 'ETH_ALEN' undeclared here (not in a function)
  __u8 dmac[ETH_ALEN];

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/rdma/mlx5-abi.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/rdma/mlx5-abi.h b/include/uapi/rdma/mlx5-abi.h
index da7cd62..0b3d308 100644
--- a/include/uapi/rdma/mlx5-abi.h
+++ b/include/uapi/rdma/mlx5-abi.h
@@ -34,6 +34,7 @@
 #define MLX5_ABI_USER_H
 
 #include <linux/types.h>
+#include <linux/if_ether.h>	/* For ETH_ALEN. */
 
 enum {
 	MLX5_QP_FLAG_SIGNATURE		= 1 << 0,
@@ -66,7 +67,7 @@ struct mlx5_ib_alloc_ucontext_req {
 };
 
 enum mlx5_lib_caps {
-	MLX5_LIB_CAP_4K_UAR	= (u64)1 << 0,
+	MLX5_LIB_CAP_4K_UAR	= (__u64)1 << 0,
 };
 
 struct mlx5_ib_alloc_ucontext_req_v2 {
-- 
ldv
