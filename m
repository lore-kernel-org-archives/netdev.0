From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 2/3] net/mlx4: Use is_kdump_kernel() to detect kdump kernel
Date: Mon, 25 Aug 2014 16:06:53 +0300
Message-ID: <1408972014-13319-3-git-send-email-amirv@mellanox.com>
References: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Vivek Goyal <vgoyal@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37445 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932232AbaHYNHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 09:07:51 -0400
In-Reply-To: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use is_kdump_kernel() to detect kdump kernel, instead of reset_devices.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/mlx4/device.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 071f6b2..783dd09 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -38,6 +38,7 @@
 #include <linux/completion.h>
 #include <linux/radix-tree.h>
 #include <linux/cpu_rmap.h>
+#include <linux/crash_dump.h>
 
 #include <linux/atomic.h>
 
@@ -1275,7 +1276,7 @@ int mlx4_mr_rereg_mem_write(struct mlx4_dev *dev, struct mlx4_mr *mr,
 /* Returns true if running in low memory profile (kdump kernel) */
 static inline bool mlx4_low_memory_profile(void)
 {
-	return reset_devices;
+	return is_kdump_kernel();
 }
 
 #endif /* MLX4_DEVICE_H */
-- 
1.8.3.4
