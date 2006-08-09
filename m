From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] socket: code style cleanup
Date: Wed, 09 Aug 2006 11:31:40 -0700
Message-ID: <20060809183349.177095462@localhost.localdomain>
References: <20060809183138.332023530@localhost.localdomain>
Cc: Paul McKenney <paulmck@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11200 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751311AbWHISlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 14:41:13 -0400
To: David Miller <davem@davemloft.net>
Cc: akpm@osdl.org
Content-Disposition: inline; filename=socket-cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make socket.c conform to current style:
	* run through Lindent
	* get rid of unneeded casts
	* split assignment and comparsion where possible

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- net-2.6.orig/net/socket.c	2006-08-09 10:08:13.000000000 -0700
+++ net-2.6/net/socket.c	2006-08-09 11:19:08.000000000 -0700
@@ -42,7 +42,7 @@
  *		Andi Kleen	:	Some small cleanups, optimizations,
  *					and fixed a copy_from_user() bug.
  *		Tigran Aivazian	:	sys_send(args) calls sys_sendto(args, NULL, 0)
- *		Tigran Aivazian	:	Made listen(2) backlog sanity checks 
+ *		Tigran Aivazian	:	Made listen(2) backlog sanity checks
  *					protocol-independent
  *
  *
@@ -53,7 +53,7 @@
  *
  *
  *	This module is effectively the top level interface to the BSD socket
- *	paradigm. 
+ *	paradigm.
  *
  *	Based upon Swansea University Computer Society NET3.039
  */
@@ -95,28 +95,27 @@
 #include <linux/netfilter.h>
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
-static ssize_t sock_aio_read(struct kiocb *iocb, char __user *buf,
-			 size_t size, loff_t pos);
-static ssize_t sock_aio_write(struct kiocb *iocb, const char __user *buf,
-			  size_t size, loff_t pos);
-static int sock_mmap(struct file *file, struct vm_area_struct * vma);
+static ssize_t sock_aio_read(struct kiocb *iocb, char __user * buf,
+			     size_t size, loff_t pos);
+static ssize_t sock_aio_write(struct kiocb *iocb, const char __user * buf,
+			      size_t size, loff_t pos);
+static int sock_mmap(struct file *file, struct vm_area_struct *vma);
 
 static int sock_close(struct inode *inode, struct file *file);
 static unsigned int sock_poll(struct file *file,
 			      struct poll_table_struct *wait);
-static long sock_ioctl(struct file *file,
-		      unsigned int cmd, unsigned long arg);
+static long sock_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 #ifdef CONFIG_COMPAT
 static long compat_sock_ioctl(struct file *file,
-		      unsigned int cmd, unsigned long arg);
+			      unsigned int cmd, unsigned long arg);
 #endif
 static int sock_fasync(int fd, struct file *filp, int on);
 static ssize_t sock_readv(struct file *file, const struct iovec *vector,
-			  unsigned long count, loff_t *ppos);
+			  unsigned long count, loff_t * ppos);
 static ssize_t sock_writev(struct file *file, const struct iovec *vector,
-			  unsigned long count, loff_t *ppos);
+			   unsigned long count, loff_t * ppos);
 static ssize_t sock_sendpage(struct file *file, struct page *page,
-			     int offset, size_t size, loff_t *ppos, int more);
+			     int offset, size_t size, loff_t * ppos, int more);
 
 /*
  *	Socket files have a set of 'special' operations as well as the generic file ones. These don't appear
@@ -193,7 +192,6 @@
 #define net_family_read_unlock() do { } while(0)
 #endif
 
-
 /*
  *	Statistics counters of the socket lists
  */
@@ -201,19 +199,20 @@
 static DEFINE_PER_CPU(int, sockets_in_use) = 0;
 
 /*
- *	Support routines. Move socket addresses back and forth across the kernel/user
- *	divide and look after the messy bits.
+ * Support routines.
+ * Move socket addresses back and forth across the kernel/user
+ * divide and look after the messy bits.
  */
 
-#define MAX_SOCK_ADDR	128		/* 108 for Unix domain - 
+#define MAX_SOCK_ADDR	128		/* 108 for Unix domain -
 					   16 for IP, 16 for IPX,
 					   24 for IPv6,
-					   about 80 for AX.25 
+					   about 80 for AX.25
 					   must be at least one bigger than
 					   the AF_UNIX size (see net/unix/af_unix.c
-					   :unix_mkname()).  
+					   :unix_mkname()).
 					 */
-					 
+
 /**
  *	move_addr_to_kernel	-	copy a socket address into kernel space
  *	@uaddr: Address in user space
@@ -225,13 +224,13 @@
  *	invalid addresses -EFAULT is returned. On a success 0 is returned.
  */
 
-int move_addr_to_kernel(void __user *uaddr, int ulen, void *kaddr)
+int move_addr_to_kernel(void __user * uaddr, int ulen, void *kaddr)
 {
-	if(ulen<0||ulen>MAX_SOCK_ADDR)
+	if (ulen < 0 || ulen > MAX_SOCK_ADDR)
 		return -EINVAL;
-	if(ulen==0)
+	if (ulen == 0)
 		return 0;
-	if(copy_from_user(kaddr,uaddr,ulen))
+	if (copy_from_user(kaddr, uaddr, ulen))
 		return -EFAULT;
 	return audit_sockaddr(ulen, kaddr);
 }
@@ -252,44 +251,46 @@
  *	length of the data is written over the length limit the user
  *	specified. Zero is returned for a success.
  */
- 
-int move_addr_to_user(void *kaddr, int klen, void __user *uaddr, int __user *ulen)
+
+int move_addr_to_user(void *kaddr, int klen, void __user * uaddr,
+		      int __user * ulen)
 {
 	int err;
 	int len;
 
-	if((err=get_user(len, ulen)))
+	err = get_user(len, ulen);
+	if (err)
 		return err;
-	if(len>klen)
-		len=klen;
-	if(len<0 || len> MAX_SOCK_ADDR)
+	if (len > klen)
+		len = klen;
+	if (len < 0 || len > MAX_SOCK_ADDR)
 		return -EINVAL;
-	if(len)
-	{
+	if (len) {
 		if (audit_sockaddr(klen, kaddr))
 			return -ENOMEM;
-		if(copy_to_user(uaddr,kaddr,len))
+		if (copy_to_user(uaddr, kaddr, len))
 			return -EFAULT;
 	}
 	/*
-	 *	"fromlen shall refer to the value before truncation.."
-	 *			1003.1g
+	 *      "fromlen shall refer to the value before truncation.."
+	 *                      1003.1g
 	 */
 	return __put_user(klen, ulen);
 }
 
 #define SOCKFS_MAGIC 0x534F434B
 
-static kmem_cache_t * sock_inode_cachep __read_mostly;
+static kmem_cache_t *sock_inode_cachep __read_mostly;
 
 static struct inode *sock_alloc_inode(struct super_block *sb)
 {
 	struct socket_alloc *ei;
-	ei = (struct socket_alloc *)kmem_cache_alloc(sock_inode_cachep, SLAB_KERNEL);
+
+	ei = kmem_cache_alloc(sock_inode_cachep, SLAB_KERNEL);
 	if (!ei)
 		return NULL;
 	init_waitqueue_head(&ei->socket.wait);
-	
+
 	ei->socket.fasync_list = NULL;
 	ei->socket.state = SS_UNCONNECTED;
 	ei->socket.flags = 0;
@@ -307,22 +308,25 @@
 			container_of(inode, struct socket_alloc, vfs_inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void *foo, kmem_cache_t * cachep, unsigned long flags)
 {
-	struct socket_alloc *ei = (struct socket_alloc *) foo;
+	struct socket_alloc *ei = (struct socket_alloc *)foo;
 
-	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
-	    SLAB_CTOR_CONSTRUCTOR)
+	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR))
+	    == SLAB_CTOR_CONSTRUCTOR)
 		inode_init_once(&ei->vfs_inode);
 }
- 
+
 static int init_inodecache(void)
 {
 	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
-				sizeof(struct socket_alloc),
-				0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-					SLAB_MEM_SPREAD),
-				init_once, NULL);
+					      sizeof(struct socket_alloc),
+					      0,
+					      (SLAB_HWCACHE_ALIGN |
+					       SLAB_RECLAIM_ACCOUNT |
+					       SLAB_MEM_SPREAD),
+					      init_once,
+					      NULL);
 	if (sock_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
@@ -335,7 +339,8 @@
 };
 
 static int sockfs_get_sb(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
+			 int flags, const char *dev_name, void *data,
+			 struct vfsmount *mnt)
 {
 	return get_sb_pseudo(fs_type, "socket:", &sockfs_ops, SOCKFS_MAGIC,
 			     mnt);
@@ -348,12 +353,13 @@
 	.get_sb =	sockfs_get_sb,
 	.kill_sb =	kill_anon_super,
 };
+
 static int sockfs_delete_dentry(struct dentry *dentry)
 {
 	return 1;
 }
 static struct dentry_operations sockfs_dentry_operations = {
-	.d_delete =	sockfs_delete_dentry,
+	.d_delete = sockfs_delete_dentry,
 };
 
 /*
@@ -477,10 +483,12 @@
 	struct file *file;
 	struct socket *sock;
 
-	if (!(file = fget(fd))) {
+	file = fget(fd);
+	if (!file) {
 		*err = -EBADF;
 		return NULL;
 	}
+
 	sock = sock_from_file(file, err);
 	if (!sock)
 		fput(file);
@@ -505,7 +513,7 @@
 
 /**
  *	sock_alloc	-	allocate a socket
- *	
+ *
  *	Allocate a new inode and socket object. The two are bound together
  *	and initialised. The socket is then returned. If we are out of inodes
  *	NULL is returned.
@@ -513,8 +521,8 @@
 
 static struct socket *sock_alloc(void)
 {
-	struct inode * inode;
-	struct socket * sock;
+	struct inode *inode;
+	struct socket *sock;
 
 	inode = new_inode(sock_mnt->mnt_sb);
 	if (!inode)
@@ -522,7 +530,7 @@
 
 	sock = SOCKET_I(inode);
 
-	inode->i_mode = S_IFSOCK|S_IRWXUGO;
+	inode->i_mode = S_IFSOCK | S_IRWXUGO;
 	inode->i_uid = current->fsuid;
 	inode->i_gid = current->fsgid;
 
@@ -536,7 +544,7 @@
  *	a back door. Remember to keep it shut otherwise you'll let the
  *	creepy crawlies in.
  */
-  
+
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare)
 {
 	return -ENXIO;
@@ -553,9 +561,9 @@
  *
  *	The socket is released from the protocol stack if it has a release
  *	callback, and the inode is then released if the socket is bound to
- *	an inode not a file. 
+ *	an inode not a file.
  */
- 
+
 void sock_release(struct socket *sock)
 {
 	if (sock->ops) {
@@ -575,10 +583,10 @@
 		iput(SOCK_INODE(sock));
 		return;
 	}
-	sock->file=NULL;
+	sock->file = NULL;
 }
 
-static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock, 
+static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 				 struct msghdr *msg, size_t size)
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
@@ -621,14 +629,14 @@
 	 * the following is safe, since for compiler definitions of kvec and
 	 * iovec are identical, yielding the same in-core layout and alignment
 	 */
-	msg->msg_iov = (struct iovec *)vec,
+	msg->msg_iov = (struct iovec *)vec;
 	msg->msg_iovlen = num;
 	result = sock_sendmsg(sock, msg, size);
 	set_fs(oldfs);
 	return result;
 }
 
-static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock, 
+static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 				 struct msghdr *msg, size_t size, int flags)
 {
 	int err;
@@ -647,14 +655,14 @@
 	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
 }
 
-int sock_recvmsg(struct socket *sock, struct msghdr *msg, 
+int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 		 size_t size, int flags)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;
 	int ret;
 
-        init_sync_kiocb(&iocb, NULL);
+	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
 	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
 	if (-EIOCBQUEUED == ret)
@@ -662,9 +670,8 @@
 	return ret;
 }
 
-int kernel_recvmsg(struct socket *sock, struct msghdr *msg, 
-		   struct kvec *vec, size_t num,
-		   size_t size, int flags)
+int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
+		   struct kvec *vec, size_t num, size_t size, int flags)
 {
 	mm_segment_t oldfs = get_fs();
 	int result;
@@ -674,8 +681,7 @@
 	 * the following is safe, since for compiler definitions of kvec and
 	 * iovec are identical, yielding the same in-core layout and alignment
 	 */
-	msg->msg_iov = (struct iovec *)vec,
-	msg->msg_iovlen = num;
+	msg->msg_iov = (struct iovec *)vec, msg->msg_iovlen = num;
 	result = sock_recvmsg(sock, msg, size, flags);
 	set_fs(oldfs);
 	return result;
@@ -687,7 +693,7 @@
 }
 
 static ssize_t sock_sendpage(struct file *file, struct page *page,
-			     int offset, size_t size, loff_t *ppos, int more)
+			     int offset, size_t size, loff_t * ppos, int more)
 {
 	struct socket *sock;
 	int flags;
@@ -702,7 +708,8 @@
 }
 
 static struct sock_iocb *alloc_sock_iocb(struct kiocb *iocb,
-		char __user *ubuf, size_t size, struct sock_iocb *siocb)
+					 char __user * ubuf, size_t size,
+					 struct sock_iocb *siocb)
 {
 	if (!is_sync_kiocb(iocb)) {
 		siocb = kmalloc(sizeof(*siocb), GFP_KERNEL);
@@ -720,20 +727,21 @@
 }
 
 static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
-		struct file *file, struct iovec *iov, unsigned long nr_segs)
+			    struct file *file, struct iovec *iov,
+			    unsigned long nr_segs)
 {
 	struct socket *sock = file->private_data;
 	size_t size = 0;
 	int i;
 
-        for (i = 0 ; i < nr_segs ; i++)
-                size += iov[i].iov_len;
+	for (i = 0; i < nr_segs; i++)
+		size += iov[i].iov_len;
 
 	msg->msg_name = NULL;
 	msg->msg_namelen = 0;
 	msg->msg_control = NULL;
 	msg->msg_controllen = 0;
-	msg->msg_iov = (struct iovec *) iov;
+	msg->msg_iov = (struct iovec *)iov;
 	msg->msg_iovlen = nr_segs;
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 
@@ -741,14 +749,14 @@
 }
 
 static ssize_t sock_readv(struct file *file, const struct iovec *iov,
-			  unsigned long nr_segs, loff_t *ppos)
+			  unsigned long nr_segs, loff_t * ppos)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;
 	struct msghdr msg;
 	int ret;
 
-        init_sync_kiocb(&iocb, NULL);
+	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
 
 	ret = do_sock_read(&msg, &iocb, file, (struct iovec *)iov, nr_segs);
@@ -757,8 +765,8 @@
 	return ret;
 }
 
-static ssize_t sock_aio_read(struct kiocb *iocb, char __user *ubuf,
-			 size_t count, loff_t pos)
+static ssize_t sock_aio_read(struct kiocb *iocb, char __user * ubuf,
+			     size_t count, loff_t pos)
 {
 	struct sock_iocb siocb, *x;
 
@@ -771,24 +779,25 @@
 	if (!x)
 		return -ENOMEM;
 	return do_sock_read(&x->async_msg, iocb, iocb->ki_filp,
-			&x->async_iov, 1);
+			    &x->async_iov, 1);
 }
 
 static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
-		struct file *file, struct iovec *iov, unsigned long nr_segs)
+			     struct file *file, struct iovec *iov,
+			     unsigned long nr_segs)
 {
 	struct socket *sock = file->private_data;
 	size_t size = 0;
 	int i;
 
-        for (i = 0 ; i < nr_segs ; i++)
-                size += iov[i].iov_len;
+	for (i = 0; i < nr_segs; i++)
+		size += iov[i].iov_len;
 
 	msg->msg_name = NULL;
 	msg->msg_namelen = 0;
 	msg->msg_control = NULL;
 	msg->msg_controllen = 0;
-	msg->msg_iov = (struct iovec *) iov;
+	msg->msg_iov = (struct iovec *)iov;
 	msg->msg_iovlen = nr_segs;
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 	if (sock->type == SOCK_SEQPACKET)
@@ -798,7 +807,7 @@
 }
 
 static ssize_t sock_writev(struct file *file, const struct iovec *iov,
-			   unsigned long nr_segs, loff_t *ppos)
+			   unsigned long nr_segs, loff_t * ppos)
 {
 	struct msghdr msg;
 	struct kiocb iocb;
@@ -814,8 +823,8 @@
 	return ret;
 }
 
-static ssize_t sock_aio_write(struct kiocb *iocb, const char __user *ubuf,
-			  size_t count, loff_t pos)
+static ssize_t sock_aio_write(struct kiocb *iocb, const char __user * ubuf,
+			      size_t count, loff_t pos)
 {
 	struct sock_iocb siocb, *x;
 
@@ -829,46 +838,48 @@
 		return -ENOMEM;
 
 	return do_sock_write(&x->async_msg, iocb, iocb->ki_filp,
-			&x->async_iov, 1);
+			     &x->async_iov, 1);
 }
 
-
 /*
  * Atomic setting of ioctl hooks to avoid race
  * with module unload.
  */
 
 static DEFINE_MUTEX(br_ioctl_mutex);
-static int (*br_ioctl_hook)(unsigned int cmd, void __user *arg) = NULL;
+static int (*br_ioctl_hook) (unsigned int cmd, void __user * arg) = NULL;
 
-void brioctl_set(int (*hook)(unsigned int, void __user *))
+void brioctl_set(int (*hook) (unsigned int, void __user *))
 {
 	mutex_lock(&br_ioctl_mutex);
 	br_ioctl_hook = hook;
 	mutex_unlock(&br_ioctl_mutex);
 }
+
 EXPORT_SYMBOL(brioctl_set);
 
 static DEFINE_MUTEX(vlan_ioctl_mutex);
-static int (*vlan_ioctl_hook)(void __user *arg);
+static int (*vlan_ioctl_hook) (void __user * arg);
 
-void vlan_ioctl_set(int (*hook)(void __user *))
+void vlan_ioctl_set(int (*hook) (void __user *))
 {
 	mutex_lock(&vlan_ioctl_mutex);
 	vlan_ioctl_hook = hook;
 	mutex_unlock(&vlan_ioctl_mutex);
 }
+
 EXPORT_SYMBOL(vlan_ioctl_set);
 
 static DEFINE_MUTEX(dlci_ioctl_mutex);
-static int (*dlci_ioctl_hook)(unsigned int, void __user *);
+static int (*dlci_ioctl_hook) (unsigned int, void __user *);
 
-void dlci_ioctl_set(int (*hook)(unsigned int, void __user *))
+void dlci_ioctl_set(int (*hook) (unsigned int, void __user *))
 {
 	mutex_lock(&dlci_ioctl_mutex);
 	dlci_ioctl_hook = hook;
 	mutex_unlock(&dlci_ioctl_mutex);
 }
+
 EXPORT_SYMBOL(dlci_ioctl_set);
 
 /*
@@ -890,8 +901,8 @@
 	if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST) {
 		err = dev_ioctl(cmd, argp);
 	} else
-#endif	/* CONFIG_WIRELESS_EXT */
-	switch (cmd) {
+#endif				/* CONFIG_WIRELESS_EXT */
+		switch (cmd) {
 		case FIOSETOWN:
 		case SIOCSPGRP:
 			err = -EFAULT;
@@ -901,7 +912,8 @@
 			break;
 		case FIOGETOWN:
 		case SIOCGPGRP:
-			err = put_user(sock->file->f_owner.pid, (int __user *)argp);
+			err = put_user(sock->file->f_owner.pid,
+				       (int __user *)argp);
 			break;
 		case SIOCGIFBR:
 		case SIOCSIFBR:
@@ -912,7 +924,7 @@
 				request_module("bridge");
 
 			mutex_lock(&br_ioctl_mutex);
-			if (br_ioctl_hook) 
+			if (br_ioctl_hook)
 				err = br_ioctl_hook(cmd, argp);
 			mutex_unlock(&br_ioctl_mutex);
 			break;
@@ -929,7 +941,7 @@
 			break;
 		case SIOCGIFDIVERT:
 		case SIOCSIFDIVERT:
-		/* Convert this to call through a hook */
+			/* Convert this to call through a hook */
 			err = divert_ioctl(cmd, argp);
 			break;
 		case SIOCADDDLCI:
@@ -954,7 +966,7 @@
 			if (err == -ENOIOCTLCMD)
 				err = dev_ioctl(cmd, argp);
 			break;
-	}
+		}
 	return err;
 }
 
@@ -962,7 +974,7 @@
 {
 	int err;
 	struct socket *sock = NULL;
-	
+
 	err = security_socket_create(family, type, protocol, 1);
 	if (err)
 		goto out;
@@ -986,13 +998,13 @@
 	struct socket *sock;
 
 	/*
-	 *	We can't return errors to poll, so it's either yes or no. 
+	 *      We can't return errors to poll, so it's either yes or no.
 	 */
 	sock = file->private_data;
 	return sock->ops->poll(file, sock, wait);
 }
 
-static int sock_mmap(struct file * file, struct vm_area_struct * vma)
+static int sock_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct socket *sock = file->private_data;
 
@@ -1002,12 +1014,11 @@
 static int sock_close(struct inode *inode, struct file *filp)
 {
 	/*
-	 *	It was possible the inode is NULL we were 
-	 *	closing an unfinished socket. 
+	 *      It was possible the inode is NULL we were
+	 *      closing an unfinished socket.
 	 */
 
-	if (!inode)
-	{
+	if (!inode) {
 		printk(KERN_DEBUG "sock_close: NULL inode\n");
 		return 0;
 	}
@@ -1033,57 +1044,52 @@
 
 static int sock_fasync(int fd, struct file *filp, int on)
 {
-	struct fasync_struct *fa, *fna=NULL, **prev;
+	struct fasync_struct *fa, *fna = NULL, **prev;
 	struct socket *sock;
 	struct sock *sk;
 
-	if (on)
-	{
+	if (on) {
 		fna = kmalloc(sizeof(struct fasync_struct), GFP_KERNEL);
-		if(fna==NULL)
+		if (fna == NULL)
 			return -ENOMEM;
 	}
 
 	sock = filp->private_data;
 
-	if ((sk=sock->sk) == NULL) {
+	sk = sock->sk;
+	if (sk == NULL) {
 		kfree(fna);
 		return -EINVAL;
 	}
 
 	lock_sock(sk);
 
-	prev=&(sock->fasync_list);
+	prev = &(sock->fasync_list);
 
-	for (fa=*prev; fa!=NULL; prev=&fa->fa_next,fa=*prev)
-		if (fa->fa_file==filp)
+	for (fa = *prev; fa != NULL; prev = &fa->fa_next, fa = *prev)
+		if (fa->fa_file == filp)
 			break;
 
-	if(on)
-	{
-		if(fa!=NULL)
-		{
+	if (on) {
+		if (fa != NULL) {
 			write_lock_bh(&sk->sk_callback_lock);
-			fa->fa_fd=fd;
+			fa->fa_fd = fd;
 			write_unlock_bh(&sk->sk_callback_lock);
 
 			kfree(fna);
 			goto out;
 		}
-		fna->fa_file=filp;
-		fna->fa_fd=fd;
-		fna->magic=FASYNC_MAGIC;
-		fna->fa_next=sock->fasync_list;
+		fna->fa_file = filp;
+		fna->fa_fd = fd;
+		fna->magic = FASYNC_MAGIC;
+		fna->fa_next = sock->fasync_list;
 		write_lock_bh(&sk->sk_callback_lock);
-		sock->fasync_list=fna;
+		sock->fasync_list = fna;
 		write_unlock_bh(&sk->sk_callback_lock);
-	}
-	else
-	{
-		if (fa!=NULL)
-		{
+	} else {
+		if (fa != NULL) {
 			write_lock_bh(&sk->sk_callback_lock);
-			*prev=fa->fa_next;
+			*prev = fa->fa_next;
 			write_unlock_bh(&sk->sk_callback_lock);
 			kfree(fa);
 		}
@@ -1100,10 +1106,9 @@
 {
 	if (!sock || !sock->fasync_list)
 		return -1;
-	switch (how)
-	{
+	switch (how) {
 	case 1:
-		
+
 		if (test_bit(SOCK_ASYNC_WAITDATA, &sock->flags))
 			break;
 		goto call_kill;
@@ -1112,7 +1117,7 @@
 			break;
 		/* fall through */
 	case 0:
-	call_kill:
+call_kill:
 		__kill_fasync(sock->fasync_list, SIGIO, band);
 		break;
 	case 3:
@@ -1121,13 +1126,14 @@
 	return 0;
 }
 
-static int __sock_create(int family, int type, int protocol, struct socket **res, int kern)
+static int __sock_create(int family, int type, int protocol,
+			 struct socket **res, int kern)
 {
 	int err;
 	struct socket *sock;
 
 	/*
-	 *	Check protocol is in range
+	 *      Check protocol is in range
 	 */
 	if (family < 0 || family >= NPROTO)
 		return -EAFNOSUPPORT;
@@ -1140,10 +1146,11 @@
 	   deadlock in module load.
 	 */
 	if (family == PF_INET && type == SOCK_PACKET) {
-		static int warned; 
+		static int warned;
 		if (!warned) {
 			warned = 1;
-			printk(KERN_INFO "%s uses obsolete (PF_INET,SOCK_PACKET)\n", current->comm);
+			printk(KERN_INFO "%s uses obsolete (PF_INET,SOCK_PACKET)\n",
+			       current->comm);
 		}
 		family = PF_PACKET;
 	}
@@ -1151,17 +1158,16 @@
 	err = security_socket_create(family, type, protocol, kern);
 	if (err)
 		return err;
-		
+
 #if defined(CONFIG_KMOD)
-	/* Attempt to load a protocol module if the find failed. 
-	 * 
-	 * 12/09/1996 Marcin: But! this makes REALLY only sense, if the user 
+	/* Attempt to load a protocol module if the find failed.
+	 *
+	 * 12/09/1996 Marcin: But! this makes REALLY only sense, if the user
 	 * requested real, full-featured networking support upon configuration.
 	 * Otherwise module support will break!
 	 */
-	if (net_families[family]==NULL)
-	{
-		request_module("net-pf-%d",family);
+	if (net_families[family] == NULL) {
+		request_module("net-pf-%d", family);
 	}
 #endif
 
@@ -1179,12 +1185,12 @@
 
 	if (!(sock = sock_alloc())) {
 		printk(KERN_WARNING "socket: no more sockets\n");
-		err = -ENFILE;		/* Not exactly a match, but its the
-					   closest posix thing */
+		err = -ENFILE;	/* Not exactly a match, but its the
+				   closest posix thing */
 		goto out;
 	}
 
-	sock->type  = type;
+	sock->type = type;
 
 	/*
 	 * We will call the ->create function, that possibly is in a loadable
@@ -1262,7 +1268,8 @@
  *	Create a pair of connected sockets.
  */
 
-asmlinkage long sys_socketpair(int family, int type, int protocol, int __user *usockvec)
+asmlinkage long sys_socketpair(int family, int type, int protocol,
+			       int __user * usockvec)
 {
 	struct socket *sock1, *sock2;
 	int fd1, fd2, err;
@@ -1281,7 +1288,7 @@
 		goto out_release_1;
 
 	err = sock1->ops->socketpair(sock1, sock2);
-	if (err < 0) 
+	if (err < 0)
 		goto out_release_both;
 
 	fd1 = fd2 = -1;
@@ -1300,7 +1307,7 @@
 	 * Not kernel problem.
 	 */
 
-	err = put_user(fd1, &usockvec[0]); 
+	err = put_user(fd1, &usockvec[0]);
 	if (!err)
 		err = put_user(fd2, &usockvec[1]);
 	if (!err)
@@ -1311,19 +1318,18 @@
 	return err;
 
 out_close_1:
-        sock_release(sock2);
+	sock_release(sock2);
 	sys_close(fd1);
 	return err;
 
 out_release_both:
-        sock_release(sock2);
+	sock_release(sock2);
 out_release_1:
-        sock_release(sock1);
+	sock_release(sock1);
 out:
 	return err;
 }
 
-
 /*
  *	Bind a name to a socket. Nothing much to do here since it's
  *	the protocol's responsibility to handle the local address.
@@ -1332,26 +1338,29 @@
  *	the protocol layer (having also checked the address is ok).
  */
 
-asmlinkage long sys_bind(int fd, struct sockaddr __user *umyaddr, int addrlen)
+asmlinkage long sys_bind(int fd, struct sockaddr __user * umyaddr, int addrlen)
 {
 	struct socket *sock;
 	char address[MAX_SOCK_ADDR];
 	int err, fput_needed;
 
-	if((sock = sockfd_lookup_light(fd, &err, &fput_needed))!=NULL)
-	{
-		if((err=move_addr_to_kernel(umyaddr,addrlen,address))>=0) {
-			err = security_socket_bind(sock, (struct sockaddr *)address, addrlen);
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	if(sock) {
+		err = move_addr_to_kernel(umyaddr, addrlen, address);
+		if (err >= 0) {
+			err = security_socket_bind(sock,
+						   (struct sockaddr *)address,
+						   addrlen);
 			if (!err)
 				err = sock->ops->bind(sock,
-					(struct sockaddr *)address, addrlen);
+						      (struct sockaddr *)
+						      address, addrlen);
 		}
 		fput_light(sock->file, fput_needed);
-	}			
+	}
 	return err;
 }
 
-
 /*
  *	Perform a listen. Basically, we allow the protocol to do anything
  *	necessary for a listen, and if that works, we mark the socket as
@@ -1364,9 +1373,10 @@
 {
 	struct socket *sock;
 	int err, fput_needed;
-	
-	if ((sock = sockfd_lookup_light(fd, &err, &fput_needed)) != NULL) {
-		if ((unsigned) backlog > sysctl_somaxconn)
+
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	if (sock) {
+		if ((unsigned)backlog > sysctl_somaxconn)
 			backlog = sysctl_somaxconn;
 
 		err = security_socket_listen(sock, backlog);
@@ -1378,7 +1388,6 @@
 	return err;
 }
 
-
 /*
  *	For accept, we attempt to create a new socket, set up the link
  *	with the client, wake up the client, then return the new
@@ -1391,7 +1400,8 @@
  *	clean when we restucture accept also.
  */
 
-asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr, int __user *upeer_addrlen)
+asmlinkage long sys_accept(int fd, struct sockaddr __user * upeer_sockaddr,
+			   int __user * upeer_addrlen)
 {
 	struct socket *sock, *newsock;
 	struct file *newfile;
@@ -1403,7 +1413,7 @@
 		goto out;
 
 	err = -ENFILE;
-	if (!(newsock = sock_alloc())) 
+	if (!(newsock = sock_alloc()))
 		goto out_put;
 
 	newsock->type = sock->type;
@@ -1435,11 +1445,13 @@
 		goto out_fd;
 
 	if (upeer_sockaddr) {
-		if(newsock->ops->getname(newsock, (struct sockaddr *)address, &len, 2)<0) {
+		if (newsock->ops->getname(newsock, (struct sockaddr *)address,
+					  &len, 2) < 0) {
 			err = -ECONNABORTED;
 			goto out_fd;
 		}
-		err = move_addr_to_user(address, len, upeer_sockaddr, upeer_addrlen);
+		err = move_addr_to_user(address, len, upeer_sockaddr,
+					upeer_addrlen);
 		if (err < 0)
 			goto out_fd;
 	}
@@ -1461,7 +1473,6 @@
 	goto out_put;
 }
 
-
 /*
  *	Attempt to connect to a socket with the server address.  The address
  *	is in user space so we verify it is OK and move it to kernel space.
@@ -1474,7 +1485,8 @@
  *	include the -EINPROGRESS status for such sockets.
  */
 
-asmlinkage long sys_connect(int fd, struct sockaddr __user *uservaddr, int addrlen)
+asmlinkage long sys_connect(int fd, struct sockaddr __user * uservaddr,
+			    int addrlen)
 {
 	struct socket *sock;
 	char address[MAX_SOCK_ADDR];
@@ -1487,11 +1499,12 @@
 	if (err < 0)
 		goto out_put;
 
-	err = security_socket_connect(sock, (struct sockaddr *)address, addrlen);
+	err =
+	    security_socket_connect(sock, (struct sockaddr *)address, addrlen);
 	if (err)
 		goto out_put;
 
-	err = sock->ops->connect(sock, (struct sockaddr *) address, addrlen,
+	err = sock->ops->connect(sock, (struct sockaddr *)address, addrlen,
 				 sock->file->f_flags);
 out_put:
 	fput_light(sock->file, fput_needed);
@@ -1504,12 +1517,13 @@
  *	name to user space.
  */
 
-asmlinkage long sys_getsockname(int fd, struct sockaddr __user *usockaddr, int __user *usockaddr_len)
+asmlinkage long sys_getsockname(int fd, struct sockaddr __user * usockaddr,
+				int __user * usockaddr_len)
 {
 	struct socket *sock;
 	char address[MAX_SOCK_ADDR];
 	int len, err, fput_needed;
-	
+
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
 		goto out;
@@ -1534,22 +1548,27 @@
  *	name to user space.
  */
 
-asmlinkage long sys_getpeername(int fd, struct sockaddr __user *usockaddr, int __user *usockaddr_len)
+asmlinkage long sys_getpeername(int fd, struct sockaddr __user * usockaddr,
+				int __user * usockaddr_len)
 {
 	struct socket *sock;
 	char address[MAX_SOCK_ADDR];
 	int len, err, fput_needed;
 
-	if ((sock = sockfd_lookup_light(fd, &err, &fput_needed)) != NULL) {
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	if (sock != NULL) {
 		err = security_socket_getpeername(sock);
 		if (err) {
 			fput_light(sock->file, fput_needed);
 			return err;
 		}
 
-		err = sock->ops->getname(sock, (struct sockaddr *)address, &len, 1);
+		err =
+		    sock->ops->getname(sock, (struct sockaddr *)address, &len,
+				       1);
 		if (!err)
-			err=move_addr_to_user(address,len, usockaddr, usockaddr_len);
+			err = move_addr_to_user(address, len, usockaddr,
+						usockaddr_len);
 		fput_light(sock->file, fput_needed);
 	}
 	return err;
@@ -1561,8 +1580,9 @@
  *	the protocol.
  */
 
-asmlinkage long sys_sendto(int fd, void __user * buff, size_t len, unsigned flags,
-			   struct sockaddr __user *addr, int addr_len)
+asmlinkage long sys_sendto(int fd, void __user * buff, size_t len,
+			   unsigned flags, struct sockaddr __user * addr,
+			   int addr_len)
 {
 	struct socket *sock;
 	char address[MAX_SOCK_ADDR];
@@ -1579,33 +1599,33 @@
 	sock = sock_from_file(sock_file, &err);
 	if (!sock)
 		goto out_put;
-	iov.iov_base=buff;
-	iov.iov_len=len;
-	msg.msg_name=NULL;
-	msg.msg_iov=&iov;
-	msg.msg_iovlen=1;
-	msg.msg_control=NULL;
-	msg.msg_controllen=0;
-	msg.msg_namelen=0;
+	iov.iov_base = buff;
+	iov.iov_len = len;
+	msg.msg_name = NULL;
+	msg.msg_iov = &iov;
+	msg.msg_iovlen = 1;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_namelen = 0;
 	if (addr) {
 		err = move_addr_to_kernel(addr, addr_len, address);
 		if (err < 0)
 			goto out_put;
-		msg.msg_name=address;
-		msg.msg_namelen=addr_len;
+		msg.msg_name = address;
+		msg.msg_namelen = addr_len;
 	}
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	msg.msg_flags = flags;
 	err = sock_sendmsg(sock, &msg, len);
 
-out_put:		
+out_put:
 	fput_light(sock_file, fput_needed);
 	return err;
 }
 
 /*
- *	Send a datagram down a socket. 
+ *	Send a datagram down a socket.
  */
 
 asmlinkage long sys_send(int fd, void __user * buff, size_t len, unsigned flags)
@@ -1614,19 +1634,20 @@
 }
 
 /*
- *	Receive a frame from the socket and optionally record the address of the 
+ *	Receive a frame from the socket and optionally record the address of the
  *	sender. We verify the buffers are writable and if needed move the
  *	sender address from kernel to user space.
  */
 
-asmlinkage long sys_recvfrom(int fd, void __user * ubuf, size_t size, unsigned flags,
-			     struct sockaddr __user *addr, int __user *addr_len)
+asmlinkage long sys_recvfrom(int fd, void __user * ubuf, size_t size,
+			     unsigned flags, struct sockaddr __user * addr,
+			     int __user * addr_len)
 {
 	struct socket *sock;
 	struct iovec iov;
 	struct msghdr msg;
 	char address[MAX_SOCK_ADDR];
-	int err,err2;
+	int err, err2;
 	struct file *sock_file;
 	int fput_needed;
 
@@ -1638,23 +1659,22 @@
 	if (!sock)
 		goto out;
 
-	msg.msg_control=NULL;
-	msg.msg_controllen=0;
-	msg.msg_iovlen=1;
-	msg.msg_iov=&iov;
-	iov.iov_len=size;
-	iov.iov_base=ubuf;
-	msg.msg_name=address;
-	msg.msg_namelen=MAX_SOCK_ADDR;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_iovlen = 1;
+	msg.msg_iov = &iov;
+	iov.iov_len = size;
+	iov.iov_base = ubuf;
+	msg.msg_name = address;
+	msg.msg_namelen = MAX_SOCK_ADDR;
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
-	err=sock_recvmsg(sock, &msg, size, flags);
+	err = sock_recvmsg(sock, &msg, size, flags);
 
-	if(err >= 0 && addr != NULL)
-	{
-		err2=move_addr_to_user(address, msg.msg_namelen, addr, addr_len);
-		if(err2<0)
-			err=err2;
+	if (err >= 0 && addr != NULL) {
+		err2 = move_addr_to_user(address, msg.msg_namelen, addr, addr_len);
+		if (err2 < 0)
+			err = err2;
 	}
 out:
 	fput_light(sock_file, fput_needed);
@@ -1662,10 +1682,11 @@
 }
 
 /*
- *	Receive a datagram from a socket. 
+ *	Receive a datagram from a socket.
  */
 
-asmlinkage long sys_recv(int fd, void __user * ubuf, size_t size, unsigned flags)
+asmlinkage long sys_recv(int fd, void __user * ubuf, size_t size,
+			 unsigned flags)
 {
 	return sys_recvfrom(fd, ubuf, size, flags, NULL, NULL);
 }
@@ -1675,24 +1696,29 @@
  *	to pass the user mode parameter for the protocols to sort out.
  */
 
-asmlinkage long sys_setsockopt(int fd, int level, int optname, char __user *optval, int optlen)
+asmlinkage long sys_setsockopt(int fd, int level, int optname,
+			       char __user * optval, int optlen)
 {
 	int err, fput_needed;
 	struct socket *sock;
 
 	if (optlen < 0)
 		return -EINVAL;
-			
-	if ((sock = sockfd_lookup_light(fd, &err, &fput_needed)) != NULL)
-	{
-		err = security_socket_setsockopt(sock,level,optname);
+
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	if (sock != NULL) {
+		err = security_socket_setsockopt(sock, level, optname);
 		if (err)
 			goto out_put;
 
 		if (level == SOL_SOCKET)
-			err=sock_setsockopt(sock,level,optname,optval,optlen);
+			err =
+			    sock_setsockopt(sock, level, optname, optval,
+					    optlen);
 		else
-			err=sock->ops->setsockopt(sock, level, optname, optval, optlen);
+			err =
+			    sock->ops->setsockopt(sock, level, optname, optval,
+						  optlen);
 out_put:
 		fput_light(sock->file, fput_needed);
 	}
@@ -1704,27 +1730,32 @@
  *	to pass a user mode parameter for the protocols to sort out.
  */
 
-asmlinkage long sys_getsockopt(int fd, int level, int optname, char __user *optval, int __user *optlen)
+asmlinkage long sys_getsockopt(int fd, int level, int optname,
+			       char __user * optval, int __user * optlen)
 {
 	int err, fput_needed;
 	struct socket *sock;
 
-	if ((sock = sockfd_lookup_light(fd, &err, &fput_needed)) != NULL) {
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	if (sock != NULL) {
 		err = security_socket_getsockopt(sock, level, optname);
 		if (err)
 			goto out_put;
 
 		if (level == SOL_SOCKET)
-			err=sock_getsockopt(sock,level,optname,optval,optlen);
+			err =
+			    sock_getsockopt(sock, level, optname, optval,
+					    optlen);
 		else
-			err=sock->ops->getsockopt(sock, level, optname, optval, optlen);
+			err =
+			    sock->ops->getsockopt(sock, level, optname, optval,
+						  optlen);
 out_put:
 		fput_light(sock->file, fput_needed);
 	}
 	return err;
 }
 
-
 /*
  *	Shutdown a socket.
  */
@@ -1734,8 +1765,8 @@
 	int err, fput_needed;
 	struct socket *sock;
 
-	if ((sock = sockfd_lookup_light(fd, &err, &fput_needed))!=NULL)
-	{
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	if (sock != NULL) {
 		err = security_socket_shutdown(sock, how);
 		if (!err)
 			err = sock->ops->shutdown(sock, how);
@@ -1744,41 +1775,42 @@
 	return err;
 }
 
-/* A couple of helpful macros for getting the address of the 32/64 bit 
+/* A couple of helpful macros for getting the address of the 32/64 bit
  * fields which are the same type (int / unsigned) on our platforms.
  */
 #define COMPAT_MSG(msg, member)	((MSG_CMSG_COMPAT & flags) ? &msg##_compat->member : &msg->member)
 #define COMPAT_NAMELEN(msg)	COMPAT_MSG(msg, msg_namelen)
 #define COMPAT_FLAGS(msg)	COMPAT_MSG(msg, msg_flags)
 
-
 /*
  *	BSD sendmsg interface
  */
 
-asmlinkage long sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags)
+asmlinkage long sys_sendmsg(int fd, struct msghdr __user * msg, unsigned flags)
 {
-	struct compat_msghdr __user *msg_compat = (struct compat_msghdr __user *)msg;
+	struct compat_msghdr __user *msg_compat =
+	    (struct compat_msghdr __user *)msg;
 	struct socket *sock;
 	char address[MAX_SOCK_ADDR];
 	struct iovec iovstack[UIO_FASTIOV], *iov = iovstack;
 	unsigned char ctl[sizeof(struct cmsghdr) + 20]
-			__attribute__ ((aligned (sizeof(__kernel_size_t))));
-			/* 20 is size of ipv6_pktinfo */
+	    __attribute__ ((aligned(sizeof(__kernel_size_t))));
+	/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
 	struct msghdr msg_sys;
 	int err, ctl_len, iov_size, total_len;
 	int fput_needed;
-	
+
 	err = -EFAULT;
 	if (MSG_CMSG_COMPAT & flags) {
 		if (get_compat_msghdr(&msg_sys, msg_compat))
 			return -EFAULT;
-	} else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
+	}
+	else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
-	if (!sock) 
+	if (!sock)
 		goto out;
 
 	/* do not move before msg_sys is valid */
@@ -1786,7 +1818,7 @@
 	if (msg_sys.msg_iovlen > UIO_MAXIOV)
 		goto out_put;
 
-	/* Check whether to allocate the iovec area*/
+	/* Check whether to allocate the iovec area */
 	err = -ENOMEM;
 	iov_size = msg_sys.msg_iovlen * sizeof(struct iovec);
 	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
@@ -1800,7 +1832,7 @@
 		err = verify_compat_iovec(&msg_sys, iov, address, VERIFY_READ);
 	} else
 		err = verify_iovec(&msg_sys, iov, address, VERIFY_READ);
-	if (err < 0) 
+	if (err < 0)
 		goto out_freeiov;
 	total_len = err;
 
@@ -1808,18 +1840,19 @@
 
 	if (msg_sys.msg_controllen > INT_MAX)
 		goto out_freeiov;
-	ctl_len = msg_sys.msg_controllen; 
+	ctl_len = msg_sys.msg_controllen;
 	if ((MSG_CMSG_COMPAT & flags) && ctl_len) {
-		err = cmsghdr_from_user_compat_to_kern(&msg_sys, sock->sk, ctl, sizeof(ctl));
+		err =
+		    cmsghdr_from_user_compat_to_kern(&msg_sys, sock->sk, ctl,
+						     sizeof(ctl));
 		if (err)
 			goto out_freeiov;
 		ctl_buf = msg_sys.msg_control;
 		ctl_len = msg_sys.msg_controllen;
 	} else if (ctl_len) {
-		if (ctl_len > sizeof(ctl))
-		{
+		if (ctl_len > sizeof(ctl)) {
 			ctl_buf = sock_kmalloc(sock->sk, ctl_len, GFP_KERNEL);
-			if (ctl_buf == NULL) 
+			if (ctl_buf == NULL)
 				goto out_freeiov;
 		}
 		err = -EFAULT;
@@ -1828,7 +1861,8 @@
 		 * Afterwards, it will be a kernel pointer. Thus the compiler-assisted
 		 * checking falls down on this.
 		 */
-		if (copy_from_user(ctl_buf, (void __user *) msg_sys.msg_control, ctl_len))
+		if (copy_from_user(ctl_buf, (void __user *)msg_sys.msg_control,
+				   ctl_len))
 			goto out_freectl;
 		msg_sys.msg_control = ctl_buf;
 	}
@@ -1839,14 +1873,14 @@
 	err = sock_sendmsg(sock, &msg_sys, total_len);
 
 out_freectl:
-	if (ctl_buf != ctl)    
+	if (ctl_buf != ctl)
 		sock_kfree_s(sock->sk, ctl_buf, ctl_len);
 out_freeiov:
 	if (iov != iovstack)
 		sock_kfree_s(sock->sk, iov, iov_size);
 out_put:
 	fput_light(sock->file, fput_needed);
-out:       
+out:
 	return err;
 }
 
@@ -1854,12 +1888,14 @@
  *	BSD recvmsg interface
  */
 
-asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg, unsigned int flags)
+asmlinkage long sys_recvmsg(int fd, struct msghdr __user * msg,
+			    unsigned int flags)
 {
-	struct compat_msghdr __user *msg_compat = (struct compat_msghdr __user *)msg;
+	struct compat_msghdr __user *msg_compat =
+	    (struct compat_msghdr __user *)msg;
 	struct socket *sock;
 	struct iovec iovstack[UIO_FASTIOV];
-	struct iovec *iov=iovstack;
+	struct iovec *iov = iovstack;
 	struct msghdr msg_sys;
 	unsigned long cmsg_ptr;
 	int err, iov_size, total_len, len;
@@ -1871,13 +1907,13 @@
 	/* user mode address pointers */
 	struct sockaddr __user *uaddr;
 	int __user *uaddr_len;
-	
+
 	if (MSG_CMSG_COMPAT & flags) {
 		if (get_compat_msghdr(&msg_sys, msg_compat))
 			return -EFAULT;
-	} else
-		if (copy_from_user(&msg_sys,msg,sizeof(struct msghdr)))
-			return -EFAULT;
+	}
+	else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
+		return -EFAULT;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
@@ -1886,8 +1922,8 @@
 	err = -EMSGSIZE;
 	if (msg_sys.msg_iovlen > UIO_MAXIOV)
 		goto out_put;
-	
-	/* Check whether to allocate the iovec area*/
+
+	/* Check whether to allocate the iovec area */
 	err = -ENOMEM;
 	iov_size = msg_sys.msg_iovlen * sizeof(struct iovec);
 	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
@@ -1897,11 +1933,11 @@
 	}
 
 	/*
-	 *	Save the user-mode address (verify_iovec will change the
-	 *	kernel msghdr to use the kernel address space)
+	 *      Save the user-mode address (verify_iovec will change the
+	 *      kernel msghdr to use the kernel address space)
 	 */
-	 
-	uaddr = (void __user *) msg_sys.msg_name;
+
+	uaddr = (void __user *)msg_sys.msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags) {
 		err = verify_compat_iovec(&msg_sys, iov, addr, VERIFY_WRITE);
@@ -1909,13 +1945,13 @@
 		err = verify_iovec(&msg_sys, iov, addr, VERIFY_WRITE);
 	if (err < 0)
 		goto out_freeiov;
-	total_len=err;
+	total_len = err;
 
 	cmsg_ptr = (unsigned long)msg_sys.msg_control;
 	msg_sys.msg_flags = 0;
 	if (MSG_CMSG_COMPAT & flags)
 		msg_sys.msg_flags = MSG_CMSG_COMPAT;
-	
+
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	err = sock_recvmsg(sock, &msg_sys, total_len, flags);
@@ -1924,7 +1960,8 @@
 	len = err;
 
 	if (uaddr != NULL) {
-		err = move_addr_to_user(addr, msg_sys.msg_namelen, uaddr, uaddr_len);
+		err = move_addr_to_user(addr, msg_sys.msg_namelen, uaddr,
+					uaddr_len);
 		if (err < 0)
 			goto out_freeiov;
 	}
@@ -1933,10 +1970,10 @@
 	if (err)
 		goto out_freeiov;
 	if (MSG_CMSG_COMPAT & flags)
-		err = __put_user((unsigned long)msg_sys.msg_control-cmsg_ptr, 
+		err = __put_user((unsigned long)msg_sys.msg_control - cmsg_ptr,
 				 &msg_compat->msg_controllen);
 	else
-		err = __put_user((unsigned long)msg_sys.msg_control-cmsg_ptr, 
+		err = __put_user((unsigned long)msg_sys.msg_control - cmsg_ptr,
 				 &msg->msg_controllen);
 	if (err)
 		goto out_freeiov;
@@ -1955,102 +1992,113 @@
 
 /* Argument list sizes for sys_socketcall */
 #define AL(x) ((x) * sizeof(unsigned long))
-static unsigned char nargs[18]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
-				AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)};
+static const unsigned char nargs[18]={
+	AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
+	AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
+	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)
+};
+
 #undef AL
 
 /*
- *	System call vectors. 
+ *	System call vectors.
  *
  *	Argument checking cleaned up. Saved 20% in size.
  *  This function doesn't need to set the kernel lock because
- *  it is set by the callees. 
+ *  it is set by the callees.
  */
 
-asmlinkage long sys_socketcall(int call, unsigned long __user *args)
+asmlinkage long sys_socketcall(int call, unsigned long __user * args)
 {
 	unsigned long a[6];
-	unsigned long a0,a1;
+	unsigned long a0, a1;
 	int err;
 
-	if(call<1||call>SYS_RECVMSG)
+	if (call < 1 || call > SYS_RECVMSG)
 		return -EINVAL;
 
 	/* copy_from_user should be SMP safe. */
 	if (copy_from_user(a, args, nargs[call]))
 		return -EFAULT;
 
-	err = audit_socketcall(nargs[call]/sizeof(unsigned long), a);
+	err = audit_socketcall(nargs[call] / sizeof(unsigned long), a);
 	if (err)
 		return err;
 
-	a0=a[0];
-	a1=a[1];
-	
-	switch(call) 
-	{
-		case SYS_SOCKET:
-			err = sys_socket(a0,a1,a[2]);
-			break;
-		case SYS_BIND:
-			err = sys_bind(a0,(struct sockaddr __user *)a1, a[2]);
-			break;
-		case SYS_CONNECT:
-			err = sys_connect(a0, (struct sockaddr __user *)a1, a[2]);
-			break;
-		case SYS_LISTEN:
-			err = sys_listen(a0,a1);
-			break;
-		case SYS_ACCEPT:
-			err = sys_accept(a0,(struct sockaddr __user *)a1, (int __user *)a[2]);
-			break;
-		case SYS_GETSOCKNAME:
-			err = sys_getsockname(a0,(struct sockaddr __user *)a1, (int __user *)a[2]);
-			break;
-		case SYS_GETPEERNAME:
-			err = sys_getpeername(a0, (struct sockaddr __user *)a1, (int __user *)a[2]);
-			break;
-		case SYS_SOCKETPAIR:
-			err = sys_socketpair(a0,a1, a[2], (int __user *)a[3]);
-			break;
-		case SYS_SEND:
-			err = sys_send(a0, (void __user *)a1, a[2], a[3]);
-			break;
-		case SYS_SENDTO:
-			err = sys_sendto(a0,(void __user *)a1, a[2], a[3],
-					 (struct sockaddr __user *)a[4], a[5]);
-			break;
-		case SYS_RECV:
-			err = sys_recv(a0, (void __user *)a1, a[2], a[3]);
-			break;
-		case SYS_RECVFROM:
-			err = sys_recvfrom(a0, (void __user *)a1, a[2], a[3],
-					   (struct sockaddr __user *)a[4], (int __user *)a[5]);
-			break;
-		case SYS_SHUTDOWN:
-			err = sys_shutdown(a0,a1);
-			break;
-		case SYS_SETSOCKOPT:
-			err = sys_setsockopt(a0, a1, a[2], (char __user *)a[3], a[4]);
-			break;
-		case SYS_GETSOCKOPT:
-			err = sys_getsockopt(a0, a1, a[2], (char __user *)a[3], (int __user *)a[4]);
-			break;
-		case SYS_SENDMSG:
-			err = sys_sendmsg(a0, (struct msghdr __user *) a1, a[2]);
-			break;
-		case SYS_RECVMSG:
-			err = sys_recvmsg(a0, (struct msghdr __user *) a1, a[2]);
-			break;
-		default:
-			err = -EINVAL;
-			break;
+	a0 = a[0];
+	a1 = a[1];
+
+	switch (call) {
+	case SYS_SOCKET:
+		err = sys_socket(a0, a1, a[2]);
+		break;
+	case SYS_BIND:
+		err = sys_bind(a0, (struct sockaddr __user *)a1, a[2]);
+		break;
+	case SYS_CONNECT:
+		err = sys_connect(a0, (struct sockaddr __user *)a1, a[2]);
+		break;
+	case SYS_LISTEN:
+		err = sys_listen(a0, a1);
+		break;
+	case SYS_ACCEPT:
+		err =
+		    sys_accept(a0, (struct sockaddr __user *)a1,
+			       (int __user *)a[2]);
+		break;
+	case SYS_GETSOCKNAME:
+		err =
+		    sys_getsockname(a0, (struct sockaddr __user *)a1,
+				    (int __user *)a[2]);
+		break;
+	case SYS_GETPEERNAME:
+		err =
+		    sys_getpeername(a0, (struct sockaddr __user *)a1,
+				    (int __user *)a[2]);
+		break;
+	case SYS_SOCKETPAIR:
+		err = sys_socketpair(a0, a1, a[2], (int __user *)a[3]);
+		break;
+	case SYS_SEND:
+		err = sys_send(a0, (void __user *)a1, a[2], a[3]);
+		break;
+	case SYS_SENDTO:
+		err = sys_sendto(a0, (void __user *)a1, a[2], a[3],
+				 (struct sockaddr __user *)a[4], a[5]);
+		break;
+	case SYS_RECV:
+		err = sys_recv(a0, (void __user *)a1, a[2], a[3]);
+		break;
+	case SYS_RECVFROM:
+		err = sys_recvfrom(a0, (void __user *)a1, a[2], a[3],
+				   (struct sockaddr __user *)a[4],
+				   (int __user *)a[5]);
+		break;
+	case SYS_SHUTDOWN:
+		err = sys_shutdown(a0, a1);
+		break;
+	case SYS_SETSOCKOPT:
+		err = sys_setsockopt(a0, a1, a[2], (char __user *)a[3], a[4]);
+		break;
+	case SYS_GETSOCKOPT:
+		err =
+		    sys_getsockopt(a0, a1, a[2], (char __user *)a[3],
+				   (int __user *)a[4]);
+		break;
+	case SYS_SENDMSG:
+		err = sys_sendmsg(a0, (struct msghdr __user *)a1, a[2]);
+		break;
+	case SYS_RECVMSG:
+		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
+		break;
+	default:
+		err = -EINVAL;
+		break;
 	}
 	return err;
 }
 
-#endif /* __ARCH_WANT_SYS_SOCKETCALL */
+#endif				/* __ARCH_WANT_SYS_SOCKETCALL */
 
 /*
  *	This function is called by a protocol handler that wants to
@@ -2063,18 +2111,18 @@
 	int err;
 
 	if (ops->family >= NPROTO) {
-		printk(KERN_CRIT "protocol %d >= NPROTO(%d)\n", ops->family, NPROTO);
+		printk(KERN_CRIT "protocol %d >= NPROTO(%d)\n", ops->family,
+		       NPROTO);
 		return -ENOBUFS;
 	}
 	net_family_write_lock();
 	err = -EEXIST;
 	if (net_families[ops->family] == NULL) {
-		net_families[ops->family]=ops;
+		net_families[ops->family] = ops;
 		err = 0;
 	}
 	net_family_write_unlock();
-	printk(KERN_INFO "NET: Registered protocol family %d\n",
-	       ops->family);
+	printk(KERN_INFO "NET: Registered protocol family %d\n", ops->family);
 	return err;
 }
 
@@ -2090,28 +2138,27 @@
 		return -1;
 
 	net_family_write_lock();
-	net_families[family]=NULL;
+	net_families[family] = NULL;
 	net_family_write_unlock();
-	printk(KERN_INFO "NET: Unregistered protocol family %d\n",
-	       family);
+	printk(KERN_INFO "NET: Unregistered protocol family %d\n", family);
 	return 0;
 }
 
 static int __init sock_init(void)
 {
 	/*
-	 *	Initialize sock SLAB cache.
+	 *      Initialize sock SLAB cache.
 	 */
-	 
+
 	sk_init();
 
 	/*
-	 *	Initialize skbuff SLAB cache 
+	 *      Initialize skbuff SLAB cache
 	 */
 	skb_init();
 
 	/*
-	 *	Initialize the protocols module. 
+	 *      Initialize the protocols module.
 	 */
 
 	init_inodecache();
@@ -2137,7 +2184,7 @@
 	int counter = 0;
 
 	for_each_possible_cpu(cpu)
-		counter += per_cpu(sockets_in_use, cpu);
+	    counter += per_cpu(sockets_in_use, cpu);
 
 	/* It can be negative, by the way. 8) */
 	if (counter < 0)
@@ -2145,11 +2192,11 @@
 
 	seq_printf(seq, "sockets: used %d\n", counter);
 }
-#endif /* CONFIG_PROC_FS */
+#endif				/* CONFIG_PROC_FS */
 
 #ifdef CONFIG_COMPAT
 static long compat_sock_ioctl(struct file *file, unsigned cmd,
-				unsigned long arg)
+			      unsigned long arg)
 {
 	struct socket *sock = file->private_data;
 	int ret = -ENOIOCTLCMD;

--

