From: Benjamin LaHaise <bcrl@redhat.com>
Subject: [patch/bk] remove scm_cookie parameter to send/recvmsg
Date: Mon, 20 Jan 2003 16:17:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030120161755.B23890@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hey Dave, please do a

	bk pull kernel.bkbits.net:/bcrl/net-2.5

The changeset removes the struct scm_cookie * from the esnd/recvmsg ops, 
as well as removing the struct from the sock_iocb.  This helps speed up 
tcp_bw in LMbench by elimnating the excess memset and credentials setup 
and teardown.  Cheers,

		-ben

This will update the following files:

 arch/ia64/ia32/sys_ia32.c         |    5 +-
 arch/parisc/kernel/sys_parisc32.c |    6 ++-
 arch/ppc64/kernel/sys_ppc32.c     |    6 ++-
 arch/s390x/kernel/linux32.c       |   11 +++--
 arch/sparc64/kernel/sys_sparc32.c |    5 +-
 arch/x86_64/ia32/socket32.c       |    5 +-
 drivers/net/pppoe.c               |    7 ++-
 fs/smbfs/sock.c                   |   72 ++----------------------------------
 include/linux/net.h               |   15 +++----
 include/net/bluetooth/bluetooth.h |    2 -
 include/net/inet_common.h         |    4 +-
 include/net/sock.h                |    9 +---
 net/appletalk/ddp.c               |    4 +-
 net/atm/common.c                  |    4 +-
 net/atm/common.h                  |    4 +-
 net/ax25/af_ax25.c                |    5 +-
 net/bluetooth/af_bluetooth.c      |    2 -
 net/bluetooth/bnep/core.c         |   29 +-------------
 net/bluetooth/hci_sock.c          |    5 +-
 net/bluetooth/l2cap.c             |    2 -
 net/bluetooth/rfcomm/core.c       |   31 +--------------
 net/bluetooth/rfcomm/sock.c       |    5 +-
 net/bluetooth/sco.c               |    2 -
 net/core/sock.c                   |    4 +-
 net/decnet/af_decnet.c            |    4 +-
 net/econet/af_econet.c            |    5 +-
 net/ipv4/af_inet.c                |    4 +-
 net/ipx/af_ipx.c                  |    4 +-
 net/irda/af_irda.c                |   22 +++++------
 net/key/af_key.c                  |    5 +-
 net/llc/af_llc.c                  |    7 +--
 net/netlink/af_netlink.c          |   29 +++++++++++---
 net/netrom/af_netrom.c            |    5 +-
 net/packet/af_packet.c            |    8 +---
 net/rose/af_rose.c                |    5 +-
 net/socket.c                      |   27 +++----------
 net/unix/af_unix.c                |   74 ++++++++++++++++++++++++++------------
 net/wanrouter/af_wanpipe.c        |    5 +-
 net/x25/af_x25.c                  |    4 +-
 39 files changed, 178 insertions(+), 274 deletions(-)

through these ChangeSets:

<bcrl@redhat.com> (03/01/20 1.946.1.1)
   Remove struct scm_cookie * from socket send/recvmsg() ops.  Credentials 
   are only used by af_unix and af_netlink anyways, so by only using them 
   in those paths we eliminate overhead from all other network protocols' 
   fastpaths.


through these patches:

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.946   -> 1.946.1.1
#	    net/llc/af_llc.c	1.32    -> 1.33   
#	net/bluetooth/rfcomm/core.c	1.8     -> 1.9    
#	arch/x86_64/ia32/socket32.c	1.3     -> 1.4    
#	  net/ipv4/af_inet.c	1.37    -> 1.38   
#	    net/ipx/af_ipx.c	1.22    -> 1.23   
#	net/bluetooth/af_bluetooth.c	1.11    -> 1.12   
#	 net/bluetooth/sco.c	1.8     -> 1.9    
#	    net/key/af_key.c	1.12    -> 1.13   
#	  net/irda/af_irda.c	1.35    -> 1.36   
#	arch/parisc/kernel/sys_parisc32.c	1.5     -> 1.6    
#	        net/socket.c	1.41    -> 1.42   
#	     fs/smbfs/sock.c	1.13    -> 1.14   
#	 include/linux/net.h	1.7     -> 1.8    
#	include/net/bluetooth/bluetooth.h	1.10    -> 1.11   
#	net/econet/af_econet.c	1.12    -> 1.13   
#	net/netrom/af_netrom.c	1.21    -> 1.22   
#	  net/rose/af_rose.c	1.18    -> 1.19   
#	net/netlink/af_netlink.c	1.15    -> 1.16   
#	net/decnet/af_decnet.c	1.20    -> 1.21   
#	net/bluetooth/hci_sock.c	1.14    -> 1.15   
#	arch/ia64/ia32/sys_ia32.c	1.36    -> 1.37   
#	  net/unix/af_unix.c	1.34    -> 1.35   
#	arch/sparc64/kernel/sys_sparc32.c	1.59    -> 1.60   
#	 drivers/net/pppoe.c	1.20    -> 1.21   
#	net/bluetooth/rfcomm/sock.c	1.9     -> 1.10   
#	net/packet/af_packet.c	1.18    -> 1.19   
#	net/bluetooth/bnep/core.c	1.9     -> 1.10   
#	net/bluetooth/l2cap.c	1.13    -> 1.14   
#	arch/ppc64/kernel/sys_ppc32.c	1.44    -> 1.45   
#	arch/s390x/kernel/linux32.c	1.33    -> 1.34   
#	  include/net/sock.h	1.29    -> 1.30   
#	     net/core/sock.c	1.14    -> 1.15   
#	include/net/inet_common.h	1.4     -> 1.5    
#	    net/atm/common.h	1.2     -> 1.3    
#	  net/ax25/af_ax25.c	1.17    -> 1.18   
#	    net/x25/af_x25.c	1.21    -> 1.22   
#	net/wanrouter/af_wanpipe.c	1.13    -> 1.14   
#	 net/appletalk/ddp.c	1.16    -> 1.17   
#	    net/atm/common.c	1.11    -> 1.12   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/01/16	ink@jurassic.park.msu.ru	1.944.1.1
# [PATCH] alpha PCI setup update
# 
# Until now, we were configuring all PCI resources from scratch.
# This patch allows to use unchanged PCI setup on platforms
# where the firmware does it reasonably well (titan and marvel).
# 
# [The patch to setup-bus.c that removes "FIXME" from here (ie makes
# pci_assign_unassigned_resources to match its name) exists at least
# for two months, but I've yet to convince Linus that it does the
# right thing...]
# 
# Ivan.
# --------------------------------------------
# 03/01/16	ink@jurassic.park.msu.ru	1.944.1.2
# [PATCH] alpha_remap_area_pages
# From Jeff.Wiedemeier@hp.com:
# 
# Add arch/alpha/mm/remap.c (__alpha_remap_area_pages).
# --------------------------------------------
# 03/01/16	ink@jurassic.park.msu.ru	1.944.1.3
# [PATCH] alpha titan update
# From Jeff.Wiedemeier@hp.com:
# 
# Update titan system support include AlphaServer DS25, AGP,
# enhanced machine check handling.
# --------------------------------------------
# 03/01/16	torvalds@home.transmeta.com	1.947
# Merge http://linux-voyager.bkbits.net/eisa-sysfs-2.5
# into home.transmeta.com:/home/torvalds/v2.5/linux
# --------------------------------------------
# 03/01/16	rth@kanga.twiddle.net	1.944.1.4
# [ALPHA] Use direct calls to titan_ioremap/unmap when building
# a titan specific kernel.
# --------------------------------------------
# 03/01/16	ink@jurassic.park.msu.ru	1.944.1.5
# [PATCH] alpha irq proc update
# From Jeff.Wiedemeier@hp.com:
# 
# - Only create smp_affinity /proc nodes if a set_affinity handler
#   is provided.
# - Limit the number of irq nodes that will be created in /proc
#   to avoid overfilling the /proc inode space.
# --------------------------------------------
# 03/01/16	ink@jurassic.park.msu.ru	1.944.1.6
# [PATCH] alpha smp callin
# From Jeff.Wiedemeier@hp.com:
# 
# Add platform-specific callin for SMP.
# --------------------------------------------
# 03/01/16	ak@muc.de	1.948
# [PATCH] x86_64 update
# 
# x86-64 updates for 2.5.58. Changes only x86-64 specific files.
# 
#  - Rewrote module allocation. Lots of bugs fixed. Module loading
#    should work now again.
#  - Kconfig help fixes from Randy Dunlap
#  - Makefile cleanups from Pavel Machek and Sam Ravnborg
#  - Assembly cleanups from Pavel
#  - defconfig update
#  - Better strlen_user/strnlen_user
#  - Merge with i386: new ptrace commands, 32bit vsyscall signal trampolines
# 		new deactivate_mm, add asm/bug.h
#  - Make sure initramfs is freed after booting (thanks to Kai for the hint)
#  - User per cpu data for profile counters (Ravikiran Thirumalai)
#  - 32bit compat_* updates from Stephen Rothwell
#  - Fix race in context switch. The exception handler for bogus segment
#    loads in __switch_to needs to keep interrupts disabled, otherwise an
#    interrupt can deadlock on scheduler locks.  Also make sure they don't
#    printk or set oops_in_progress during printk because printk does a
#    wake_up too.
#  - Disable 64bit GS base changes for processes.  I cannot get it to work
#    reliably.
#  - Clear IOPL on kernel entry
# --------------------------------------------
# 03/01/16	hch@sgi.com	1.949
# [PATCH] remove MOD_IN_USE
# 
# Another left-over from ancient module code, it was supposed to return
# non-zero if the module has a use count, but currently it always
# evaluates to 0.
# 
# There are a few users of different types:
# (1)  ioctl that perform a while(MOD_IN_USE) MOD_DEC_USE_COUNT loop.
#      Just rip them out, we now have forced module unloading.
# (2)  printk's that moan if the use-count in not zero in the exitfunc.
#      Just rip them out, this can't happen.
# (3)  if(MOD_IN_USE) MOD_DEC_USE_COUNT constructs in ->close of a few
#      serial drivers.  Just remove the conditional, we did a
#      MOD_INC_USE_COUNT in ->open.
# (4)  This one is interesting:  drivers/sbus/char/display7seg.c uses
#      the module use count to track openers.  Replace this with an
#      atomic_t.
# 
# In addition remove tons of stale comments in network driver that aren't
# understandable for anyone who doesn't know ancient Linux module semantics.
# --------------------------------------------
# 03/01/16	mbligh@aracnet.com	1.950
# [PATCH] (1/3) Minimal NUMA scheduler
# 
# Patch from Martin J. Bligh
# 
# This adds a small hook to the find_busiest_queue routine to allow us to
# specify a mask of which CPUs to search over. In the NUMA case, it will
# only balance inside the node (much cheaper to search, and stops tasks
# from bouncing across nodes, which is very costly). The cpus_to_balance
# routine is conditionally defined to ensure no impact to non-NUMA machines.
# 
# This is a tiny NUMA scheduler, but it needs the assistance of the second
# and third patches in order to spread tasks across nodes.
# --------------------------------------------
# 03/01/16	mbligh@aracnet.com	1.951
# [PATCH] (2/3) Initial load balancing
# 
# Patch from Michael Hohnbaum
# 
# This adds a hook, sched_balance_exec(), to the exec code, to make it
# place the exec'ed task on the least loaded queue. We have less state
# to move at exec time than fork time, so this is the cheapest point
# to cross-node migrate. Experience in Dynix/PTX and testing on Linux
# has confirmed that this is the cheapest time to move tasks between nodes.
# 
# It also macro-wraps changes to nr_running, to allow us to keep track of
# per-node nr_running as well. Again, no impact on non-NUMA machines.
# --------------------------------------------
# 03/01/16	mbligh@aracnet.com	1.952
# [PATCH] (3/3) NUMA rebalancer
# 
# Patch from Erich Focht
# 
# This adds a hook to rebalance globally across nodes every NODE_BALANCE_RATE
# iterations of the rebalancer. This allows us to easily tune on an architecture
# specific basis how often we wish to rebalance - machines with higher NUMA
# ratios (more expensive off-node access) will want to do this less often.
# It's currently set to 100 for NUMA-Q and 10 for other machines. If the
# imbalance between nodes is > 125%, we'll rebalance them. The hook for this
# is added to the NUMA definition of cpus_to_balance, so again, no impact
# on non-NUMA machines.
# --------------------------------------------
# 03/01/16	rth@kanga.twiddle.net	1.944.1.7
# [ALPHA] AGP infrastructure for AGP implemented in Alpha corelogic
# (Titan / Marvel), Kconfig and headers.
# 
# From Jeff Wiedemeier.
# --------------------------------------------
# 03/01/16	rth@kanga.twiddle.net	1.944.1.8
# [ALPHA] Marvel (AlphaServer ES47, ES80, GS1280) support.
# From Jeff.Wiedemeier@hp.com.
# --------------------------------------------
# 03/01/16	rth@kanga.twiddle.net	1.944.1.9
# [ALPHA] Fixups to Marvel and Titan for incomplete merging
# of AGP and SRMCONS patches.
# --------------------------------------------
# 03/01/16	rth@kanga.twiddle.net	1.944.1.10
# [ALPHA] Formatting cleanup, warning removal, move declarations
# to header files where they belong.
# --------------------------------------------
# 03/01/16	rth@kanga.twiddle.net	1.944.1.11
# [ALPHA] Correct io.h exports and inlining for marvel and titan.
# --------------------------------------------
# 03/01/16	rth@kanga.twiddle.net	1.953
# Merge kanga.twiddle.net:/home/rth/linux/linus-2.5
# into kanga.twiddle.net:/home/rth/linux/axp-2.5
# --------------------------------------------
# 03/01/16	Jeff.Wiedemeier@hp.com	1.954
# [PATCH] Fix marvel irq count computation.
# 
# Found a buglet in the marvel code -- doesn't change the number of IRQS
# just the logic to get there.. This applies on top of the other marvel
# code.
# 
# /jeff
# --------------------------------------------
# 03/01/16	torvalds@home.transmeta.com	1.955
# Merge bk://bk.arm.linux.org.uk
# into home.transmeta.com:/home/torvalds/v2.5/linux
# --------------------------------------------
# 03/01/16	torvalds@penguin.transmeta.com	1.956
# Linux v2.5.59
# --------------------------------------------
# 03/01/20	bcrl@redhat.com	1.946.1.1
# Remove struct scm_cookie * from socket send/recvmsg() ops.  Credentials 
# are only used by af_unix and af_netlink anyways, so by only using them 
# in those paths we eliminate overhead from all other network protocols' 
# fastpaths.
# --------------------------------------------
#
diff -Nru a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
--- a/arch/ia64/ia32/sys_ia32.c	Mon Jan 20 16:00:08 2003
+++ b/arch/ia64/ia32/sys_ia32.c	Mon Jan 20 16:00:08 2003
@@ -1649,20 +1649,21 @@
 	/* XXX This code needs massive updating... -DaveM */
 	lock_kernel();
 	{
+		struct scm_cookie scm;
 		struct sock_iocb *si;
 		struct kiocb iocb;
 
 		init_sync_kiocb(&iocb, NULL);
 		si = kiocb_to_siocb(&iocb);
 		si->sock = sock;
-		si->scm = &si->async_scm;
+		si->scm = &scm;
 		si->msg = &msg_sys;
 		si->size = total_len;
 		si->flags = flags;
 		memset(si->scm, 0, sizeof(*si->scm));
 
 		err = sock->ops->recvmsg(&iocb, sock, &msg_sys, total_len,
-					 flags, si->scm);
+					 flags);
 		if (-EIOCBQUEUED == err)
 			err = wait_on_sync_kiocb(&iocb);
 
diff -Nru a/arch/parisc/kernel/sys_parisc32.c b/arch/parisc/kernel/sys_parisc32.c
--- a/arch/parisc/kernel/sys_parisc32.c	Mon Jan 20 16:00:07 2003
+++ b/arch/parisc/kernel/sys_parisc32.c	Mon Jan 20 16:00:07 2003
@@ -1600,21 +1600,23 @@
 	if (sock != NULL) {
 		struct sock_iocb *si;
 		struct kiocb iocb;
+		struct scm_cookie scm;
 
 		if (sock->file->f_flags & O_NONBLOCK)
 			user_flags |= MSG_DONTWAIT;
 
+		memset(&scm, 0, sizeof(scm));
 		init_sync_kiocb(&iocb, NULL);
 		si = kiocb_to_siocb(&iocb);
 		si->sock = sock;
-		si->scm = &si->async_scm;
+		si->scm = &scm;
 		si->msg = &kern_msg;
 		si->size = total_len;
 		si->flags = user_flags;
 		memset(si->scm, 0, sizeof(*si->scm));
 
 		err = sock->ops->recvmsg(&iocb, sock, &kern_msg, total_len,
-					 user_flags, si->scm);
+					 user_flags);
 		if (-EIOCBQUEUED == err)
 			err = wait_on_sync_kiocb(&iocb);
 
diff -Nru a/arch/ppc64/kernel/sys_ppc32.c b/arch/ppc64/kernel/sys_ppc32.c
--- a/arch/ppc64/kernel/sys_ppc32.c	Mon Jan 20 16:00:08 2003
+++ b/arch/ppc64/kernel/sys_ppc32.c	Mon Jan 20 16:00:08 2003
@@ -2833,21 +2833,23 @@
 	if (sock != NULL) {
 		struct sock_iocb *si;
 		struct kiocb iocb;
+		struct scm_cookie scm;
 
 		if (sock->file->f_flags & O_NONBLOCK)
 			user_flags |= MSG_DONTWAIT;
 
+		memset(&scm, 0, sizeof(scm));
 		init_sync_kiocb(&iocb, NULL);
 		si = kiocb_to_siocb(&iocb);
 		si->sock = sock;
-		si->scm = &si->async_scm;
+		si->scm = &scm;
 		si->msg = &kern_msg;
 		si->size = total_len;
 		si->flags = user_flags;
 		memset(si->scm, 0, sizeof(*si->scm));
 
 		err = sock->ops->recvmsg(&iocb, sock, &kern_msg, total_len,
-					 user_flags, si->scm);
+					 user_flags);
 		if (-EIOCBQUEUED == err)
 			err = wait_on_sync_kiocb(&iocb);
 
diff -Nru a/arch/s390x/kernel/linux32.c b/arch/s390x/kernel/linux32.c
--- a/arch/s390x/kernel/linux32.c	Mon Jan 20 16:00:08 2003
+++ b/arch/s390x/kernel/linux32.c	Mon Jan 20 16:00:08 2003
@@ -2390,24 +2390,25 @@
 {
 	struct sock_iocb *si;
 	struct kiocb iocb;
+	struct scm_cookie scm;
 
 	init_sync_kiocb(&iocb, NULL);
 
 	si = kiocb_to_siocb(&iocb);
 	si->sock = sock;
-	si->scm = &si->async_scm;
+	si->scm = &scm;
 	si->msg = msg;
 	si->size = size;
 	si->flags = flags;
 
 	memset(si->scm, 0, sizeof(*si->scm));
 
-	size = sock->ops->recvmsg(&iocb, sock, msg, size, flags, si->scm);
-	if (size >= 0)
-		scm_recv32(sock, msg, si->scm, flags, cmsg_ptr);
-
+	size = sock->ops->recvmsg(&iocb, sock, msg, size, flags);
 	if (-EIOCBQUEUED == size)
 		size = wait_on_sync_kiocb(&iocb);
+
+	if (size >= 0)
+		scm_recv32(sock, msg, si->scm, flags, cmsg_ptr);
 
 	return size;
 }
diff -Nru a/arch/sparc64/kernel/sys_sparc32.c b/arch/sparc64/kernel/sys_sparc32.c
--- a/arch/sparc64/kernel/sys_sparc32.c	Mon Jan 20 16:00:08 2003
+++ b/arch/sparc64/kernel/sys_sparc32.c	Mon Jan 20 16:00:08 2003
@@ -2421,6 +2421,7 @@
 	if (sock != NULL) {
 		struct sock_iocb *si;
 		struct kiocb iocb;
+		struct scm_cookie scm;
 
 		if (sock->file->f_flags & O_NONBLOCK)
 			user_flags |= MSG_DONTWAIT;
@@ -2428,14 +2429,14 @@
 		init_sync_kiocb(&iocb, NULL);
 		si = kiocb_to_siocb(&iocb);
 		si->sock = sock;
-		si->scm = &si->async_scm;
+		si->scm = &scm;
 		si->msg = &kern_msg;
 		si->size = total_len;
 		si->flags = user_flags;
 		memset(si->scm, 0, sizeof(*si->scm));
 
 		err = sock->ops->recvmsg(&iocb, sock, &kern_msg, total_len,
-					 user_flags, si->scm);
+					 user_flags);
 		if (-EIOCBQUEUED == err)
 			err = wait_on_sync_kiocb(&iocb);
 
diff -Nru a/arch/x86_64/ia32/socket32.c b/arch/x86_64/ia32/socket32.c
--- a/arch/x86_64/ia32/socket32.c	Mon Jan 20 16:00:07 2003
+++ b/arch/x86_64/ia32/socket32.c	Mon Jan 20 16:00:07 2003
@@ -442,6 +442,7 @@
 	if (sock != NULL) {
 		struct sock_iocb *si;
 		struct kiocb iocb;
+		struct scm_cookie scm;
 
 		if (sock->file->f_flags & O_NONBLOCK)
 			user_flags |= MSG_DONTWAIT;
@@ -449,14 +450,14 @@
 		init_sync_kiocb(&iocb, NULL);
 		si = kiocb_to_siocb(&iocb);
 		si->sock = sock;
-		si->scm = &si->async_scm;
+		si->scm = &scm;
 		si->msg = &kern_msg;
 		si->size = total_len;
 		si->flags = user_flags;
 		memset(si->scm, 0, sizeof(*si->scm));
 
 		err = sock->ops->recvmsg(&iocb, sock, &kern_msg, total_len,
-					 user_flags, si->scm);
+					 user_flags);
 		if (-EIOCBQUEUED == err)
 			err = wait_on_sync_kiocb(&iocb);
 
diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	Mon Jan 20 16:00:08 2003
+++ b/drivers/net/pppoe.c	Mon Jan 20 16:00:08 2003
@@ -777,7 +777,7 @@
 
 
 int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		  int total_len, struct scm_cookie *scm)
+		  int total_len)
 {
 	struct sk_buff *skb = NULL;
 	struct sock *sk = sock->sk;
@@ -937,7 +937,8 @@
 
 struct ppp_channel_ops pppoe_chan_ops = { pppoe_xmit , NULL };
 
-int pppoe_rcvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m, int total_len, int flags, struct scm_cookie *scm)
+int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
+		  struct msghdr *m, int total_len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb = NULL;
@@ -1089,7 +1090,7 @@
     .setsockopt		= sock_no_setsockopt,
     .getsockopt		= sock_no_getsockopt,
     .sendmsg		= pppoe_sendmsg,
-    .recvmsg		= pppoe_rcvmsg,
+    .recvmsg		= pppoe_recvmsg,
     .mmap		= sock_no_mmap
 };
 
diff -Nru a/fs/smbfs/sock.c b/fs/smbfs/sock.c
--- a/fs/smbfs/sock.c	Mon Jan 20 16:00:07 2003
+++ b/fs/smbfs/sock.c	Mon Jan 20 16:00:07 2003
@@ -41,8 +41,6 @@
 {
 	struct iovec iov;
 	struct msghdr msg;
-	struct kiocb iocb;
-	struct sock_iocb *si;
 	mm_segment_t fs;
 
 	fs = get_fs();
@@ -58,21 +56,7 @@
 	iov.iov_base = ubuf;
 	iov.iov_len = size;
 
-	init_sync_kiocb(&iocb, NULL);
-	si = kiocb_to_siocb(&iocb);
-	si->sock = socket;
-	si->scm = &si->async_scm;
-	si->msg = &msg;
-	si->size = size;
-	si->flags = flags;
-
-	memset(si->scm, 0, sizeof(*si->scm));
-
-	size = socket->ops->recvmsg(&iocb, socket, &msg, size, flags, si->scm);
-	if (size >= 0)
-		scm_recv(socket, &msg, si->scm, flags);
-	if (-EIOCBQUEUED == size)
-		size = wait_on_sync_kiocb(&iocb);
+	size = sock_recvmsg(socket, &msg, size, flags);
 
 	set_fs(fs);
 	return size;
@@ -299,8 +283,6 @@
 	unsigned int flags;
 	struct iovec iov;
 	struct msghdr msg;
-	struct kiocb iocb;
-	struct sock_iocb *si;
 	mm_segment_t fs;
 	int rlen = smb_len(server->header) - server->smb_read + 4;
 	int result = -EIO;
@@ -327,21 +309,7 @@
 	if (rlen > PAGE_SIZE)
 		rlen = PAGE_SIZE;
 
-	init_sync_kiocb(&iocb, NULL);
-	si = kiocb_to_siocb(&iocb);
-	si->sock = sock;
-	si->scm = &si->async_scm;
-	si->msg = &msg;
-	si->size = rlen;
-	si->flags = flags;
-
-	memset(si->scm, 0, sizeof(*si->scm));
-
-	result = sock->ops->recvmsg(&iocb, sock, &msg, rlen, flags, si->scm);
-	if (result >= 0)
-		scm_recv(sock, &msg, si->scm, flags);
-	if (-EIOCBQUEUED == result)
-		result = wait_on_sync_kiocb(&iocb);
+	result = sock_recvmsg(sock, &msg, rlen, flags);
 
 	set_fs(fs);
 
@@ -370,8 +338,6 @@
 	unsigned int flags;
 	struct iovec iov[4];
 	struct msghdr msg;
-	struct kiocb iocb;
-	struct sock_iocb *si;
 	mm_segment_t fs;
 	int rlen;
 	int result = -EIO;
@@ -398,21 +364,7 @@
 	if (req->rq_rlen < rlen)
 		rlen = req->rq_rlen;
 
-	init_sync_kiocb(&iocb, NULL);
-	si = kiocb_to_siocb(&iocb);
-	si->sock = sock;
-	si->scm = &si->async_scm;
-	si->msg = &msg;
-	si->size = rlen;
-	si->flags = flags;
-
-	memset(si->scm, 0, sizeof(*si->scm));
-
-	result = sock->ops->recvmsg(&iocb, sock, &msg, rlen, flags, si->scm);
-	if (result >= 0)
-		scm_recv(sock, &msg, si->scm, flags);
-	if (-EIOCBQUEUED == result)
-		result = wait_on_sync_kiocb(&iocb);
+	result = sock_recvmsg(sock, &msg, rlen, flags);
 
 	set_fs(fs);
 
@@ -440,8 +392,6 @@
 	mm_segment_t fs;
 	struct smb_sb_info *server = req->rq_server;
 	struct socket *sock;
-	struct kiocb iocb;
-	struct sock_iocb *si;
 	struct msghdr msg;
         int slen = req->rq_slen - req->rq_bytes_sent;
 	int result = -EIO;
@@ -465,23 +415,9 @@
 	if (req->rq_bytes_sent)
 		smb_move_iov(&msg, iov, req->rq_bytes_sent);
 
-	init_sync_kiocb(&iocb, NULL);
-	si = kiocb_to_siocb(&iocb);
-	si->scm = &si->async_scm;
-	si->sock = sock;
-	si->msg = &msg;
-	si->size = slen;
-
 	fs = get_fs();
 	set_fs(get_ds());
-	result = scm_send(sock, &msg, si->scm);
-	if (result >= 0) {
-		result = sock->ops->sendmsg(&iocb, sock, &msg, slen, si->scm);
-		if (-EIOCBQUEUED != result)
-			scm_destroy(si->scm);
-	}
-	if (-EIOCBQUEUED == result)
-		result = wait_on_sync_kiocb(&iocb);
+	result = sock_sendmsg(sock, &msg, slen);
 	set_fs(fs);
 
 	if (result >= 0) {
diff -Nru a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h	Mon Jan 20 16:00:07 2003
+++ b/include/linux/net.h	Mon Jan 20 16:00:07 2003
@@ -78,7 +78,6 @@
 	unsigned char		passcred;
 };
 
-struct scm_cookie;
 struct vm_area_struct;
 struct page;
 struct kiocb;
@@ -106,11 +105,9 @@
   int	(*getsockopt)	(struct socket *sock, int level, int optname,
 			 char *optval, int *optlen);
   int   (*sendmsg)	(struct kiocb *iocb, struct socket *sock,
-			 struct msghdr *m, int total_len,
-			 struct scm_cookie *scm);
+			 struct msghdr *m, int total_len);
   int   (*recvmsg)	(struct kiocb *iocb, struct socket *sock,
-			 struct msghdr *m, int total_len, int flags,
-			 struct scm_cookie *scm);
+			 struct msghdr *m, int total_len, int flags);
   int	(*mmap)		(struct file *file, struct socket *sock, struct vm_area_struct * vma);
   ssize_t (*sendpage)	(struct socket *sock, struct page *page, int offset, size_t size, int flags);
 };
@@ -202,10 +199,10 @@
 			 char *optval, int optlen), (sock, level, optname, optval, optlen)) \
 SOCKCALL_WRAP(name, getsockopt, (struct socket *sock, int level, int optname, \
 			 char *optval, int *optlen), (sock, level, optname, optval, optlen)) \
-SOCKCALL_WRAP(name, sendmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, int len, struct scm_cookie *scm), \
-	      (iocb, sock, m, len, scm)) \
-SOCKCALL_WRAP(name, recvmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, int len, int flags, struct scm_cookie *scm), \
-	      (iocb, sock, m, len, flags, scm)) \
+SOCKCALL_WRAP(name, sendmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, int len), \
+	      (iocb, sock, m, len)) \
+SOCKCALL_WRAP(name, recvmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, int len, int flags), \
+	      (iocb, sock, m, len, flags)) \
 SOCKCALL_WRAP(name, mmap, (struct file *file, struct socket *sock, struct vm_area_struct *vma), \
 	      (file, sock, vma)) \
 	      \
diff -Nru a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
--- a/include/net/bluetooth/bluetooth.h	Mon Jan 20 16:00:07 2003
+++ b/include/net/bluetooth/bluetooth.h	Mon Jan 20 16:00:07 2003
@@ -128,7 +128,7 @@
 struct sock *bt_sock_alloc(struct socket *sock, int proto, int pi_size, int prio);
 void bt_sock_link(struct bt_sock_list *l, struct sock *s);
 void bt_sock_unlink(struct bt_sock_list *l, struct sock *s);
-int  bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len, int flags, struct scm_cookie *scm);
+int  bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len, int flags);
 uint bt_sock_poll(struct file * file, struct socket *sock, poll_table *wait);
 int  bt_sock_w4_connect(struct sock *sk, int flags);
 
diff -Nru a/include/net/inet_common.h b/include/net/inet_common.h
--- a/include/net/inet_common.h	Mon Jan 20 16:00:08 2003
+++ b/include/net/inet_common.h	Mon Jan 20 16:00:08 2003
@@ -23,11 +23,11 @@
 extern int			inet_recvmsg(struct kiocb *iocb,
 					     struct socket *sock, 
 					     struct msghdr *ubuf, 
-					     int size, int flags, struct scm_cookie *scm);
+					     int size, int flags);
 extern int			inet_sendmsg(struct kiocb *iocb,
 					     struct socket *sock, 
 					     struct msghdr *msg, 
-					     int size, struct scm_cookie *scm);
+					     int size);
 extern int			inet_shutdown(struct socket *sock, int how);
 extern unsigned int		inet_poll(struct file * file, struct socket *sock, struct poll_table_struct *wait);
 extern int			inet_setsockopt(struct socket *sock, int level,
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	Mon Jan 20 16:00:08 2003
+++ b/include/net/sock.h	Mon Jan 20 16:00:08 2003
@@ -51,7 +51,6 @@
 
 #include <asm/atomic.h>
 #include <net/dst.h>
-#include <net/scm.h>
 
 /*
  * This structure really needs to be cleaned up.
@@ -305,9 +304,9 @@
 	int			size;
 	struct socket		*sock;
 	struct sock		*sk;
+	struct scm_cookie	*scm;
 	struct msghdr		*msg, async_msg;
 	struct iovec		async_iov;
-	struct scm_cookie	*scm, async_scm;
 };
 
 static inline struct sock_iocb *kiocb_to_siocb(struct kiocb *iocb)
@@ -433,11 +432,9 @@
 extern int			sock_no_setsockopt(struct socket *, int, int,
 						   char *, int);
 extern int                      sock_no_sendmsg(struct kiocb *, struct socket *,
-						struct msghdr *, int,
-						struct scm_cookie *);
+						struct msghdr *, int);
 extern int                      sock_no_recvmsg(struct kiocb *, struct socket *,
-						struct msghdr *, int, int,
-						struct scm_cookie *);
+						struct msghdr *, int, int);
 extern int			sock_no_mmap(struct file *file,
 					     struct socket *sock,
 					     struct vm_area_struct *vma);
diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Mon Jan 20 16:00:08 2003
+++ b/net/appletalk/ddp.c	Mon Jan 20 16:00:08 2003
@@ -1492,7 +1492,7 @@
 }
 
 static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-			 int len, struct scm_cookie *scm)
+			 int len)
 {
 	struct sock *sk = sock->sk;
 	struct atalk_sock *at = at_sk(sk);
@@ -1651,7 +1651,7 @@
 }
 
 static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-			 int size, int flags, struct scm_cookie *scm)
+			 int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_at *sat = (struct sockaddr_at *)msg->msg_name;
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jan 20 16:00:08 2003
+++ b/net/atm/common.c	Mon Jan 20 16:00:08 2003
@@ -337,7 +337,7 @@
 
 
 int atm_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		int total_len, int flags, struct scm_cookie *scm)
+		int total_len, int flags)
 {
 	DECLARE_WAITQUEUE(wait,current);
 	struct atm_vcc *vcc;
@@ -418,7 +418,7 @@
 
 
 int atm_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		int total_len, struct scm_cookie *scm)
+		int total_len)
 {
 	DECLARE_WAITQUEUE(wait,current);
 	struct atm_vcc *vcc;
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Jan 20 16:00:08 2003
+++ b/net/atm/common.h	Mon Jan 20 16:00:08 2003
@@ -14,9 +14,9 @@
 int atm_release(struct socket *sock);
 int atm_connect(struct socket *sock,int itf,short vpi,int vci);
 int atm_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		int total_len, int flags, struct scm_cookie *scm);
+		int total_len, int flags);
 int atm_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		int total_len, struct scm_cookie *scm);
+		int total_len);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
 int atm_ioctl(struct socket *sock,unsigned int cmd,unsigned long arg);
 int atm_setsockopt(struct socket *sock,int level,int optname,char *optval,
diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	Mon Jan 20 16:00:08 2003
+++ b/net/ax25/af_ax25.c	Mon Jan 20 16:00:08 2003
@@ -1411,8 +1411,7 @@
 }
 
 static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, int len,
-	struct scm_cookie *scm)
+			struct msghdr *msg, int len)
 {
 	struct sockaddr_ax25 *usax = (struct sockaddr_ax25 *)msg->msg_name;
 	struct sock *sk = sock->sk;
@@ -1590,7 +1589,7 @@
 }
 
 static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, int size, int flags, struct scm_cookie *scm)
+	struct msghdr *msg, int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff -Nru a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c	Mon Jan 20 16:00:07 2003
+++ b/net/bluetooth/af_bluetooth.c	Mon Jan 20 16:00:07 2003
@@ -212,7 +212,7 @@
 }
 
 int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, int len, int flags, struct scm_cookie *scm)
+	struct msghdr *msg, int len, int flags)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
diff -Nru a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
--- a/net/bluetooth/bnep/core.c	Mon Jan 20 16:00:08 2003
+++ b/net/bluetooth/bnep/core.c	Mon Jan 20 16:00:08 2003
@@ -97,26 +97,12 @@
 
 static int bnep_send(struct bnep_session *s, void *data, size_t len)
 {
-	struct kiocb iocb;
-	struct sock_iocb *si;
 	struct socket *sock = s->sock;
 	struct iovec iv = { data, len };
-	int err;
 
 	s->msg.msg_iov    = &iv;
 	s->msg.msg_iovlen = 1;
-	init_sync_kiocb(&iocb, NULL);
-	si = kiocb_to_siocb(&iocb);
-	si->scm = NULL;
-	si->sock = sock;
-	si->msg = &s->msg;
-	si->size = len;
-
-	err = sock->ops->sendmsg(&iocb, sock, &s->msg, len, NULL);
-	if (-EIOCBQUEUED == err)
-		err = wait_on_sync_kiocb(&iocb);
-
-	return err;
+	return sock_sendmsg(sock, &s->msg, len);
 }
 
 static int bnep_send_rsp(struct bnep_session *s, u8 ctrl, u16 resp)
@@ -442,20 +428,9 @@
 	
 	/* FIXME: linearize skb */
 	{
-		struct kiocb iocb;
-		struct sock_iocb *si;
-	
 		s->msg.msg_iov    = iv;
 		s->msg.msg_iovlen = il;
-		init_sync_kiocb(&iocb, NULL);
-		si = kiocb_to_siocb(&iocb);
-		si->scm = NULL;
-		si->sock = sock;
-		si->msg = &s->msg;
-		si->size = len;
-		len = sock->ops->sendmsg(&iocb, sock, &s->msg, len, NULL);
-		if (-EIOCBQUEUED == len)
-			len = wait_on_sync_kiocb(&iocb);
+		len = sock_sendmsg(sock, &s->msg, len);
 	}
 	kfree_skb(skb);
 
diff -Nru a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
--- a/net/bluetooth/hci_sock.c	Mon Jan 20 16:00:08 2003
+++ b/net/bluetooth/hci_sock.c	Mon Jan 20 16:00:08 2003
@@ -316,7 +316,7 @@
         	put_cmsg(msg, SOL_HCI, HCI_CMSG_TSTAMP, sizeof(skb->stamp), &skb->stamp);
 }
  
-static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len, int flags, struct scm_cookie *scm)
+static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len, int flags)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
@@ -352,8 +352,7 @@
 	return err ? : copied;
 }
 
-static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len,
-                            struct scm_cookie *scm)
+static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct hci_dev *hdev;
diff -Nru a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c	Mon Jan 20 16:00:08 2003
+++ b/net/bluetooth/l2cap.c	Mon Jan 20 16:00:08 2003
@@ -709,7 +709,7 @@
 	return err;
 }
 
-static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len, struct scm_cookie *scm)
+static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
diff -Nru a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
--- a/net/bluetooth/rfcomm/core.c	Mon Jan 20 16:00:07 2003
+++ b/net/bluetooth/rfcomm/core.c	Mon Jan 20 16:00:07 2003
@@ -604,29 +604,17 @@
 /* ---- RFCOMM frame sending ---- */
 static int rfcomm_send_frame(struct rfcomm_session *s, u8 *data, int len)
 {
-	struct kiocb iocb;
-	struct sock_iocb *si;
 	struct socket *sock = s->sock;
 	struct iovec iv = { data, len };
 	struct msghdr msg;
-	int err;
 
 	BT_DBG("session %p len %d", s, len);
 
 	memset(&msg, 0, sizeof(msg));
 	msg.msg_iovlen = 1;
 	msg.msg_iov = &iv;
-	init_sync_kiocb(&iocb, NULL);
-	si = kiocb_to_siocb(&iocb);
-	si->scm = NULL;
-	si->sock = sock;
-	si->msg = &msg;
-	si->size = len;
-
-	err = sock->ops->sendmsg(&iocb, sock, &msg, len, NULL);
-	if (-EIOCBQUEUED == err)
-		err = wait_on_sync_kiocb(&iocb);
-	return err;
+
+	return sock_sendmsg(sock, &msg, len);
 }
 
 static int rfcomm_send_sabm(struct rfcomm_session *s, u8 dlci)
@@ -838,13 +826,10 @@
 
 static int rfcomm_send_test(struct rfcomm_session *s, int cr, u8 *pattern, int len)
 {
-	struct kiocb iocb;
-	struct sock_iocb *si;
 	struct socket *sock = s->sock;
 	struct iovec iv[3];
 	struct msghdr msg;
 	unsigned char hdr[5], crc[1];
-	int err;
 
 	if (len > 125)
 		return -EINVAL;
@@ -869,18 +854,8 @@
 	memset(&msg, 0, sizeof(msg));
 	msg.msg_iovlen = 3;
 	msg.msg_iov = iv;
-	init_sync_kiocb(&iocb, NULL);
-	si = kiocb_to_siocb(&iocb);
-	si->scm = NULL;
-	si->sock = sock;
-	si->msg = &msg;
-	si->size = 6 + len;
-
-	err = sock->ops->sendmsg(&iocb, sock, &msg, 6 + len, NULL);
-	if (-EIOCBQUEUED == err)
-		err = wait_on_sync_kiocb(&iocb);
 
-	return err;
+	return sock_sendmsg(sock, &msg, 6 + len);
 }
 
 static int rfcomm_send_credits(struct rfcomm_session *s, u8 addr, u8 credits)
diff -Nru a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c	Mon Jan 20 16:00:08 2003
+++ b/net/bluetooth/rfcomm/sock.c	Mon Jan 20 16:00:08 2003
@@ -479,7 +479,7 @@
 }
 
 static int rfcomm_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int len, struct scm_cookie *scm)
+			       struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
@@ -553,8 +553,7 @@
 }
 
 static int rfcomm_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int size, int flags,
-			       struct scm_cookie *scm)
+			       struct msghdr *msg, int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	int target, err = 0, copied = 0;
diff -Nru a/net/bluetooth/sco.c b/net/bluetooth/sco.c
--- a/net/bluetooth/sco.c	Mon Jan 20 16:00:07 2003
+++ b/net/bluetooth/sco.c	Mon Jan 20 16:00:07 2003
@@ -632,7 +632,7 @@
 	return 0;
 }
 
-static int sco_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len, struct scm_cookie *scm)
+static int sco_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
diff -Nru a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c	Mon Jan 20 16:00:08 2003
+++ b/net/core/sock.c	Mon Jan 20 16:00:08 2003
@@ -960,13 +960,13 @@
 }
 
 int sock_no_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		    int flags, struct scm_cookie *scm)
+		    int flags)
 {
 	return -EOPNOTSUPP;
 }
 
 int sock_no_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		    int len, int flags, struct scm_cookie *scm)
+		    int len, int flags)
 {
 	return -EOPNOTSUPP;
 }
diff -Nru a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	Mon Jan 20 16:00:08 2003
+++ b/net/decnet/af_decnet.c	Mon Jan 20 16:00:08 2003
@@ -1718,7 +1718,7 @@
 
 
 static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, int size, int flags, struct scm_cookie *scm)
+	struct msghdr *msg, int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
@@ -1889,7 +1889,7 @@
 }
 
 static int dn_sendmsg(struct kiocb *iocb, struct socket *sock,
-	   struct msghdr *msg, int size, struct scm_cookie *scm)
+	   struct msghdr *msg, int size)
 {
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	Mon Jan 20 16:00:07 2003
+++ b/net/econet/af_econet.c	Mon Jan 20 16:00:07 2003
@@ -126,8 +126,7 @@
  */
 
 static int econet_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len, int flags,
-			  struct scm_cookie *scm)
+			  struct msghdr *msg, int len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
@@ -260,7 +259,7 @@
  */
 
 static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len, struct scm_cookie *scm)
+			  struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ec *saddr=(struct sockaddr_ec *)msg->msg_name;
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	Mon Jan 20 16:00:07 2003
+++ b/net/ipv4/af_inet.c	Mon Jan 20 16:00:07 2003
@@ -730,7 +730,7 @@
 
 
 int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 int size, int flags, struct scm_cookie *scm)
+		 int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	int addr_len = 0;
@@ -745,7 +745,7 @@
 
 
 int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 int size, struct scm_cookie *scm)
+		 int size)
 {
 	struct sock *sk = sock->sk;
 
diff -Nru a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
--- a/net/ipx/af_ipx.c	Mon Jan 20 16:00:07 2003
+++ b/net/ipx/af_ipx.c	Mon Jan 20 16:00:07 2003
@@ -2010,7 +2010,7 @@
 }
 
 static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, int len, struct scm_cookie *scm)
+	struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_opt *ipxs = ipx_sk(sk);
@@ -2070,7 +2070,7 @@
 
 
 static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
-		struct msghdr *msg, int size, int flags, struct scm_cookie *scm)
+		struct msghdr *msg, int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_opt *ipxs = ipx_sk(sk);
diff -Nru a/net/irda/af_irda.c b/net/irda/af_irda.c
--- a/net/irda/af_irda.c	Mon Jan 20 16:00:07 2003
+++ b/net/irda/af_irda.c	Mon Jan 20 16:00:07 2003
@@ -1253,14 +1253,14 @@
 }
 
 /*
- * Function irda_sendmsg (iocb, sock, msg, len, scm)
+ * Function irda_sendmsg (iocb, sock, msg, len)
  *
  *    Send message down to TinyTP. This function is used for both STREAM and
  *    SEQPACK services. This is possible since it forces the client to
  *    fragment the message if necessary
  */
 static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, int len, struct scm_cookie *scm)
+			struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
@@ -1326,14 +1326,13 @@
 }
 
 /*
- * Function irda_recvmsg_dgram (iocb, sock, msg, size, flags, scm)
+ * Function irda_recvmsg_dgram (iocb, sock, msg, size, flags)
  *
  *    Try to receive message and copy it to user. The frame is discarded
  *    after being read, regardless of how much the user actually read
  */
 static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, int size, int flags,
-			      struct scm_cookie *scm)
+			      struct msghdr *msg, int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
@@ -1380,11 +1379,10 @@
 }
 
 /*
- * Function irda_recvmsg_stream (iocb, sock, msg, size, flags, scm)
+ * Function irda_recvmsg_stream (iocb, sock, msg, size, flags)
  */
 static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int size, int flags,
-			       struct scm_cookie *scm)
+			       struct msghdr *msg, int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
@@ -1504,14 +1502,14 @@
 }
 
 /*
- * Function irda_sendmsg_dgram (iocb, sock, msg, len, scm)
+ * Function irda_sendmsg_dgram (iocb, sock, msg, len)
  *
  *    Send message down to TinyTP for the unreliable sequenced
  *    packet service...
  *
  */
 static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, int len, struct scm_cookie *scm)
+			      struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
@@ -1570,14 +1568,14 @@
 }
 
 /*
- * Function irda_sendmsg_ultra (iocb, sock, msg, len, scm)
+ * Function irda_sendmsg_ultra (iocb, sock, msg, len)
  *
  *    Send message down to IrLMP for the unreliable Ultra
  *    packet service...
  */
 #ifdef CONFIG_IRDA_ULTRA
 static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, int len, struct scm_cookie *scm)
+			      struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
diff -Nru a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c	Mon Jan 20 16:00:07 2003
+++ b/net/key/af_key.c	Mon Jan 20 16:00:07 2003
@@ -2141,8 +2141,7 @@
 }
 
 static int pfkey_sendmsg(struct kiocb *kiocb,
-			 struct socket *sock, struct msghdr *msg, int len,
-			 struct scm_cookie *scm)
+			 struct socket *sock, struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb = NULL;
@@ -2185,7 +2184,7 @@
 
 static int pfkey_recvmsg(struct kiocb *kiocb,
 			 struct socket *sock, struct msghdr *msg, int len,
-			 int flags, struct scm_cookie *scm)
+			 int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff -Nru a/net/llc/af_llc.c b/net/llc/af_llc.c
--- a/net/llc/af_llc.c	Mon Jan 20 16:00:07 2003
+++ b/net/llc/af_llc.c	Mon Jan 20 16:00:07 2003
@@ -672,14 +672,12 @@
  *	@msg: Various user space related information.
  *	@size: Size of user buffer.
  *	@flags: User specified flags.
- *	@scm: Unknown.
  *
  *	Copy received data to the socket user.
  *	Returns non-negative upon success, negative otherwise.
  */
 static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int size, int flags,
-			  struct scm_cookie *scm)
+			  struct msghdr *msg, int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_llc *uaddr = (struct sockaddr_llc *)msg->msg_name;
@@ -727,13 +725,12 @@
  *	@sock: Socket to transmit data from.
  *	@msg: Various user related information.
  *	@len: Length of data to transmit.
- *	@scm: Unknown.
  *
  *	Transmit data provided by the socket user.
  *	Returns non-negative upon success, negative otherwise.
  */
 static int llc_ui_sendmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len, struct scm_cookie *scm)
+			  struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct llc_opt *llc = llc_sk(sk);
diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	Mon Jan 20 16:00:08 2003
+++ b/net/netlink/af_netlink.c	Mon Jan 20 16:00:08 2003
@@ -584,10 +584,10 @@
 	read_unlock(&nl_table_lock);
 }
 
-static int netlink_sendmsg(struct kiocb *iocb, struct socket *sock,
-			   struct msghdr *msg, int len,
-			   struct scm_cookie *scm)
+static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
+			   struct msghdr *msg, int len)
 {
+	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct netlink_opt *nlk = nlk_sk(sk);
 	struct sockaddr_nl *addr=msg->msg_name;
@@ -595,10 +595,17 @@
 	u32 dst_groups;
 	struct sk_buff *skb;
 	int err;
+	struct scm_cookie scm;
 
 	if (msg->msg_flags&MSG_OOB)
 		return -EOPNOTSUPP;
 
+	if (NULL == siocb->scm)
+		siocb->scm = &scm;
+	err = scm_send(sock, msg, siocb->scm);
+	if (err < 0)
+		return err;
+
 	if (msg->msg_namelen) {
 		if (addr->nl_family != AF_NETLINK)
 			return -EINVAL;
@@ -629,7 +636,7 @@
 	NETLINK_CB(skb).groups	= nlk->groups;
 	NETLINK_CB(skb).dst_pid = dst_pid;
 	NETLINK_CB(skb).dst_groups = dst_groups;
-	memcpy(NETLINK_CREDS(skb), &scm->creds, sizeof(struct ucred));
+	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 
 	/* What can I do? Netlink is asynchronous, so that
 	   we will have to save current capabilities to
@@ -654,10 +661,12 @@
 	return err;
 }
 
-static int netlink_recvmsg(struct kiocb *iocb, struct socket *sock,
+static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 			   struct msghdr *msg, int len,
-			   int flags, struct scm_cookie *scm)
+			   int flags)
 {
+	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
+	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
 	struct netlink_opt *nlk = nlk_sk(sk);
 	int noblock = flags&MSG_DONTWAIT;
@@ -693,11 +702,17 @@
 		msg->msg_namelen = sizeof(*addr);
 	}
 
-	scm->creds = *NETLINK_CREDS(skb);
+	if (NULL == siocb->scm) {
+		memset(&scm, 0, sizeof(scm));
+		siocb->scm = &scm;
+	}
+	siocb->scm->creds = *NETLINK_CREDS(skb);
 	skb_free_datagram(sk, skb);
 
 	if (nlk->cb && atomic_read(&sk->rmem_alloc) <= sk->rcvbuf / 2)
 		netlink_dump(sk);
+
+	scm_recv(sock, msg, siocb->scm, flags);
 
 out:
 	if (skb_queue_len(&sk->receive_queue) <= sk->rcvbuf/2) {
diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Mon Jan 20 16:00:07 2003
+++ b/net/netrom/af_netrom.c	Mon Jan 20 16:00:08 2003
@@ -967,7 +967,7 @@
 }
 
 static int nr_sendmsg(struct kiocb *iocb, struct socket *sock,
-		      struct msghdr *msg, int len, struct scm_cookie *scm)
+		      struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	nr_cb *nr = nr_sk(sk);
@@ -1058,8 +1058,7 @@
 }
 
 static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
-		      struct msghdr *msg, int size, int flags,
-		      struct scm_cookie *scm)
+		      struct msghdr *msg, int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ax25 *sax = (struct sockaddr_ax25 *)msg->msg_name;
diff -Nru a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c	Mon Jan 20 16:00:08 2003
+++ b/net/packet/af_packet.c	Mon Jan 20 16:00:08 2003
@@ -280,8 +280,7 @@
  */
  
 static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int len,
-			       struct scm_cookie *scm)
+			       struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_pkt *saddr=(struct sockaddr_pkt *)msg->msg_name;
@@ -658,7 +657,7 @@
 
 
 static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len, struct scm_cookie *scm)
+			  struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ll *saddr=(struct sockaddr_ll *)msg->msg_name;
@@ -1013,8 +1012,7 @@
  */
 
 static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, int len,
-			  int flags, struct scm_cookie *scm)
+			  struct msghdr *msg, int len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	Mon Jan 20 16:00:08 2003
+++ b/net/rose/af_rose.c	Mon Jan 20 16:00:08 2003
@@ -1026,7 +1026,7 @@
 }
 
 static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, int len, struct scm_cookie *scm)
+			struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	rose_cb *rose = rose_sk(sk);
@@ -1190,8 +1190,7 @@
 
 
 static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, int size, int flags,
-			struct scm_cookie *scm)
+			struct msghdr *msg, int size, int flags)
 {
 	struct sock *sk = sock->sk;
 	rose_cb *rose = rose_sk(sk);
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Mon Jan 20 16:00:07 2003
+++ b/net/socket.c	Mon Jan 20 16:00:07 2003
@@ -89,7 +89,6 @@
 #include <asm/uaccess.h>
 
 #include <net/sock.h>
-#include <net/scm.h>
 #include <linux/netfilter.h>
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
@@ -517,23 +516,16 @@
 	sock->file=NULL;
 }
 
-static int __sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int size)
+static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int size)
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
-	int err;
 
-	si->scm = &si->async_scm;
 	si->sock = sock;
+	si->scm = NULL;
 	si->msg = msg;
 	si->size = size;
 
-	err = scm_send(sock, msg, si->scm);
-	if (err >= 0) {
-		err = sock->ops->sendmsg(iocb, sock, msg, size, si->scm);
-		if (-EIOCBQUEUED != err)
-			scm_destroy(si->scm);
-	}
-	return err;
+	return sock->ops->sendmsg(iocb, sock, msg, size);
 }
 
 int sock_sendmsg(struct socket *sock, struct msghdr *msg, int size)
@@ -549,24 +541,17 @@
 }
 
 
-int __sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int size, int flags)
+static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int size, int flags)
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
 	si->sock = sock;
-	si->scm = &si->async_scm;
-	si->sock = sock;
+	si->scm = NULL;
 	si->msg = msg;
 	si->size = size;
 	si->flags = flags;
 
-	memset(si->scm, 0, sizeof(*si->scm));
-
-	size = sock->ops->recvmsg(iocb, sock, msg, size, flags, si->scm);
-	if (size >= 0)
-		scm_recv(sock, msg, si->scm, flags);
-
-	return size;
+	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
 }
 
 int sock_recvmsg(struct socket *sock, struct msghdr *msg, int size, int flags)
diff -Nru a/net/unix/af_unix.c b/net/unix/af_unix.c
--- a/net/unix/af_unix.c	Mon Jan 20 16:00:08 2003
+++ b/net/unix/af_unix.c	Mon Jan 20 16:00:08 2003
@@ -1180,10 +1180,10 @@
  *	Send AF_UNIX data.
  */
 
-static int unix_dgram_sendmsg(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, int len,
-			      struct scm_cookie *scm)
+static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
+			      struct msghdr *msg, int len)
 {
+	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr=msg->msg_name;
@@ -1193,6 +1193,13 @@
 	unsigned hash;
 	struct sk_buff *skb;
 	long timeo;
+	struct scm_cookie scm;
+
+	if (NULL == siocb->scm)
+		siocb->scm = &scm;
+	err = scm_send(sock, msg, siocb->scm);
+	if (err < 0)
+		return err;
 
 	err = -EOPNOTSUPP;
 	if (msg->msg_flags&MSG_OOB)
@@ -1222,9 +1229,9 @@
 	if (skb==NULL)
 		goto out;
 
-	memcpy(UNIXCREDS(skb), &scm->creds, sizeof(struct ucred));
-	if (scm->fp)
-		unix_attach_fds(scm, skb);
+	memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
+	if (siocb->scm->fp)
+		unix_attach_fds(siocb->scm, skb);
 
 	skb->h.raw = skb->data;
 	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
@@ -1300,6 +1307,7 @@
 	unix_state_runlock(other);
 	other->data_ready(other, len);
 	sock_put(other);
+	scm_destroy(siocb->scm);
 	return len;
 
 out_unlock:
@@ -1309,20 +1317,28 @@
 out:
 	if (other)
 		sock_put(other);
+	scm_destroy(siocb->scm);
 	return err;
 }
 
 		
-static int unix_stream_sendmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int len,
-			       struct scm_cookie *scm)
+static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
+			       struct msghdr *msg, int len)
 {
+	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	unix_socket *other = NULL;
 	struct sockaddr_un *sunaddr=msg->msg_name;
 	int err,size;
 	struct sk_buff *skb;
 	int sent=0;
+	struct scm_cookie scm;
+
+	if (NULL == siocb->scm)
+		siocb->scm = &scm;
+	err = scm_send(sock, msg, siocb->scm);
+	if (err < 0)
+		return err;
 
 	err = -EOPNOTSUPP;
 	if (msg->msg_flags&MSG_OOB)
@@ -1376,9 +1392,9 @@
 		 */
 		size = min_t(int, size, skb_tailroom(skb));
 
-		memcpy(UNIXCREDS(skb), &scm->creds, sizeof(struct ucred));
-		if (scm->fp)
-			unix_attach_fds(scm, skb);
+		memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
+		if (siocb->scm->fp)
+			unix_attach_fds(siocb->scm, skb);
 
 		if ((err = memcpy_fromiovec(skb_put(skb,size), msg->msg_iov, size)) != 0) {
 			kfree_skb(skb);
@@ -1396,6 +1412,10 @@
 		sent+=size;
 	}
 	sock_put(other);
+
+	scm_destroy(siocb->scm);
+	siocb->scm = NULL;
+
 	return sent;
 
 pipe_err_free:
@@ -1408,6 +1428,8 @@
 out_err:
         if (other)
 		sock_put(other);
+	scm_destroy(siocb->scm);
+	siocb->scm = NULL;
 	return sent ? : err;
 }
 
@@ -1424,8 +1446,9 @@
 
 static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 			      struct msghdr *msg, int size,
-			      int flags, struct scm_cookie *scm)
+			      int flags)
 {
+	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
 	int noblock = flags & MSG_DONTWAIT;
@@ -1456,12 +1479,13 @@
 	if (err)
 		goto out_free;
 
-	scm->creds = *UNIXCREDS(skb);
+	memset(&scm, 0, sizeof(scm));
+	scm.creds = *UNIXCREDS(skb);
 
 	if (!(flags & MSG_PEEK))
 	{
 		if (UNIXCB(skb).fp)
-			unix_detach_fds(scm, skb);
+			unix_detach_fds(&scm, skb);
 	}
 	else 
 	{
@@ -1478,10 +1502,12 @@
 		   
 		*/
 		if (UNIXCB(skb).fp)
-			scm->fp = scm_fp_dup(UNIXCB(skb).fp);
+			scm.fp = scm_fp_dup(UNIXCB(skb).fp);
 	}
 	err = size;
 
+	scm_recv(sock, msg, &scm, flags);
+
 out_free:
 	skb_free_datagram(sk,skb);
 out:
@@ -1527,8 +1553,9 @@
 
 static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, int size,
-			       int flags, struct scm_cookie *scm)
+			       int flags)
 {
+	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr=msg->msg_name;
@@ -1555,6 +1582,8 @@
 	 * while sleeps in memcpy_tomsg
 	 */
 
+	memset(&scm, 0, sizeof(scm));
+
 	down(&u->readsem);
 
 	do
@@ -1593,13 +1622,13 @@
 
 		if (check_creds) {
 			/* Never glue messages from different writers */
-			if (memcmp(UNIXCREDS(skb), &scm->creds, sizeof(scm->creds)) != 0) {
+			if (memcmp(UNIXCREDS(skb), &scm.creds, sizeof(scm.creds)) != 0) {
 				skb_queue_head(&sk->receive_queue, skb);
 				break;
 			}
 		} else {
 			/* Copy credentials */
-			scm->creds = *UNIXCREDS(skb);
+			scm.creds = *UNIXCREDS(skb);
 			check_creds = 1;
 		}
 
@@ -1626,7 +1655,7 @@
 			skb_pull(skb, chunk);
 
 			if (UNIXCB(skb).fp)
-				unix_detach_fds(scm, skb);
+				unix_detach_fds(&scm, skb);
 
 			/* put the skb back if we didn't use it up.. */
 			if (skb->len)
@@ -1637,7 +1666,7 @@
 
 			kfree_skb(skb);
 
-			if (scm->fp)
+			if (scm.fp)
 				break;
 		}
 		else
@@ -1645,7 +1674,7 @@
 			/* It is questionable, see note in unix_dgram_recvmsg.
 			 */
 			if (UNIXCB(skb).fp)
-				scm->fp = scm_fp_dup(UNIXCB(skb).fp);
+				scm.fp = scm_fp_dup(UNIXCB(skb).fp);
 
 			/* put message back and return */
 			skb_queue_head(&sk->receive_queue, skb);
@@ -1654,6 +1683,7 @@
 	} while (size);
 
 	up(&u->readsem);
+	scm_recv(sock, msg, &scm, flags);
 out:
 	return copied ? : err;
 }
diff -Nru a/net/wanrouter/af_wanpipe.c b/net/wanrouter/af_wanpipe.c
--- a/net/wanrouter/af_wanpipe.c	Mon Jan 20 16:00:08 2003
+++ b/net/wanrouter/af_wanpipe.c	Mon Jan 20 16:00:08 2003
@@ -542,7 +542,7 @@
  *===========================================================*/
 
 static int wanpipe_sendmsg(struct kiocb *iocb, struct socket *sock,
-			   struct msghdr *msg, int len, struct scm_cookie *scm)
+			   struct msghdr *msg, int len)
 {
 	wanpipe_opt *wp;
 	struct sock *sk = sock->sk;
@@ -1649,8 +1649,7 @@
  *===========================================================*/
 
 static int wanpipe_recvmsg(struct kiocb *iocb, struct socket *sock,
-			   struct msghdr *msg, int len, int flags,
-			   struct scm_cookie *scm)
+			   struct msghdr *msg, int len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff -Nru a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	Mon Jan 20 16:00:08 2003
+++ b/net/x25/af_x25.c	Mon Jan 20 16:00:08 2003
@@ -917,7 +917,7 @@
 }
 
 static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, int len, struct scm_cookie *scm)
+		       struct msghdr *msg, int len)
 {
 	struct sock *sk = sock->sk;
 	struct x25_opt *x25 = x25_sk(sk);
@@ -1093,7 +1093,7 @@
 
 static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *msg, int size,
-		       int flags, struct scm_cookie *scm)
+		       int flags)
 {
 	struct sock *sk = sock->sk;
 	struct x25_opt *x25 = x25_sk(sk);
Mail text in /tmp/linus.txt; please check and send using your favourite
mailer.
