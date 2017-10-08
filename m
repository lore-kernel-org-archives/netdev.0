From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH 11/12] net/mlx5: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
Date: Mon,  9 Oct 2017 01:10:12 +0900
Message-ID: <1507479013-5207-12-git-send-email-yamada.masahiro@socionext.com>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Matan Barak <matanb@mellanox.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The header include/linux/mlx5/driver.h requires the definition of
struct radix_tree_root, but does not need to know anything about
other radix tree stuff.

Include <linux/radix-tree-root.h> instead of <linux/radix-tree.h> to
reduce the number of included header files.

Also, add <linux/radix-tree.h> to include/linux/mlx5/gp.h where radix
tree accessors are used.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 include/linux/mlx5/driver.h | 2 +-
 include/linux/mlx5/qp.h     | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 401c897..0aea568 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -40,7 +40,7 @@
 #include <linux/semaphore.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
-#include <linux/radix-tree.h>
+#include <linux/radix-tree-root.h>
 #include <linux/workqueue.h>
 #include <linux/mempool.h>
 #include <linux/interrupt.h>
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index 66d19b6..a90996f 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -35,6 +35,7 @@
 
 #include <linux/mlx5/device.h>
 #include <linux/mlx5/driver.h>
+#include <linux/radix-tree.h>
 
 #define MLX5_INVALID_LKEY	0x100
 #define MLX5_SIG_WQE_SIZE	(MLX5_SEND_WQE_BB * 5)
-- 
2.7.4
