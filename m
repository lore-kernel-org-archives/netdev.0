From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 05/17] fs: move struct kiocb to fs.h
Date: Sat, 11 Apr 2015 22:18:16 +0100
Message-ID: <1428787108-13650-5-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37866 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932393AbbDKVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:30 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>

struct kiocb now is a generic I/O container, so move it to fs.h.
Also do a #include diet for aio.h while we're at it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 arch/s390/hypfs/inode.c                      |  2 +-
 drivers/char/mem.c                           |  2 +-
 drivers/char/tile-srom.c                     |  1 -
 drivers/infiniband/hw/ipath/ipath_file_ops.c |  1 -
 drivers/infiniband/hw/qib/qib_file_ops.c     |  1 -
 drivers/misc/mei/amthif.c                    |  1 -
 drivers/misc/mei/main.c                      |  1 -
 drivers/misc/mei/pci-me.c                    |  1 -
 drivers/scsi/sg.c                            |  2 +-
 drivers/staging/unisys/include/timskmod.h    |  1 -
 drivers/usb/gadget/function/f_fs.c           |  1 +
 drivers/usb/gadget/legacy/inode.c            |  1 +
 fs/9p/vfs_addr.c                             |  2 +-
 fs/affs/file.c                               |  2 +-
 fs/afs/write.c                               |  1 -
 fs/bfs/inode.c                               |  1 +
 fs/block_dev.c                               |  1 -
 fs/btrfs/file.c                              |  2 +-
 fs/btrfs/inode.c                             |  2 +-
 fs/ceph/file.c                               |  1 -
 fs/direct-io.c                               |  1 -
 fs/ecryptfs/file.c                           |  1 -
 fs/ext2/inode.c                              |  2 +-
 fs/ext3/inode.c                              |  2 +-
 fs/ext4/file.c                               |  2 +-
 fs/ext4/indirect.c                           |  2 +-
 fs/ext4/inode.c                              |  1 -
 fs/ext4/page-io.c                            |  1 -
 fs/f2fs/data.c                               |  2 +-
 fs/fat/inode.c                               |  1 -
 fs/fuse/cuse.c                               |  2 +-
 fs/fuse/dev.c                                |  1 -
 fs/fuse/file.c                               |  2 +-
 fs/gfs2/aops.c                               |  2 +-
 fs/gfs2/file.c                               |  1 -
 fs/hfs/inode.c                               |  2 +-
 fs/hfsplus/inode.c                           |  2 +-
 fs/jfs/inode.c                               |  2 +-
 fs/nfs/file.c                                |  1 -
 fs/nilfs2/inode.c                            |  2 +-
 fs/ntfs/file.c                               |  1 -
 fs/ntfs/inode.c                              |  1 -
 fs/ocfs2/aops.c                              |  1 +
 fs/ocfs2/aops.h                              |  2 +-
 fs/pipe.c                                    |  1 -
 fs/read_write.c                              |  1 -
 fs/reiserfs/inode.c                          |  2 +-
 fs/splice.c                                  |  1 -
 fs/ubifs/file.c                              |  1 -
 fs/udf/file.c                                |  2 +-
 fs/udf/inode.c                               |  2 +-
 fs/xfs/xfs_aops.c                            |  1 -
 fs/xfs/xfs_file.c                            |  1 -
 include/linux/aio.h                          | 31 +---------------------------
 include/linux/fs.h                           | 22 ++++++++++++++++++++
 include/net/sock.h                           |  1 -
 kernel/printk/printk.c                       |  2 +-
 kernel/sysctl.c                              |  1 +
 mm/filemap.c                                 |  1 -
 mm/page_io.c                                 |  2 +-
 mm/shmem.c                                   |  2 +-
 net/ipv4/raw.c                               |  1 -
 sound/core/pcm_native.c                      |  2 +-
 63 files changed, 55 insertions(+), 86 deletions(-)

diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
index 4c8008d..ad66b07 100644
--- a/arch/s390/hypfs/inode.c
+++ b/arch/s390/hypfs/inode.c
@@ -21,7 +21,7 @@
 #include <linux/module.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 #include <asm/ebcdic.h>
 #include "hypfs.h"
 
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 297110c..9c4fd7a 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -26,7 +26,7 @@
 #include <linux/pfn.h>
 #include <linux/export.h>
 #include <linux/io.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 
 #include <linux/uaccess.h>
 
diff --git a/drivers/char/tile-srom.c b/drivers/char/tile-srom.c
index 02e76ac..69f6b4a 100644
--- a/drivers/char/tile-srom.c
+++ b/drivers/char/tile-srom.c
@@ -27,7 +27,6 @@
 #include <linux/types.h>	/* size_t */
 #include <linux/proc_fs.h>
 #include <linux/fcntl.h>	/* O_ACCMODE */
-#include <linux/aio.h>
 #include <linux/pagemap.h>
 #include <linux/hugetlb.h>
 #include <linux/uaccess.h>
diff --git a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infiniband/hw/ipath/ipath_file_ops.c
index 6d7f453..aed8afe 100644
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -40,7 +40,6 @@
 #include <linux/slab.h>
 #include <linux/highmem.h>
 #include <linux/io.h>
-#include <linux/aio.h>
 #include <linux/jiffies.h>
 #include <linux/cpu.h>
 #include <asm/pgtable.h>
diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
index b15e34e..826c17e 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -39,7 +39,6 @@
 #include <linux/vmalloc.h>
 #include <linux/highmem.h>
 #include <linux/io.h>
-#include <linux/aio.h>
 #include <linux/jiffies.h>
 #include <asm/pgtable.h>
 #include <linux/delay.h>
diff --git a/drivers/misc/mei/amthif.c b/drivers/misc/mei/amthif.c
index c4cb9a9..40ea639 100644
--- a/drivers/misc/mei/amthif.c
+++ b/drivers/misc/mei/amthif.c
@@ -19,7 +19,6 @@
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
-#include <linux/aio.h>
 #include <linux/ioctl.h>
 #include <linux/cdev.h>
 #include <linux/list.h>
diff --git a/drivers/misc/mei/main.c b/drivers/misc/mei/main.c
index 3c019c0..47680c8 100644
--- a/drivers/misc/mei/main.c
+++ b/drivers/misc/mei/main.c
@@ -22,7 +22,6 @@
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
-#include <linux/aio.h>
 #include <linux/poll.h>
 #include <linux/init.h>
 #include <linux/ioctl.h>
diff --git a/drivers/misc/mei/pci-me.c b/drivers/misc/mei/pci-me.c
index bd3039a..af44ee2 100644
--- a/drivers/misc/mei/pci-me.c
+++ b/drivers/misc/mei/pci-me.c
@@ -21,7 +21,6 @@
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
-#include <linux/aio.h>
 #include <linux/pci.h>
 #include <linux/poll.h>
 #include <linux/ioctl.h>
diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
index 0cbc1fb..c78a6f7 100644
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -33,7 +33,6 @@ static int sg_version_num = 30536;	/* 2 digits for each component */
 #include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/mm.h>
-#include <linux/aio.h>
 #include <linux/errno.h>
 #include <linux/mtio.h>
 #include <linux/ioctl.h>
@@ -51,6 +50,7 @@ static int sg_version_num = 30536;	/* 2 digits for each component */
 #include <linux/mutex.h>
 #include <linux/atomic.h>
 #include <linux/ratelimit.h>
+#include <linux/uio.h>
 
 #include "scsi.h"
 #include <scsi/scsi_dbg.h>
diff --git a/drivers/staging/unisys/include/timskmod.h b/drivers/staging/unisys/include/timskmod.h
index 4019a0d..52648d4 100644
--- a/drivers/staging/unisys/include/timskmod.h
+++ b/drivers/staging/unisys/include/timskmod.h
@@ -46,7 +46,6 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/fcntl.h>
-#include <linux/aio.h>
 #include <linux/workqueue.h>
 #include <linux/kthread.h>
 #include <linux/seq_file.h>
diff --git a/drivers/usb/gadget/function/f_fs.c b/drivers/usb/gadget/function/f_fs.c
index b64538b..a12315a78 100644
--- a/drivers/usb/gadget/function/f_fs.c
+++ b/drivers/usb/gadget/function/f_fs.c
@@ -23,6 +23,7 @@
 #include <linux/export.h>
 #include <linux/hid.h>
 #include <linux/module.h>
+#include <linux/uio.h>
 #include <asm/unaligned.h>
 
 #include <linux/usb/composite.h>
diff --git a/drivers/usb/gadget/legacy/inode.c b/drivers/usb/gadget/legacy/inode.c
index a4a8069..662ef2c 100644
--- a/drivers/usb/gadget/legacy/inode.c
+++ b/drivers/usb/gadget/legacy/inode.c
@@ -26,6 +26,7 @@
 #include <linux/poll.h>
 #include <linux/mmu_context.h>
 #include <linux/aio.h>
+#include <linux/uio.h>
 
 #include <linux/device.h>
 #include <linux/moduleparam.h>
diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index eb14e05..ff1a5ba 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -33,7 +33,7 @@
 #include <linux/pagemap.h>
 #include <linux/idr.h>
 #include <linux/sched.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 #include <net/9p/9p.h>
 #include <net/9p/client.h>
 
diff --git a/fs/affs/file.c b/fs/affs/file.c
index d2468bf..33eaa67 100644
--- a/fs/affs/file.c
+++ b/fs/affs/file.c
@@ -12,7 +12,7 @@
  *  affs regular file handling primitives
  */
 
-#include <linux/aio.h>
+#include <linux/uio.h>
 #include "affs.h"
 
 static struct buffer_head *affs_get_extblock_slow(struct inode *inode, u32 ext);
diff --git a/fs/afs/write.c b/fs/afs/write.c
index c13cb08..0714abc 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -14,7 +14,6 @@
 #include <linux/pagemap.h>
 #include <linux/writeback.h>
 #include <linux/pagevec.h>
-#include <linux/aio.h>
 #include "internal.h"
 
 static int afs_write_back_from_locked_page(struct afs_writeback *wb,
diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index 90bc079..fdcb4d6 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -15,6 +15,7 @@
 #include <linux/buffer_head.h>
 #include <linux/vfs.h>
 #include <linux/writeback.h>
+#include <linux/uio.h>
 #include <asm/uaccess.h>
 #include "bfs.h"
 
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 975266b..2e522ae 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -27,7 +27,6 @@
 #include <linux/namei.h>
 #include <linux/log2.h>
 #include <linux/cleancache.h>
-#include <linux/aio.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index b78bbba..69c9508 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -24,7 +24,6 @@
 #include <linux/string.h>
 #include <linux/backing-dev.h>
 #include <linux/mpage.h>
-#include <linux/aio.h>
 #include <linux/falloc.h>
 #include <linux/swap.h>
 #include <linux/writeback.h>
@@ -32,6 +31,7 @@
 #include <linux/compat.h>
 #include <linux/slab.h>
 #include <linux/btrfs.h>
+#include <linux/uio.h>
 #include "ctree.h"
 #include "disk-io.h"
 #include "transaction.h"
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 54bcf63..b214ab1 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -32,7 +32,6 @@
 #include <linux/writeback.h>
 #include <linux/statfs.h>
 #include <linux/compat.h>
-#include <linux/aio.h>
 #include <linux/bit_spinlock.h>
 #include <linux/xattr.h>
 #include <linux/posix_acl.h>
@@ -43,6 +42,7 @@
 #include <linux/btrfs.h>
 #include <linux/blkdev.h>
 #include <linux/posix_acl_xattr.h>
+#include <linux/uio.h>
 #include "ctree.h"
 #include "disk-io.h"
 #include "transaction.h"
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 081c4e3..98e257c 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -7,7 +7,6 @@
 #include <linux/mount.h>
 #include <linux/namei.h>
 #include <linux/writeback.h>
-#include <linux/aio.h>
 #include <linux/falloc.h>
 
 #include "super.h"
diff --git a/fs/direct-io.c b/fs/direct-io.c
index c38b460..6fb00e3 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -37,7 +37,6 @@
 #include <linux/uio.h>
 #include <linux/atomic.h>
 #include <linux/prefetch.h>
-#include <linux/aio.h>
 
 /*
  * How many user pages to map in one call to get_user_pages().  This determines
diff --git a/fs/ecryptfs/file.c b/fs/ecryptfs/file.c
index a36da88..273d36e 100644
--- a/fs/ecryptfs/file.c
+++ b/fs/ecryptfs/file.c
@@ -31,7 +31,6 @@
 #include <linux/security.h>
 #include <linux/compat.h>
 #include <linux/fs_stack.h>
-#include <linux/aio.h>
 #include "ecryptfs_kernel.h"
 
 /**
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 6434bc0..df9d6af 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -31,7 +31,7 @@
 #include <linux/mpage.h>
 #include <linux/fiemap.h>
 #include <linux/namei.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 #include "ext2.h"
 #include "acl.h"
 #include "xattr.h"
diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index 2c6ccc4..db07ffb 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -27,7 +27,7 @@
 #include <linux/writeback.h>
 #include <linux/mpage.h>
 #include <linux/namei.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 #include "ext3.h"
 #include "xattr.h"
 #include "acl.h"
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 33a09da..598abbb 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -23,9 +23,9 @@
 #include <linux/jbd2.h>
 #include <linux/mount.h>
 #include <linux/path.h>
-#include <linux/aio.h>
 #include <linux/quotaops.h>
 #include <linux/pagevec.h>
+#include <linux/uio.h>
 #include "ext4.h"
 #include "ext4_jbd2.h"
 #include "xattr.h"
diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
index 6b9878a..8611640 100644
--- a/fs/ext4/indirect.c
+++ b/fs/ext4/indirect.c
@@ -20,9 +20,9 @@
  *	(sct@redhat.com), 1993, 1998
  */
 
-#include <linux/aio.h>
 #include "ext4_jbd2.h"
 #include "truncate.h"
+#include <linux/uio.h>
 
 #include <trace/events/ext4.h>
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 85404f1..6325d2c 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -37,7 +37,6 @@
 #include <linux/printk.h>
 #include <linux/slab.h>
 #include <linux/ratelimit.h>
-#include <linux/aio.h>
 #include <linux/bitops.h>
 
 #include "ext4_jbd2.h"
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index b24a254..4649842 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -18,7 +18,6 @@
 #include <linux/pagevec.h>
 #include <linux/mpage.h>
 #include <linux/namei.h>
-#include <linux/aio.h>
 #include <linux/uio.h>
 #include <linux/bio.h>
 #include <linux/workqueue.h>
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 985ed02..497f851 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -12,12 +12,12 @@
 #include <linux/f2fs_fs.h>
 #include <linux/buffer_head.h>
 #include <linux/mpage.h>
-#include <linux/aio.h>
 #include <linux/writeback.h>
 #include <linux/backing-dev.h>
 #include <linux/blkdev.h>
 #include <linux/bio.h>
 #include <linux/prefetch.h>
+#include <linux/uio.h>
 
 #include "f2fs.h"
 #include "node.h"
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 497c7c5..8521207 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -19,7 +19,6 @@
 #include <linux/mpage.h>
 #include <linux/buffer_head.h>
 #include <linux/mount.h>
-#include <linux/aio.h>
 #include <linux/vfs.h>
 #include <linux/parser.h>
 #include <linux/uio.h>
diff --git a/fs/fuse/cuse.c b/fs/fuse/cuse.c
index 28d0c7a..b3fa050 100644
--- a/fs/fuse/cuse.c
+++ b/fs/fuse/cuse.c
@@ -38,7 +38,6 @@
 #include <linux/device.h>
 #include <linux/file.h>
 #include <linux/fs.h>
-#include <linux/aio.h>
 #include <linux/kdev_t.h>
 #include <linux/kthread.h>
 #include <linux/list.h>
@@ -48,6 +47,7 @@
 #include <linux/slab.h>
 #include <linux/stat.h>
 #include <linux/module.h>
+#include <linux/uio.h>
 
 #include "fuse_i.h"
 
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index ed19a7d..8c92c72 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -19,7 +19,6 @@
 #include <linux/pipe_fs_i.h>
 #include <linux/swap.h>
 #include <linux/splice.h>
-#include <linux/aio.h>
 
 MODULE_ALIAS_MISCDEV(FUSE_MINOR);
 MODULE_ALIAS("devname:fuse");
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index a5c5e38..ff102cb 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -15,8 +15,8 @@
 #include <linux/module.h>
 #include <linux/compat.h>
 #include <linux/swap.h>
-#include <linux/aio.h>
 #include <linux/falloc.h>
+#include <linux/uio.h>
 
 static const struct file_operations fuse_direct_io_file_operations;
 
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 4ad4f94..fe6634d 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -20,7 +20,7 @@
 #include <linux/swap.h>
 #include <linux/gfs2_ondisk.h>
 #include <linux/backing-dev.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 #include <trace/events/writeback.h>
 
 #include "gfs2.h"
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 3e32bb8..f6fc412 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -25,7 +25,6 @@
 #include <asm/uaccess.h>
 #include <linux/dlm.h>
 #include <linux/dlm_plock.h>
-#include <linux/aio.h>
 #include <linux/delay.h>
 
 #include "gfs2.h"
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index d0929bc..98d4ea4 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -14,7 +14,7 @@
 #include <linux/pagemap.h>
 #include <linux/mpage.h>
 #include <linux/sched.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 
 #include "hfs_fs.h"
 #include "btree.h"
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index 0cf786f..f541196 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -14,7 +14,7 @@
 #include <linux/pagemap.h>
 #include <linux/mpage.h>
 #include <linux/sched.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 
 #include "hfsplus_fs.h"
 #include "hfsplus_raw.h"
diff --git a/fs/jfs/inode.c b/fs/jfs/inode.c
index bd3df1c..3197aed 100644
--- a/fs/jfs/inode.c
+++ b/fs/jfs/inode.c
@@ -22,8 +22,8 @@
 #include <linux/buffer_head.h>
 #include <linux/pagemap.h>
 #include <linux/quotaops.h>
+#include <linux/uio.h>
 #include <linux/writeback.h>
-#include <linux/aio.h>
 #include "jfs_incore.h"
 #include "jfs_inode.h"
 #include "jfs_filsys.h"
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 94712fc..5d8b89c 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -26,7 +26,6 @@
 #include <linux/nfs_mount.h>
 #include <linux/mm.h>
 #include <linux/pagemap.h>
-#include <linux/aio.h>
 #include <linux/gfp.h>
 #include <linux/swap.h>
 
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index 8b59695..ab4987b 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -26,7 +26,7 @@
 #include <linux/mpage.h>
 #include <linux/pagemap.h>
 #include <linux/writeback.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 #include "nilfs.h"
 #include "btnode.h"
 #include "segment.h"
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 1da9b2d..f16f2d8 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -28,7 +28,6 @@
 #include <linux/swap.h>
 #include <linux/uio.h>
 #include <linux/writeback.h>
-#include <linux/aio.h>
 
 #include <asm/page.h>
 #include <asm/uaccess.h>
diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
index 898b994..1d0c21d 100644
--- a/fs/ntfs/inode.c
+++ b/fs/ntfs/inode.c
@@ -28,7 +28,6 @@
 #include <linux/quotaops.h>
 #include <linux/slab.h>
 #include <linux/log2.h>
-#include <linux/aio.h>
 
 #include "aops.h"
 #include "attrib.h"
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index 44db180..e1bf18c 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -29,6 +29,7 @@
 #include <linux/mpage.h>
 #include <linux/quotaops.h>
 #include <linux/blkdev.h>
+#include <linux/uio.h>
 
 #include <cluster/masklog.h>
 
diff --git a/fs/ocfs2/aops.h b/fs/ocfs2/aops.h
index 6cae155..dd59599 100644
--- a/fs/ocfs2/aops.h
+++ b/fs/ocfs2/aops.h
@@ -22,7 +22,7 @@
 #ifndef OCFS2_AOPS_H
 #define OCFS2_AOPS_H
 
-#include <linux/aio.h>
+#include <linux/fs.h>
 
 handle_t *ocfs2_start_walk_page_trans(struct inode *inode,
 							 struct page *page,
diff --git a/fs/pipe.c b/fs/pipe.c
index 21981e5..2d084f2 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -21,7 +21,6 @@
 #include <linux/audit.h>
 #include <linux/syscalls.h>
 #include <linux/fcntl.h>
-#include <linux/aio.h>
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
diff --git a/fs/read_write.c b/fs/read_write.c
index 76e324e..99a6ef9 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -9,7 +9,6 @@
 #include <linux/fcntl.h>
 #include <linux/file.h>
 #include <linux/uio.h>
-#include <linux/aio.h>
 #include <linux/fsnotify.h>
 #include <linux/security.h>
 #include <linux/export.h>
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index e72401e..9312b78 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -18,7 +18,7 @@
 #include <linux/writeback.h>
 #include <linux/quotaops.h>
 #include <linux/swap.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 
 int reiserfs_commit_write(struct file *f, struct page *page,
 			  unsigned from, unsigned to);
diff --git a/fs/splice.c b/fs/splice.c
index 7968da9..4bbfa95 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -32,7 +32,6 @@
 #include <linux/gfp.h>
 #include <linux/socket.h>
 #include <linux/compat.h>
-#include <linux/aio.h>
 #include "internal.h"
 
 /*
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index e627c0a..c3d15fe 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -50,7 +50,6 @@
  */
 
 #include "ubifs.h"
-#include <linux/aio.h>
 #include <linux/mount.h>
 #include <linux/namei.h>
 #include <linux/slab.h>
diff --git a/fs/udf/file.c b/fs/udf/file.c
index 9c0b6da..7f885cc 100644
--- a/fs/udf/file.c
+++ b/fs/udf/file.c
@@ -34,7 +34,7 @@
 #include <linux/errno.h>
 #include <linux/pagemap.h>
 #include <linux/buffer_head.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 
 #include "udf_i.h"
 #include "udf_sb.h"
diff --git a/fs/udf/inode.c b/fs/udf/inode.c
index a445d59..9c1fbd2 100644
--- a/fs/udf/inode.c
+++ b/fs/udf/inode.c
@@ -38,7 +38,7 @@
 #include <linux/slab.h>
 #include <linux/crc-itu-t.h>
 #include <linux/mpage.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 
 #include "udf_i.h"
 #include "udf_sb.h"
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 3a9b7a1..4f8cdc5 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -31,7 +31,6 @@
 #include "xfs_bmap.h"
 #include "xfs_bmap_util.h"
 #include "xfs_bmap_btree.h"
-#include <linux/aio.h>
 #include <linux/gfp.h>
 #include <linux/mpage.h>
 #include <linux/pagevec.h>
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 1cdba95..f527618 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -37,7 +37,6 @@
 #include "xfs_log.h"
 #include "xfs_icache.h"
 
-#include <linux/aio.h>
 #include <linux/dcache.h>
 #include <linux/falloc.h>
 #include <linux/pagevec.h>
diff --git a/include/linux/aio.h b/include/linux/aio.h
index 5c40b61..9eb42db 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -1,52 +1,23 @@
 #ifndef __LINUX__AIO_H
 #define __LINUX__AIO_H
 
-#include <linux/list.h>
-#include <linux/workqueue.h>
 #include <linux/aio_abi.h>
-#include <linux/uio.h>
-#include <linux/rcupdate.h>
-
-#include <linux/atomic.h>
 
 struct kioctx;
 struct kiocb;
+struct mm_struct;
 
 #define KIOCB_KEY		0
 
 typedef int (kiocb_cancel_fn)(struct kiocb *);
 
-#define IOCB_EVENTFD		(1 << 0)
-
-struct kiocb {
-	struct file		*ki_filp;
-	loff_t			ki_pos;
-	void (*ki_complete)(struct kiocb *iocb, long ret, long ret2);
-	void			*private;
-	int			ki_flags;
-};
-
-static inline bool is_sync_kiocb(struct kiocb *kiocb)
-{
-	return kiocb->ki_complete == NULL;
-}
-
-static inline void init_sync_kiocb(struct kiocb *kiocb, struct file *filp)
-{
-	*kiocb = (struct kiocb) {
-			.ki_filp = filp,
-		};
-}
-
 /* prototypes */
 #ifdef CONFIG_AIO
-struct mm_struct;
 extern void exit_aio(struct mm_struct *mm);
 extern long do_io_submit(aio_context_t ctx_id, long nr,
 			 struct iocb __user *__user *iocbpp, bool compat);
 void kiocb_set_cancel_fn(struct kiocb *req, kiocb_cancel_fn *cancel);
 #else
-struct mm_struct;
 static inline void exit_aio(struct mm_struct *mm) { }
 static inline long do_io_submit(aio_context_t ctx_id, long nr,
 				struct iocb __user * __user *iocbpp,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 447932a..48c1472 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -314,6 +314,28 @@ struct page;
 struct address_space;
 struct writeback_control;
 
+#define IOCB_EVENTFD		(1 << 0)
+
+struct kiocb {
+	struct file		*ki_filp;
+	loff_t			ki_pos;
+	void (*ki_complete)(struct kiocb *iocb, long ret, long ret2);
+	void			*private;
+	int			ki_flags;
+};
+
+static inline bool is_sync_kiocb(struct kiocb *kiocb)
+{
+	return kiocb->ki_complete == NULL;
+}
+
+static inline void init_sync_kiocb(struct kiocb *kiocb, struct file *filp)
+{
+	*kiocb = (struct kiocb) {
+		.ki_filp = filp,
+	};
+}
+
 /*
  * "descriptor" for what we're up to with a read.
  * This allows us to use the same read code yet
diff --git a/include/net/sock.h b/include/net/sock.h
index ab186b1..71c1300 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -57,7 +57,6 @@
 #include <linux/page_counter.h>
 #include <linux/memcontrol.h>
 #include <linux/static_key.h>
-#include <linux/aio.h>
 #include <linux/sched.h>
 
 #include <linux/filter.h>
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 60b2aa2..40d50cc 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -32,7 +32,6 @@
 #include <linux/security.h>
 #include <linux/bootmem.h>
 #include <linux/memblock.h>
-#include <linux/aio.h>
 #include <linux/syscalls.h>
 #include <linux/kexec.h>
 #include <linux/kdb.h>
@@ -46,6 +45,7 @@
 #include <linux/irq_work.h>
 #include <linux/utsname.h>
 #include <linux/ctype.h>
+#include <linux/uio.h>
 
 #include <asm/uaccess.h>
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 88ea2d6..83d907a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -19,6 +19,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/aio.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
diff --git a/mm/filemap.c b/mm/filemap.c
index ad72420..876f4e6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -13,7 +13,6 @@
 #include <linux/compiler.h>
 #include <linux/fs.h>
 #include <linux/uaccess.h>
-#include <linux/aio.h>
 #include <linux/capability.h>
 #include <linux/kernel_stat.h>
 #include <linux/gfp.h>
diff --git a/mm/page_io.c b/mm/page_io.c
index 7ef2157..a96c856 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -20,8 +20,8 @@
 #include <linux/buffer_head.h>
 #include <linux/writeback.h>
 #include <linux/frontswap.h>
-#include <linux/aio.h>
 #include <linux/blkdev.h>
+#include <linux/uio.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags,
diff --git a/mm/shmem.c b/mm/shmem.c
index a63031f..944b940 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -31,7 +31,7 @@
 #include <linux/mm.h>
 #include <linux/export.h>
 #include <linux/swap.h>
-#include <linux/aio.h>
+#include <linux/uio.h>
 
 static struct vfsmount *shm_mnt;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index f027a70..4a356b7 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -46,7 +46,6 @@
 #include <linux/stddef.h>
 #include <linux/slab.h>
 #include <linux/errno.h>
-#include <linux/aio.h>
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <linux/spinlock.h>
diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
index b03a638..9ecff24 100644
--- a/sound/core/pcm_native.c
+++ b/sound/core/pcm_native.c
@@ -25,7 +25,6 @@
 #include <linux/slab.h>
 #include <linux/time.h>
 #include <linux/pm_qos.h>
-#include <linux/aio.h>
 #include <linux/io.h>
 #include <linux/dma-mapping.h>
 #include <sound/core.h>
@@ -35,6 +34,7 @@
 #include <sound/pcm_params.h>
 #include <sound/timer.h>
 #include <sound/minors.h>
+#include <linux/uio.h>
 
 /*
  *  Compatibility
-- 
2.1.4
