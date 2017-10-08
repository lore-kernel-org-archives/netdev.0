From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH 10/12] net/mlx4: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
Date: Mon,  9 Oct 2017 01:10:11 +0900
Message-ID: <1507479013-5207-11-git-send-email-yamada.masahiro@socionext.com>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        linux-rdma@vger.kernel.org, Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The headers
 - include/linux/mlx4/device.h
 - drivers/net/ethernet/mellanox/mlx4/mlx4.h
require the definition of struct radix_tree_root, but do not need to
know anything about other radix tree stuff.

Include <linux/radix-tree-root.h> instead of <linux/radix-tree.h> to
reduce the header dependency.

While we are here, let's add missing <linux/radix-tree.h> where
radix tree accessors are used.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 drivers/net/ethernet/mellanox/mlx4/cq.c   | 1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h | 2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c   | 1 +
 drivers/net/ethernet/mellanox/mlx4/srq.c  | 1 +
 include/linux/mlx4/device.h               | 2 +-
 include/linux/mlx4/qp.h                   | 1 +
 6 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 72eb50c..4cbe65c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -36,6 +36,7 @@
 
 #include <linux/hardirq.h>
 #include <linux/export.h>
+#include <linux/radix-tree.h>
 
 #include <linux/mlx4/cmd.h>
 #include <linux/mlx4/cq.h>
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index c68da19..975ef70 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -38,7 +38,7 @@
 #define MLX4_H
 
 #include <linux/mutex.h>
-#include <linux/radix-tree.h>
+#include <linux/radix-tree-root.h>
 #include <linux/rbtree.h>
 #include <linux/timer.h>
 #include <linux/semaphore.h>
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 728a2fb..50cbc62 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -35,6 +35,7 @@
 
 #include <linux/gfp.h>
 #include <linux/export.h>
+#include <linux/radix-tree.h>
 
 #include <linux/mlx4/cmd.h>
 #include <linux/mlx4/qp.h>
diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index bedf521..4201a46 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -36,6 +36,7 @@
 #include <linux/mlx4/srq.h>
 #include <linux/export.h>
 #include <linux/gfp.h>
+#include <linux/radix-tree.h>
 
 #include "mlx4.h"
 #include "icm.h"
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b0a57e0..75eac23 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -36,7 +36,7 @@
 #include <linux/if_ether.h>
 #include <linux/pci.h>
 #include <linux/completion.h>
-#include <linux/radix-tree.h>
+#include <linux/radix-tree-root.h>
 #include <linux/cpu_rmap.h>
 #include <linux/crash_dump.h>
 
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 8e2828d..dfa7d8e 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -35,6 +35,7 @@
 
 #include <linux/types.h>
 #include <linux/if_ether.h>
+#include <linux/radix-tree.h>
 
 #include <linux/mlx4/device.h>
 
-- 
2.7.4
