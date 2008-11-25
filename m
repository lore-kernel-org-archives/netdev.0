From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [resend take 3 4/4] DST Makefile/Kconfig files.
Date: Tue, 25 Nov 2008 17:37:50 +0300
Message-ID: <12276238751973-git-send-email-zbr@ioremap.net>
References: <12276238703113-git-send-email-zbr@ioremap.net>
 <1227623874638-git-send-email-zbr@ioremap.net>
 <12276238741618-git-send-email-zbr@ioremap.net>
 <12276238742680-git-send-email-zbr@ioremap.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <12276238742680-git-send-email-zbr@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 61ad8d6..2a92cd8 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -445,4 +445,6 @@ config BLK_DEV_HD
 
 	  If unsure, say N.
 
+source "drivers/block/dst/Kconfig"
+
 endif # BLK_DEV
diff --git a/drivers/block/Makefile b/drivers/block/Makefile
index 204332b..6400de0 100644
--- a/drivers/block/Makefile
+++ b/drivers/block/Makefile
@@ -32,3 +32,5 @@ obj-$(CONFIG_BLK_DEV_UB)	+= ub.o
 obj-$(CONFIG_BLK_DEV_HD)	+= hd.o
 
 obj-$(CONFIG_XEN_BLKDEV_FRONTEND)	+= xen-blkfront.o
+
+obj-$(CONFIG_DST)	+= dst/
diff --git a/drivers/block/dst/Kconfig b/drivers/block/dst/Kconfig
new file mode 100644
index 0000000..507dba8
--- /dev/null
+++ b/drivers/block/dst/Kconfig
@@ -0,0 +1,14 @@
+config DST
+	tristate "Distributed storage"
+	depends on NET && CRYPTO && SYSFS
+	select CONNECTOR
+	select LIBCRC32C
+	---help---
+	This driver allows to create a distributed storage block device.
+
+config DST_DEBUG
+	bool "DST debug"
+	depends on DST
+	---help---
+	This option will turn HEAVY debugging of the DST.
+	Turn it on ONLY if you have to debug some really obscure problem.
diff --git a/drivers/block/dst/Makefile b/drivers/block/dst/Makefile
new file mode 100644
index 0000000..3a8b0cf
--- /dev/null
+++ b/drivers/block/dst/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_DST) += nst.o
+
+nst-y := dcore.o state.o export.o thread_pool.o crypto.o trans.o
