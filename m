From: Matthew Shaw <shaw500@gmail.com>
Subject: [PATCH] net: socket: fixed coding style issues.
Date: Mon, 11 Jun 2012 14:17:36 +0100
Message-ID: <1339420656-11512-1-git-send-email-shaw500@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matthew Shaw <shaw500@gmail.com>
To: davem@emloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed an instance where brances are used but not needed, and some lines
in the comments and code that exceed the 80 character limit.

Signed-off-by: Matthew Shaw <shaw500@gmail.com>
---
 net/socket.c |  137 ++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 75 insertions(+), 62 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 6e0ccc0..2133040 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -8,48 +8,48 @@
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *
  * Fixes:
- *		Anonymous	:	NOTSOCK/BADF cleanup. Error fix in
- *					shutdown()
- *		Alan Cox	:	verify_area() fixes
- *		Alan Cox	:	Removed DDI
- *		Jonathan Kamens	:	SOCK_DGRAM reconnect bug
- *		Alan Cox	:	Moved a load of checks to the very
- *					top level.
- *		Alan Cox	:	Move address structures to/from user
- *					mode above the protocol layers.
- *		Rob Janssen	:	Allow 0 length sends.
- *		Alan Cox	:	Asynchronous I/O support (cribbed from the
- *					tty drivers).
- *		Niibe Yutaka	:	Asynchronous I/O for writes (4.4BSD style)
- *		Jeff Uphoff	:	Made max number of sockets command-line
- *					configurable.
- *		Matti Aarnio	:	Made the number of sockets dynamic,
- *					to be allocated when needed, and mr.
- *					Uphoff's max is used as max to be
- *					allowed to allocate.
- *		Linus		:	Argh. removed all the socket allocation
- *					altogether: it's in the inode now.
- *		Alan Cox	:	Made sock_alloc()/sock_release() public
- *					for NetROM and future kernel nfsd type
- *					stuff.
- *		Alan Cox	:	sendmsg/recvmsg basics.
- *		Tom Dyas	:	Export net symbols.
- *		Marcin Dalecki	:	Fixed problems with CONFIG_NET="n".
- *		Alan Cox	:	Added thread locking to sys_* calls
- *					for sockets. May have errors at the
- *					moment.
- *		Kevin Buhr	:	Fixed the dumb errors in the above.
- *		Andi Kleen	:	Some small cleanups, optimizations,
- *					and fixed a copy_from_user() bug.
- *		Tigran Aivazian	:	sys_send(args) calls sys_sendto(args, NULL, 0)
- *		Tigran Aivazian	:	Made listen(2) backlog sanity checks
- *					protocol-independent
+ *	Anonymous	:	NOTSOCK/BADF cleanup. Error fix in
+ *				shutdown()
+ *	Alan Cox	:	verify_area() fixes
+ *	Alan Cox	:	Removed DDI
+ *	Jonathan Kamens	:	SOCK_DGRAM reconnect bug
+ *	Alan Cox	:	Moved a load of checks to the very
+ *				top level.
+ *	Alan Cox	:	Move address structures to/from user
+ *				mode above the protocol layers.
+ *	Rob Janssen	:	Allow 0 length sends.
+ *	Alan Cox	:	Asynchronous I/O support (cribbed from the
+ *				tty drivers).
+ *	Niibe Yutaka	:	Asynchronous I/O for writes (4.4BSD style)
+ *	Jeff Uphoff	:	Made max number of sockets command-line
+ *				configurable.
+ *	Matti Aarnio	:	Made the number of sockets dynamic,
+ *				to be allocated when needed, and mr.
+ *				Uphoff's max is used as max to be
+ *				allowed to allocate.
+ *	Linus		:	Argh. removed all the socket allocation
+ *				altogether: it's in the inode now.
+ *	Alan Cox	:	Made sock_alloc()/sock_release() public
+ *				for NetROM and future kernel nfsd type
+ *				stuff.
+ *	Alan Cox	:	sendmsg/recvmsg basics.
+ *	Tom Dyas	:	Export net symbols.
+ *	Marcin Dalecki	:	Fixed problems with CONFIG_NET="n".
+ *	Alan Cox	:	Added thread locking to sys_* calls
+ *				for sockets. May have errors at the
+ *				moment.
+ *	Kevin Buhr	:	Fixed the dumb errors in the above.
+ *	Andi Kleen	:	Some small cleanups, optimizations,
+ *				and fixed a copy_from_user() bug.
+ *	Tigran Aivazian	:	sys_send(args) calls sys_sendto(args, NULL, 0)
+ *	Tigran Aivazian	:	Made listen(2) backlog sanity checks
+ *				protocol-independent
  *
  *
- *		This program is free software; you can redistribute it and/or
- *		modify it under the terms of the GNU General Public License
- *		as published by the Free Software Foundation; either version
- *		2 of the License, or (at your option) any later version.
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
  *
  *
  *	This module is effectively the top level interface to the BSD socket
@@ -128,8 +128,9 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 				unsigned int flags);
 
 /*
- *	Socket files have a set of 'special' operations as well as the generic file ones. These don't appear
- *	in the operation structures but are done directly via the socketcall() multiplexor.
+ *	Socket files have a set of 'special' operations as well as the generic
+ *      file ones. These don't appear in the operation structures but are done
+ *      directly via the socketcall() multiplexor.
  */
 
 static const struct file_operations socket_file_ops = {
@@ -181,7 +182,8 @@ static DEFINE_PER_CPU(int, sockets_in_use);
  *	invalid addresses -EFAULT is returned. On a success 0 is returned.
  */
 
-int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr_storage *kaddr)
+int move_addr_to_kernel(void __user *uaddr, int ulen,
+			struct sockaddr_storage *kaddr)
 {
 	if (ulen < 0 || ulen > sizeof(struct sockaddr_storage))
 		return -EINVAL;
@@ -584,7 +586,8 @@ int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
-static int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
+static int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg,
+			      size_t size)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;
@@ -711,7 +714,8 @@ void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
 
 static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
-				       struct msghdr *msg, size_t size, int flags)
+				       struct msghdr *msg, size_t size,
+				       int flags)
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
@@ -1158,7 +1162,9 @@ static int sock_fasync(int fd, struct file *filp, int on)
 	return 0;
 }
 
-/* This function may be called only under socket lock or callback_lock or rcu_lock */
+/* This function may be called only under socket lock or callback_lock
+ * or rcu_lock.
+ */
 
 int sock_wake_async(struct socket *sock, int how, int band)
 {
@@ -1229,8 +1235,8 @@ int __sock_create(struct net *net, int family, int type, int protocol,
 
 	/*
 	 *	Allocate the socket and allow the family to set things up. if
-	 *	the protocol is 0, the family is instructed to select an appropriate
-	 *	default.
+	 *	the protocol is 0, the family is instructed to select an
+	 *	appropriate default.
 	 */
 	sock = sock_alloc();
 	if (!sock) {
@@ -1308,7 +1314,8 @@ EXPORT_SYMBOL(__sock_create);
 
 int sock_create(int family, int type, int protocol, struct socket **res)
 {
-	return __sock_create(current->nsproxy->net_ns, family, type, protocol, res, 0);
+	return __sock_create(current->nsproxy->net_ns, family, type, protocol,
+			     res, 0);
 }
 EXPORT_SYMBOL(sock_create);
 
@@ -1928,9 +1935,9 @@ static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
 	}
 
 	/* This will also move the address data into kernel space */
-	if (MSG_CMSG_COMPAT & flags) {
+	if (MSG_CMSG_COMPAT & flags)
 		err = verify_compat_iovec(msg_sys, iov, &address, VERIFY_READ);
-	} else
+	else
 		err = verify_iovec(msg_sys, iov, &address, VERIFY_READ);
 	if (err < 0)
 		goto out_freeiov;
@@ -1957,9 +1964,9 @@ static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
 		}
 		err = -EFAULT;
 		/*
-		 * Careful! Before this, msg_sys->msg_control contains a user pointer.
-		 * Afterwards, it will be a kernel pointer. Thus the compiler-assisted
-		 * checking falls down on this.
+		 * Careful! Before this, msg_sys->msg_control contains a user
+		 * pointer. Afterwards, it will be a kernel pointer. Thus the
+		 * compiler-assisted checking falls down on this.
 		 */
 		if (copy_from_user(ctl_buf,
 				   (void __user __force *)msg_sys->msg_control,
@@ -2010,7 +2017,8 @@ out:
  *	BSD sendmsg interface
  */
 
-SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned int, flags)
+SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned int,
+		flags)
 {
 	int fput_needed, err;
 	struct msghdr msg_sys;
@@ -2056,7 +2064,8 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 
 	while (datagrams < vlen) {
 		if (MSG_CMSG_COMPAT & flags) {
-			err = __sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
+			err = __sys_sendmsg(sock,
+					   (struct msghdr __user *)compat_entry,
 					    &msg_sys, flags, &used_address);
 			if (err < 0)
 				break;
@@ -2132,9 +2141,9 @@ static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 
 	uaddr = (__force void __user *)msg_sys->msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
-	if (MSG_CMSG_COMPAT & flags) {
+	if (MSG_CMSG_COMPAT & flags)
 		err = verify_compat_iovec(msg_sys, iov, &addr, VERIFY_WRITE);
-	} else
+	else
 		err = verify_iovec(msg_sys, iov, &addr, VERIFY_WRITE);
 	if (err < 0)
 		goto out_freeiov;
@@ -2661,13 +2670,15 @@ static int dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
 		ifc.ifc_req = NULL;
 		uifc = compat_alloc_user_space(sizeof(struct ifconf));
 	} else {
-		size_t len = ((ifc32.ifc_len / sizeof(struct compat_ifreq)) + 1) *
+		size_t len = ((ifc32.ifc_len /
+			sizeof(struct compat_ifreq)) + 1) *
 			sizeof(struct ifreq);
 		uifc = compat_alloc_user_space(sizeof(struct ifconf) + len);
 		ifc.ifc_len = len;
 		ifr = ifc.ifc_req = (void __user *)(uifc + 1);
 		ifr32 = compat_ptr(ifc32.ifcbuf);
-		for (i = 0; i < ifc32.ifc_len; i += sizeof(struct compat_ifreq)) {
+		for (i = 0; i < ifc32.ifc_len;
+		     i += sizeof(struct compat_ifreq)) {
 			if (copy_in_user(ifr, ifr32, sizeof(struct compat_ifreq)))
 				return -EFAULT;
 			ifr++;
@@ -2832,7 +2843,8 @@ static int ethtool_ioctl(struct net *net, struct compat_ifreq __user *ifr32)
 	return 0;
 }
 
-static int compat_siocwandev(struct net *net, struct compat_ifreq __user *uifr32)
+static int compat_siocwandev(struct net *net,
+			     struct compat_ifreq __user *uifr32)
 {
 	void __user *uptr;
 	compat_uptr_t uptr32;
@@ -3000,7 +3012,8 @@ static int compat_sioc_ifmap(struct net *net, unsigned int cmd,
 	return err;
 }
 
-static int compat_siocshwtstamp(struct net *net, struct compat_ifreq __user *uifr32)
+static int compat_siocshwtstamp(struct net *net,
+				struct compat_ifreq __user *uifr32)
 {
 	void __user *uptr;
 	compat_uptr_t uptr32;
-- 
1.7.9.5
