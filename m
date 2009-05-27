From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: net/core/sock.c cleanup
Date: Wed, 27 May 2009 23:30:05 +0200
Message-ID: <4A1DB0DD.1080605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47866 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbZE0VaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 17:30:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pure style cleanup patch.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/sock.c |  103 +++++++++++++++++++---------------------------
 1 files changed, 44 insertions(+), 59 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 7dbf3ff..58dec9d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -212,6 +212,7 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 
 /* Maximal space eaten by iovec or ancilliary data plus some space */
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
+EXPORT_SYMBOL(sysctl_optmem_max);
 
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
@@ -444,7 +445,7 @@ static inline void sock_valbool_flag(struct sock *sk, int bit, int valbool)
 int sock_setsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, int optlen)
 {
-	struct sock *sk=sock->sk;
+	struct sock *sk = sock->sk;
 	int val;
 	int valbool;
 	struct linger ling;
@@ -463,15 +464,15 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	if (get_user(val, (int __user *)optval))
 		return -EFAULT;
 
-	valbool = val?1:0;
+	valbool = val ? 1 : 0;
 
 	lock_sock(sk);
 
-	switch(optname) {
+	switch (optname) {
 	case SO_DEBUG:
-		if (val && !capable(CAP_NET_ADMIN)) {
+		if (val && !capable(CAP_NET_ADMIN))
 			ret = -EACCES;
-		} else
+		else
 			sock_valbool_flag(sk, SOCK_DBG, valbool);
 		break;
 	case SO_REUSEADDR:
@@ -582,7 +583,7 @@ set_rcvbuf:
 			ret = -EINVAL;	/* 1003.1g */
 			break;
 		}
-		if (copy_from_user(&ling,optval,sizeof(ling))) {
+		if (copy_from_user(&ling, optval, sizeof(ling))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -690,9 +691,8 @@ set_rcvbuf:
 	case SO_MARK:
 		if (!capable(CAP_NET_ADMIN))
 			ret = -EPERM;
-		else {
+		else
 			sk->sk_mark = val;
-		}
 		break;
 
 		/* We implement the SO_SNDLOWAT etc to
@@ -704,6 +704,7 @@ set_rcvbuf:
 	release_sock(sk);
 	return ret;
 }
+EXPORT_SYMBOL(sock_setsockopt);
 
 
 int sock_getsockopt(struct socket *sock, int level, int optname,
@@ -727,7 +728,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 
 	memset(&v, 0, sizeof(v));
 
-	switch(optname) {
+	switch (optname) {
 	case SO_DEBUG:
 		v.val = sock_flag(sk, SOCK_DBG);
 		break;
@@ -762,7 +763,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 
 	case SO_ERROR:
 		v.val = -sock_error(sk);
-		if (v.val==0)
+		if (v.val == 0)
 			v.val = xchg(&sk->sk_err_soft, 0);
 		break;
 
@@ -816,7 +817,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_RCVTIMEO:
-		lv=sizeof(struct timeval);
+		lv = sizeof(struct timeval);
 		if (sk->sk_rcvtimeo == MAX_SCHEDULE_TIMEOUT) {
 			v.tm.tv_sec = 0;
 			v.tm.tv_usec = 0;
@@ -827,7 +828,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_SNDTIMEO:
-		lv=sizeof(struct timeval);
+		lv = sizeof(struct timeval);
 		if (sk->sk_sndtimeo == MAX_SCHEDULE_TIMEOUT) {
 			v.tm.tv_sec = 0;
 			v.tm.tv_usec = 0;
@@ -842,7 +843,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_SNDLOWAT:
-		v.val=1;
+		v.val = 1;
 		break;
 
 	case SO_PASSCRED:
@@ -1002,6 +1003,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 
 	return sk;
 }
+EXPORT_SYMBOL(sk_alloc);
 
 void sk_free(struct sock *sk)
 {
@@ -1026,6 +1028,7 @@ void sk_free(struct sock *sk)
 	put_net(sock_net(sk));
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
+EXPORT_SYMBOL(sk_free);
 
 /*
  * Last sock_put should drop referrence to sk->sk_net. It has already
@@ -1126,7 +1129,6 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 out:
 	return newsk;
 }
-
 EXPORT_SYMBOL_GPL(sk_clone);
 
 void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
@@ -1177,6 +1179,7 @@ void sock_wfree(struct sk_buff *skb)
 		sk->sk_write_space(sk);
 	sock_put(sk);
 }
+EXPORT_SYMBOL(sock_wfree);
 
 /*
  * Read buffer destructor automatically called from kfree_skb.
@@ -1188,6 +1191,7 @@ void sock_rfree(struct sk_buff *skb)
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
 	sk_mem_uncharge(skb->sk, skb->truesize);
 }
+EXPORT_SYMBOL(sock_rfree);
 
 
 int sock_i_uid(struct sock *sk)
@@ -1199,6 +1203,7 @@ int sock_i_uid(struct sock *sk)
 	read_unlock(&sk->sk_callback_lock);
 	return uid;
 }
+EXPORT_SYMBOL(sock_i_uid);
 
 unsigned long sock_i_ino(struct sock *sk)
 {
@@ -1209,6 +1214,7 @@ unsigned long sock_i_ino(struct sock *sk)
 	read_unlock(&sk->sk_callback_lock);
 	return ino;
 }
+EXPORT_SYMBOL(sock_i_ino);
 
 /*
  * Allocate a skb from the socket's send buffer.
@@ -1217,7 +1223,7 @@ struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 			     gfp_t priority)
 {
 	if (force || atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf) {
-		struct sk_buff * skb = alloc_skb(size, priority);
+		struct sk_buff *skb = alloc_skb(size, priority);
 		if (skb) {
 			skb_set_owner_w(skb, sk);
 			return skb;
@@ -1225,6 +1231,7 @@ struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(sock_wmalloc);
 
 /*
  * Allocate a skb from the socket's receive buffer.
@@ -1261,6 +1268,7 @@ void *sock_kmalloc(struct sock *sk, int size, gfp_t priority)
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(sock_kmalloc);
 
 /*
  * Free an option memory block.
@@ -1270,11 +1278,12 @@ void sock_kfree_s(struct sock *sk, void *mem, int size)
 	kfree(mem);
 	atomic_sub(size, &sk->sk_omem_alloc);
 }
+EXPORT_SYMBOL(sock_kfree_s);
 
 /* It is almost wait_for_tcp_memory minus release_sock/lock_sock.
    I think, these locks should be removed for datagram sockets.
  */
-static long sock_wait_for_wmem(struct sock * sk, long timeo)
+static long sock_wait_for_wmem(struct sock *sk, long timeo)
 {
 	DEFINE_WAIT(wait);
 
@@ -1392,6 +1401,7 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 {
 	return sock_alloc_send_pskb(sk, size, 0, noblock, errcode);
 }
+EXPORT_SYMBOL(sock_alloc_send_skb);
 
 static void __lock_sock(struct sock *sk)
 {
@@ -1460,7 +1470,6 @@ int sk_wait_data(struct sock *sk, long *timeo)
 	finish_wait(sk->sk_sleep, &wait);
 	return rc;
 }
-
 EXPORT_SYMBOL(sk_wait_data);
 
 /**
@@ -1541,7 +1550,6 @@ suppress_allocation:
 	atomic_sub(amt, prot->memory_allocated);
 	return 0;
 }
-
 EXPORT_SYMBOL(__sk_mem_schedule);
 
 /**
@@ -1560,7 +1568,6 @@ void __sk_mem_reclaim(struct sock *sk)
 	    (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0]))
 		*prot->memory_pressure = 0;
 }
-
 EXPORT_SYMBOL(__sk_mem_reclaim);
 
 
@@ -1575,78 +1582,92 @@ int sock_no_bind(struct socket *sock, struct sockaddr *saddr, int len)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_bind);
 
 int sock_no_connect(struct socket *sock, struct sockaddr *saddr,
 		    int len, int flags)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_connect);
 
 int sock_no_socketpair(struct socket *sock1, struct socket *sock2)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_socketpair);
 
 int sock_no_accept(struct socket *sock, struct socket *newsock, int flags)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_accept);
 
 int sock_no_getname(struct socket *sock, struct sockaddr *saddr,
 		    int *len, int peer)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_getname);
 
-unsigned int sock_no_poll(struct file * file, struct socket *sock, poll_table *pt)
+unsigned int sock_no_poll(struct file *file, struct socket *sock, poll_table *pt)
 {
 	return 0;
 }
+EXPORT_SYMBOL(sock_no_poll);
 
 int sock_no_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_ioctl);
 
 int sock_no_listen(struct socket *sock, int backlog)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_listen);
 
 int sock_no_shutdown(struct socket *sock, int how)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_shutdown);
 
 int sock_no_setsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, int optlen)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_setsockopt);
 
 int sock_no_getsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, int __user *optlen)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_getsockopt);
 
 int sock_no_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		    size_t len)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_sendmsg);
 
 int sock_no_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		    size_t len, int flags)
 {
 	return -EOPNOTSUPP;
 }
+EXPORT_SYMBOL(sock_no_recvmsg);
 
 int sock_no_mmap(struct file *file, struct socket *sock, struct vm_area_struct *vma)
 {
 	/* Mirror missing mmap method error code */
 	return -ENODEV;
 }
+EXPORT_SYMBOL(sock_no_mmap);
 
 ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags)
 {
@@ -1660,6 +1681,7 @@ ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset, siz
 	kunmap(page);
 	return res;
 }
+EXPORT_SYMBOL(sock_no_sendpage);
 
 /*
  *	Default Socket Callbacks
@@ -1723,6 +1745,7 @@ void sk_send_sigurg(struct sock *sk)
 		if (send_sigurg(&sk->sk_socket->file->f_owner))
 			sk_wake_async(sk, SOCK_WAKE_URG, POLL_PRI);
 }
+EXPORT_SYMBOL(sk_send_sigurg);
 
 void sk_reset_timer(struct sock *sk, struct timer_list* timer,
 		    unsigned long expires)
@@ -1730,7 +1753,6 @@ void sk_reset_timer(struct sock *sk, struct timer_list* timer,
 	if (!mod_timer(timer, expires))
 		sock_hold(sk);
 }
-
 EXPORT_SYMBOL(sk_reset_timer);
 
 void sk_stop_timer(struct sock *sk, struct timer_list* timer)
@@ -1738,7 +1760,6 @@ void sk_stop_timer(struct sock *sk, struct timer_list* timer)
 	if (timer_pending(timer) && del_timer(timer))
 		__sock_put(sk);
 }
-
 EXPORT_SYMBOL(sk_stop_timer);
 
 void sock_init_data(struct socket *sock, struct sock *sk)
@@ -1797,6 +1818,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	atomic_set(&sk->sk_refcnt, 1);
 	atomic_set(&sk->sk_drops, 0);
 }
+EXPORT_SYMBOL(sock_init_data);
 
 void lock_sock_nested(struct sock *sk, int subclass)
 {
@@ -1812,7 +1834,6 @@ void lock_sock_nested(struct sock *sk, int subclass)
 	mutex_acquire(&sk->sk_lock.dep_map, subclass, 0, _RET_IP_);
 	local_bh_enable();
 }
-
 EXPORT_SYMBOL(lock_sock_nested);
 
 void release_sock(struct sock *sk)
@@ -1895,7 +1916,6 @@ int sock_common_getsockopt(struct socket *sock, int level, int optname,
 
 	return sk->sk_prot->getsockopt(sk, level, optname, optval, optlen);
 }
-
 EXPORT_SYMBOL(sock_common_getsockopt);
 
 #ifdef CONFIG_COMPAT
@@ -1925,7 +1945,6 @@ int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_namelen = addr_len;
 	return err;
 }
-
 EXPORT_SYMBOL(sock_common_recvmsg);
 
 /*
@@ -1938,7 +1957,6 @@ int sock_common_setsockopt(struct socket *sock, int level, int optname,
 
 	return sk->sk_prot->setsockopt(sk, level, optname, optval, optlen);
 }
-
 EXPORT_SYMBOL(sock_common_setsockopt);
 
 #ifdef CONFIG_COMPAT
@@ -1989,7 +2007,6 @@ void sk_common_release(struct sock *sk)
 	sk_refcnt_debug_release(sk);
 	sock_put(sk);
 }
-
 EXPORT_SYMBOL(sk_common_release);
 
 static DEFINE_RWLOCK(proto_list_lock);
@@ -2171,7 +2188,6 @@ out_free_sock_slab:
 out:
 	return -ENOBUFS;
 }
-
 EXPORT_SYMBOL(proto_register);
 
 void proto_unregister(struct proto *prot)
@@ -2198,7 +2214,6 @@ void proto_unregister(struct proto *prot)
 		prot->twsk_prot->twsk_slab = NULL;
 	}
 }
-
 EXPORT_SYMBOL(proto_unregister);
 
 #ifdef CONFIG_PROC_FS
@@ -2324,33 +2339,3 @@ static int __init proto_init(void)
 subsys_initcall(proto_init);
 
 #endif /* PROC_FS */
-
-EXPORT_SYMBOL(sk_alloc);
-EXPORT_SYMBOL(sk_free);
-EXPORT_SYMBOL(sk_send_sigurg);
-EXPORT_SYMBOL(sock_alloc_send_skb);
-EXPORT_SYMBOL(sock_init_data);
-EXPORT_SYMBOL(sock_kfree_s);
-EXPORT_SYMBOL(sock_kmalloc);
-EXPORT_SYMBOL(sock_no_accept);
-EXPORT_SYMBOL(sock_no_bind);
-EXPORT_SYMBOL(sock_no_connect);
-EXPORT_SYMBOL(sock_no_getname);
-EXPORT_SYMBOL(sock_no_getsockopt);
-EXPORT_SYMBOL(sock_no_ioctl);
-EXPORT_SYMBOL(sock_no_listen);
-EXPORT_SYMBOL(sock_no_mmap);
-EXPORT_SYMBOL(sock_no_poll);
-EXPORT_SYMBOL(sock_no_recvmsg);
-EXPORT_SYMBOL(sock_no_sendmsg);
-EXPORT_SYMBOL(sock_no_sendpage);
-EXPORT_SYMBOL(sock_no_setsockopt);
-EXPORT_SYMBOL(sock_no_shutdown);
-EXPORT_SYMBOL(sock_no_socketpair);
-EXPORT_SYMBOL(sock_rfree);
-EXPORT_SYMBOL(sock_setsockopt);
-EXPORT_SYMBOL(sock_wfree);
-EXPORT_SYMBOL(sock_wmalloc);
-EXPORT_SYMBOL(sock_i_uid);
-EXPORT_SYMBOL(sock_i_ino);
-EXPORT_SYMBOL(sysctl_optmem_max);
