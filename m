From: Benjamin LaHaise <bcrl@redhat.com>
Subject: [patch] add iocb to network protocols
Date: Thu, 10 Oct 2002 18:35:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010183528.A13432@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Dave,

Below is a copy of the bk tree at:

	bk pull master.kernel.org:/home/bcrl/net-2.5

This tree adds the iocb parameter into the sendmsg and recvmsg 
operations within the network operations.  sock_read and sock_write 
are also replaced by sock_aio_read/sock_aio_write, so this requires 
the other aio changes to fs/read_write.c that are in fresh trees 
from Linus.  Comments?

This will update the following files:

 include/linux/net.h          |    9 ++
 include/net/inet_common.h    |    6 +
 include/net/sock.h           |   82 ++++++++++++++++---------
 include/net/tcp.h            |    5 -
 include/net/udp.h            |    3 
 net/atm/common.c             |    8 +-
 net/atm/common.h             |    8 +-
 net/ax25/af_ax25.c           |    7 +-
 net/bluetooth/af_bluetooth.c |    3 
 net/core/sock.c              |    8 +-
 net/decnet/af_decnet.c       |    8 +-
 net/econet/af_econet.c       |    9 +-
 net/ipv4/af_inet.c           |   17 ++---
 net/ipv4/raw.c               |    7 +-
 net/ipv4/tcp.c               |    5 -
 net/ipv4/udp.c               |    7 +-
 net/ipx/af_ipx.c             |    8 +-
 net/irda/af_irda.c           |    9 +-
 net/llc/af_llc.c             |    9 +-
 net/netlink/af_netlink.c     |    6 +
 net/netrom/af_netrom.c       |    8 +-
 net/packet/af_packet.c       |   10 +--
 net/rose/af_rose.c           |    9 +-
 net/socket.c                 |  141 ++++++++++++++++++++++++++-----------------
 net/unix/af_unix.c           |   12 ++-
 net/wanrouter/af_wanpipe.c   |    9 +-
 net/x25/af_x25.c             |    7 +-
 27 files changed, 255 insertions(+), 165 deletions(-)

through these ChangeSets:

<bcrl@redhat.com> (02/10/10 1.741)
   correct sock_aio_write prototype

<bcrl@redhat.com> (02/10/10 1.740)
   eliminate a compiler warning for aio_write in net/socket.c

<bcrl@bob.home.kvack.org> (02/10/10 1.733.4.2)
   clean up whitespace and patch import errors from net-kiocb patch

<bcrl@bob.home.kvack.org> (02/10/10 1.733.4.1)
   net-kiocb.diff


through these patches:

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.740   -> 1.741  
#	        net/socket.c	1.31    -> 1.32   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/10/10	bcrl@redhat.com	1.741
# correct sock_aio_write prototype
# --------------------------------------------
#
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Thu Oct 10 18:27:23 2002
+++ b/net/socket.c	Thu Oct 10 18:27:23 2002
@@ -92,7 +92,7 @@
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, char *buf,
 			 size_t size, loff_t pos);
-static ssize_t sock_aio_write(struct kiocb *iocb, char *buf,
+static ssize_t sock_aio_write(struct kiocb *iocb, const char *buf,
 			  size_t size, loff_t pos);
 static int sock_mmap(struct file *file, struct vm_area_struct * vma);
 
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.739   -> 1.740  
#	        net/socket.c	1.30    -> 1.31   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/10/10	bcrl@redhat.com	1.740
# eliminate a compiler warning for aio_write in net/socket.c
# --------------------------------------------
#
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Thu Oct 10 18:27:24 2002
+++ b/net/socket.c	Thu Oct 10 18:27:24 2002
@@ -619,7 +619,7 @@
  *	is readable by the user process.
  */
 
-static ssize_t sock_aio_write(struct kiocb *iocb, char *ubuf,
+static ssize_t sock_aio_write(struct kiocb *iocb, const char *ubuf,
 			  size_t size, loff_t pos)
 {
 	struct sock_iocb *x = kiocb_to_siocb(iocb);
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.733.4.1 -> 1.733.4.2
#	        net/socket.c	1.29    -> 1.30   
#	  include/net/sock.h	1.21    -> 1.22   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/10/10	torvalds@penguin.transmeta.com	1.733.1.27
# Clean up after timers - move the "timers" Makefile info
# into the proper subdirectory (kernel) where it is used.
# 
# Drop unused variables.
# --------------------------------------------
# 02/10/10	axboe@suse.de	1.733.1.28
# [PATCH] excessive stack usage in cdrom
# 
# CD-ROM puts struct cdrom_changer_info on the stack in a few places, this
# is a bad idea since it's big (a bit over 1kb).  This makes us allocate
# it instead.
# 
# Noticed by Anton.
# --------------------------------------------
# 02/10/10	sam@ravnborg.org	1.733.1.29
# [PATCH] drivers/scsi - Makefile fix
# 
# Reference to .ver file incorrect after recent makefile changes.
# Grepped the kernel tree, and this is the only Makefile that
# uses $(MODVERDIR).
# --------------------------------------------
# 02/10/10	olaf.dietsche#list.linux-kernel@t-online.de	1.733.1.30
# [PATCH] 2.5.40: fix chmod/chown on procfs
# 
# This patch allows to change uid, gid and mode of files and directories
# located in procfs.
# 
# Without this patch you can change uid, gid and mode as long as the
# file is open. As soon as you close the file, it reverts back to its
# default, which is root:root and readonly usually.
# --------------------------------------------
# 02/10/10	paulus@samba.org	1.733.1.31
# [PATCH] add PCI device ID for Motorola MPC107
# 
# This patch adds the PCI device ID for the Motorola MPC107 host bridge.
# The entry is already in the list at pciids.sf.net but isn't in the
# kernel pci_ids.h file yet.  Please apply this to your tree.
# --------------------------------------------
# 02/10/10	paulus@samba.org	1.733.1.32
# [PATCH] adjust PPC sysctls
# 
# This patch takes out the unused KERN_PPC_ZEROPAGED sysctl, and
# restricts the KERN_PPC_POWERSAVE_NAP and KERN_PPC_L2CR sysctls to be
# present only on those PPC processors where they are useful.  This
# patch only affects PPC.
# --------------------------------------------
# 02/10/10	Andries.Brouwer@cwi.nl	1.733.1.33
# [PATCH] isofs fix
# 
# The patch below removes some dead code and nonsense code.
# The part that changes behaviour is
# 
#  -       if (sbi->s_cruft == 'n' &&
#  -           (volume_seq_no != 0) && (volume_seq_no != 1)) {
#  -               printk(KERN_WARNING "Warning: defective CD-ROM "
#  -                      "(volume sequence number %d). "
#  -                      "Enabling \"cruft\" mount option.\n", volume_seq_no);
#  -               sbi->s_cruft = 'y';
#  -       }
# 
# that has already bitten lots of people.
# 
# Nothing is wrong with a volume sequence number different from 0 or 1.
# (Cf. Ecma-119.pdf, Sections 4.17, 4.18, 6.6.)
# --------------------------------------------
# 02/10/10	torvalds@penguin.transmeta.com	1.733.1.34
# Merge http://linux-isdn.bkbits.net/linux-2.5.make
# into penguin.transmeta.com:/home/penguin/torvalds/repositories/kernel/linux
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.35
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# Instantiate a new file, include/linux/nfs4.h, which contains
# constants and typedef's for the NFSv4 protocol (by analogy with
# include/linux/nfs2.h and include/linux/nfs3.h).
# 
# Also #include this file in a few places where it will be needed
# later.
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.36
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# In a number of places in the NFS client, I had to change
# 
#   #ifdef CONFIG_NFS_V3
#      /* ... */
#   #endif
# 
# to
# 
#   #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
#      /* ... */
#   #endif
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.37
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# This patch changes the interface of the ->readdir() nfs_rpc_op
# so that its first argument is a dentry instead of an inode.
# 
# [Explanation: The dentry is required because in NFSv4, we need
#  to make use of the _parent_ directory's inode.  This is because
#  NFSv4 servers no longer return an entry for ".." in the READDIR
#  response, so the client kernel needs to fake this entry, inode
#  number and all.]
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.38
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# This patch changes the interface of the ->setattr() nfs_rpc_op
# so that its first argument is a dentry instead of an inode.
# 
# [Explanation: The dentry is required because in NFSv4, we may
#  need to OPEN the file before doing the SETATTR.  (This is
#  required if the file size is changed as part of the setattr.)
#  Opening the file requires making use of the containing
#  directory's inode.]
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.39
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# In NFSv4, there is no hard limit on the length of symlink text.
# This patch changes the -ENAMETOOLONG test in nfs_symlink() accordingly.
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.40
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# In NFSv4, an fsid is a 64-bit major number together with a 64-bit
# minor number.  In previous versions, an fsid is a single number.
# This patch changes 'struct nfs_fattr' accordingly.
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.41
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# This is a nontrivial change to the NFS client.
# 
# NFSv4 defines a new file attribute, change_attr.  This is a per-file
# opaque quantity returned by the server, whose value is required to
# change whenever the file is modified.  If it exists, we want to use
# it for all cache consistency checks in nfs_refresh_inode().  Some
# operations also return a "pre-operation" value of the change_attr;
# we want to take this into account too.
# 
# First, define flags
#   NFS_ATTR_FATTR_V4 - indicates that the 'struct nfs_fattr' is an
#                       NFSv4 fattr, so the change_attr field is valid
#   NFS_ATTR_PRE_CHANGE - indicates that the server returned a pre-operation
#                       change_attr, so the pre_change_attr field is valid
# 
# Second, change nfs_refresh_inode() so that the caches are invalidated
# if there is a change_attr mismatch.  Exception: If the pre_change_attr
# tells us that the mismatch was caused by our operation, then do not
# invalidate the caches.
# 
# This patch should leave the logic in nfs_refresh_inode() unchanged
# if neither of the new flags are set.
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.42
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# If the NFS_ATTR_FATTR_V4 flag is set, use the NFSv3 convention for
# the 'space_used' part of the fattr.
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.43
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# This is a nontrivial change to the NFS client.
# 
# Synchronous READ operations are currently done via the ->read() nfs_rpc_op.
# Therefore, the synchronous READ path can easily be adapted for NFSv4.  On
# the other hand, the asynchronous READ path contains several NFSv3-specific
# features, which make it difficult to adapt for NFSv4.
# 
# In this patch and the next, we modify the async READ path to be
# version-agnostic.  This patch just changes the 'struct nfs_read_data'
# so that the v2- and v3-specific parts are moved into a private area,
# with room for a v4-specific part in parallel.  None of the logic is
# changed.
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.44
# [PATCH] A basic NFSv4 client for 2.5.x
# 
# This is a nontrivial change to the NFS client.
# 
# In this patch, we finish modifying the async READ path so that it is
# version-agnostic.  We define a new nfs_rpc_op ->setup_read(), and move
# the v2- and v3-specific code in nfs_read_rpcsetup() there.  We also
# have to change nfs_readpage() result so that the 'count' of bytes
# read is a parameter.  The extra parameter means that it can no longer
# be ->tk_exit().  Instead, it is called from a version-specific ->tk_exit()
# routine which is set in ->read_setup().
# 
# The upshot of all this is that the version-specific part of the
# async READ path has been encapsulated in a new nfs_rpc_op
# ->read_setup(), and NFSv4 can share the logic for asynchronous
# READ's with NFSv2 and v3.
# --------------------------------------------
# 02/10/10	trond.myklebust@fys.uio.no	1.733.1.45
# [PATCH] Fix NFS locking over TCP
# 
# The 2.5.x RPC code is currently broken in that it demands that all
# tasks that call xprt_create_proto() in order to open a TCP socket must
# have CAP_NET_BIND_SERVICE capabilities, and must bind to a privileged
# port.
# 
# This breaks the NLM locking code and its use of the call_bind() RPC
# portmapper lookup feature.
# 
# This patch allows the built-in portmapper client to use unbound TCP
# sockets if the user does not have the necessary capabilities.
# --------------------------------------------
# 02/10/10	greg@kroah.com	1.733.1.46
# [PATCH] minor i386 timer changes for 2.5.41
# 
# Here's an additional patch that contains the cleanups I did to John's
# timer patches.  It does the following:
# 
# 	- uses C99 initializers
# 	- makes the timer list static
# 	- adds better documentation to the timer function structure
# 	- makes the timer init function return 0 on success
# 	- NULL terminates the list of timers to make further patches
# 	  easier.
# --------------------------------------------
# 02/10/10	dledford@redhat.com	1.733.1.47
# [PATCH] atp870 driver
# 
# This is a minimal patch to allow me to load/use the atp module so I can do
# further testing work on it.
# --------------------------------------------
# 02/10/10	bcrl@bob.home.kvack.org	1.733.4.2
# clean up whitespace and patch import errors from net-kiocb patch
# --------------------------------------------
#
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	Thu Oct 10 18:27:25 2002
+++ b/include/net/sock.h	Thu Oct 10 18:27:25 2002
@@ -318,30 +318,6 @@
 	return container_of((void *)si, struct kiocb, private);
 }
 
-/* sock_iocb: used to kick off async processing of socket ios */
-struct sock_iocb {
-	struct list_head	list;
-
-	int			flags;
-	int			size;
-	struct socket		*sock;
-	struct sock		*sk;
-	struct msghdr		*msg, async_msg;
-	struct iovec		async_iov;
-	struct scm_cookie	*scm, async_scm;
-};
-
-static inline struct sock_iocb *kiocb_to_siocb(struct kiocb *iocb)
-{
-	BUG_ON(sizeof(struct sock_iocb) > KIOCB_PRIVATE_SIZE);
-	return (struct sock_iocb *)iocb->private;
-}
-
-static inline struct kiocb *siocb_to_kiocb(struct sock_iocb *si)
-{
-	return container_of((void *)si, struct kiocb, private);
-}
-
 /* Used by processes to "lock" a socket state, so that
  * interrupts and bottom half handlers won't change it
  * from under us. It essentially blocks any incoming
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Thu Oct 10 18:27:25 2002
+++ b/net/socket.c	Thu Oct 10 18:27:25 2002
@@ -117,7 +117,7 @@
 
 static struct file_operations socket_file_ops = {
 	.llseek =	no_llseek,
-	.aio_read =		sock_aio_read,
+	.aio_read =	sock_aio_read,
 	.aio_write =	sock_aio_write,
 	.poll =		sock_poll,
 	.ioctl =	sock_ioctl,
@@ -541,7 +541,7 @@
 	struct kiocb iocb;
 	int ret;
 
-        init_sync_kiocb(&iocb, NULL);
+	init_sync_kiocb(&iocb, NULL);
 	ret = __sock_sendmsg(&iocb, sock, msg, size);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.733.1.15 -> 1.733.4.1
#	    net/llc/af_llc.c	1.31    -> 1.32   
#	      net/ipv4/raw.c	1.11    -> 1.12   
#	   include/net/tcp.h	1.19    -> 1.20   
#	  net/ipv4/af_inet.c	1.19    -> 1.20   
#	    net/ipx/af_ipx.c	1.21    -> 1.22   
#	      net/ipv4/udp.c	1.11    -> 1.12   
#	net/bluetooth/af_bluetooth.c	1.6     -> 1.7    
#	      net/ipv4/tcp.c	1.27    -> 1.28   
#	  net/irda/af_irda.c	1.31    -> 1.32   
#	        net/socket.c	1.28    -> 1.29   
#	 include/linux/net.h	1.4     -> 1.5    
#	net/econet/af_econet.c	1.10    -> 1.11   
#	  net/rose/af_rose.c	1.17    -> 1.18   
#	net/netrom/af_netrom.c	1.20    -> 1.21   
#	net/netlink/af_netlink.c	1.11    -> 1.12   
#	net/decnet/af_decnet.c	1.17    -> 1.18   
#	  net/unix/af_unix.c	1.28    -> 1.29   
#	net/packet/af_packet.c	1.15    -> 1.16   
#	  include/net/sock.h	1.19    -> 1.21   
#	     net/core/sock.c	1.12    -> 1.13   
#	include/net/inet_common.h	1.3     -> 1.4    
#	    net/atm/common.h	1.1     -> 1.2    
#	   include/net/udp.h	1.4     -> 1.5    
#	  net/ax25/af_ax25.c	1.15    -> 1.16   
#	    net/x25/af_x25.c	1.20    -> 1.21   
#	net/wanrouter/af_wanpipe.c	1.9     -> 1.10   
#	    net/atm/common.c	1.9     -> 1.10   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/10/10	bcrl@redhat.com	1.736
# Merge redhat.com:/md0/linus-2.5 into redhat.com:/md0/aio-2.5
# --------------------------------------------
# 02/10/10	mingo@elte.hu	1.733.1.16
# [PATCH] timer cleanups
# 
# This is my latest timer patchset, it makes del_timer_sync() a bit more
# robust wrt.  code that re-adds timers from the timer handler.
# 
# Other changes in the patch:
# 
#  - clean up cascading a bit.
# 
#  - do not save flags in __run_timer_list - we enter from an irqs-enabled
#    tasklet.
# --------------------------------------------
# 02/10/10	akpm@digeo.com	1.733.1.17
# [PATCH] mremap use-after-free bugfix
# 
# I have invented a new software development methodology! You send an
# email to Hugh saying "I don't have the foggiest idea why this guy's
# kernel is oopsing" and next morning, you get a patch! I shall patent
# this.
# 
# Since 2.5.3, move_vma() has been passing a freed vma into
# move_page_tables().  Fix it to move back to the previous vma in the
# list if we're about to delete this one.
# 
# Thanks to Morten Helgesen for patient reporting, diagnosis and testing.
# --------------------------------------------
# 02/10/10	akpm@digeo.com	1.733.1.18
# [PATCH] move_one_page atomicity fix
# 
# The atomicicty fix for move_one_page() was not quite right.
# 
# We only do the page_table_present() test if CONFIG_HIGHPTE=y.  Which is
# fine, but even with CONFIG_HIGHPTE=n, the pte mapping functions still
# do an inc_preempt_count() due to their unconditional kmap_atomic().  So
# we get a might_sleep() warning.
# 
# The warning is actually bogus, because those pte's are always in
# direct-mapped memory.
# 
# So hm.  Three fixes suggest themselves:
# 
# 1: Run the page_table_present() test if CONFIG_HIGHMEM.
# 
#    Rejected: penalises non-pte_highmem setups
# 
# 2: Make kmap_atomic() not do inc_preempt_count() is the page was
#    direct mapped.
# 
#    Rejected: I don't think we want kmap_atomic side effects to be
#    varying according to the page which was passed.
# 
# 3: Change the pte mapping functions so they don't run kmap_atomic at
#    all if CONFIG_HIGHPTE=n
# 
#    This is what I did.  And guess what?  For CONFIG_HIGHMEM=y,
#    CONFIG_HIGHPTE=n this patch shrinks the kernel by 5 kbytes.  Because
#    kmap_atomic is inlined.
# 
#    The lesson: we do way too much damn inlining.
# --------------------------------------------
# 02/10/10	akpm@digeo.com	1.733.1.19
# [PATCH] fix the raw driver
# 
# Fix the raw driver by tricking it into performing O_DIRECT IO against
# the bound blockdev.
# 
# - rewrite the i_mapping for /dev/raw/raw0 to point at the same thing
#   as bdev->bd_inode->i_mapping.  We've performed a bdget() against the
#   blockdev, which should pin it for the correct lifetime.
# 
# - set the O_DIRECT bit on the caller's file->flags.
# --------------------------------------------
# 02/10/10	akpm@digeo.com	1.733.1.20
# [PATCH] remove radix_tree_reserve()
# 
# From Hugh Dickins.
# 
# radix_tree_reserve() exists solely for the tmpfs move_to_swap_cache()
# and move_from_swap_cache() functions, and yet they don't need it: there
# is no problem in the one page being simultaneously listed in two radix
# trees (while both locks are held).  Use radix_tree_insert(), and remove
# radix_tree_reserve(); also removed a few blank lines.
# --------------------------------------------
# 02/10/10	akpm@digeo.com	1.733.1.21
# [PATCH] remove the sched_yield from the ext3 fsync path
# 
# The changed sched_yield() semantics have made ext3's transaction
# batching terribly slow.
# 
# Apparently a schedule() fixes that, although it probably breaks
# transaction batching.
# 
# This patch largely fixes my complaints about the new scheduler being
# extremely sluggish to interactive applications.  Evidently those
# applications were calling fsync() and were spending extremely long
# periods in sched_yield().
# --------------------------------------------
# 02/10/10	akpm@digeo.com	1.733.1.22
# [PATCH] make readv/writev return 0 for 0 segments
# 
# Should resolve an ongoing fiasco concerning what we should return to
# userspace if they do a readv or writev of zero segments.
# 
# SuS is ambiguous, but implies EINVAL.  We're currently returning
# EINVAL, but 2.4 returns zero.
# 
# I think zero makes more sense, and it is what 2.4 does.
# --------------------------------------------
# 02/10/10	bcrl@redhat.com	1.737
# fix symbol export in fs/read_write.c
# --------------------------------------------
# 02/10/10	johnstul@us.ibm.com	1.733.1.23
# [PATCH] linux-2.5.41_timer-changes_A4 (1/3 - infrastructure)
# 
#         The i386 time.c code is turning into a mess. We've got multiple
# functions that do the same thing, only with different hardware, all
# surrounded #ifdefs and even more difficult to follow #ifndefs. George
# Anzinger is introducing a new ACPIpm time source, I'm going to attempt
# to add the cyclone counter as a time source, and in the future there
# will be HPET to deal with. These will not go in cleanly together as
# things are now.
# 
#         Inspired by suggestions from Alan, this collection of patches
# tries to clean up time.c by breaking out the PIT and TSC specific parts
# into their own files. Additionally the patch creates an abstract
# interface to use these existing time soruces, as well as make it easier
# to add future time sources.
# 
#         It introduces "struct timer_ops" which gives the time code a
# clear interface to use these different time sources. It also allows for
# clearer conditional compilation of these various time sources.
# 
#         This first patch (part 1 of 3) provides the infrastructure
# needed via the timer_ops structure, as well as the select_timer()
# function for choosing the best available timer.
# --------------------------------------------
# 02/10/10	johnstul@us.ibm.com	1.733.1.24
# [PATCH] linux-2.5.41_timer-changes_A4 (2/3 - bulk move)
# 
#         This is part 2 of 3 of my timer-change patch. Part 2 is just a
# bulk move of code out of time.c and into timer_pit.c and timer_tsc.c. No
# code is changed, only moved.
# 
#         Please note, this code will not compile without the final third
# part of this patch collection. This was done for readability alone.
# --------------------------------------------
# 02/10/10	johnstul@us.ibm.com	1.733.1.25
# [PATCH] linux-2.5.41_timer-changes_A4 (3/3 - integration)
# 
#         This is the final part 3 of 3 of my timer-change patch. Part 3
# integrates the moved code (from part 2) into the new infrastructure
# (from part 1).
# --------------------------------------------
# 02/10/10	johnstul@us.ibm.com	1.733.1.26
# [PATCH] linux-2.5.41_cyclone-timer_B2
# 
#         In order to demonstrate how new time-sources are added to my
# timer-changes patch. Here is my current version of my cyclone-timer
# patch for 2.5.41. This uses the infrastructure set up in the
# timer-changes_A4 patch set to add the cyclone counter (found on IBM
# Summit Based hardware) as a time-source.
# 
#         The current code is not enabled as it also depends on James
# Cleverdon's 2.5 summit patch, however it illustrates how cleanly new
# time-sources can be added.
# --------------------------------------------
# 02/10/10	stevef@smfhome1.austin.rr.com	1.733.3.1
# Initial check in of cifs filesystem version 0.54 for Linux 2.5 (to clean tree as one changeset)
# --------------------------------------------
# 02/10/10	bcrl@bob.home.kvack.org	1.733.4.1
# net-kiocb.diff
# --------------------------------------------
#
diff -Nru a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h	Thu Oct 10 18:27:27 2002
+++ b/include/linux/net.h	Thu Oct 10 18:27:27 2002
@@ -81,6 +81,7 @@
 struct scm_cookie;
 struct vm_area_struct;
 struct page;
+struct kiocb;
 
 struct proto_ops {
   int	family;
@@ -104,8 +105,12 @@
 			 char *optval, int optlen);
   int	(*getsockopt)	(struct socket *sock, int level, int optname,
 			 char *optval, int *optlen);
-  int   (*sendmsg)	(struct socket *sock, struct msghdr *m, int total_len, struct scm_cookie *scm);
-  int   (*recvmsg)	(struct socket *sock, struct msghdr *m, int total_len, int flags, struct scm_cookie *scm);
+  int   (*sendmsg)	(struct kiocb *iocb, struct socket *sock,
+			 struct msghdr *m, int total_len,
+			 struct scm_cookie *scm);
+  int   (*recvmsg)	(struct kiocb *iocb, struct socket *sock,
+			 struct msghdr *m, int total_len, int flags,
+			 struct scm_cookie *scm);
   int	(*mmap)		(struct file *file, struct socket *sock, struct vm_area_struct * vma);
   ssize_t (*sendpage)	(struct socket *sock, struct page *page, int offset, size_t size, int flags);
 };
diff -Nru a/include/net/inet_common.h b/include/net/inet_common.h
--- a/include/net/inet_common.h	Thu Oct 10 18:27:27 2002
+++ b/include/net/inet_common.h	Thu Oct 10 18:27:27 2002
@@ -20,10 +20,12 @@
 						   int addr_len, int flags);
 extern int			inet_accept(struct socket *sock, 
 					    struct socket *newsock, int flags);
-extern int			inet_recvmsg(struct socket *sock, 
+extern int			inet_recvmsg(struct kiocb *iocb,
+					     struct socket *sock, 
 					     struct msghdr *ubuf, 
 					     int size, int flags, struct scm_cookie *scm);
-extern int			inet_sendmsg(struct socket *sock, 
+extern int			inet_sendmsg(struct kiocb *iocb,
+					     struct socket *sock, 
 					     struct msghdr *msg, 
 					     int size, struct scm_cookie *scm);
 extern int			inet_shutdown(struct socket *sock, int how);
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	Thu Oct 10 18:27:27 2002
+++ b/include/net/sock.h	Thu Oct 10 18:27:27 2002
@@ -51,6 +51,7 @@
 
 #include <asm/atomic.h>
 #include <net/dst.h>
+#include <net/scm.h>	/* for sock_iocb */
 
 /*
  * This structure really needs to be cleaned up.
@@ -242,9 +243,10 @@
 	int			(*getsockopt)(struct sock *sk, int level, 
 					int optname, char *optval, 
 					int *option);  	 
-	int			(*sendmsg)(struct sock *sk, struct msghdr *msg,
-					   int len);
-	int			(*recvmsg)(struct sock *sk, struct msghdr *msg,
+	int			(*sendmsg)(struct kiocb *iocb, struct sock *sk,
+					   struct msghdr *msg, int len);
+	int			(*recvmsg)(struct kiocb *iocb, struct sock *sk,
+					   struct msghdr *msg,
 					int len, int noblock, int flags, 
 					int *addr_len);
 	int			(*bind)(struct sock *sk, 
@@ -292,7 +294,53 @@
 #define SOCK_BINDADDR_LOCK	4
 #define SOCK_BINDPORT_LOCK	8
 
+/* sock_iocb: used to kick off async processing of socket ios */
+struct sock_iocb {
+	struct list_head	list;
+
+	int			flags;
+	int			size;
+	struct socket		*sock;
+	struct sock		*sk;
+	struct msghdr		*msg, async_msg;
+	struct iovec		async_iov;
+	struct scm_cookie	*scm, async_scm;
+};
+
+static inline struct sock_iocb *kiocb_to_siocb(struct kiocb *iocb)
+{
+	BUG_ON(sizeof(struct sock_iocb) > KIOCB_PRIVATE_SIZE);
+	return (struct sock_iocb *)iocb->private;
+}
+
+static inline struct kiocb *siocb_to_kiocb(struct sock_iocb *si)
+{
+	return container_of((void *)si, struct kiocb, private);
+}
 
+/* sock_iocb: used to kick off async processing of socket ios */
+struct sock_iocb {
+	struct list_head	list;
+
+	int			flags;
+	int			size;
+	struct socket		*sock;
+	struct sock		*sk;
+	struct msghdr		*msg, async_msg;
+	struct iovec		async_iov;
+	struct scm_cookie	*scm, async_scm;
+};
+
+static inline struct sock_iocb *kiocb_to_siocb(struct kiocb *iocb)
+{
+	BUG_ON(sizeof(struct sock_iocb) > KIOCB_PRIVATE_SIZE);
+	return (struct sock_iocb *)iocb->private;
+}
+
+static inline struct kiocb *siocb_to_kiocb(struct sock_iocb *si)
+{
+	return container_of((void *)si, struct kiocb, private);
+}
 
 /* Used by processes to "lock" a socket state, so that
  * interrupts and bottom half handlers won't change it
@@ -390,10 +438,10 @@
 						   char *, int *);
 extern int			sock_no_setsockopt(struct socket *, int, int,
 						   char *, int);
-extern int                      sock_no_sendmsg(struct socket *,
+extern int                      sock_no_sendmsg(struct kiocb *, struct socket *,
 						struct msghdr *, int,
 						struct scm_cookie *);
-extern int                      sock_no_recvmsg(struct socket *,
+extern int                      sock_no_recvmsg(struct kiocb *, struct socket *,
 						struct msghdr *, int, int,
 						struct scm_cookie *);
 extern int			sock_no_mmap(struct file *file,
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	Thu Oct 10 18:27:27 2002
+++ b/include/net/tcp.h	Thu Oct 10 18:27:27 2002
@@ -648,7 +648,8 @@
 
 extern int		    	tcp_v4_tw_remember_stamp(struct tcp_tw_bucket *tw);
 
-extern int			tcp_sendmsg(struct sock *sk, struct msghdr *msg, int size);
+extern int			tcp_sendmsg(struct kiocb *iocb, struct sock *sk,
+					    struct msghdr *msg, int size);
 extern ssize_t			tcp_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags);
 
 extern int			tcp_ioctl(struct sock *sk, 
@@ -739,7 +740,7 @@
 					       int optname, char *optval, 
 					       int optlen);
 extern void			tcp_set_keepalive(struct sock *sk, int val);
-extern int			tcp_recvmsg(struct sock *sk, 
+extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 					    struct msghdr *msg,
 					    int len, int nonblock, 
 					    int flags, int *addr_len);
diff -Nru a/include/net/udp.h b/include/net/udp.h
--- a/include/net/udp.h	Thu Oct 10 18:27:27 2002
+++ b/include/net/udp.h	Thu Oct 10 18:27:27 2002
@@ -64,7 +64,8 @@
 extern int	udp_connect(struct sock *sk,
 			    struct sockaddr *usin, int addr_len);
 
-extern int	udp_sendmsg(struct sock *sk, struct msghdr *msg, int len);
+extern int	udp_sendmsg(struct kiocb *iocb, struct sock *sk,
+			    struct msghdr *msg, int len);
 
 extern int	udp_rcv(struct sk_buff *skb);
 extern int	udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Thu Oct 10 18:27:27 2002
+++ b/net/atm/common.c	Thu Oct 10 18:27:27 2002
@@ -336,8 +336,8 @@
 }
 
 
-int atm_recvmsg(struct socket *sock,struct msghdr *m,int total_len,
-    int flags,struct scm_cookie *scm)
+int atm_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+		int total_len, int flags, struct scm_cookie *scm)
 {
 	DECLARE_WAITQUEUE(wait,current);
 	struct atm_vcc *vcc;
@@ -417,8 +417,8 @@
 }
 
 
-int atm_sendmsg(struct socket *sock,struct msghdr *m,int total_len,
-    struct scm_cookie *scm)
+int atm_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+		int total_len, struct scm_cookie *scm)
 {
 	DECLARE_WAITQUEUE(wait,current);
 	struct atm_vcc *vcc;
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Thu Oct 10 18:27:27 2002
+++ b/net/atm/common.h	Thu Oct 10 18:27:27 2002
@@ -13,10 +13,10 @@
 int atm_create(struct socket *sock,int protocol,int family);
 int atm_release(struct socket *sock);
 int atm_connect(struct socket *sock,int itf,short vpi,int vci);
-int atm_recvmsg(struct socket *sock,struct msghdr *m,int total_len,
-    int flags,struct scm_cookie *scm);
-int atm_sendmsg(struct socket *sock,struct msghdr *m,int total_len,
-  struct scm_cookie *scm);
+int atm_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+		int total_len, int flags, struct scm_cookie *scm);
+int atm_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+		int total_len, struct scm_cookie *scm);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
 int atm_ioctl(struct socket *sock,unsigned int cmd,unsigned long arg);
 int atm_setsockopt(struct socket *sock,int level,int optname,char *optval,
diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	Thu Oct 10 18:27:27 2002
+++ b/net/ax25/af_ax25.c	Thu Oct 10 18:27:27 2002
@@ -1410,7 +1410,8 @@
 	return err;
 }
 
-static int ax25_sendmsg(struct socket *sock, struct msghdr *msg, int len,
+static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
+			struct msghdr *msg, int len,
 	struct scm_cookie *scm)
 {
 	struct sockaddr_ax25 *usax = (struct sockaddr_ax25 *)msg->msg_name;
@@ -1588,8 +1589,8 @@
 	return err;
 }
 
-static int ax25_recvmsg(struct socket *sock, struct msghdr *msg, int size,
-	int flags, struct scm_cookie *scm)
+static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
+	struct msghdr *msg, int size, int flags, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff -Nru a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c	Thu Oct 10 18:27:27 2002
+++ b/net/bluetooth/af_bluetooth.c	Thu Oct 10 18:27:27 2002
@@ -207,7 +207,8 @@
 	return NULL;
 }
 
-int bluez_sock_recvmsg(struct socket *sock, struct msghdr *msg, int len, int flags, struct scm_cookie *scm)
+int bluez_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
+	struct msghdr *msg, int len, int flags, struct scm_cookie *scm)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	Thu Oct 10 18:27:27 2002
+++ b/net/core/sock.c	Thu Oct 10 18:27:27 2002
@@ -1047,14 +1047,14 @@
 	return -EOPNOTSUPP;
 }
 
-int sock_no_sendmsg(struct socket *sock, struct msghdr *m, int flags,
-		    struct scm_cookie *scm)
+int sock_no_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+		    int flags, struct scm_cookie *scm)
 {
 	return -EOPNOTSUPP;
 }
 
-int sock_no_recvmsg(struct socket *sock, struct msghdr *m, int len, int flags,
-		    struct scm_cookie *scm)
+int sock_no_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+		    int len, int flags, struct scm_cookie *scm)
 {
 	return -EOPNOTSUPP;
 }
diff -Nru a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	Thu Oct 10 18:27:27 2002
+++ b/net/decnet/af_decnet.c	Thu Oct 10 18:27:27 2002
@@ -1733,8 +1733,8 @@
 }
 
 
-static int dn_recvmsg(struct socket *sock, struct msghdr *msg, int size,
-	int flags, struct scm_cookie *scm)
+static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
+	struct msghdr *msg, int size, int flags, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
@@ -1901,8 +1901,8 @@
 	return 0;
 }
 
-static int dn_sendmsg(struct socket *sock, struct msghdr *msg, int size, 
-	   struct scm_cookie *scm)
+static int dn_sendmsg(struct kiocb *iocb, struct socket *sock,
+	   struct msghdr *msg, int size, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	Thu Oct 10 18:27:27 2002
+++ b/net/econet/af_econet.c	Thu Oct 10 18:27:27 2002
@@ -97,8 +97,9 @@
  *	If necessary we block.
  */
 
-static int econet_recvmsg(struct socket *sock, struct msghdr *msg, int len,
-			  int flags, struct scm_cookie *scm)
+static int econet_recvmsg(struct kiocb *iocb, struct socket *sock,
+			  struct msghdr *msg, int len, int flags,
+			  struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
@@ -230,8 +231,8 @@
  *	and hence whether to use real Econet or the UDP emulation.
  */
 
-static int econet_sendmsg(struct socket *sock, struct msghdr *msg, int len,
-			  struct scm_cookie *scm)
+static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
+			  struct msghdr *msg, int len, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ec *saddr=(struct sockaddr_ec *)msg->msg_name;
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	Thu Oct 10 18:27:27 2002
+++ b/net/ipv4/af_inet.c	Thu Oct 10 18:27:27 2002
@@ -753,22 +753,23 @@
 }
 
 
-
-int inet_recvmsg(struct socket *sock, struct msghdr *msg, int size,
-		 int flags, struct scm_cookie *scm)
+int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
+		 int size, int flags, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	int addr_len = 0;
-	int err = sk->prot->recvmsg(sk, msg, size, flags & MSG_DONTWAIT,
-				    flags & ~MSG_DONTWAIT, &addr_len);
+	int err;
+
+	err = sk->prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAIT,
+				flags & ~MSG_DONTWAIT, &addr_len);
 	if (err >= 0)
 		msg->msg_namelen = addr_len;
 	return err;
 }
 
 
-int inet_sendmsg(struct socket *sock, struct msghdr *msg, int size,
-		 struct scm_cookie *scm)
+int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
+		 int size, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 
@@ -776,7 +777,7 @@
 	if (!inet_sk(sk)->num && inet_autobind(sk))
 		return -EAGAIN;
 
-	return sk->prot->sendmsg(sk, msg, size);
+	return sk->prot->sendmsg(iocb, sk, msg, size);
 }
 
 int inet_shutdown(struct socket *sock, int how)
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	Thu Oct 10 18:27:27 2002
+++ b/net/ipv4/raw.c	Thu Oct 10 18:27:27 2002
@@ -295,7 +295,8 @@
 	return 0;
 }
 
-static int raw_sendmsg(struct sock *sk, struct msghdr *msg, int len)
+static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       int len)
 {
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipcm_cookie ipc;
@@ -476,8 +477,8 @@
  *	we return it, otherwise we block.
  */
 
-int raw_recvmsg(struct sock *sk, struct msghdr *msg, int len,
-		int noblock, int flags, int *addr_len)
+int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		int len, int noblock, int flags, int *addr_len)
 {
 	struct inet_opt *inet = inet_sk(sk);
 	int copied = 0;
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	Thu Oct 10 18:27:27 2002
+++ b/net/ipv4/tcp.c	Thu Oct 10 18:27:27 2002
@@ -1013,7 +1013,8 @@
 	return tmp;
 }
 
-int tcp_sendmsg(struct sock *sk, struct msghdr *msg, int size)
+int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		int size)
 {
 	struct iovec *iov;
 	struct tcp_opt *tp = tcp_sk(sk);
@@ -1475,7 +1476,7 @@
  *	Probably, code can be easily improved even more.
  */
 
-int tcp_recvmsg(struct sock *sk, struct msghdr *msg,
+int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		int len, int nonblock, int flags, int *addr_len)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	Thu Oct 10 18:27:27 2002
+++ b/net/ipv4/udp.c	Thu Oct 10 18:27:27 2002
@@ -423,7 +423,8 @@
 				   fraglen);
 }
 
-int udp_sendmsg(struct sock *sk, struct msghdr *msg, int len)
+int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		int len)
 {
 	struct inet_opt *inet = inet_sk(sk);
 	int ulen = len + sizeof(struct udphdr);
@@ -635,8 +636,8 @@
  * 	return it, otherwise we block.
  */
 
-int udp_recvmsg(struct sock *sk, struct msghdr *msg, int len,
-		int noblock, int flags, int *addr_len)
+int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		int len, int noblock, int flags, int *addr_len)
 {
 	struct inet_opt *inet = inet_sk(sk);
   	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
diff -Nru a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
--- a/net/ipx/af_ipx.c	Thu Oct 10 18:27:27 2002
+++ b/net/ipx/af_ipx.c	Thu Oct 10 18:27:27 2002
@@ -2009,8 +2009,8 @@
 out:	return ret;
 }
 
-static int ipx_sendmsg(struct socket *sock, struct msghdr *msg, int len,
-	struct scm_cookie *scm)
+static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
+	struct msghdr *msg, int len, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_opt *ipxs = ipx_sk(sk);
@@ -2069,8 +2069,8 @@
 }
 
 
-static int ipx_recvmsg(struct socket *sock, struct msghdr *msg, int size,
-		int flags, struct scm_cookie *scm)
+static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *msg, int size, int flags, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_opt *ipxs = ipx_sk(sk);
diff -Nru a/net/irda/af_irda.c b/net/irda/af_irda.c
--- a/net/irda/af_irda.c	Thu Oct 10 18:27:27 2002
+++ b/net/irda/af_irda.c	Thu Oct 10 18:27:27 2002
@@ -1259,8 +1259,8 @@
  *    SEQPACK services. This is possible since it forces the client to
  *    fragment the message if necessary
  */
-static int irda_sendmsg(struct socket *sock, struct msghdr *msg, int len,
-			struct scm_cookie *scm)
+static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
+			struct msghdr *msg, int len, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
@@ -1331,8 +1331,9 @@
  *    Try to receive message and copy it to user. The frame is discarded
  *    after being read, regardless of how much the user actually read
  */
-static int irda_recvmsg_dgram(struct socket *sock, struct msghdr *msg,
-			      int size, int flags, struct scm_cookie *scm)
+static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
+			      struct msghdr *msg, int size, int flags,
+			      struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
diff -Nru a/net/llc/af_llc.c b/net/llc/af_llc.c
--- a/net/llc/af_llc.c	Thu Oct 10 18:27:27 2002
+++ b/net/llc/af_llc.c	Thu Oct 10 18:27:27 2002
@@ -677,8 +677,9 @@
  *	Copy received data to the socket user.
  *	Returns non-negative upon success, negative otherwise.
  */
-static int llc_ui_recvmsg(struct socket *sock, struct msghdr *msg, int size,
-			  int flags, struct scm_cookie *scm)
+static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
+			  struct msghdr *msg, int size, int flags,
+			  struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_llc *uaddr = (struct sockaddr_llc *)msg->msg_name;
@@ -731,8 +732,8 @@
  *	Transmit data provided by the socket user.
  *	Returns non-negative upon success, negative otherwise.
  */
-static int llc_ui_sendmsg(struct socket *sock, struct msghdr *msg, int len,
-			  struct scm_cookie *scm)
+static int llc_ui_sendmsg(struct kiocb *iocb, struct socket *sock,
+			  struct msghdr *msg, int len, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct llc_opt *llc = llc_sk(sk);
diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	Thu Oct 10 18:27:27 2002
+++ b/net/netlink/af_netlink.c	Thu Oct 10 18:27:27 2002
@@ -570,7 +570,8 @@
 	read_unlock(&nl_table_lock);
 }
 
-static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, int len,
+static int netlink_sendmsg(struct kiocb *iocb, struct socket *sock,
+			   struct msghdr *msg, int len,
 			   struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
@@ -639,7 +640,8 @@
 	return err;
 }
 
-static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, int len,
+static int netlink_recvmsg(struct kiocb *iocb, struct socket *sock,
+			   struct msghdr *msg, int len,
 			   int flags, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Thu Oct 10 18:27:27 2002
+++ b/net/netrom/af_netrom.c	Thu Oct 10 18:27:27 2002
@@ -966,7 +966,8 @@
 	return 1;
 }
 
-static int nr_sendmsg(struct socket *sock, struct msghdr *msg, int len, struct scm_cookie *scm)
+static int nr_sendmsg(struct kiocb *iocb, struct socket *sock,
+		      struct msghdr *msg, int len, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	nr_cb *nr = nr_sk(sk);
@@ -1056,8 +1057,9 @@
 	return len;
 }
 
-static int nr_recvmsg(struct socket *sock, struct msghdr *msg, int size, 
-	int flags, struct scm_cookie *scm)
+static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
+		      struct msghdr *msg, int size, int flags,
+		      struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ax25 *sax = (struct sockaddr_ax25 *)msg->msg_name;
diff -Nru a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c	Thu Oct 10 18:27:27 2002
+++ b/net/packet/af_packet.c	Thu Oct 10 18:27:27 2002
@@ -288,7 +288,8 @@
  *	protocol layers and you must therefore supply it with a complete frame
  */
  
-static int packet_sendmsg_spkt(struct socket *sock, struct msghdr *msg, int len,
+static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
+			       struct msghdr *msg, int len,
 			       struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
@@ -665,8 +666,8 @@
 #endif
 
 
-static int packet_sendmsg(struct socket *sock, struct msghdr *msg, int len,
-			  struct scm_cookie *scm)
+static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
+			  struct msghdr *msg, int len, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ll *saddr=(struct sockaddr_ll *)msg->msg_name;
@@ -1020,7 +1021,8 @@
  *	If necessary we block.
  */
 
-static int packet_recvmsg(struct socket *sock, struct msghdr *msg, int len,
+static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
+			  struct msghdr *msg, int len,
 			  int flags, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	Thu Oct 10 18:27:27 2002
+++ b/net/rose/af_rose.c	Thu Oct 10 18:27:27 2002
@@ -1025,8 +1025,8 @@
 	return 1;
 }
 
-static int rose_sendmsg(struct socket *sock, struct msghdr *msg, int len,
-				struct scm_cookie *scm)
+static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
+			struct msghdr *msg, int len, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	rose_cb *rose = rose_sk(sk);
@@ -1189,8 +1189,9 @@
 }
 
 
-static int rose_recvmsg(struct socket *sock, struct msghdr *msg, int size,
-		   int flags, struct scm_cookie *scm)
+static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
+			struct msghdr *msg, int size, int flags,
+			struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	rose_cb *rose = rose_sk(sk);
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Thu Oct 10 18:27:27 2002
+++ b/net/socket.c	Thu Oct 10 18:27:27 2002
@@ -90,10 +90,10 @@
 #include <linux/netfilter.h>
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
-static ssize_t sock_read(struct file *file, char *buf,
-			 size_t size, loff_t *ppos);
-static ssize_t sock_write(struct file *file, const char *buf,
-			  size_t size, loff_t *ppos);
+static ssize_t sock_aio_read(struct kiocb *iocb, char *buf,
+			 size_t size, loff_t pos);
+static ssize_t sock_aio_write(struct kiocb *iocb, char *buf,
+			  size_t size, loff_t pos);
 static int sock_mmap(struct file *file, struct vm_area_struct * vma);
 
 static int sock_close(struct inode *inode, struct file *file);
@@ -117,8 +117,8 @@
 
 static struct file_operations socket_file_ops = {
 	.llseek =	no_llseek,
-	.read =		sock_read,
-	.write =	sock_write,
+	.aio_read =		sock_aio_read,
+	.aio_write =	sock_aio_write,
 	.poll =		sock_poll,
 	.ioctl =	sock_ioctl,
 	.mmap =		sock_mmap,
@@ -517,64 +517,100 @@
 	sock->file=NULL;
 }
 
-int sock_sendmsg(struct socket *sock, struct msghdr *msg, int size)
+static int __sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int size)
 {
+	struct sock_iocb *si = kiocb_to_siocb(iocb);
 	int err;
-	struct scm_cookie scm;
 
-	err = scm_send(sock, msg, &scm);
+	si->scm = &si->async_scm;
+	si->sock = sock;
+	si->msg = msg;
+	si->size = size;
+
+	err = scm_send(sock, msg, si->scm);
 	if (err >= 0) {
-		err = sock->ops->sendmsg(sock, msg, size, &scm);
-		scm_destroy(&scm);
+		err = sock->ops->sendmsg(iocb, sock, msg, size, si->scm);
+		if (-EIOCBQUEUED != err)
+			scm_destroy(si->scm);
 	}
 	return err;
 }
 
-int sock_recvmsg(struct socket *sock, struct msghdr *msg, int size, int flags)
+int sock_sendmsg(struct socket *sock, struct msghdr *msg, int size)
+{
+	struct kiocb iocb;
+	int ret;
+
+        init_sync_kiocb(&iocb, NULL);
+	ret = __sock_sendmsg(&iocb, sock, msg, size);
+	if (-EIOCBQUEUED == ret)
+		ret = wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
+
+int __sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int size, int flags)
 {
-	struct scm_cookie scm;
+	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
-	memset(&scm, 0, sizeof(scm));
+	si->sock = sock;
+	si->scm = &si->async_scm;
+	si->sock = sock;
+	si->msg = msg;
+	si->size = size;
+	si->flags = flags;
 
-	size = sock->ops->recvmsg(sock, msg, size, flags, &scm);
+	memset(si->scm, 0, sizeof(*si->scm));
+
+	size = sock->ops->recvmsg(iocb, sock, msg, size, flags, si->scm);
 	if (size >= 0)
-		scm_recv(sock, msg, &scm, flags);
+		scm_recv(sock, msg, si->scm, flags);
 
 	return size;
 }
 
+int sock_recvmsg(struct socket *sock, struct msghdr *msg, int size, int flags)
+{
+	struct kiocb iocb;
+	int ret;
+
+        init_sync_kiocb(&iocb, NULL);
+	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
+	if (-EIOCBQUEUED == ret)
+		ret = wait_on_sync_kiocb(&iocb);
+	return ret;
+}
 
 /*
  *	Read data from a socket. ubuf is a user mode pointer. We make sure the user
  *	area ubuf...ubuf+size-1 is writable before asking the protocol.
  */
 
-static ssize_t sock_read(struct file *file, char *ubuf,
-			 size_t size, loff_t *ppos)
+static ssize_t sock_aio_read(struct kiocb *iocb, char *ubuf,
+			 size_t size, loff_t pos)
 {
+	struct sock_iocb *x = kiocb_to_siocb(iocb);
 	struct socket *sock;
-	struct iovec iov;
-	struct msghdr msg;
 	int flags;
 
-	if (ppos != &file->f_pos)
+	if (pos != 0)
 		return -ESPIPE;
 	if (size==0)		/* Match SYS5 behaviour */
 		return 0;
 
-	sock = SOCKET_I(file->f_dentry->d_inode); 
+	sock = SOCKET_I(iocb->ki_filp->f_dentry->d_inode); 
 
-	msg.msg_name=NULL;
-	msg.msg_namelen=0;
-	msg.msg_iov=&iov;
-	msg.msg_iovlen=1;
-	msg.msg_control=NULL;
-	msg.msg_controllen=0;
-	iov.iov_base=ubuf;
-	iov.iov_len=size;
-	flags = !(file->f_flags & O_NONBLOCK) ? 0 : MSG_DONTWAIT;
+	x->async_msg.msg_name = NULL;
+	x->async_msg.msg_namelen = 0;
+	x->async_msg.msg_iov = &x->async_iov;
+	x->async_msg.msg_iovlen = 1;
+	x->async_msg.msg_control = NULL;
+	x->async_msg.msg_controllen = 0;
+	x->async_iov.iov_base = ubuf;
+	x->async_iov.iov_len = size;
+	flags = !(iocb->ki_filp->f_flags & O_NONBLOCK) ? 0 : MSG_DONTWAIT;
 
-	return sock_recvmsg(sock, &msg, size, flags);
+	return __sock_recvmsg(iocb, sock, &x->async_msg, size, flags);
 }
 
 
@@ -583,33 +619,32 @@
  *	is readable by the user process.
  */
 
-static ssize_t sock_write(struct file *file, const char *ubuf,
-			  size_t size, loff_t *ppos)
+static ssize_t sock_aio_write(struct kiocb *iocb, char *ubuf,
+			  size_t size, loff_t pos)
 {
+	struct sock_iocb *x = kiocb_to_siocb(iocb);
 	struct socket *sock;
-	struct msghdr msg;
-	struct iovec iov;
 	
-	if (ppos != &file->f_pos)
+	if (pos != 0)
 		return -ESPIPE;
 	if(size==0)		/* Match SYS5 behaviour */
 		return 0;
 
-	sock = SOCKET_I(file->f_dentry->d_inode); 
+	sock = SOCKET_I(iocb->ki_filp->f_dentry->d_inode); 
 
-	msg.msg_name=NULL;
-	msg.msg_namelen=0;
-	msg.msg_iov=&iov;
-	msg.msg_iovlen=1;
-	msg.msg_control=NULL;
-	msg.msg_controllen=0;
-	msg.msg_flags=!(file->f_flags & O_NONBLOCK) ? 0 : MSG_DONTWAIT;
+	x->async_msg.msg_name = NULL;
+	x->async_msg.msg_namelen = 0;
+	x->async_msg.msg_iov = &x->async_iov;
+	x->async_msg.msg_iovlen = 1;
+	x->async_msg.msg_control = NULL;
+	x->async_msg.msg_controllen = 0;
+	x->async_msg.msg_flags = !(iocb->ki_filp->f_flags & O_NONBLOCK) ? 0 : MSG_DONTWAIT;
 	if (sock->type == SOCK_SEQPACKET)
-		msg.msg_flags |= MSG_EOR;
-	iov.iov_base=(void *)ubuf;
-	iov.iov_len=size;
+		x->async_msg.msg_flags |= MSG_EOR;
+	x->async_iov.iov_base = (void *)ubuf;
+	x->async_iov.iov_len = size;
 	
-	return sock_sendmsg(sock, &msg, size);
+	return __sock_sendmsg(iocb, sock, &x->async_msg, size);
 }
 
 ssize_t sock_sendpage(struct file *file, struct page *page,
diff -Nru a/net/unix/af_unix.c b/net/unix/af_unix.c
--- a/net/unix/af_unix.c	Thu Oct 10 18:27:27 2002
+++ b/net/unix/af_unix.c	Thu Oct 10 18:27:27 2002
@@ -1175,7 +1175,8 @@
  *	Send AF_UNIX data.
  */
 
-static int unix_dgram_sendmsg(struct socket *sock, struct msghdr *msg, int len,
+static int unix_dgram_sendmsg(struct kiocb *iocb, struct socket *sock,
+			      struct msghdr *msg, int len,
 			      struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
@@ -1307,7 +1308,8 @@
 }
 
 		
-static int unix_stream_sendmsg(struct socket *sock, struct msghdr *msg, int len,
+static int unix_stream_sendmsg(struct kiocb *iocb, struct socket *sock,
+			       struct msghdr *msg, int len,
 			       struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
@@ -1415,7 +1417,8 @@
 	}
 }
 
-static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg, int size,
+static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
+			      struct msghdr *msg, int size,
 			      int flags, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
@@ -1517,7 +1520,8 @@
 
 
 
-static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg, int size,
+static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
+			       struct msghdr *msg, int size,
 			       int flags, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
diff -Nru a/net/wanrouter/af_wanpipe.c b/net/wanrouter/af_wanpipe.c
--- a/net/wanrouter/af_wanpipe.c	Thu Oct 10 18:27:27 2002
+++ b/net/wanrouter/af_wanpipe.c	Thu Oct 10 18:27:27 2002
@@ -540,8 +540,8 @@
  *      a packet is queued into sk->write_queue.
  *===========================================================*/
 
-static int wanpipe_sendmsg(struct socket *sock, struct msghdr *msg, int len,
-			  struct scm_cookie *scm)
+static int wanpipe_sendmsg(struct kiocb *iocb, struct socket *sock,
+			   struct msghdr *msg, int len, struct scm_cookie *scm)
 {
 	wanpipe_opt *wp;
 	struct sock *sk = sock->sk;
@@ -1647,8 +1647,9 @@
  *      to the user. If necessary we block.
  *===========================================================*/
 
-static int wanpipe_recvmsg(struct socket *sock, struct msghdr *msg, int len,
-			  int flags, struct scm_cookie *scm)
+static int wanpipe_recvmsg(struct kiocb *iocb, struct socket *sock,
+			   struct msghdr *msg, int len, int flags,
+			   struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff -Nru a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	Thu Oct 10 18:27:27 2002
+++ b/net/x25/af_x25.c	Thu Oct 10 18:27:27 2002
@@ -916,8 +916,8 @@
 	goto out;
 }
 
-static int x25_sendmsg(struct socket *sock, struct msghdr *msg, int len,
-		       struct scm_cookie *scm)
+static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
+		       struct msghdr *msg, int len, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
 	struct x25_opt *x25 = x25_sk(sk);
@@ -1091,7 +1091,8 @@
 }
 
 
-static int x25_recvmsg(struct socket *sock, struct msghdr *msg, int size,
+static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
+		       struct msghdr *msg, int size,
 		       int flags, struct scm_cookie *scm)
 {
 	struct sock *sk = sock->sk;
