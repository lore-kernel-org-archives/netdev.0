From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 2/2] net: Remove iocb argument from sendmsg and recvmsg
Date: Mon, 2 Mar 2015 15:37:48 +0800
Message-ID: <1425281868-25684-3-git-send-email-ying.xue@windriver.com>
References: <1425281868-25684-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <erik.hugne@ericsson.com>,
	<jon.maloy@ericsson.com>
To: <viro@ZenIV.linux.org.uk>, <hch@lst.de>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43846 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbbCBHiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 02:38:11 -0500
In-Reply-To: <1425281868-25684-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After TIPC doesn't depend on iocb argument in its internal
implementations of sendmsg() and recvmsg() hooks defined in proto
structure, no any user is using iocb argument in them at all now.
Then we can drop the redundant iocb argument completely from kinds of
implementations of both sendmsg() and recvmsg() in the entire
networking stack.

Cc: Christoph Hellwig <hch@lst.de>
Suggested-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 crypto/algif_hash.c               |    8 ++--
 crypto/algif_rng.c                |    4 +-
 crypto/algif_skcipher.c           |    8 ++--
 drivers/isdn/mISDN/socket.c       |    7 ++--
 drivers/net/macvtap.c             |    9 ++---
 drivers/net/ppp/pppoe.c           |    8 ++--
 drivers/net/tun.c                 |    6 +--
 drivers/vhost/net.c               |    6 +--
 include/linux/net.h               |   10 ++---
 include/net/af_vsock.h            |    4 +-
 include/net/bluetooth/bluetooth.h |    8 ++--
 include/net/inet_common.h         |    7 ++--
 include/net/ping.h                |    7 ++--
 include/net/sock.h                |   16 ++++----
 include/net/tcp.h                 |    7 ++--
 include/net/udp.h                 |    3 +-
 net/appletalk/ddp.c               |    7 ++--
 net/atm/common.c                  |    7 ++--
 net/atm/common.h                  |    7 ++--
 net/ax25/af_ax25.c                |    7 ++--
 net/bluetooth/af_bluetooth.c      |    8 ++--
 net/bluetooth/hci_sock.c          |    8 ++--
 net/bluetooth/l2cap_sock.c        |   12 +++---
 net/bluetooth/rfcomm/sock.c       |   10 ++---
 net/bluetooth/sco.c               |   10 ++---
 net/caif/caif_socket.c            |   17 ++++----
 net/can/bcm.c                     |    7 ++--
 net/can/raw.c                     |    7 ++--
 net/core/sock.c                   |   13 +++----
 net/dccp/dccp.h                   |    8 ++--
 net/dccp/probe.c                  |    3 +-
 net/dccp/proto.c                  |    7 ++--
 net/decnet/af_decnet.c            |    7 ++--
 net/ieee802154/socket.c           |   21 +++++-----
 net/ipv4/af_inet.c                |   11 +++---
 net/ipv4/ping.c                   |    7 ++--
 net/ipv4/raw.c                    |    7 ++--
 net/ipv4/tcp.c                    |    7 ++--
 net/ipv4/udp.c                    |    9 ++---
 net/ipv4/udp_impl.h               |    4 +-
 net/ipv6/ping.c                   |    3 +-
 net/ipv6/raw.c                    |    8 ++--
 net/ipv6/udp.c                    |   10 ++---
 net/ipv6/udp_impl.h               |    7 ++--
 net/ipx/af_ipx.c                  |    7 ++--
 net/irda/af_irda.c                |   29 +++++++-------
 net/iucv/af_iucv.c                |    8 ++--
 net/key/af_key.c                  |    6 +--
 net/l2tp/l2tp_ip.c                |    4 +-
 net/l2tp/l2tp_ip6.c               |    8 ++--
 net/l2tp/l2tp_ppp.c               |    7 ++--
 net/llc/af_llc.c                  |    7 ++--
 net/netlink/af_netlink.c          |    6 +--
 net/netrom/af_netrom.c            |    7 ++--
 net/nfc/llcp_sock.c               |    8 ++--
 net/nfc/rawsock.c                 |    7 ++--
 net/packet/af_packet.c            |   11 +++---
 net/phonet/datagram.c             |    8 ++--
 net/phonet/pep.c                  |    8 ++--
 net/phonet/socket.c               |    6 +--
 net/rds/rds.h                     |    7 ++--
 net/rds/recv.c                    |    4 +-
 net/rds/send.c                    |    3 +-
 net/rose/af_rose.c                |    7 ++--
 net/rxrpc/af_rxrpc.c              |    7 ++--
 net/rxrpc/ar-internal.h           |   10 ++---
 net/rxrpc/ar-output.c             |   20 ++++------
 net/rxrpc/ar-recvmsg.c            |    4 +-
 net/sctp/socket.c                 |    8 ++--
 net/socket.c                      |   78 +++++++------------------------------
 net/tipc/socket.c                 |   23 ++++-------
 net/unix/af_unix.c                |   50 ++++++++++--------------
 net/vmw_vsock/af_vsock.c          |   20 +++++-----
 net/vmw_vsock/vmci_transport.c    |    3 +-
 net/x25/af_x25.c                  |    6 +--
 75 files changed, 302 insertions(+), 442 deletions(-)

diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 01da360..0a465e0 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -34,8 +34,8 @@ struct hash_ctx {
 	struct ahash_request req;
 };
 
-static int hash_sendmsg(struct kiocb *unused, struct socket *sock,
-			struct msghdr *msg, size_t ignored)
+static int hash_sendmsg(struct socket *sock, struct msghdr *msg,
+			size_t ignored)
 {
 	int limit = ALG_MAX_PAGES * PAGE_SIZE;
 	struct sock *sk = sock->sk;
@@ -139,8 +139,8 @@ unlock:
 	return err ?: size;
 }
 
-static int hash_recvmsg(struct kiocb *unused, struct socket *sock,
-			struct msghdr *msg, size_t len, int flags)
+static int hash_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+			int flags)
 {
 	struct sock *sk = sock->sk;
 	struct alg_sock *ask = alg_sk(sk);
diff --git a/crypto/algif_rng.c b/crypto/algif_rng.c
index 67f612c..3acba0a 100644
--- a/crypto/algif_rng.c
+++ b/crypto/algif_rng.c
@@ -55,8 +55,8 @@ struct rng_ctx {
 	struct crypto_rng *drng;
 };
 
-static int rng_recvmsg(struct kiocb *unused, struct socket *sock,
-		       struct msghdr *msg, size_t len, int flags)
+static int rng_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+		       int flags)
 {
 	struct sock *sk = sock->sk;
 	struct alg_sock *ask = alg_sk(sk);
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 0c8a1e5..b9743dc 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -239,8 +239,8 @@ static void skcipher_data_wakeup(struct sock *sk)
 	rcu_read_unlock();
 }
 
-static int skcipher_sendmsg(struct kiocb *unused, struct socket *sock,
-			    struct msghdr *msg, size_t size)
+static int skcipher_sendmsg(struct socket *sock, struct msghdr *msg,
+			    size_t size)
 {
 	struct sock *sk = sock->sk;
 	struct alg_sock *ask = alg_sk(sk);
@@ -424,8 +424,8 @@ unlock:
 	return err ?: size;
 }
 
-static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
-			    struct msghdr *msg, size_t ignored, int flags)
+static int skcipher_recvmsg(struct socket *sock, struct msghdr *msg,
+			    size_t ignored, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct alg_sock *ask = alg_sk(sk);
diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 84b3592..8dc7290 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -112,8 +112,8 @@ mISDN_sock_cmsg(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 }
 
 static int
-mISDN_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-		   struct msghdr *msg, size_t len, int flags)
+mISDN_sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+		   int flags)
 {
 	struct sk_buff		*skb;
 	struct sock		*sk = sock->sk;
@@ -173,8 +173,7 @@ mISDN_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 }
 
 static int
-mISDN_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-		   struct msghdr *msg, size_t len)
+mISDN_sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock		*sk = sock->sk;
 	struct sk_buff		*skb;
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index e40fdfc..1e51c6b 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1127,16 +1127,15 @@ static const struct file_operations macvtap_fops = {
 #endif
 };
 
-static int macvtap_sendmsg(struct kiocb *iocb, struct socket *sock,
-			   struct msghdr *m, size_t total_len)
+static int macvtap_sendmsg(struct socket *sock, struct msghdr *m,
+			   size_t total_len)
 {
 	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
 	return macvtap_get_user(q, m, &m->msg_iter, m->msg_flags & MSG_DONTWAIT);
 }
 
-static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
-			   struct msghdr *m, size_t total_len,
-			   int flags)
+static int macvtap_recvmsg(struct socket *sock, struct msghdr *m,
+			   size_t total_len, int flags)
 {
 	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
 	int ret;
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index d2408a5..77d2d8a 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -820,8 +820,8 @@ static int pppoe_ioctl(struct socket *sock, unsigned int cmd,
 	return err;
 }
 
-static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock,
-		  struct msghdr *m, size_t total_len)
+static int pppoe_sendmsg(struct socket *sock, struct msghdr *m,
+			 size_t total_len)
 {
 	struct sk_buff *skb;
 	struct sock *sk = sock->sk;
@@ -962,8 +962,8 @@ static const struct ppp_channel_ops pppoe_chan_ops = {
 	.start_xmit = pppoe_xmit,
 };
 
-static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
-		  struct msghdr *m, size_t total_len, int flags)
+static int pppoe_recvmsg(struct socket *sock, struct msghdr *m,
+			 size_t total_len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 857dca4..b96b94c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1448,8 +1448,7 @@ static void tun_sock_write_space(struct sock *sk)
 	kill_fasync(&tfile->fasync, SIGIO, POLL_OUT);
 }
 
-static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *m, size_t total_len)
+static int tun_sendmsg(struct socket *sock, struct msghdr *m, size_t total_len)
 {
 	int ret;
 	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
@@ -1464,8 +1463,7 @@ static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
 	return ret;
 }
 
-static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *m, size_t total_len,
+static int tun_recvmsg(struct socket *sock, struct msghdr *m, size_t total_len,
 		       int flags)
 {
 	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index afa06d2..633012c 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -390,7 +390,7 @@ static void handle_tx(struct vhost_net *net)
 			ubufs = NULL;
 		}
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
-		err = sock->ops->sendmsg(NULL, sock, &msg, len);
+		err = sock->ops->sendmsg(sock, &msg, len);
 		if (unlikely(err < 0)) {
 			if (zcopy_used) {
 				vhost_net_ubuf_put(ubufs);
@@ -566,7 +566,7 @@ static void handle_rx(struct vhost_net *net)
 		/* On overrun, truncate and discard */
 		if (unlikely(headcount > UIO_MAXIOV)) {
 			iov_iter_init(&msg.msg_iter, READ, vq->iov, 1, 1);
-			err = sock->ops->recvmsg(NULL, sock, &msg,
+			err = sock->ops->recvmsg(sock, &msg,
 						 1, MSG_DONTWAIT | MSG_TRUNC);
 			pr_debug("Discarded rx packet: len %zd\n", sock_len);
 			continue;
@@ -597,7 +597,7 @@ static void handle_rx(struct vhost_net *net)
 			 */
 			iov_iter_advance(&fixup, sizeof(hdr));
 		}
-		err = sock->ops->recvmsg(NULL, sock, &msg,
+		err = sock->ops->recvmsg(sock, &msg,
 					 sock_len, MSG_DONTWAIT | MSG_TRUNC);
 		/* Userspace might have consumed the packet meanwhile:
 		 * it's not supposed to do this usually, but might be hard
diff --git a/include/linux/net.h b/include/linux/net.h
index 17d8339..e74114b 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -120,7 +120,6 @@ struct socket {
 
 struct vm_area_struct;
 struct page;
-struct kiocb;
 struct sockaddr;
 struct msghdr;
 struct module;
@@ -162,8 +161,8 @@ struct proto_ops {
 	int		(*compat_getsockopt)(struct socket *sock, int level,
 				      int optname, char __user *optval, int __user *optlen);
 #endif
-	int		(*sendmsg)   (struct kiocb *iocb, struct socket *sock,
-				      struct msghdr *m, size_t total_len);
+	int		(*sendmsg)   (struct socket *sock, struct msghdr *m,
+				      size_t total_len);
 	/* Notes for implementing recvmsg:
 	 * ===============================
 	 * msg->msg_namelen should get updated by the recvmsg handlers
@@ -172,9 +171,8 @@ struct proto_ops {
 	 * handlers can assume that msg.msg_name is either NULL or has
 	 * a minimum size of sizeof(struct sockaddr_storage).
 	 */
-	int		(*recvmsg)   (struct kiocb *iocb, struct socket *sock,
-				      struct msghdr *m, size_t total_len,
-				      int flags);
+	int		(*recvmsg)   (struct socket *sock, struct msghdr *m,
+				      size_t total_len, int flags);
 	int		(*mmap)	     (struct file *file, struct socket *sock,
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 0d87674..172632d 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -100,8 +100,8 @@ struct vsock_transport {
 
 	/* DGRAM. */
 	int (*dgram_bind)(struct vsock_sock *, struct sockaddr_vm *);
-	int (*dgram_dequeue)(struct kiocb *kiocb, struct vsock_sock *vsk,
-			     struct msghdr *msg, size_t len, int flags);
+	int (*dgram_dequeue)(struct vsock_sock *vsk, struct msghdr *msg,
+			     size_t len, int flags);
 	int (*dgram_enqueue)(struct vsock_sock *, struct sockaddr_vm *,
 			     struct msghdr *, size_t len);
 	bool (*dgram_allow)(u32 cid, u32 port);
diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index e00455a..237325b 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -245,10 +245,10 @@ int  bt_sock_register(int proto, const struct net_proto_family *ops);
 void bt_sock_unregister(int proto);
 void bt_sock_link(struct bt_sock_list *l, struct sock *s);
 void bt_sock_unlink(struct bt_sock_list *l, struct sock *s);
-int  bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-				struct msghdr *msg, size_t len, int flags);
-int  bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t len, int flags);
+int  bt_sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+		     int flags);
+int  bt_sock_stream_recvmsg(struct socket *sock, struct msghdr *msg,
+			    size_t len, int flags);
 uint bt_sock_poll(struct file *file, struct socket *sock, poll_table *wait);
 int  bt_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int  bt_sock_wait_state(struct sock *sk, int state, unsigned long timeo);
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index b2828a0..4a92423 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -21,12 +21,11 @@ int __inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 int inet_dgram_connect(struct socket *sock, struct sockaddr *uaddr,
 		       int addr_len, int flags);
 int inet_accept(struct socket *sock, struct socket *newsock, int flags);
-int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 size_t size);
+int inet_sendmsg(struct socket *sock, struct msghdr *msg, size_t size);
 ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 		      size_t size, int flags);
-int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 size_t size, int flags);
+int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		 int flags);
 int inet_shutdown(struct socket *sock, int how);
 int inet_listen(struct socket *sock, int backlog);
 void inet_sock_destruct(struct sock *sk);
diff --git a/include/net/ping.h b/include/net/ping.h
index cc16d41..ac80cb4 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -75,12 +75,11 @@ void ping_err(struct sk_buff *skb, int offset, u32 info);
 int  ping_getfrag(void *from, char *to, int offset, int fraglen, int odd,
 		  struct sk_buff *);
 
-int  ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		  size_t len, int noblock, int flags, int *addr_len);
+int  ping_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
+		  int flags, int *addr_len);
 int  ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 			 void *user_icmph, size_t icmph_len);
-int  ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		     size_t len);
+int  ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
 int  ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 bool ping_rcv(struct sk_buff *skb);
 
diff --git a/include/net/sock.h b/include/net/sock.h
index ab186b1..819b4a1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -958,10 +958,9 @@ struct proto {
 	int			(*compat_ioctl)(struct sock *sk,
 					unsigned int cmd, unsigned long arg);
 #endif
-	int			(*sendmsg)(struct kiocb *iocb, struct sock *sk,
-					   struct msghdr *msg, size_t len);
-	int			(*recvmsg)(struct kiocb *iocb, struct sock *sk,
-					   struct msghdr *msg,
+	int			(*sendmsg)(struct sock *sk, struct msghdr *msg,
+					   size_t len);
+	int			(*recvmsg)(struct sock *sk, struct msghdr *msg,
 					   size_t len, int noblock, int flags,
 					   int *addr_len);
 	int			(*sendpage)(struct sock *sk, struct page *page,
@@ -1562,9 +1561,8 @@ int sock_no_listen(struct socket *, int);
 int sock_no_shutdown(struct socket *, int);
 int sock_no_getsockopt(struct socket *, int , int, char __user *, int __user *);
 int sock_no_setsockopt(struct socket *, int, int, char __user *, unsigned int);
-int sock_no_sendmsg(struct kiocb *, struct socket *, struct msghdr *, size_t);
-int sock_no_recvmsg(struct kiocb *, struct socket *, struct msghdr *, size_t,
-		    int);
+int sock_no_sendmsg(struct socket *, struct msghdr *, size_t);
+int sock_no_recvmsg(struct socket *, struct msghdr *, size_t, int);
 int sock_no_mmap(struct file *file, struct socket *sock,
 		 struct vm_area_struct *vma);
 ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset,
@@ -1576,8 +1574,8 @@ ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset,
  */
 int sock_common_getsockopt(struct socket *sock, int level, int optname,
 				  char __user *optval, int __user *optlen);
-int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size, int flags);
+int sock_common_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+			int flags);
 int sock_common_setsockopt(struct socket *sock, int level, int optname,
 				  char __user *optval, unsigned int optlen);
 int compat_sock_common_getsockopt(struct socket *sock, int level,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8d6b983..f87599d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -349,8 +349,7 @@ void tcp_v4_early_demux(struct sk_buff *skb);
 int tcp_v4_rcv(struct sk_buff *skb);
 
 int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
-int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t size);
+int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
 int tcp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
 void tcp_release_cb(struct sock *sk);
@@ -430,8 +429,8 @@ int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, unsigned int optlen);
 void tcp_set_keepalive(struct sock *sk, int val);
 void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
-int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int nonblock, int flags, int *addr_len);
+int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
+		int flags, int *addr_len);
 void tcp_parse_options(const struct sk_buff *skb,
 		       struct tcp_options_received *opt_rx,
 		       int estab, struct tcp_fastopen_cookie *foc);
diff --git a/include/net/udp.h b/include/net/udp.h
index 07f9b70..7a9f26c 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -229,8 +229,7 @@ int udp_get_port(struct sock *sk, unsigned short snum,
 		 int (*saddr_cmp)(const struct sock *,
 				  const struct sock *));
 void udp_err(struct sk_buff *, u32);
-int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len);
+int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
 int udp_push_pending_frames(struct sock *sk);
 void udp_flush_pending_frames(struct sock *sk);
 void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 0d0766e..3b7ad43 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1559,8 +1559,7 @@ freeit:
 	return 0;
 }
 
-static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-			 size_t len)
+static int atalk_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct atalk_sock *at = at_sk(sk);
@@ -1728,8 +1727,8 @@ out:
 	return err ? : len;
 }
 
-static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-			 size_t size, int flags)
+static int atalk_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+			 int flags)
 {
 	struct sock *sk = sock->sk;
 	struct ddpehdr *ddp;
diff --git a/net/atm/common.c b/net/atm/common.c
index b84057e..ed04666 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -523,8 +523,8 @@ int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 	return 0;
 }
 
-int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t size, int flags)
+int vcc_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		int flags)
 {
 	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
@@ -569,8 +569,7 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	return copied;
 }
 
-int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		size_t size)
+int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 {
 	struct sock *sk = sock->sk;
 	DEFINE_WAIT(wait);
diff --git a/net/atm/common.h b/net/atm/common.h
index cc3c2da..4d6f5b2 100644
--- a/net/atm/common.h
+++ b/net/atm/common.h
@@ -13,10 +13,9 @@
 int vcc_create(struct net *net, struct socket *sock, int protocol, int family);
 int vcc_release(struct socket *sock);
 int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
-int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t size, int flags);
-int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		size_t total_len);
+int vcc_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		int flags);
+int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t total_len);
 unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int vcc_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index ca049a7..330c1f4 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1432,8 +1432,7 @@ out:
 	return err;
 }
 
-static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t len)
+static int ax25_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	DECLARE_SOCKADDR(struct sockaddr_ax25 *, usax, msg->msg_name);
 	struct sock *sk = sock->sk;
@@ -1599,8 +1598,8 @@ out:
 	return err;
 }
 
-static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, size_t size, int flags)
+static int ax25_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+			int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index ce22e0c..f1a08c7 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -210,8 +210,8 @@ struct sock *bt_accept_dequeue(struct sock *parent, struct socket *newsock)
 }
 EXPORT_SYMBOL(bt_accept_dequeue);
 
-int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-				struct msghdr *msg, size_t len, int flags)
+int bt_sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+		    int flags)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
@@ -283,8 +283,8 @@ static long bt_sock_data_wait(struct sock *sk, long timeo)
 	return timeo;
 }
 
-int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size, int flags)
+int bt_sock_stream_recvmsg(struct socket *sock, struct msghdr *msg,
+			   size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 1d65c5b..5c44112 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -826,8 +826,8 @@ static void hci_sock_cmsg(struct sock *sk, struct msghdr *msg,
 	}
 }
 
-static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *msg, size_t len, int flags)
+static int hci_sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+			    int flags)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
@@ -871,8 +871,8 @@ static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	return err ? : copied;
 }
 
-static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *msg, size_t len)
+static int hci_sock_sendmsg(struct socket *sock, struct msghdr *msg,
+			    size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct hci_dev *hdev;
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 60694f0..9070720 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -944,8 +944,8 @@ static int l2cap_sock_setsockopt(struct socket *sock, int level, int optname,
 	return err;
 }
 
-static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t len)
+static int l2cap_sock_sendmsg(struct socket *sock, struct msghdr *msg,
+			      size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct l2cap_chan *chan = l2cap_pi(sk)->chan;
@@ -976,8 +976,8 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	return err;
 }
 
-static int l2cap_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t len, int flags)
+static int l2cap_sock_recvmsg(struct socket *sock, struct msghdr *msg,
+			      size_t len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
@@ -1004,9 +1004,9 @@ static int l2cap_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	release_sock(sk);
 
 	if (sock->type == SOCK_STREAM)
-		err = bt_sock_stream_recvmsg(iocb, sock, msg, len, flags);
+		err = bt_sock_stream_recvmsg(sock, msg, len, flags);
 	else
-		err = bt_sock_recvmsg(iocb, sock, msg, len, flags);
+		err = bt_sock_recvmsg(sock, msg, len, flags);
 
 	if (pi->chan->mode != L2CAP_MODE_ERTM)
 		return err;
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 3c6d2c8..825e8fb 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -549,8 +549,8 @@ static int rfcomm_sock_getname(struct socket *sock, struct sockaddr *addr, int *
 	return 0;
 }
 
-static int rfcomm_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t len)
+static int rfcomm_sock_sendmsg(struct socket *sock, struct msghdr *msg,
+			       size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
@@ -615,8 +615,8 @@ done:
 	return sent;
 }
 
-static int rfcomm_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size, int flags)
+static int rfcomm_sock_recvmsg(struct socket *sock, struct msghdr *msg,
+			       size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
@@ -627,7 +627,7 @@ static int rfcomm_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return 0;
 	}
 
-	len = bt_sock_stream_recvmsg(iocb, sock, msg, size, flags);
+	len = bt_sock_stream_recvmsg(sock, msg, size, flags);
 
 	lock_sock(sk);
 	if (!(flags & MSG_PEEK) && len > 0)
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 76321b5..2bb7ef4 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -688,8 +688,8 @@ static int sco_sock_getname(struct socket *sock, struct sockaddr *addr, int *len
 	return 0;
 }
 
-static int sco_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *msg, size_t len)
+static int sco_sock_sendmsg(struct socket *sock, struct msghdr *msg,
+			    size_t len)
 {
 	struct sock *sk = sock->sk;
 	int err;
@@ -758,8 +758,8 @@ static void sco_conn_defer_accept(struct hci_conn *conn, u16 setting)
 	}
 }
 
-static int sco_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *msg, size_t len, int flags)
+static int sco_sock_recvmsg(struct socket *sock, struct msghdr *msg,
+			    size_t len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sco_pinfo *pi = sco_pi(sk);
@@ -777,7 +777,7 @@ static int sco_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	release_sock(sk);
 
-	return bt_sock_recvmsg(iocb, sock, msg, len, flags);
+	return bt_sock_recvmsg(sock, msg, len, flags);
 }
 
 static int sco_sock_setsockopt(struct socket *sock, int level, int optname, char __user *optval, unsigned int optlen)
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 769b185..b6bf51b 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -271,8 +271,8 @@ static void caif_check_flow_release(struct sock *sk)
  * Copied from unix_dgram_recvmsg, but removed credit checks,
  * changed locking, address handling and added MSG_TRUNC.
  */
-static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *m, size_t len, int flags)
+static int caif_seqpkt_recvmsg(struct socket *sock, struct msghdr *m,
+			       size_t len, int flags)
 
 {
 	struct sock *sk = sock->sk;
@@ -343,9 +343,8 @@ static long caif_stream_data_wait(struct sock *sk, long timeo)
  * Copied from unix_stream_recvmsg, but removed credit checks,
  * changed locking calls, changed address handling.
  */
-static int caif_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size,
-			       int flags)
+static int caif_stream_recvmsg(struct socket *sock, struct msghdr *msg,
+			       size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	int copied = 0;
@@ -511,8 +510,8 @@ static int transmit_skb(struct sk_buff *skb, struct caifsock *cf_sk,
 }
 
 /* Copied from af_unix:unix_dgram_sendmsg, and adapted to CAIF */
-static int caif_seqpkt_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			       struct msghdr *msg, size_t len)
+static int caif_seqpkt_sendmsg(struct socket *sock, struct msghdr *msg,
+			       size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
@@ -586,8 +585,8 @@ err:
  * Changed removed permission handling and added waiting for flow on
  * and other minor adaptations.
  */
-static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			       struct msghdr *msg, size_t len)
+static int caif_stream_sendmsg(struct socket *sock, struct msghdr *msg,
+			       size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
diff --git a/net/can/bcm.c b/net/can/bcm.c
index ee9ffd9..5cbafd2 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1231,8 +1231,7 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 /*
  * bcm_sendmsg - process BCM commands (opcodes) from the userspace
  */
-static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, size_t size)
+static int bcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 {
 	struct sock *sk = sock->sk;
 	struct bcm_sock *bo = bcm_sk(sk);
@@ -1535,8 +1534,8 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 	return 0;
 }
 
-static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, size_t size, int flags)
+static int bcm_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		       int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff --git a/net/can/raw.c b/net/can/raw.c
index 00c13ef..30f3181 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -658,8 +658,7 @@ static int raw_getsockopt(struct socket *sock, int level, int optname,
 	return 0;
 }
 
-static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, size_t size)
+static int raw_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 {
 	struct sock *sk = sock->sk;
 	struct raw_sock *ro = raw_sk(sk);
@@ -728,8 +727,8 @@ send_failed:
 	return err;
 }
 
-static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, size_t size, int flags)
+static int raw_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		       int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff --git a/net/core/sock.c b/net/core/sock.c
index 93c8b20..f0c76ec 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2163,15 +2163,14 @@ int sock_no_getsockopt(struct socket *sock, int level, int optname,
 }
 EXPORT_SYMBOL(sock_no_getsockopt);
 
-int sock_no_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		    size_t len)
+int sock_no_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 {
 	return -EOPNOTSUPP;
 }
 EXPORT_SYMBOL(sock_no_sendmsg);
 
-int sock_no_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		    size_t len, int flags)
+int sock_no_recvmsg(struct socket *sock, struct msghdr *m, size_t len,
+		    int flags)
 {
 	return -EOPNOTSUPP;
 }
@@ -2543,14 +2542,14 @@ int compat_sock_common_getsockopt(struct socket *sock, int level, int optname,
 EXPORT_SYMBOL(compat_sock_common_getsockopt);
 #endif
 
-int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t size, int flags)
+int sock_common_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+			int flags)
 {
 	struct sock *sk = sock->sk;
 	int addr_len = 0;
 	int err;
 
-	err = sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAIT,
+	err = sk->sk_prot->recvmsg(sk, msg, size, flags & MSG_DONTWAIT,
 				   flags & ~MSG_DONTWAIT, &addr_len);
 	if (err >= 0)
 		msg->msg_namelen = addr_len;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index e4c144f..3b1d64d 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -310,11 +310,9 @@ int compat_dccp_setsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, unsigned int optlen);
 #endif
 int dccp_ioctl(struct sock *sk, int cmd, unsigned long arg);
-int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		 size_t size);
-int dccp_recvmsg(struct kiocb *iocb, struct sock *sk,
-		 struct msghdr *msg, size_t len, int nonblock, int flags,
-		 int *addr_len);
+int dccp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
+int dccp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
+		 int flags, int *addr_len);
 void dccp_shutdown(struct sock *sk, int how);
 int inet_dccp_listen(struct socket *sock, int backlog);
 unsigned int dccp_poll(struct file *file, struct socket *sock,
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 595ddf0..d8346d0 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -72,8 +72,7 @@ static void printl(const char *fmt, ...)
 	wake_up(&dccpw.wait);
 }
 
-static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
-			 struct msghdr *msg, size_t size)
+static int jdccp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	const struct inet_sock *inet = inet_sk(sk);
 	struct ccid3_hc_tx_sock *hc = NULL;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e171b78..52a9401 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -741,8 +741,7 @@ static int dccp_msghdr_parse(struct msghdr *msg, struct sk_buff *skb)
 	return 0;
 }
 
-int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		 size_t len)
+int dccp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
 	const int flags = msg->msg_flags;
@@ -806,8 +805,8 @@ out_discard:
 
 EXPORT_SYMBOL_GPL(dccp_sendmsg);
 
-int dccp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		 size_t len, int nonblock, int flags, int *addr_len)
+int dccp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
+		 int flags, int *addr_len)
 {
 	const struct dccp_hdr *dh;
 	long timeo;
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 8102286..754484b 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1669,8 +1669,8 @@ static int dn_data_ready(struct sock *sk, struct sk_buff_head *q, int flags, int
 }
 
 
-static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, size_t size, int flags)
+static int dn_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		      int flags)
 {
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
@@ -1905,8 +1905,7 @@ static inline struct sk_buff *dn_alloc_send_pskb(struct sock *sk,
 	return skb;
 }
 
-static int dn_sendmsg(struct kiocb *iocb, struct socket *sock,
-		      struct msghdr *msg, size_t size)
+static int dn_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 {
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
diff --git a/net/ieee802154/socket.c b/net/ieee802154/socket.c
index 2878d8c..b60c65f 100644
--- a/net/ieee802154/socket.c
+++ b/net/ieee802154/socket.c
@@ -98,12 +98,12 @@ static int ieee802154_sock_release(struct socket *sock)
 	return 0;
 }
 
-static int ieee802154_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-				   struct msghdr *msg, size_t len)
+static int ieee802154_sock_sendmsg(struct socket *sock, struct msghdr *msg,
+				   size_t len)
 {
 	struct sock *sk = sock->sk;
 
-	return sk->sk_prot->sendmsg(iocb, sk, msg, len);
+	return sk->sk_prot->sendmsg(sk, msg, len);
 }
 
 static int ieee802154_sock_bind(struct socket *sock, struct sockaddr *uaddr,
@@ -255,8 +255,7 @@ static int raw_disconnect(struct sock *sk, int flags)
 	return 0;
 }
 
-static int raw_sendmsg(struct kiocb *iocb, struct sock *sk,
-		       struct msghdr *msg, size_t size)
+static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	struct net_device *dev;
 	unsigned int mtu;
@@ -327,8 +326,8 @@ out:
 	return err;
 }
 
-static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		       size_t len, int noblock, int flags, int *addr_len)
+static int raw_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
+		       int noblock, int flags, int *addr_len)
 {
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
@@ -615,8 +614,7 @@ static int dgram_disconnect(struct sock *sk, int flags)
 	return 0;
 }
 
-static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
-			 struct msghdr *msg, size_t size)
+static int dgram_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	struct net_device *dev;
 	unsigned int mtu;
@@ -715,9 +713,8 @@ out:
 	return err;
 }
 
-static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
-			 struct msghdr *msg, size_t len, int noblock,
-			 int flags, int *addr_len)
+static int dgram_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
+			 int noblock, int flags, int *addr_len)
 {
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d2e49ba..9c217e4 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -716,8 +716,7 @@ int inet_getname(struct socket *sock, struct sockaddr *uaddr,
 }
 EXPORT_SYMBOL(inet_getname);
 
-int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 size_t size)
+int inet_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 {
 	struct sock *sk = sock->sk;
 
@@ -728,7 +727,7 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	    inet_autobind(sk))
 		return -EAGAIN;
 
-	return sk->sk_prot->sendmsg(iocb, sk, msg, size);
+	return sk->sk_prot->sendmsg(sk, msg, size);
 }
 EXPORT_SYMBOL(inet_sendmsg);
 
@@ -750,8 +749,8 @@ ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 }
 EXPORT_SYMBOL(inet_sendpage);
 
-int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 size_t size, int flags)
+int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		 int flags)
 {
 	struct sock *sk = sock->sk;
 	int addr_len = 0;
@@ -759,7 +758,7 @@ int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 
 	sock_rps_record_flow(sk);
 
-	err = sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAIT,
+	err = sk->sk_prot->recvmsg(sk, msg, size, flags & MSG_DONTWAIT,
 				   flags & ~MSG_DONTWAIT, &addr_len);
 	if (err >= 0)
 		msg->msg_namelen = addr_len;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index e9f66e1..3648e7f 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -684,8 +684,7 @@ int ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 }
 EXPORT_SYMBOL_GPL(ping_common_sendmsg);
 
-static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-			   size_t len)
+static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct net *net = sock_net(sk);
 	struct flowi4 fl4;
@@ -841,8 +840,8 @@ do_confirm:
 	goto out;
 }
 
-int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		 size_t len, int noblock, int flags, int *addr_len)
+int ping_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
+		 int flags, int *addr_len)
 {
 	struct inet_sock *isk = inet_sk(sk);
 	int family = sk->sk_family;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index f027a70..923cf53 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -481,8 +481,7 @@ static int raw_getfrag(void *from, char *to, int offset, int len, int odd,
 	return ip_generic_getfrag(rfv->msg, to, offset, len, odd, skb);
 }
 
-static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		       size_t len)
+static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipcm_cookie ipc;
@@ -709,8 +708,8 @@ out:	return ret;
  *	we return it, otherwise we block.
  */
 
-static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		       size_t len, int noblock, int flags, int *addr_len)
+static int raw_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
+		       int noblock, int flags, int *addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	size_t copied = 0;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9d72a0f..702045f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1064,8 +1064,7 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 	return err;
 }
 
-int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t size)
+int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -1543,8 +1542,8 @@ EXPORT_SYMBOL(tcp_read_sock);
  *	Probably, code can be easily improved even more.
  */
 
-int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int nonblock, int flags, int *addr_len)
+int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
+		int flags, int *addr_len)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int copied = 0;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 97ef1f8b..a2ce3cc 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -873,8 +873,7 @@ out:
 }
 EXPORT_SYMBOL(udp_push_pending_frames);
 
-int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len)
+int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct udp_sock *up = udp_sk(sk);
@@ -1136,7 +1135,7 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 		 * sendpage interface can't pass.
 		 * This will succeed only when the socket is connected.
 		 */
-		ret = udp_sendmsg(NULL, sk, &msg, 0);
+		ret = udp_sendmsg(sk, &msg, 0);
 		if (ret < 0)
 			return ret;
 	}
@@ -1254,8 +1253,8 @@ EXPORT_SYMBOL(udp_ioctl);
  * 	return it, otherwise we block.
  */
 
-int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int noblock, int flags, int *addr_len)
+int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
+		int flags, int *addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index f3c2789..7e0fe4b 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -21,8 +21,8 @@ int compat_udp_setsockopt(struct sock *sk, int level, int optname,
 int compat_udp_getsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int __user *optlen);
 #endif
-int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int noblock, int flags, int *addr_len);
+int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
+		int flags, int *addr_len);
 int udp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
 int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index bd46f73..fee25c0 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -77,8 +77,7 @@ static int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 	return 0;
 }
 
-int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		    size_t len)
+int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 0d84b2c..a5287b3 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -456,9 +456,8 @@ int rawv6_rcv(struct sock *sk, struct sk_buff *skb)
  *	we return it, otherwise we block.
  */
 
-static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
-		  struct msghdr *msg, size_t len,
-		  int noblock, int flags, int *addr_len)
+static int rawv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
+			 int noblock, int flags, int *addr_len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
@@ -730,8 +729,7 @@ static int raw6_getfrag(void *from, char *to, int offset, int len, int odd,
 	return ip_generic_getfrag(rfv->msg, to, offset, len, odd, skb);
 }
 
-static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
-		   struct msghdr *msg, size_t len)
+static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct ipv6_txoptions opt_space;
 	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d048d46..70568a4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -391,8 +391,7 @@ EXPORT_SYMBOL_GPL(udp6_lib_lookup);
  *	return it, otherwise we block.
  */
 
-int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
-		  struct msghdr *msg, size_t len,
+int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 		  int noblock, int flags, int *addr_len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1101,8 +1100,7 @@ out:
 	return err;
 }
 
-int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
-		  struct msghdr *msg, size_t len)
+int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct ipv6_txoptions opt_space;
 	struct udp_sock *up = udp_sk(sk);
@@ -1164,12 +1162,12 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 do_udp_sendmsg:
 			if (__ipv6_only_sock(sk))
 				return -ENETUNREACH;
-			return udp_sendmsg(iocb, sk, msg, len);
+			return udp_sendmsg(sk, msg, len);
 		}
 	}
 
 	if (up->pending == AF_INET)
-		return udp_sendmsg(iocb, sk, msg, len);
+		return udp_sendmsg(sk, msg, len);
 
 	/* Rough check on arithmetic overflow,
 	   better check is made in ip6_append_data().
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index c779c3c..0682c03 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -23,10 +23,9 @@ int compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
 int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 			    char __user *optval, int __user *optlen);
 #endif
-int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		  size_t len);
-int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		  size_t len, int noblock, int flags, int *addr_len);
+int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
+int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
+		  int flags, int *addr_len);
 int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 void udpv6_destroy_sock(struct sock *sk);
 
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index f11ad1d..4ea5d74 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1688,8 +1688,7 @@ out:
 	return rc;
 }
 
-static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, size_t len)
+static int ipx_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_sock *ipxs = ipx_sk(sk);
@@ -1754,8 +1753,8 @@ out:
 }
 
 
-static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
-		struct msghdr *msg, size_t size, int flags)
+static int ipx_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		       int flags)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_sock *ipxs = ipx_sk(sk);
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 568edc7..ee0ea25 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1256,14 +1256,13 @@ static int irda_release(struct socket *sock)
 }
 
 /*
- * Function irda_sendmsg (iocb, sock, msg, len)
+ * Function irda_sendmsg (sock, msg, len)
  *
  *    Send message down to TinyTP. This function is used for both STREAM and
  *    SEQPACK services. This is possible since it forces the client to
  *    fragment the message if necessary
  */
-static int irda_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t len)
+static int irda_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
@@ -1348,13 +1347,13 @@ out:
 }
 
 /*
- * Function irda_recvmsg_dgram (iocb, sock, msg, size, flags)
+ * Function irda_recvmsg_dgram (sock, msg, size, flags)
  *
  *    Try to receive message and copy it to user. The frame is discarded
  *    after being read, regardless of how much the user actually read
  */
-static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t size, int flags)
+static int irda_recvmsg_dgram(struct socket *sock, struct msghdr *msg,
+			      size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
@@ -1398,10 +1397,10 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 }
 
 /*
- * Function irda_recvmsg_stream (iocb, sock, msg, size, flags)
+ * Function irda_recvmsg_stream (sock, msg, size, flags)
  */
-static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size, int flags)
+static int irda_recvmsg_stream(struct socket *sock, struct msghdr *msg,
+			       size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
@@ -1515,14 +1514,14 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 }
 
 /*
- * Function irda_sendmsg_dgram (iocb, sock, msg, len)
+ * Function irda_sendmsg_dgram (sock, msg, len)
  *
  *    Send message down to TinyTP for the unreliable sequenced
  *    packet service...
  *
  */
-static int irda_sendmsg_dgram(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t len)
+static int irda_sendmsg_dgram(struct socket *sock, struct msghdr *msg,
+			      size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
@@ -1594,14 +1593,14 @@ out:
 }
 
 /*
- * Function irda_sendmsg_ultra (iocb, sock, msg, len)
+ * Function irda_sendmsg_ultra (sock, msg, len)
  *
  *    Send message down to IrLMP for the unreliable Ultra
  *    packet service...
  */
 #ifdef CONFIG_IRDA_ULTRA
-static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t len)
+static int irda_sendmsg_ultra(struct socket *sock, struct msghdr *msg,
+			      size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 2e9953b..94b4c89 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1026,8 +1026,8 @@ static int iucv_send_iprm(struct iucv_path *path, struct iucv_message *msg,
 				 (void *) prmdata, 8);
 }
 
-static int iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			     struct msghdr *msg, size_t len)
+static int iucv_sock_sendmsg(struct socket *sock, struct msghdr *msg,
+			     size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv = iucv_sk(sk);
@@ -1317,8 +1317,8 @@ static void iucv_process_message_q(struct sock *sk)
 	}
 }
 
-static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			     struct msghdr *msg, size_t len, int flags)
+static int iucv_sock_recvmsg(struct socket *sock, struct msghdr *msg,
+			     size_t len, int flags)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index f8ac939..9255fd9 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3588,8 +3588,7 @@ static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 }
 #endif
 
-static int pfkey_sendmsg(struct kiocb *kiocb,
-			 struct socket *sock, struct msghdr *msg, size_t len)
+static int pfkey_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb = NULL;
@@ -3630,8 +3629,7 @@ out:
 	return err ? : len;
 }
 
-static int pfkey_recvmsg(struct kiocb *kiocb,
-			 struct socket *sock, struct msghdr *msg, size_t len,
+static int pfkey_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			 int flags)
 {
 	struct sock *sk = sock->sk;
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 05dfc8a..7964993 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -385,7 +385,7 @@ drop:
 /* Userspace will call sendmsg() on the tunnel socket to send L2TP
  * control frames.
  */
-static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg, size_t len)
+static int l2tp_ip_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct sk_buff *skb;
 	int rc;
@@ -506,7 +506,7 @@ no_route:
 	goto out;
 }
 
-static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+static int l2tp_ip_recvmsg(struct sock *sk, struct msghdr *msg,
 			   size_t len, int noblock, int flags, int *addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 8611f1b..d1ded37 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -480,8 +480,7 @@ out:
 /* Userspace will call sendmsg() on the tunnel socket to send L2TP
  * control frames.
  */
-static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
-			    struct msghdr *msg, size_t len)
+static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct ipv6_txoptions opt_space;
 	DECLARE_SOCKADDR(struct sockaddr_l2tpip6 *, lsa, msg->msg_name);
@@ -643,9 +642,8 @@ do_confirm:
 	goto done;
 }
 
-static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
-			    struct msghdr *msg, size_t len, int noblock,
-			    int flags, int *addr_len)
+static int l2tp_ip6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
+			    int noblock, int flags, int *addr_len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_l2tpip6 *, lsa, msg->msg_name);
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index cc7a828..e9b0dec 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -185,9 +185,8 @@ static int pppol2tp_recv_payload_hook(struct sk_buff *skb)
 
 /* Receive message. This is the recvmsg for the PPPoL2TP socket.
  */
-static int pppol2tp_recvmsg(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *msg, size_t len,
-			    int flags)
+static int pppol2tp_recvmsg(struct socket *sock, struct msghdr *msg,
+			    size_t len, int flags)
 {
 	int err;
 	struct sk_buff *skb;
@@ -295,7 +294,7 @@ static void pppol2tp_session_sock_put(struct l2tp_session *session)
  * when a user application does a sendmsg() on the session socket. L2TP and
  * PPP headers must be inserted into the user's data.
  */
-static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
+static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
 			    size_t total_len)
 {
 	static const unsigned char ppph[2] = { 0xff, 0x03 };
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 2c0b83c..17a8dff 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -704,8 +704,8 @@ out:
  *	Copy received data to the socket user.
  *	Returns non-negative upon success, negative otherwise.
  */
-static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, size_t len, int flags)
+static int llc_ui_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+			  int flags)
 {
 	DECLARE_SOCKADDR(struct sockaddr_llc *, uaddr, msg->msg_name);
 	const int nonblock = flags & MSG_DONTWAIT;
@@ -878,8 +878,7 @@ copy_uaddr:
  *	Transmit data provided by the socket user.
  *	Returns non-negative upon success, negative otherwise.
  */
-static int llc_ui_sendmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, size_t len)
+static int llc_ui_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct llc_sock *llc = llc_sk(sk);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2702673..a96025c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2256,8 +2256,7 @@ static void netlink_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 	put_cmsg(msg, SOL_NETLINK, NETLINK_PKTINFO, sizeof(info), &info);
 }
 
-static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			   struct msghdr *msg, size_t len)
+static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -2346,8 +2345,7 @@ out:
 	return err;
 }
 
-static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
-			   struct msghdr *msg, size_t len,
+static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			   int flags)
 {
 	struct scm_cookie scm;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 69f1d5e..b987fd5 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1023,8 +1023,7 @@ int nr_rx_frame(struct sk_buff *skb, struct net_device *dev)
 	return 1;
 }
 
-static int nr_sendmsg(struct kiocb *iocb, struct socket *sock,
-		      struct msghdr *msg, size_t len)
+static int nr_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct nr_sock *nr = nr_sk(sk);
@@ -1133,8 +1132,8 @@ out:
 	return err;
 }
 
-static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
-		      struct msghdr *msg, size_t size, int flags)
+static int nr_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		      int flags)
 {
 	struct sock *sk = sock->sk;
 	DECLARE_SOCKADDR(struct sockaddr_ax25 *, sax, msg->msg_name);
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index e181e29..9578bd6 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -750,8 +750,8 @@ error:
 	return ret;
 }
 
-static int llcp_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			     struct msghdr *msg, size_t len)
+static int llcp_sock_sendmsg(struct socket *sock, struct msghdr *msg,
+			     size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct nfc_llcp_sock *llcp_sock = nfc_llcp_sock(sk);
@@ -793,8 +793,8 @@ static int llcp_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	return nfc_llcp_send_i_frame(llcp_sock, msg, len);
 }
 
-static int llcp_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			     struct msghdr *msg, size_t len, int flags)
+static int llcp_sock_recvmsg(struct socket *sock, struct msghdr *msg,
+			     size_t len, int flags)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index 373e138..82b4e80 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -211,8 +211,7 @@ static void rawsock_tx_work(struct work_struct *work)
 	}
 }
 
-static int rawsock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			   struct msghdr *msg, size_t len)
+static int rawsock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct nfc_dev *dev = nfc_rawsock(sk)->dev;
@@ -248,8 +247,8 @@ static int rawsock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	return len;
 }
 
-static int rawsock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			   struct msghdr *msg, size_t len, int flags)
+static int rawsock_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+			   int flags)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9c28cec..85da83c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1600,8 +1600,8 @@ oom:
  *	protocol layers and you must therefore supply it with a complete frame
  */
 
-static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t len)
+static int packet_sendmsg_spkt(struct socket *sock, struct msghdr *msg,
+			       size_t len)
 {
 	struct sock *sk = sock->sk;
 	DECLARE_SOCKADDR(struct sockaddr_pkt *, saddr, msg->msg_name);
@@ -2595,8 +2595,7 @@ out:
 	return err;
 }
 
-static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
-		struct msghdr *msg, size_t len)
+static int packet_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
@@ -2876,8 +2875,8 @@ out:
  *	If necessary we block.
  */
 
-static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, size_t len, int flags)
+static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+			  int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 26054b4..5e71043 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -83,8 +83,7 @@ static int pn_init(struct sock *sk)
 	return 0;
 }
 
-static int pn_sendmsg(struct kiocb *iocb, struct sock *sk,
-			struct msghdr *msg, size_t len)
+static int pn_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	DECLARE_SOCKADDR(struct sockaddr_pn *, target, msg->msg_name);
 	struct sk_buff *skb;
@@ -125,9 +124,8 @@ static int pn_sendmsg(struct kiocb *iocb, struct sock *sk,
 	return (err >= 0) ? len : err;
 }
 
-static int pn_recvmsg(struct kiocb *iocb, struct sock *sk,
-			struct msghdr *msg, size_t len, int noblock,
-			int flags, int *addr_len)
+static int pn_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
+		      int noblock, int flags, int *addr_len)
 {
 	struct sk_buff *skb = NULL;
 	struct sockaddr_pn sa;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 5d3f2b7..6de2aeb 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1118,8 +1118,7 @@ static int pipe_skb_send(struct sock *sk, struct sk_buff *skb)
 
 }
 
-static int pep_sendmsg(struct kiocb *iocb, struct sock *sk,
-			struct msghdr *msg, size_t len)
+static int pep_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct pep_sock *pn = pep_sk(sk);
 	struct sk_buff *skb;
@@ -1246,9 +1245,8 @@ struct sk_buff *pep_read(struct sock *sk)
 	return skb;
 }
 
-static int pep_recvmsg(struct kiocb *iocb, struct sock *sk,
-			struct msghdr *msg, size_t len, int noblock,
-			int flags, int *addr_len)
+static int pep_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
+		       int noblock, int flags, int *addr_len)
 {
 	struct sk_buff *skb;
 	int err;
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 008214a..d575ef4 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -425,15 +425,15 @@ out:
 	return err;
 }
 
-static int pn_socket_sendmsg(struct kiocb *iocb, struct socket *sock,
-				struct msghdr *m, size_t total_len)
+static int pn_socket_sendmsg(struct socket *sock, struct msghdr *m,
+			     size_t total_len)
 {
 	struct sock *sk = sock->sk;
 
 	if (pn_socket_autobind(sock))
 		return -EAGAIN;
 
-	return sk->sk_prot->sendmsg(iocb, sk, m, total_len);
+	return sk->sk_prot->sendmsg(sk, m, total_len);
 }
 
 const struct proto_ops phonet_dgram_ops = {
diff --git a/net/rds/rds.h b/net/rds/rds.h
index c2a5eef..c3f2855 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -702,8 +702,8 @@ void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 void rds_inc_put(struct rds_incoming *inc);
 void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 		       struct rds_incoming *inc, gfp_t gfp);
-int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t size, int msg_flags);
+int rds_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		int msg_flags);
 void rds_clear_recv_queue(struct rds_sock *rs);
 int rds_notify_queue_get(struct rds_sock *rs, struct msghdr *msg);
 void rds_inc_info_copy(struct rds_incoming *inc,
@@ -711,8 +711,7 @@ void rds_inc_info_copy(struct rds_incoming *inc,
 		       __be32 saddr, __be32 daddr, int flip);
 
 /* send.c */
-int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t payload_len);
+int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len);
 void rds_send_reset(struct rds_connection *conn);
 int rds_send_xmit(struct rds_connection *conn);
 struct sockaddr_in;
diff --git a/net/rds/recv.c b/net/rds/recv.c
index f9ec1ac..a00462b 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -395,8 +395,8 @@ static int rds_cmsg_recv(struct rds_incoming *inc, struct msghdr *msg)
 	return 0;
 }
 
-int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t size, int msg_flags)
+int rds_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		int msg_flags)
 {
 	struct sock *sk = sock->sk;
 	struct rds_sock *rs = rds_sk_to_rs(sk);
diff --git a/net/rds/send.c b/net/rds/send.c
index 42f65d4..44672be 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -920,8 +920,7 @@ static int rds_cmsg_send(struct rds_sock *rs, struct rds_message *rm,
 	return ret;
 }
 
-int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t payload_len)
+int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 {
 	struct sock *sk = sock->sk;
 	struct rds_sock *rs = rds_sk_to_rs(sk);
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 43bac7c..8ae6030 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1046,8 +1046,7 @@ int rose_rx_call_request(struct sk_buff *skb, struct net_device *dev, struct ros
 	return 1;
 }
 
-static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t len)
+static int rose_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct rose_sock *rose = rose_sk(sk);
@@ -1211,8 +1210,8 @@ static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
 }
 
 
-static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t size, int flags)
+static int rose_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+			int flags)
 {
 	struct sock *sk = sock->sk;
 	struct rose_sock *rose = rose_sk(sk);
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 7b16704..0095b9a 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -441,8 +441,7 @@ static int rxrpc_connect(struct socket *sock, struct sockaddr *addr,
  *   - sends a call data packet
  *   - may send an abort (abort code in control data)
  */
-static int rxrpc_sendmsg(struct kiocb *iocb, struct socket *sock,
-			 struct msghdr *m, size_t len)
+static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 {
 	struct rxrpc_transport *trans;
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
@@ -482,7 +481,7 @@ static int rxrpc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	switch (rx->sk.sk_state) {
 	case RXRPC_SERVER_LISTENING:
 		if (!m->msg_name) {
-			ret = rxrpc_server_sendmsg(iocb, rx, m, len);
+			ret = rxrpc_server_sendmsg(rx, m, len);
 			break;
 		}
 	case RXRPC_SERVER_BOUND:
@@ -492,7 +491,7 @@ static int rxrpc_sendmsg(struct kiocb *iocb, struct socket *sock,
 			break;
 		}
 	case RXRPC_CLIENT_CONNECTED:
-		ret = rxrpc_client_sendmsg(iocb, rx, trans, m, len);
+		ret = rxrpc_client_sendmsg(rx, trans, m, len);
 		break;
 	default:
 		ret = -ENOTCONN;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ba9fd36..2fc1e65 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -548,10 +548,9 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time_t,
 extern unsigned rxrpc_resend_timeout;
 
 int rxrpc_send_packet(struct rxrpc_transport *, struct sk_buff *);
-int rxrpc_client_sendmsg(struct kiocb *, struct rxrpc_sock *,
-			 struct rxrpc_transport *, struct msghdr *, size_t);
-int rxrpc_server_sendmsg(struct kiocb *, struct rxrpc_sock *, struct msghdr *,
-			 size_t);
+int rxrpc_client_sendmsg(struct rxrpc_sock *, struct rxrpc_transport *,
+			 struct msghdr *, size_t);
+int rxrpc_server_sendmsg(struct rxrpc_sock *, struct msghdr *, size_t);
 
 /*
  * ar-peer.c
@@ -572,8 +571,7 @@ extern const struct file_operations rxrpc_connection_seq_fops;
  * ar-recvmsg.c
  */
 void rxrpc_remove_user_ID(struct rxrpc_sock *, struct rxrpc_call *);
-int rxrpc_recvmsg(struct kiocb *, struct socket *, struct msghdr *, size_t,
-		  int);
+int rxrpc_recvmsg(struct socket *, struct msghdr *, size_t, int);
 
 /*
  * ar-security.c
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 8331c95..09f5845 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -23,8 +23,7 @@
  */
 unsigned rxrpc_resend_timeout = 4 * HZ;
 
-static int rxrpc_send_data(struct kiocb *iocb,
-			   struct rxrpc_sock *rx,
+static int rxrpc_send_data(struct rxrpc_sock *rx,
 			   struct rxrpc_call *call,
 			   struct msghdr *msg, size_t len);
 
@@ -129,9 +128,8 @@ static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
  * - caller holds the socket locked
  * - the socket may be either a client socket or a server socket
  */
-int rxrpc_client_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
-			 struct rxrpc_transport *trans, struct msghdr *msg,
-			 size_t len)
+int rxrpc_client_sendmsg(struct rxrpc_sock *rx, struct rxrpc_transport *trans,
+			 struct msghdr *msg, size_t len)
 {
 	struct rxrpc_conn_bundle *bundle;
 	enum rxrpc_command cmd;
@@ -191,7 +189,7 @@ int rxrpc_client_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
 		/* request phase complete for this client call */
 		ret = -EPROTO;
 	} else {
-		ret = rxrpc_send_data(iocb, rx, call, msg, len);
+		ret = rxrpc_send_data(rx, call, msg, len);
 	}
 
 	rxrpc_put_call(call);
@@ -232,7 +230,7 @@ int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
 		   call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
 		ret = -EPROTO; /* request phase complete for this client call */
 	} else {
-		ret = rxrpc_send_data(NULL, call->socket, call, msg, len);
+		ret = rxrpc_send_data(call->socket, call, msg, len);
 	}
 
 	release_sock(&call->socket->sk);
@@ -271,8 +269,7 @@ EXPORT_SYMBOL(rxrpc_kernel_abort_call);
  * send a message through a server socket
  * - caller holds the socket locked
  */
-int rxrpc_server_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
-			 struct msghdr *msg, size_t len)
+int rxrpc_server_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 {
 	enum rxrpc_command cmd;
 	struct rxrpc_call *call;
@@ -313,7 +310,7 @@ int rxrpc_server_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
 			break;
 		}
 
-		ret = rxrpc_send_data(iocb, rx, call, msg, len);
+		ret = rxrpc_send_data(rx, call, msg, len);
 		break;
 
 	case RXRPC_CMD_SEND_ABORT:
@@ -520,8 +517,7 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
  * - must be called in process context
  * - caller holds the socket locked
  */
-static int rxrpc_send_data(struct kiocb *iocb,
-			   struct rxrpc_sock *rx,
+static int rxrpc_send_data(struct rxrpc_sock *rx,
 			   struct rxrpc_call *call,
 			   struct msghdr *msg, size_t len)
 {
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index 4575485..0c19c9e 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -43,8 +43,8 @@ void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
  * - we need to be careful about two or more threads calling recvmsg
  *   simultaneously
  */
-int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
-		  struct msghdr *msg, size_t len, int flags)
+int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+		  int flags)
 {
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_call *call = NULL, *continue_call = NULL;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index aafe94b..f1a6539 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1586,8 +1586,7 @@ static int sctp_error(struct sock *sk, int flags, int err)
 
 static int sctp_msghdr_parse(const struct msghdr *, sctp_cmsgs_t *);
 
-static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
-			struct msghdr *msg, size_t msg_len)
+static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 {
 	struct net *net = sock_net(sk);
 	struct sctp_sock *sp;
@@ -2066,9 +2065,8 @@ static int sctp_skb_pull(struct sk_buff *skb, int len)
  *  flags   - flags sent or received with the user message, see Section
  *            5 for complete description of the flags.
  */
-static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
-			struct msghdr *msg, size_t len, int noblock,
-			int flags, int *addr_len)
+static int sctp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
+			int noblock, int flags, int *addr_len)
 {
 	struct sctp_ulpevent *event = NULL;
 	struct sctp_sock *sp = sctp_sk(sk);
diff --git a/net/socket.c b/net/socket.c
index bbedbfc..27ef900 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -610,45 +610,20 @@ void __sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
 }
 EXPORT_SYMBOL(__sock_tx_timestamp);
 
-static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
-				       struct msghdr *msg, size_t size)
+static inline int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg,
+				     size_t size)
 {
-	return sock->ops->sendmsg(iocb, sock, msg, size);
+	return sock->ops->sendmsg(sock, msg, size);
 }
 
-static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-				 struct msghdr *msg, size_t size)
+int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 {
 	int err = security_socket_sendmsg(sock, msg, size);
 
-	return err ?: __sock_sendmsg_nosec(iocb, sock, msg, size);
-}
-
-static int do_sock_sendmsg(struct socket *sock, struct msghdr *msg,
-			   size_t size, bool nosec)
-{
-	struct kiocb iocb;
-	int ret;
-
-	init_sync_kiocb(&iocb, NULL);
-	ret = nosec ? __sock_sendmsg_nosec(&iocb, sock, msg, size) :
-		      __sock_sendmsg(&iocb, sock, msg, size);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&iocb);
-	return ret;
-}
-
-int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
-{
-	return do_sock_sendmsg(sock, msg, size, false);
+	return err ?: sock_sendmsg_nosec(sock, msg, size);
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
-static int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
-{
-	return do_sock_sendmsg(sock, msg, size, true);
-}
-
 int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size)
 {
@@ -744,47 +719,21 @@ void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
 
-static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
-				       struct msghdr *msg, size_t size, int flags)
+static inline int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
+				     size_t size, int flags)
 {
-	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
+	return sock->ops->recvmsg(sock, msg, size, flags);
 }
 
-static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-				 struct msghdr *msg, size_t size, int flags)
+int sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		 int flags)
 {
 	int err = security_socket_recvmsg(sock, msg, size, flags);
 
-	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
-}
-
-int sock_recvmsg(struct socket *sock, struct msghdr *msg,
-		 size_t size, int flags)
-{
-	struct kiocb iocb;
-	int ret;
-
-	init_sync_kiocb(&iocb, NULL);
-	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&iocb);
-	return ret;
+	return err ?: sock_recvmsg_nosec(sock, msg, size, flags);
 }
 EXPORT_SYMBOL(sock_recvmsg);
 
-static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
-			      size_t size, int flags)
-{
-	struct kiocb iocb;
-	int ret;
-
-	init_sync_kiocb(&iocb, NULL);
-	ret = __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
-	if (-EIOCBQUEUED == ret)
-		ret = wait_on_sync_kiocb(&iocb);
-	return ret;
-}
-
 /**
  * kernel_recvmsg - Receive a message from a socket (kernel space)
  * @sock:       The socket to receive the message from
@@ -861,8 +810,7 @@ static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (iocb->ki_nbytes == 0)	/* Match SYS5 behaviour */
 		return 0;
 
-	res = __sock_recvmsg(iocb, sock, &msg,
-			     iocb->ki_nbytes, msg.msg_flags);
+	res = sock_recvmsg(sock, &msg, iocb->ki_nbytes, msg.msg_flags);
 	*to = msg.msg_iter;
 	return res;
 }
@@ -883,7 +831,7 @@ static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (sock->type == SOCK_SEQPACKET)
 		msg.msg_flags |= MSG_EOR;
 
-	res = __sock_sendmsg(iocb, sock, &msg, iocb->ki_nbytes);
+	res = sock_sendmsg(sock, &msg, iocb->ki_nbytes);
 	*from = msg.msg_iter;
 	return res;
 }
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index c245ec3..dcb797c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -895,7 +895,6 @@ static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
 
 /**
  * tipc_sendmsg - send message in connectionless manner
- * @iocb: if NULL, indicates that socket lock is already held
  * @sock: socket structure
  * @m: message to send
  * @dsz: amount of user data to be sent
@@ -907,7 +906,7 @@ static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
  *
  * Returns the number of bytes sent on success, or errno otherwise
  */
-static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
+static int tipc_sendmsg(struct socket *sock,
 			struct msghdr *m, size_t dsz)
 {
 	struct sock *sk = sock->sk;
@@ -1052,7 +1051,6 @@ static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
 
 /**
  * tipc_send_stream - send stream-oriented data
- * @iocb: (unused)
  * @sock: socket structure
  * @m: data to send
  * @dsz: total length of data to be transmitted
@@ -1062,8 +1060,7 @@ static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
  * Returns the number of bytes sent on success (or partial success),
  * or errno if no data sent
  */
-static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *m, size_t dsz)
+static int tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 {
 	struct sock *sk = sock->sk;
 	int ret;
@@ -1147,7 +1144,6 @@ next:
 
 /**
  * tipc_send_packet - send a connection-oriented message
- * @iocb: if NULL, indicates that socket lock is already held
  * @sock: socket structure
  * @m: message to send
  * @dsz: length of data to be transmitted
@@ -1156,13 +1152,12 @@ next:
  *
  * Returns the number of bytes sent on success, or errno otherwise
  */
-static int tipc_send_packet(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *m, size_t dsz)
+static int tipc_send_packet(struct socket *sock, struct msghdr *m, size_t dsz)
 {
 	if (dsz > TIPC_MAX_USER_MSG_SIZE)
 		return -EMSGSIZE;
 
-	return tipc_send_stream(iocb, sock, m, dsz);
+	return tipc_send_stream(sock, m, dsz);
 }
 
 /* tipc_sk_finish_conn - complete the setup of a connection
@@ -1337,7 +1332,6 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
 
 /**
  * tipc_recvmsg - receive packet-oriented message
- * @iocb: (unused)
  * @m: descriptor for message info
  * @buf_len: total size of user buffer area
  * @flags: receive flags
@@ -1347,8 +1341,8 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
  *
  * Returns size of returned message data, errno otherwise
  */
-static int tipc_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *m, size_t buf_len, int flags)
+static int tipc_recvmsg(struct socket *sock, struct msghdr *m, size_t buf_len,
+			int flags)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
@@ -1432,7 +1426,6 @@ exit:
 
 /**
  * tipc_recv_stream - receive stream-oriented data
- * @iocb: (unused)
  * @m: descriptor for message info
  * @buf_len: total size of user buffer area
  * @flags: receive flags
@@ -1442,8 +1435,8 @@ exit:
  *
  * Returns size of returned message data, errno otherwise
  */
-static int tipc_recv_stream(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *m, size_t buf_len, int flags)
+static int tipc_recv_stream(struct socket *sock, struct msghdr *m,
+			    size_t buf_len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 526b6ed..433f287 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -516,20 +516,15 @@ static unsigned int unix_dgram_poll(struct file *, struct socket *,
 				    poll_table *);
 static int unix_ioctl(struct socket *, unsigned int, unsigned long);
 static int unix_shutdown(struct socket *, int);
-static int unix_stream_sendmsg(struct kiocb *, struct socket *,
-			       struct msghdr *, size_t);
-static int unix_stream_recvmsg(struct kiocb *, struct socket *,
-			       struct msghdr *, size_t, int);
-static int unix_dgram_sendmsg(struct kiocb *, struct socket *,
-			      struct msghdr *, size_t);
-static int unix_dgram_recvmsg(struct kiocb *, struct socket *,
-			      struct msghdr *, size_t, int);
+static int unix_stream_sendmsg(struct socket *, struct msghdr *, size_t);
+static int unix_stream_recvmsg(struct socket *, struct msghdr *, size_t, int);
+static int unix_dgram_sendmsg(struct socket *, struct msghdr *, size_t);
+static int unix_dgram_recvmsg(struct socket *, struct msghdr *, size_t, int);
 static int unix_dgram_connect(struct socket *, struct sockaddr *,
 			      int, int);
-static int unix_seqpacket_sendmsg(struct kiocb *, struct socket *,
-				  struct msghdr *, size_t);
-static int unix_seqpacket_recvmsg(struct kiocb *, struct socket *,
-				  struct msghdr *, size_t, int);
+static int unix_seqpacket_sendmsg(struct socket *, struct msghdr *, size_t);
+static int unix_seqpacket_recvmsg(struct socket *, struct msghdr *, size_t,
+				  int);
 
 static int unix_set_peek_off(struct sock *sk, int val)
 {
@@ -1442,8 +1437,8 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
  *	Send AF_UNIX data.
  */
 
-static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			      struct msghdr *msg, size_t len)
+static int unix_dgram_sendmsg(struct socket *sock, struct msghdr *msg,
+			      size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
@@ -1622,8 +1617,8 @@ out:
  */
 #define UNIX_SKB_FRAGS_SZ (PAGE_SIZE << get_order(32768))
 
-static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			       struct msghdr *msg, size_t len)
+static int unix_stream_sendmsg(struct socket *sock, struct msghdr *msg,
+			       size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
@@ -1725,8 +1720,8 @@ out_err:
 	return sent ? : err;
 }
 
-static int unix_seqpacket_sendmsg(struct kiocb *kiocb, struct socket *sock,
-				  struct msghdr *msg, size_t len)
+static int unix_seqpacket_sendmsg(struct socket *sock, struct msghdr *msg,
+				  size_t len)
 {
 	int err;
 	struct sock *sk = sock->sk;
@@ -1741,19 +1736,18 @@ static int unix_seqpacket_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (msg->msg_namelen)
 		msg->msg_namelen = 0;
 
-	return unix_dgram_sendmsg(kiocb, sock, msg, len);
+	return unix_dgram_sendmsg(sock, msg, len);
 }
 
-static int unix_seqpacket_recvmsg(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t size,
-			      int flags)
+static int unix_seqpacket_recvmsg(struct socket *sock, struct msghdr *msg,
+				  size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 
 	if (sk->sk_state != TCP_ESTABLISHED)
 		return -ENOTCONN;
 
-	return unix_dgram_recvmsg(iocb, sock, msg, size, flags);
+	return unix_dgram_recvmsg(sock, msg, size, flags);
 }
 
 static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
@@ -1766,9 +1760,8 @@ static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
 	}
 }
 
-static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t size,
-			      int flags)
+static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
+			      size_t size, int flags)
 {
 	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
@@ -1900,9 +1893,8 @@ static unsigned int unix_skb_len(const struct sk_buff *skb)
 	return skb->len - UNIXCB(skb).consumed;
 }
 
-static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size,
-			       int flags)
+static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg,
+			       size_t size, int flags)
 {
 	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 1d0e39c..2ec86e6 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -949,8 +949,8 @@ static unsigned int vsock_poll(struct file *file, struct socket *sock,
 	return mask;
 }
 
-static int vsock_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			       struct msghdr *msg, size_t len)
+static int vsock_dgram_sendmsg(struct socket *sock, struct msghdr *msg,
+			       size_t len)
 {
 	int err;
 	struct sock *sk;
@@ -1062,11 +1062,10 @@ out:
 	return err;
 }
 
-static int vsock_dgram_recvmsg(struct kiocb *kiocb, struct socket *sock,
-			       struct msghdr *msg, size_t len, int flags)
+static int vsock_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
+			       size_t len, int flags)
 {
-	return transport->dgram_dequeue(kiocb, vsock_sk(sock->sk), msg, len,
-					flags);
+	return transport->dgram_dequeue(vsock_sk(sock->sk), msg, len, flags);
 }
 
 static const struct proto_ops vsock_dgram_ops = {
@@ -1505,8 +1504,8 @@ static int vsock_stream_getsockopt(struct socket *sock,
 	return 0;
 }
 
-static int vsock_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
-				struct msghdr *msg, size_t len)
+static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
+				size_t len)
 {
 	struct sock *sk;
 	struct vsock_sock *vsk;
@@ -1644,9 +1643,8 @@ out:
 
 
 static int
-vsock_stream_recvmsg(struct kiocb *kiocb,
-		     struct socket *sock,
-		     struct msghdr *msg, size_t len, int flags)
+vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+		     int flags)
 {
 	struct sock *sk;
 	struct vsock_sock *vsk;
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 7f32550..c294da0 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1730,8 +1730,7 @@ static int vmci_transport_dgram_enqueue(
 	return err - sizeof(*dg);
 }
 
-static int vmci_transport_dgram_dequeue(struct kiocb *kiocb,
-					struct vsock_sock *vsk,
+static int vmci_transport_dgram_dequeue(struct vsock_sock *vsk,
 					struct msghdr *msg, size_t len,
 					int flags)
 {
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index d9149b6..c3ab230 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1077,8 +1077,7 @@ out_clear_request:
 	goto out;
 }
 
-static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, size_t len)
+static int x25_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct x25_sock *x25 = x25_sk(sk);
@@ -1252,8 +1251,7 @@ out_kfree_skb:
 }
 
 
-static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, size_t size,
+static int x25_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		       int flags)
 {
 	struct sock *sk = sock->sk;
-- 
1.7.9.5
