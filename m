From: Karol Lewandowski <k.lewandowsk@samsung.com>
Subject: [PATCH] net: Make it possible to set defaults for net.core.[rw]mem_max
 parameters
Date: Tue, 17 Dec 2013 10:25:53 +0100
Message-ID: <1387272353-3560-1-git-send-email-k.lewandowsk@samsung.com>
Cc: kyungmin.park@samsung.com, lennart@poettering.net,
	linux-kernel@vger.kernel.org,
	Karol Lewandowski <k.lewandowsk@samsung.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Default limits are quite low even for today's embedded hardware.

Signed-off-by: Karol Lewandowski <k.lewandowsk@samsung.com>
---
 net/Kconfig      | 1 +
 net/core/Kconfig | 7 +++++++
 net/core/sock.c  | 5 ++---
 3 files changed, 10 insertions(+), 3 deletions(-)
 create mode 100644 net/core/Kconfig

diff --git a/net/Kconfig b/net/Kconfig
index d334678..75b7478 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -46,6 +46,7 @@ config COMPAT_NETLINK_MESSAGES
 
 menu "Networking options"
 
+source "net/core/Kconfig"
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
diff --git a/net/core/Kconfig b/net/core/Kconfig
new file mode 100644
index 0000000..91aa793
--- /dev/null
+++ b/net/core/Kconfig
@@ -0,0 +1,7 @@
+config SK_MEM_PACKETS
+        int "Default maximum socket queue depth (packets)" if EMBEDDED
+        range 128 65536
+        default 256
+        ---help---
+          This config option allows to set defaults for net.core.[rw]mem_max
+          parameters
diff --git a/net/core/sock.c b/net/core/sock.c
index 5393b4b..6f33bd6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -259,10 +259,9 @@ static struct lock_class_key af_callback_keys[AF_MAX];
  * platforms.  This makes socket queueing behavior and performance
  * not depend upon such differences.
  */
-#define _SK_MEM_PACKETS		256
 #define _SK_MEM_OVERHEAD	SKB_TRUESIZE(256)
-#define SK_WMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
-#define SK_RMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
+#define SK_WMEM_MAX		(_SK_MEM_OVERHEAD * CONFIG_SK_MEM_PACKETS)
+#define SK_RMEM_MAX		(_SK_MEM_OVERHEAD * CONFIG_SK_MEM_PACKETS)
 
 /* Run time adjustable parameters. */
 __u32 sysctl_wmem_max __read_mostly = SK_WMEM_MAX;
-- 
1.8.4.rc3
