From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: net/socket.c and net/compat.c cleanups
Date: Thu, 03 Jun 2010 16:29:41 +0200
Message-ID: <1275575381.2456.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60574 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755449Ab0FCO3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 10:29:46 -0400
Received: by wyi11 with SMTP id 11so95794wyi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 07:29:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cleanup patch, to match modern coding style.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/compat.c |   47 ++++++-------
 net/socket.c |  165 +++++++++++++++++++++++--------------------------
 2 files changed, 102 insertions(+), 110 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 1cf7590..63d260e 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -81,7 +81,7 @@ int verify_compat_iovec(struct msghdr *kern_msg, struct iovec *kern_iov,
 	int tot_len;
 
 	if (kern_msg->msg_namelen) {
-		if (mode==VERIFY_READ) {
+		if (mode == VERIFY_READ) {
 			int err = move_addr_to_kernel(kern_msg->msg_name,
 						      kern_msg->msg_namelen,
 						      kern_address);
@@ -354,7 +354,7 @@ static int do_set_attach_filter(struct socket *sock, int level, int optname,
 static int do_set_sock_timeout(struct socket *sock, int level,
 		int optname, char __user *optval, unsigned int optlen)
 {
-	struct compat_timeval __user *up = (struct compat_timeval __user *) optval;
+	struct compat_timeval __user *up = (struct compat_timeval __user *)optval;
 	struct timeval ktime;
 	mm_segment_t old_fs;
 	int err;
@@ -367,7 +367,7 @@ static int do_set_sock_timeout(struct socket *sock, int level,
 		return -EFAULT;
 	old_fs = get_fs();
 	set_fs(KERNEL_DS);
-	err = sock_setsockopt(sock, level, optname, (char *) &ktime, sizeof(ktime));
+	err = sock_setsockopt(sock, level, optname, (char *)&ktime, sizeof(ktime));
 	set_fs(old_fs);
 
 	return err;
@@ -389,11 +389,10 @@ asmlinkage long compat_sys_setsockopt(int fd, int level, int optname,
 				char __user *optval, unsigned int optlen)
 {
 	int err;
-	struct socket *sock;
+	struct socket *sock = sockfd_lookup(fd, &err);
 
-	if ((sock = sockfd_lookup(fd, &err))!=NULL)
-	{
-		err = security_socket_setsockopt(sock,level,optname);
+	if (sock) {
+		err = security_socket_setsockopt(sock, level, optname);
 		if (err) {
 			sockfd_put(sock);
 			return err;
@@ -453,7 +452,7 @@ static int compat_sock_getsockopt(struct socket *sock, int level, int optname,
 int compat_sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 {
 	struct compat_timeval __user *ctv =
-			(struct compat_timeval __user*) userstamp;
+			(struct compat_timeval __user *) userstamp;
 	int err = -ENOENT;
 	struct timeval tv;
 
@@ -477,7 +476,7 @@ EXPORT_SYMBOL(compat_sock_get_timestamp);
 int compat_sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
 {
 	struct compat_timespec __user *ctv =
-			(struct compat_timespec __user*) userstamp;
+			(struct compat_timespec __user *) userstamp;
 	int err = -ENOENT;
 	struct timespec ts;
 
@@ -502,12 +501,10 @@ asmlinkage long compat_sys_getsockopt(int fd, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
 	int err;
-	struct socket *sock;
+	struct socket *sock = sockfd_lookup(fd, &err);
 
-	if ((sock = sockfd_lookup(fd, &err))!=NULL)
-	{
-		err = security_socket_getsockopt(sock, level,
-							   optname);
+	if (sock) {
+		err = security_socket_getsockopt(sock, level, optname);
 		if (err) {
 			sockfd_put(sock);
 			return err;
@@ -557,7 +554,7 @@ struct compat_group_filter {
 
 int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 	char __user *optval, unsigned int optlen,
-	int (*setsockopt)(struct sock *,int,int,char __user *,unsigned int))
+	int (*setsockopt)(struct sock *, int, int, char __user *, unsigned int))
 {
 	char __user	*koptval = optval;
 	int		koptlen = optlen;
@@ -640,12 +637,11 @@ int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 	}
 	return setsockopt(sock, level, optname, koptval, koptlen);
 }
-
 EXPORT_SYMBOL(compat_mc_setsockopt);
 
 int compat_mc_getsockopt(struct sock *sock, int level, int optname,
 	char __user *optval, int __user *optlen,
-	int (*getsockopt)(struct sock *,int,int,char __user *,int __user *))
+	int (*getsockopt)(struct sock *, int, int, char __user *, int __user *))
 {
 	struct compat_group_filter __user *gf32 = (void *)optval;
 	struct group_filter __user *kgf;
@@ -681,7 +677,7 @@ int compat_mc_getsockopt(struct sock *sock, int level, int optname,
 	    __put_user(interface, &kgf->gf_interface) ||
 	    __put_user(fmode, &kgf->gf_fmode) ||
 	    __put_user(numsrc, &kgf->gf_numsrc) ||
-	    copy_in_user(&kgf->gf_group,&gf32->gf_group,sizeof(kgf->gf_group)))
+	    copy_in_user(&kgf->gf_group, &gf32->gf_group, sizeof(kgf->gf_group)))
 		return -EFAULT;
 
 	err = getsockopt(sock, level, optname, (char __user *)kgf, koptlen);
@@ -714,21 +710,22 @@ int compat_mc_getsockopt(struct sock *sock, int level, int optname,
 		copylen = numsrc * sizeof(gf32->gf_slist[0]);
 		if (copylen > klen)
 			copylen = klen;
-	        if (copy_in_user(gf32->gf_slist, kgf->gf_slist, copylen))
+		if (copy_in_user(gf32->gf_slist, kgf->gf_slist, copylen))
 			return -EFAULT;
 	}
 	return err;
 }
-
 EXPORT_SYMBOL(compat_mc_getsockopt);
 
 
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
-static unsigned char nas[20]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
-				AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
-				AL(4),AL(5)};
+static unsigned char nas[20] = {
+	AL(0), AL(3), AL(3), AL(3), AL(2), AL(3),
+	AL(3), AL(3), AL(4), AL(4), AL(4), AL(6),
+	AL(6), AL(2), AL(5), AL(5), AL(3), AL(3),
+	AL(4), AL(5)
+};
 #undef AL
 
 asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned flags)
@@ -827,7 +824,7 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 					  compat_ptr(a[4]), compat_ptr(a[5]));
 		break;
 	case SYS_SHUTDOWN:
-		ret = sys_shutdown(a0,a1);
+		ret = sys_shutdown(a0, a1);
 		break;
 	case SYS_SETSOCKOPT:
 		ret = compat_sys_setsockopt(a0, a1, a[2],
diff --git a/net/socket.c b/net/socket.c
index 367d547..b63c051 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -124,7 +124,7 @@ static int sock_fasync(int fd, struct file *filp, int on);
 static ssize_t sock_sendpage(struct file *file, struct page *page,
 			     int offset, size_t size, loff_t *ppos, int more);
 static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
-			        struct pipe_inode_info *pipe, size_t len,
+				struct pipe_inode_info *pipe, size_t len,
 				unsigned int flags);
 
 /*
@@ -162,7 +162,7 @@ static const struct net_proto_family *net_families[NPROTO] __read_mostly;
  *	Statistics counters of the socket lists
  */
 
-static DEFINE_PER_CPU(int, sockets_in_use) = 0;
+static DEFINE_PER_CPU(int, sockets_in_use);
 
 /*
  * Support routines.
@@ -309,9 +309,9 @@ static int init_inodecache(void)
 }
 
 static const struct super_operations sockfs_ops = {
-	.alloc_inode =	sock_alloc_inode,
-	.destroy_inode =sock_destroy_inode,
-	.statfs =	simple_statfs,
+	.alloc_inode	= sock_alloc_inode,
+	.destroy_inode	= sock_destroy_inode,
+	.statfs		= simple_statfs,
 };
 
 static int sockfs_get_sb(struct file_system_type *fs_type,
@@ -411,6 +411,7 @@ int sock_map_fd(struct socket *sock, int flags)
 
 	return fd;
 }
+EXPORT_SYMBOL(sock_map_fd);
 
 static struct socket *sock_from_file(struct file *file, int *err)
 {
@@ -422,7 +423,7 @@ static struct socket *sock_from_file(struct file *file, int *err)
 }
 
 /**
- *	sockfd_lookup	- 	Go from a file number to its socket slot
+ *	sockfd_lookup - Go from a file number to its socket slot
  *	@fd: file handle
  *	@err: pointer to an error code return
  *
@@ -450,6 +451,7 @@ struct socket *sockfd_lookup(int fd, int *err)
 		fput(file);
 	return sock;
 }
+EXPORT_SYMBOL(sockfd_lookup);
 
 static struct socket *sockfd_lookup_light(int fd, int *err, int *fput_needed)
 {
@@ -540,6 +542,7 @@ void sock_release(struct socket *sock)
 	}
 	sock->file = NULL;
 }
+EXPORT_SYMBOL(sock_release);
 
 int sock_tx_timestamp(struct msghdr *msg, struct sock *sk,
 		      union skb_shared_tx *shtx)
@@ -586,6 +589,7 @@ int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 		ret = wait_on_sync_kiocb(&iocb);
 	return ret;
 }
+EXPORT_SYMBOL(sock_sendmsg);
 
 int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size)
@@ -604,6 +608,7 @@ int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 	set_fs(oldfs);
 	return result;
 }
+EXPORT_SYMBOL(kernel_sendmsg);
 
 static int ktime2ts(ktime_t kt, struct timespec *ts)
 {
@@ -664,7 +669,6 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 		put_cmsg(msg, SOL_SOCKET,
 			 SCM_TIMESTAMPING, sizeof(ts), &ts);
 }
-
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
 inline void sock_recv_drops(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
@@ -720,6 +724,7 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 		ret = wait_on_sync_kiocb(&iocb);
 	return ret;
 }
+EXPORT_SYMBOL(sock_recvmsg);
 
 static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
 			      size_t size, int flags)
@@ -752,6 +757,7 @@ int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 	set_fs(oldfs);
 	return result;
 }
+EXPORT_SYMBOL(kernel_recvmsg);
 
 static void sock_aio_dtor(struct kiocb *iocb)
 {
@@ -774,7 +780,7 @@ static ssize_t sock_sendpage(struct file *file, struct page *page,
 }
 
 static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
-			        struct pipe_inode_info *pipe, size_t len,
+				struct pipe_inode_info *pipe, size_t len,
 				unsigned int flags)
 {
 	struct socket *sock = file->private_data;
@@ -887,7 +893,7 @@ static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
  */
 
 static DEFINE_MUTEX(br_ioctl_mutex);
-static int (*br_ioctl_hook) (struct net *, unsigned int cmd, void __user *arg) = NULL;
+static int (*br_ioctl_hook) (struct net *, unsigned int cmd, void __user *arg);
 
 void brioctl_set(int (*hook) (struct net *, unsigned int, void __user *))
 {
@@ -895,7 +901,6 @@ void brioctl_set(int (*hook) (struct net *, unsigned int, void __user *))
 	br_ioctl_hook = hook;
 	mutex_unlock(&br_ioctl_mutex);
 }
-
 EXPORT_SYMBOL(brioctl_set);
 
 static DEFINE_MUTEX(vlan_ioctl_mutex);
@@ -907,7 +912,6 @@ void vlan_ioctl_set(int (*hook) (struct net *, void __user *))
 	vlan_ioctl_hook = hook;
 	mutex_unlock(&vlan_ioctl_mutex);
 }
-
 EXPORT_SYMBOL(vlan_ioctl_set);
 
 static DEFINE_MUTEX(dlci_ioctl_mutex);
@@ -919,7 +923,6 @@ void dlci_ioctl_set(int (*hook) (unsigned int, void __user *))
 	dlci_ioctl_hook = hook;
 	mutex_unlock(&dlci_ioctl_mutex);
 }
-
 EXPORT_SYMBOL(dlci_ioctl_set);
 
 static long sock_do_ioctl(struct net *net, struct socket *sock,
@@ -1047,6 +1050,7 @@ out_release:
 	sock = NULL;
 	goto out;
 }
+EXPORT_SYMBOL(sock_create_lite);
 
 /* No kernel lock held - perfect */
 static unsigned int sock_poll(struct file *file, poll_table *wait)
@@ -1147,6 +1151,7 @@ call_kill:
 	rcu_read_unlock();
 	return 0;
 }
+EXPORT_SYMBOL(sock_wake_async);
 
 static int __sock_create(struct net *net, int family, int type, int protocol,
 			 struct socket **res, int kern)
@@ -1265,11 +1270,13 @@ int sock_create(int family, int type, int protocol, struct socket **res)
 {
 	return __sock_create(current->nsproxy->net_ns, family, type, protocol, res, 0);
 }
+EXPORT_SYMBOL(sock_create);
 
 int sock_create_kern(int family, int type, int protocol, struct socket **res)
 {
 	return __sock_create(&init_net, family, type, protocol, res, 1);
 }
+EXPORT_SYMBOL(sock_create_kern);
 
 SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 {
@@ -1474,7 +1481,8 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 		goto out;
 
 	err = -ENFILE;
-	if (!(newsock = sock_alloc()))
+	newsock = sock_alloc();
+	if (!newsock)
 		goto out_put;
 
 	newsock->type = sock->type;
@@ -1861,8 +1869,7 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned, flags)
 	if (MSG_CMSG_COMPAT & flags) {
 		if (get_compat_msghdr(&msg_sys, msg_compat))
 			return -EFAULT;
-	}
-	else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
+	} else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
@@ -1964,8 +1971,7 @@ static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 	if (MSG_CMSG_COMPAT & flags) {
 		if (get_compat_msghdr(msg_sys, msg_compat))
 			return -EFAULT;
-	}
-	else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
+	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
 
 	err = -EMSGSIZE;
@@ -2191,10 +2197,10 @@ SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
 /* Argument list sizes for sys_socketcall */
 #define AL(x) ((x) * sizeof(unsigned long))
 static const unsigned char nargs[20] = {
-	AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
-	AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
-	AL(4),AL(5)
+	AL(0), AL(3), AL(3), AL(3), AL(2), AL(3),
+	AL(3), AL(3), AL(4), AL(4), AL(4), AL(6),
+	AL(6), AL(2), AL(5), AL(5), AL(3), AL(3),
+	AL(4), AL(5)
 };
 
 #undef AL
@@ -2340,6 +2346,7 @@ int sock_register(const struct net_proto_family *ops)
 	printk(KERN_INFO "NET: Registered protocol family %d\n", ops->family);
 	return err;
 }
+EXPORT_SYMBOL(sock_register);
 
 /**
  *	sock_unregister - remove a protocol handler
@@ -2366,6 +2373,7 @@ void sock_unregister(int family)
 
 	printk(KERN_INFO "NET: Unregistered protocol family %d\n", family);
 }
+EXPORT_SYMBOL(sock_unregister);
 
 static int __init sock_init(void)
 {
@@ -2490,13 +2498,13 @@ static int dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
 		ifc.ifc_req = NULL;
 		uifc = compat_alloc_user_space(sizeof(struct ifconf));
 	} else {
-		size_t len =((ifc32.ifc_len / sizeof (struct compat_ifreq)) + 1) *
-			sizeof (struct ifreq);
+		size_t len = ((ifc32.ifc_len / sizeof(struct compat_ifreq)) + 1) *
+			sizeof(struct ifreq);
 		uifc = compat_alloc_user_space(sizeof(struct ifconf) + len);
 		ifc.ifc_len = len;
 		ifr = ifc.ifc_req = (void __user *)(uifc + 1);
 		ifr32 = compat_ptr(ifc32.ifcbuf);
-		for (i = 0; i < ifc32.ifc_len; i += sizeof (struct compat_ifreq)) {
+		for (i = 0; i < ifc32.ifc_len; i += sizeof(struct compat_ifreq)) {
 			if (copy_in_user(ifr, ifr32, sizeof(struct compat_ifreq)))
 				return -EFAULT;
 			ifr++;
@@ -2516,9 +2524,9 @@ static int dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
 	ifr = ifc.ifc_req;
 	ifr32 = compat_ptr(ifc32.ifcbuf);
 	for (i = 0, j = 0;
-             i + sizeof (struct compat_ifreq) <= ifc32.ifc_len && j < ifc.ifc_len;
-	     i += sizeof (struct compat_ifreq), j += sizeof (struct ifreq)) {
-		if (copy_in_user(ifr32, ifr, sizeof (struct compat_ifreq)))
+	     i + sizeof(struct compat_ifreq) <= ifc32.ifc_len && j < ifc.ifc_len;
+	     i += sizeof(struct compat_ifreq), j += sizeof(struct ifreq)) {
+		if (copy_in_user(ifr32, ifr, sizeof(struct compat_ifreq)))
 			return -EFAULT;
 		ifr32++;
 		ifr++;
@@ -2567,7 +2575,7 @@ static int compat_siocwandev(struct net *net, struct compat_ifreq __user *uifr32
 	compat_uptr_t uptr32;
 	struct ifreq __user *uifr;
 
-	uifr = compat_alloc_user_space(sizeof (*uifr));
+	uifr = compat_alloc_user_space(sizeof(*uifr));
 	if (copy_in_user(uifr, uifr32, sizeof(struct compat_ifreq)))
 		return -EFAULT;
 
@@ -2601,9 +2609,9 @@ static int bond_ioctl(struct net *net, unsigned int cmd,
 			return -EFAULT;
 
 		old_fs = get_fs();
-		set_fs (KERNEL_DS);
+		set_fs(KERNEL_DS);
 		err = dev_ioctl(net, cmd, &kifr);
-		set_fs (old_fs);
+		set_fs(old_fs);
 
 		return err;
 	case SIOCBONDSLAVEINFOQUERY:
@@ -2710,9 +2718,9 @@ static int compat_sioc_ifmap(struct net *net, unsigned int cmd,
 		return -EFAULT;
 
 	old_fs = get_fs();
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	err = dev_ioctl(net, cmd, (void __user *)&ifr);
-	set_fs (old_fs);
+	set_fs(old_fs);
 
 	if (cmd == SIOCGIFMAP && !err) {
 		err = copy_to_user(uifr32, &ifr, sizeof(ifr.ifr_name));
@@ -2734,7 +2742,7 @@ static int compat_siocshwtstamp(struct net *net, struct compat_ifreq __user *uif
 	compat_uptr_t uptr32;
 	struct ifreq __user *uifr;
 
-	uifr = compat_alloc_user_space(sizeof (*uifr));
+	uifr = compat_alloc_user_space(sizeof(*uifr));
 	if (copy_in_user(uifr, uifr32, sizeof(struct compat_ifreq)))
 		return -EFAULT;
 
@@ -2750,20 +2758,20 @@ static int compat_siocshwtstamp(struct net *net, struct compat_ifreq __user *uif
 }
 
 struct rtentry32 {
-	u32   		rt_pad1;
+	u32		rt_pad1;
 	struct sockaddr rt_dst;         /* target address               */
 	struct sockaddr rt_gateway;     /* gateway addr (RTF_GATEWAY)   */
 	struct sockaddr rt_genmask;     /* target network mask (IP)     */
-	unsigned short  rt_flags;
-	short           rt_pad2;
-	u32   		rt_pad3;
-	unsigned char   rt_tos;
-	unsigned char   rt_class;
-	short           rt_pad4;
-	short           rt_metric;      /* +1 for binary compatibility! */
+	unsigned short	rt_flags;
+	short		rt_pad2;
+	u32		rt_pad3;
+	unsigned char	rt_tos;
+	unsigned char	rt_class;
+	short		rt_pad4;
+	short		rt_metric;      /* +1 for binary compatibility! */
 	/* char * */ u32 rt_dev;        /* forcing the device at add    */
-	u32   		rt_mtu;         /* per route MTU/Window         */
-	u32   		rt_window;      /* Window clamping              */
+	u32		rt_mtu;         /* per route MTU/Window         */
+	u32		rt_window;      /* Window clamping              */
 	unsigned short  rt_irtt;        /* Initial RTT                  */
 };
 
@@ -2793,29 +2801,29 @@ static int routing_ioctl(struct net *net, struct socket *sock,
 
 	if (sock && sock->sk && sock->sk->sk_family == AF_INET6) { /* ipv6 */
 		struct in6_rtmsg32 __user *ur6 = argp;
-		ret = copy_from_user (&r6.rtmsg_dst, &(ur6->rtmsg_dst),
+		ret = copy_from_user(&r6.rtmsg_dst, &(ur6->rtmsg_dst),
 			3 * sizeof(struct in6_addr));
-		ret |= __get_user (r6.rtmsg_type, &(ur6->rtmsg_type));
-		ret |= __get_user (r6.rtmsg_dst_len, &(ur6->rtmsg_dst_len));
-		ret |= __get_user (r6.rtmsg_src_len, &(ur6->rtmsg_src_len));
-		ret |= __get_user (r6.rtmsg_metric, &(ur6->rtmsg_metric));
-		ret |= __get_user (r6.rtmsg_info, &(ur6->rtmsg_info));
-		ret |= __get_user (r6.rtmsg_flags, &(ur6->rtmsg_flags));
-		ret |= __get_user (r6.rtmsg_ifindex, &(ur6->rtmsg_ifindex));
+		ret |= __get_user(r6.rtmsg_type, &(ur6->rtmsg_type));
+		ret |= __get_user(r6.rtmsg_dst_len, &(ur6->rtmsg_dst_len));
+		ret |= __get_user(r6.rtmsg_src_len, &(ur6->rtmsg_src_len));
+		ret |= __get_user(r6.rtmsg_metric, &(ur6->rtmsg_metric));
+		ret |= __get_user(r6.rtmsg_info, &(ur6->rtmsg_info));
+		ret |= __get_user(r6.rtmsg_flags, &(ur6->rtmsg_flags));
+		ret |= __get_user(r6.rtmsg_ifindex, &(ur6->rtmsg_ifindex));
 
 		r = (void *) &r6;
 	} else { /* ipv4 */
 		struct rtentry32 __user *ur4 = argp;
-		ret = copy_from_user (&r4.rt_dst, &(ur4->rt_dst),
+		ret = copy_from_user(&r4.rt_dst, &(ur4->rt_dst),
 					3 * sizeof(struct sockaddr));
-		ret |= __get_user (r4.rt_flags, &(ur4->rt_flags));
-		ret |= __get_user (r4.rt_metric, &(ur4->rt_metric));
-		ret |= __get_user (r4.rt_mtu, &(ur4->rt_mtu));
-		ret |= __get_user (r4.rt_window, &(ur4->rt_window));
-		ret |= __get_user (r4.rt_irtt, &(ur4->rt_irtt));
-		ret |= __get_user (rtdev, &(ur4->rt_dev));
+		ret |= __get_user(r4.rt_flags, &(ur4->rt_flags));
+		ret |= __get_user(r4.rt_metric, &(ur4->rt_metric));
+		ret |= __get_user(r4.rt_mtu, &(ur4->rt_mtu));
+		ret |= __get_user(r4.rt_window, &(ur4->rt_window));
+		ret |= __get_user(r4.rt_irtt, &(ur4->rt_irtt));
+		ret |= __get_user(rtdev, &(ur4->rt_dev));
 		if (rtdev) {
-			ret |= copy_from_user (devname, compat_ptr(rtdev), 15);
+			ret |= copy_from_user(devname, compat_ptr(rtdev), 15);
 			r4.rt_dev = devname; devname[15] = 0;
 		} else
 			r4.rt_dev = NULL;
@@ -2828,9 +2836,9 @@ static int routing_ioctl(struct net *net, struct socket *sock,
 		goto out;
 	}
 
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	ret = sock_do_ioctl(net, sock, cmd, (unsigned long) r);
-	set_fs (old_fs);
+	set_fs(old_fs);
 
 out:
 	return ret;
@@ -2993,11 +3001,13 @@ int kernel_bind(struct socket *sock, struct sockaddr *addr, int addrlen)
 {
 	return sock->ops->bind(sock, addr, addrlen);
 }
+EXPORT_SYMBOL(kernel_bind);
 
 int kernel_listen(struct socket *sock, int backlog)
 {
 	return sock->ops->listen(sock, backlog);
 }
+EXPORT_SYMBOL(kernel_listen);
 
 int kernel_accept(struct socket *sock, struct socket **newsock, int flags)
 {
@@ -3022,24 +3032,28 @@ int kernel_accept(struct socket *sock, struct socket **newsock, int flags)
 done:
 	return err;
 }
+EXPORT_SYMBOL(kernel_accept);
 
 int kernel_connect(struct socket *sock, struct sockaddr *addr, int addrlen,
 		   int flags)
 {
 	return sock->ops->connect(sock, addr, addrlen, flags);
 }
+EXPORT_SYMBOL(kernel_connect);
 
 int kernel_getsockname(struct socket *sock, struct sockaddr *addr,
 			 int *addrlen)
 {
 	return sock->ops->getname(sock, addr, addrlen, 0);
 }
+EXPORT_SYMBOL(kernel_getsockname);
 
 int kernel_getpeername(struct socket *sock, struct sockaddr *addr,
 			 int *addrlen)
 {
 	return sock->ops->getname(sock, addr, addrlen, 1);
 }
+EXPORT_SYMBOL(kernel_getpeername);
 
 int kernel_getsockopt(struct socket *sock, int level, int optname,
 			char *optval, int *optlen)
@@ -3056,6 +3070,7 @@ int kernel_getsockopt(struct socket *sock, int level, int optname,
 	set_fs(oldfs);
 	return err;
 }
+EXPORT_SYMBOL(kernel_getsockopt);
 
 int kernel_setsockopt(struct socket *sock, int level, int optname,
 			char *optval, unsigned int optlen)
@@ -3072,6 +3087,7 @@ int kernel_setsockopt(struct socket *sock, int level, int optname,
 	set_fs(oldfs);
 	return err;
 }
+EXPORT_SYMBOL(kernel_setsockopt);
 
 int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 		    size_t size, int flags)
@@ -3083,6 +3099,7 @@ int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 
 	return sock_no_sendpage(sock, page, offset, size, flags);
 }
+EXPORT_SYMBOL(kernel_sendpage);
 
 int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg)
 {
@@ -3095,33 +3112,11 @@ int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg)
 
 	return err;
 }
+EXPORT_SYMBOL(kernel_sock_ioctl);
 
 int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how)
 {
 	return sock->ops->shutdown(sock, how);
 }
-
-EXPORT_SYMBOL(sock_create);
-EXPORT_SYMBOL(sock_create_kern);
-EXPORT_SYMBOL(sock_create_lite);
-EXPORT_SYMBOL(sock_map_fd);
-EXPORT_SYMBOL(sock_recvmsg);
-EXPORT_SYMBOL(sock_register);
-EXPORT_SYMBOL(sock_release);
-EXPORT_SYMBOL(sock_sendmsg);
-EXPORT_SYMBOL(sock_unregister);
-EXPORT_SYMBOL(sock_wake_async);
-EXPORT_SYMBOL(sockfd_lookup);
-EXPORT_SYMBOL(kernel_sendmsg);
-EXPORT_SYMBOL(kernel_recvmsg);
-EXPORT_SYMBOL(kernel_bind);
-EXPORT_SYMBOL(kernel_listen);
-EXPORT_SYMBOL(kernel_accept);
-EXPORT_SYMBOL(kernel_connect);
-EXPORT_SYMBOL(kernel_getsockname);
-EXPORT_SYMBOL(kernel_getpeername);
-EXPORT_SYMBOL(kernel_getsockopt);
-EXPORT_SYMBOL(kernel_setsockopt);
-EXPORT_SYMBOL(kernel_sendpage);
-EXPORT_SYMBOL(kernel_sock_ioctl);
 EXPORT_SYMBOL(kernel_sock_shutdown);
+


