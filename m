From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4: Use is_kdump_kernel() to detect kdump kernel
Date: Sun, 27 Jul 2014 17:59:15 +0300
Message-ID: <1406473156-4077-3-git-send-email-amirv@mellanox.com>
References: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vivek Goyal <vgoyal@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53391 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751745AbaG0O7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jul 2014 10:59:34 -0400
In-Reply-To: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use is_kdump_kernel() to detect kdump kernel, instead of reset_devices.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/mlx4/device.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e15b154..b96be83 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -38,6 +38,7 @@
 #include <linux/completion.h>
 #include <linux/radix-tree.h>
 #include <linux/cpu_rmap.h>
+#include <linux/crash_dump.h>
 
 #include <linux/atomic.h>
 
@@ -1258,7 +1259,7 @@ int mlx4_vf_set_enable_smi_admin(struct mlx4_dev *dev, int slave, int port,
 /* Returns true if running in low memory profile (kdump kernel) */
 static inline bool mlx4_low_memory_profile(void)
 {
-	return reset_devices;
+	return is_kdump_kernel();
 }
 
 #endif /* MLX4_DEVICE_H */
-- 
1.8.3.4
