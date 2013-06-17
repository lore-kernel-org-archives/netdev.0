From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: sctp: remove SCTP_STATIC macro
Date: Mon, 17 Jun 2013 11:40:05 +0200
Message-ID: <1371462005-19310-3-git-send-email-dborkman@redhat.com>
References: <1371462005-19310-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932201Ab3FQJkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 05:40:18 -0400
In-Reply-To: <1371462005-19310-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP_STATIC ist just another define for the static keyword. It's use
is inconsistent in the SCTP code anyway and it was introduced in the
initial implementation of SCTP in 2.5. We have a regression suite in
lksctp-tools, but this is for user space only, so noone makes use of
this macro anymore. The kernel test suite for 2.5 is incompatible with
the current SCTP code anyway.

So simply Remove it, to be more consistent with the rest of the kernel
code.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/sctp.h  |  8 -----
 net/sctp/chunk.c         |  2 +-
 net/sctp/input.c         |  4 +--
 net/sctp/ipv6.c          |  4 +--
 net/sctp/protocol.c      |  4 +--
 net/sctp/sm_make_chunk.c | 10 +++----
 net/sctp/socket.c        | 78 ++++++++++++++++++++++--------------------------
 net/sctp/tsnmap.c        | 10 +++----
 net/sctp/ulpevent.c      | 10 +++----
 9 files changed, 57 insertions(+), 73 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index b9f136a..6321c08 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -99,14 +99,6 @@
 #define SCTP_PROTOSW_FLAG INET_PROTOSW_PERMANENT
 #endif
 
-
-/* Certain internal static functions need to be exported when
- * compiled into the test frame.
- */
-#ifndef SCTP_STATIC
-#define SCTP_STATIC static
-#endif
-
 /*
  * Function declarations.
  */
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 69ce21e..7135fc0 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -66,7 +66,7 @@ static void sctp_datamsg_init(struct sctp_datamsg *msg)
 }
 
 /* Allocate and initialize datamsg. */
-SCTP_STATIC struct sctp_datamsg *sctp_datamsg_new(gfp_t gfp)
+static struct sctp_datamsg *sctp_datamsg_new(gfp_t gfp)
 {
 	struct sctp_datamsg *msg;
 	msg = kmalloc(sizeof(struct sctp_datamsg), gfp);
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 6533d81..4cfc746 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -903,11 +903,11 @@ hit:
 }
 
 /* Look up an association. BH-safe. */
-SCTP_STATIC
+static
 struct sctp_association *sctp_lookup_association(struct net *net,
 						 const union sctp_addr *laddr,
 						 const union sctp_addr *paddr,
-					    struct sctp_transport **transportp)
+						 struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc;
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 4f3e13b..adeaa0e 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -145,8 +145,8 @@ static struct notifier_block sctp_inet6addr_notifier = {
 };
 
 /* ICMP error handler. */
-SCTP_STATIC void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-			     u8 type, u8 code, int offset, __be32 info)
+static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+			u8 type, u8 code, int offset, __be32 info)
 {
 	struct inet6_dev *idev;
 	struct sock *sk;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index fad7d1b..57b568c 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1312,7 +1312,7 @@ static struct pernet_operations sctp_net_ops = {
 };
 
 /* Initialize the universe into something sensible.  */
-SCTP_STATIC __init int sctp_init(void)
+static __init int sctp_init(void)
 {
 	int i;
 	int status = -EINVAL;
@@ -1499,7 +1499,7 @@ err_chunk_cachep:
 }
 
 /* Exit handler for the SCTP protocol.  */
-SCTP_STATIC __exit void sctp_exit(void)
+static __exit void sctp_exit(void)
 {
 	/* BUG.  This should probably do something useful like clean
 	 * up all the remaining associations and all that memory.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index cf579e7..fc85487 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -68,9 +68,8 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
-SCTP_STATIC
-struct sctp_chunk *sctp_make_chunk(const struct sctp_association *asoc,
-				   __u8 type, __u8 flags, int paylen);
+static struct sctp_chunk *sctp_make_chunk(const struct sctp_association *asoc,
+					  __u8 type, __u8 flags, int paylen);
 static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const struct sctp_chunk *init_chunk,
@@ -1353,9 +1352,8 @@ const union sctp_addr *sctp_source(const struct sctp_chunk *chunk)
 /* Create a new chunk, setting the type and flags headers from the
  * arguments, reserving enough space for a 'paylen' byte payload.
  */
-SCTP_STATIC
-struct sctp_chunk *sctp_make_chunk(const struct sctp_association *asoc,
-				   __u8 type, __u8 flags, int paylen)
+static struct sctp_chunk *sctp_make_chunk(const struct sctp_association *asoc,
+					  __u8 type, __u8 flags, int paylen)
 {
 	struct sctp_chunk *retval;
 	sctp_chunkhdr_t *chunk_hdr;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 510dc79..75fe92a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -84,11 +84,6 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
-/* WARNING:  Please do not remove the SCTP_STATIC attribute to
- * any of the functions below as they are used to export functions
- * used by a project regression testsuite.
- */
-
 /* Forward declarations for internal helper functions. */
 static int sctp_writeable(struct sock *sk);
 static void sctp_wfree(struct sk_buff *skb);
@@ -279,7 +274,7 @@ static struct sctp_transport *sctp_addr_id2transport(struct sock *sk,
  *             sockaddr_in6 [RFC 2553]),
  *   addr_len - the size of the address structure.
  */
-SCTP_STATIC int sctp_bind(struct sock *sk, struct sockaddr *addr, int addr_len)
+static int sctp_bind(struct sock *sk, struct sockaddr *addr, int addr_len)
 {
 	int retval = 0;
 
@@ -333,7 +328,7 @@ static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
 }
 
 /* Bind a local address either to an endpoint or to an association.  */
-SCTP_STATIC int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
+static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 {
 	struct net *net = sock_net(sk);
 	struct sctp_sock *sp = sctp_sk(sk);
@@ -964,9 +959,9 @@ int sctp_asconf_mgmt(struct sctp_sock *sp, struct sctp_sockaddr_entry *addrw)
  *
  * Returns 0 if ok, <0 errno code on error.
  */
-SCTP_STATIC int sctp_setsockopt_bindx(struct sock* sk,
-				      struct sockaddr __user *addrs,
-				      int addrs_size, int op)
+static int sctp_setsockopt_bindx(struct sock* sk,
+				 struct sockaddr __user *addrs,
+				 int addrs_size, int op)
 {
 	struct sockaddr *kaddrs;
 	int err;
@@ -1312,7 +1307,7 @@ out_free:
  *
  * Returns >=0 if ok, <0 errno code on error.
  */
-SCTP_STATIC int __sctp_setsockopt_connectx(struct sock* sk,
+static int __sctp_setsockopt_connectx(struct sock* sk,
 				      struct sockaddr __user *addrs,
 				      int addrs_size,
 				      sctp_assoc_t *assoc_id)
@@ -1350,9 +1345,9 @@ SCTP_STATIC int __sctp_setsockopt_connectx(struct sock* sk,
  * This is an older interface.  It's kept for backward compatibility
  * to the option that doesn't provide association id.
  */
-SCTP_STATIC int sctp_setsockopt_connectx_old(struct sock* sk,
-				      struct sockaddr __user *addrs,
-				      int addrs_size)
+static int sctp_setsockopt_connectx_old(struct sock* sk,
+					struct sockaddr __user *addrs,
+					int addrs_size)
 {
 	return __sctp_setsockopt_connectx(sk, addrs, addrs_size, NULL);
 }
@@ -1363,9 +1358,9 @@ SCTP_STATIC int sctp_setsockopt_connectx_old(struct sock* sk,
  * indication to the call.  Error is always negative and association id is
  * always positive.
  */
-SCTP_STATIC int sctp_setsockopt_connectx(struct sock* sk,
-				      struct sockaddr __user *addrs,
-				      int addrs_size)
+static int sctp_setsockopt_connectx(struct sock* sk,
+				    struct sockaddr __user *addrs,
+				    int addrs_size)
 {
 	sctp_assoc_t assoc_id = 0;
 	int err = 0;
@@ -1386,9 +1381,9 @@ SCTP_STATIC int sctp_setsockopt_connectx(struct sock* sk,
  * addrs_num structure member.  That way we can re-use the existing
  * code.
  */
-SCTP_STATIC int sctp_getsockopt_connectx3(struct sock* sk, int len,
-					char __user *optval,
-					int __user *optlen)
+static int sctp_getsockopt_connectx3(struct sock* sk, int len,
+				     char __user *optval,
+				     int __user *optlen)
 {
 	struct sctp_getaddrs_old param;
 	sctp_assoc_t assoc_id = 0;
@@ -1464,7 +1459,7 @@ SCTP_STATIC int sctp_getsockopt_connectx3(struct sock* sk, int len,
  * shutdown phase does not finish during this period, close() will
  * return but the graceful shutdown phase continues in the system.
  */
-SCTP_STATIC void sctp_close(struct sock *sk, long timeout)
+static void sctp_close(struct sock *sk, long timeout)
 {
 	struct net *net = sock_net(sk);
 	struct sctp_endpoint *ep;
@@ -1573,10 +1568,10 @@ static int sctp_error(struct sock *sk, int flags, int err)
  */
 /* BUG:  We do not implement the equivalent of sk_stream_wait_memory(). */
 
-SCTP_STATIC int sctp_msghdr_parse(const struct msghdr *, sctp_cmsgs_t *);
+static int sctp_msghdr_parse(const struct msghdr *, sctp_cmsgs_t *);
 
-SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
-			     struct msghdr *msg, size_t msg_len)
+static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
+			struct msghdr *msg, size_t msg_len)
 {
 	struct net *net = sock_net(sk);
 	struct sctp_sock *sp;
@@ -2034,9 +2029,9 @@ static int sctp_skb_pull(struct sk_buff *skb, int len)
  */
 static struct sk_buff *sctp_skb_recv_datagram(struct sock *, int, int, int *);
 
-SCTP_STATIC int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
-			     struct msghdr *msg, size_t len, int noblock,
-			     int flags, int *addr_len)
+static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
+			struct msghdr *msg, size_t len, int noblock,
+			int flags, int *addr_len)
 {
 	struct sctp_ulpevent *event = NULL;
 	struct sctp_sock *sp = sctp_sk(sk);
@@ -3565,8 +3560,8 @@ static int sctp_setsockopt_paddr_thresholds(struct sock *sk,
  *   optval  - the buffer to store the value of the option.
  *   optlen  - the size of the buffer.
  */
-SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
-				char __user *optval, unsigned int optlen)
+static int sctp_setsockopt(struct sock *sk, int level, int optname,
+			   char __user *optval, unsigned int optlen)
 {
 	int retval = 0;
 
@@ -3725,8 +3720,8 @@ out_nounlock:
  *
  * len: the size of the address.
  */
-SCTP_STATIC int sctp_connect(struct sock *sk, struct sockaddr *addr,
-			     int addr_len)
+static int sctp_connect(struct sock *sk, struct sockaddr *addr,
+			int addr_len)
 {
 	int err = 0;
 	struct sctp_af *af;
@@ -3752,7 +3747,7 @@ SCTP_STATIC int sctp_connect(struct sock *sk, struct sockaddr *addr,
 }
 
 /* FIXME: Write comments. */
-SCTP_STATIC int sctp_disconnect(struct sock *sk, int flags)
+static int sctp_disconnect(struct sock *sk, int flags)
 {
 	return -EOPNOTSUPP; /* STUB */
 }
@@ -3764,7 +3759,7 @@ SCTP_STATIC int sctp_disconnect(struct sock *sk, int flags)
  * descriptor will be returned from accept() to represent the newly
  * formed association.
  */
-SCTP_STATIC struct sock *sctp_accept(struct sock *sk, int flags, int *err)
+static struct sock *sctp_accept(struct sock *sk, int flags, int *err)
 {
 	struct sctp_sock *sp;
 	struct sctp_endpoint *ep;
@@ -3817,7 +3812,7 @@ out:
 }
 
 /* The SCTP ioctl handler. */
-SCTP_STATIC int sctp_ioctl(struct sock *sk, int cmd, unsigned long arg)
+static int sctp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	int rc = -ENOTCONN;
 
@@ -3859,7 +3854,7 @@ out:
  * initialized the SCTP-specific portion of the sock.
  * The sock structure should already be zero-filled memory.
  */
-SCTP_STATIC int sctp_init_sock(struct sock *sk)
+static int sctp_init_sock(struct sock *sk)
 {
 	struct net *net = sock_net(sk);
 	struct sctp_sock *sp;
@@ -3993,7 +3988,7 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 }
 
 /* Cleanup any SCTP per socket resources.  */
-SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
+static void sctp_destroy_sock(struct sock *sk)
 {
 	struct sctp_sock *sp;
 
@@ -4028,7 +4023,7 @@ SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
  *                     Disables further send  and  receive  operations
  *                     and initiates the SCTP shutdown sequence.
  */
-SCTP_STATIC void sctp_shutdown(struct sock *sk, int how)
+static void sctp_shutdown(struct sock *sk, int how)
 {
 	struct net *net = sock_net(sk);
 	struct sctp_endpoint *ep;
@@ -5700,8 +5695,8 @@ static int sctp_getsockopt_assoc_stats(struct sock *sk, int len,
 	return 0;
 }
 
-SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
-				char __user *optval, int __user *optlen)
+static int sctp_getsockopt(struct sock *sk, int level, int optname,
+			   char __user *optval, int __user *optlen)
 {
 	int retval = 0;
 	int len;
@@ -6046,7 +6041,7 @@ static int sctp_get_port(struct sock *sk, unsigned short snum)
 /*
  *  Move a socket to LISTENING state.
  */
-SCTP_STATIC int sctp_listen_start(struct sock *sk, int backlog)
+static int sctp_listen_start(struct sock *sk, int backlog)
 {
 	struct sctp_sock *sp = sctp_sk(sk);
 	struct sctp_endpoint *ep = sp->ep;
@@ -6333,8 +6328,7 @@ static int sctp_autobind(struct sock *sk)
  * msg_control
  * points here
  */
-SCTP_STATIC int sctp_msghdr_parse(const struct msghdr *msg,
-				  sctp_cmsgs_t *cmsgs)
+static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
 {
 	struct cmsghdr *cmsg;
 	struct msghdr *my_msg = (struct msghdr *)msg;
diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
index 396c451..b460195 100644
--- a/net/sctp/tsnmap.c
+++ b/net/sctp/tsnmap.c
@@ -161,8 +161,8 @@ int sctp_tsnmap_mark(struct sctp_tsnmap *map, __u32 tsn,
 
 
 /* Initialize a Gap Ack Block iterator from memory being provided.  */
-SCTP_STATIC void sctp_tsnmap_iter_init(const struct sctp_tsnmap *map,
-				       struct sctp_tsnmap_iter *iter)
+static void sctp_tsnmap_iter_init(const struct sctp_tsnmap *map,
+				  struct sctp_tsnmap_iter *iter)
 {
 	/* Only start looking one past the Cumulative TSN Ack Point.  */
 	iter->start = map->cumulative_tsn_ack_point + 1;
@@ -171,9 +171,9 @@ SCTP_STATIC void sctp_tsnmap_iter_init(const struct sctp_tsnmap *map,
 /* Get the next Gap Ack Blocks. Returns 0 if there was not another block
  * to get.
  */
-SCTP_STATIC int sctp_tsnmap_next_gap_ack(const struct sctp_tsnmap *map,
-					 struct sctp_tsnmap_iter *iter,
-					 __u16 *start, __u16 *end)
+static int sctp_tsnmap_next_gap_ack(const struct sctp_tsnmap *map,
+				    struct sctp_tsnmap_iter *iter,
+				    __u16 *start, __u16 *end)
 {
 	int ended = 0;
 	__u16 start_ = 0, end_ = 0, offset;
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 10c018a..44a45db 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -57,9 +57,9 @@ static void sctp_ulpevent_release_frag_data(struct sctp_ulpevent *event);
 
 
 /* Initialize an ULP event from an given skb.  */
-SCTP_STATIC void sctp_ulpevent_init(struct sctp_ulpevent *event,
-				    int msg_flags,
-				    unsigned int len)
+static void sctp_ulpevent_init(struct sctp_ulpevent *event,
+			       int msg_flags,
+			       unsigned int len)
 {
 	memset(event, 0, sizeof(struct sctp_ulpevent));
 	event->msg_flags = msg_flags;
@@ -67,8 +67,8 @@ SCTP_STATIC void sctp_ulpevent_init(struct sctp_ulpevent *event,
 }
 
 /* Create a new sctp_ulpevent.  */
-SCTP_STATIC struct sctp_ulpevent *sctp_ulpevent_new(int size, int msg_flags,
-						    gfp_t gfp)
+static struct sctp_ulpevent *sctp_ulpevent_new(int size, int msg_flags,
+					       gfp_t gfp)
 {
 	struct sctp_ulpevent *event;
 	struct sk_buff *skb;
-- 
1.7.11.7
