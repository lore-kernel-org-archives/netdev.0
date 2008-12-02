From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [5/5] POHMELFS: VFS changes and make/config files.
Date: Tue,  2 Dec 2008 22:30:54 +0300
Message-ID: <12282462551908-git-send-email-zbr@ioremap.net>
References: <12282462541461-git-send-email-zbr@ioremap.net>
 <12282462542235-git-send-email-zbr@ioremap.net>
 <12282462541352-git-send-email-zbr@ioremap.net>
 <12282462542094-git-send-email-zbr@ioremap.net>
 <12282462551223-git-send-email-zbr@ioremap.net>
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <12282462551223-git-send-email-zbr@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/fs/Kconfig b/fs/Kconfig
index abccb5d..c1b2b32 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1557,6 +1557,8 @@ menuconfig NETWORK_FILESYSTEMS
 
 if NETWORK_FILESYSTEMS
 
+source "fs/pohmelfs/Kconfig"
+
 config NFS_FS
 	tristate "NFS client support"
 	depends on INET
diff --git a/fs/Makefile b/fs/Makefile
index a1482a5..56fe19c 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -122,3 +122,4 @@ obj-$(CONFIG_HPPFS)		+= hppfs/
 obj-$(CONFIG_DEBUG_FS)		+= debugfs/
 obj-$(CONFIG_OCFS2_FS)		+= ocfs2/
 obj-$(CONFIG_GFS2_FS)           += gfs2/
+obj-$(CONFIG_POHMELFS)		+= pohmelfs/
diff --git a/fs/pohmelfs/Kconfig b/fs/pohmelfs/Kconfig
new file mode 100644
index 0000000..82d13ad
--- /dev/null
+++ b/fs/pohmelfs/Kconfig
@@ -0,0 +1,23 @@
+config POHMELFS
+	tristate "POHMELFS filesystem support"
+	select CONNECTOR
+	help
+	  POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.
+	  This is a network filesystem which supports coherent caching of data and metadata
+	  on clients.
+
+config POHMELFS_DEBUG
+	bool "POHMELFS debugging"
+	depends on POHMELFS
+	default n
+	help
+	  Turns on excessive POHMELFS debugging facilities.
+	  You usually do not want to slow things down noticebly and get really lots of kernel
+	  messages in syslog.
+
+config POHMELFS_CRYPTO
+	bool "POHMELFS crypto support"
+	depends on CONFIG_CRYPTO_BLKCIPHER && CONFIG_CRYPTO_HASH
+	help
+	  This option allows to encrypt and/or protect with strong cryptographic hash all dataflow
+	  between server and clients. Each config group can have own keys.
diff --git a/fs/pohmelfs/Makefile b/fs/pohmelfs/Makefile
new file mode 100644
index 0000000..196561c
--- /dev/null
+++ b/fs/pohmelfs/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_POHMELFS)	+= pohmelfs.o
+
+pohmelfs-y := inode.o config.o dir.o net.o path_entry.o trans.o crypto.o lock.o mcache.o

diff --git a/mm/filemap.c b/mm/filemap.c
index 876bc59..016a00b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -497,6 +497,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 		lru_cache_add(page);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
 struct page *__page_cache_alloc(gfp_t gfp)
@@ -614,6 +615,7 @@ int __lock_page_killable(struct page *page)
 	return __wait_on_bit_lock(page_waitqueue(page), &wait,
 					sync_page_killable, TASK_KILLABLE);
 }
+EXPORT_SYMBOL_GPL(__lock_page_killable);
 
 /**
  * __lock_page_nosync - get a lock on the page, without calling sync_page()
