From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/3] net: convert BUG_TRAP to generic WARN_ON
Date: Fri, 25 Jul 2008 15:46:59 +0300
Message-ID: <1216990020-2716-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1216990020-2716-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45726 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbYGYMrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 08:47:32 -0400
In-Reply-To: <1216990020-2716-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes legacy reinvent-the-wheel type thing. The generic
machinery integrates much better to automated debugging aids
such as kerneloops.org (and others), and is unambiguous due to
better naming. Non-intuively BUG_TRAP() is actually equal to
WARN_ON() rather than BUG_ON() though some might actually be
promoted to BUG_ON() but I left that to future.

I could make at least one BUILD_BUG_ON conversion.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/request_sock.h              |    5 +++--
 net/appletalk/ddp.c                     |    4 ++--
 net/core/datagram.c                     |    8 ++++----
 net/core/dev.c                          |   10 +++++-----
 net/core/request_sock.c                 |    2 +-
 net/core/skbuff.c                       |   20 ++++++++++----------
 net/core/stream.c                       |    6 +++---
 net/core/user_dma.c                     |    5 ++---
 net/dccp/dccp.h                         |    2 +-
 net/dccp/input.c                        |    2 +-
 net/dccp/ipv4.c                         |    2 +-
 net/dccp/ipv6.c                         |    2 +-
 net/dccp/proto.c                        |    4 ++--
 net/dccp/timer.c                        |    2 +-
 net/ipv4/af_inet.c                      |   14 +++++++-------
 net/ipv4/devinet.c                      |    6 +++---
 net/ipv4/inet_connection_sock.c         |   18 +++++++++---------
 net/ipv4/inet_fragment.c                |    4 ++--
 net/ipv4/inet_hashtables.c              |    8 ++++----
 net/ipv4/inet_timewait_sock.c           |    2 +-
 net/ipv4/ip_fragment.c                  |    4 ++--
 net/ipv4/ip_output.c                    |    2 +-
 net/ipv4/ipcomp.c                       |    2 +-
 net/ipv4/tcp.c                          |   12 ++++++------
 net/ipv4/tcp_input.c                    |   20 ++++++++++----------
 net/ipv4/tcp_ipv4.c                     |    2 +-
 net/ipv4/tcp_timer.c                    |    2 +-
 net/ipv6/addrconf.c                     |   11 +++++++----
 net/ipv6/af_inet6.c                     |    2 +-
 net/ipv6/inet6_connection_sock.c        |    2 +-
 net/ipv6/inet6_hashtables.c             |    4 ++--
 net/ipv6/ip6_fib.c                      |   31 ++++++++++++++++-------=
--------
 net/ipv6/ip6_output.c                   |    2 +-
 net/ipv6/ipcomp6.c                      |    2 +-
 net/ipv6/mip6.c                         |    8 ++++----
 net/ipv6/netfilter/nf_conntrack_reasm.c |    4 ++--
 net/ipv6/reassembly.c                   |    4 ++--
 net/ipv6/tcp_ipv6.c                     |    2 +-
 net/key/af_key.c                        |    4 ++--
 net/netlink/af_netlink.c                |    7 ++++---
 net/packet/af_packet.c                  |    4 ++--
 net/rxrpc/af_rxrpc.c                    |    6 +++---
 net/sched/act_api.c                     |    2 +-
 net/sched/act_police.c                  |    2 +-
 net/sched/cls_u32.c                     |   10 +++++-----
 net/sched/sch_cbq.c                     |    4 ++--
 net/sched/sch_generic.c                 |    2 +-
 net/sched/sch_htb.c                     |   16 ++++++++--------
 net/sctp/associola.c                    |    2 +-
 net/unix/af_unix.c                      |    8 ++++----
 net/xfrm/xfrm_algo.c                    |    4 ++--
 net/xfrm/xfrm_state.c                   |    2 +-
 52 files changed, 160 insertions(+), 155 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 0c96e7b..8d6e991 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -18,6 +18,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
+#include <linux/bug.h>
=20
 #include <net/sock.h>
=20
@@ -170,7 +171,7 @@ static inline struct request_sock *reqsk_queue_remo=
ve(struct request_sock_queue
 {
 	struct request_sock *req =3D queue->rskq_accept_head;
=20
-	BUG_TRAP(req !=3D NULL);
+	WARN_ON(req =3D=3D NULL);
=20
 	queue->rskq_accept_head =3D req->dl_next;
 	if (queue->rskq_accept_head =3D=3D NULL)
@@ -185,7 +186,7 @@ static inline struct sock *reqsk_queue_get_child(st=
ruct request_sock_queue *queu
 	struct request_sock *req =3D reqsk_queue_remove(queue);
 	struct sock *child =3D req->sk;
=20
-	BUG_TRAP(child !=3D NULL);
+	WARN_ON(child =3D=3D NULL);
=20
 	sk_acceptq_removed(parent);
 	__reqsk_free(req);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 07b5b82..0c85042 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -959,7 +959,7 @@ static unsigned long atalk_sum_skb(const struct sk_=
buff *skb, int offset,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + skb_shinfo(skb)->frags[i].size;
 		if ((copy =3D end - offset) > 0) {
@@ -986,7 +986,7 @@ static unsigned long atalk_sum_skb(const struct sk_=
buff *skb, int offset,
 		for (; list; list =3D list->next) {
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			if ((copy =3D end - offset) > 0) {
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 8a28fc9..dd61dca 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -285,7 +285,7 @@ int skb_copy_datagram_iovec(const struct sk_buff *s=
kb, int offset,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + skb_shinfo(skb)->frags[i].size;
 		if ((copy =3D end - offset) > 0) {
@@ -315,7 +315,7 @@ int skb_copy_datagram_iovec(const struct sk_buff *s=
kb, int offset,
 		for (; list; list =3D list->next) {
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			if ((copy =3D end - offset) > 0) {
@@ -366,7 +366,7 @@ static int skb_copy_and_csum_datagram(const struct =
sk_buff *skb, int offset,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + skb_shinfo(skb)->frags[i].size;
 		if ((copy =3D end - offset) > 0) {
@@ -402,7 +402,7 @@ static int skb_copy_and_csum_datagram(const struct =
sk_buff *skb, int offset,
 		for (; list; list=3Dlist->next) {
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			if ((copy =3D end - offset) > 0) {
diff --git a/net/core/dev.c b/net/core/dev.c
index ccf97f9..c6f9c83 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1973,7 +1973,7 @@ static void net_tx_action(struct softirq_action *=
h)
 			struct sk_buff *skb =3D clist;
 			clist =3D clist->next;
=20
-			BUG_TRAP(!atomic_read(&skb->users));
+			WARN_ON(atomic_read(&skb->users));
 			__kfree_skb(skb);
 		}
 	}
@@ -3847,7 +3847,7 @@ static void rollback_registered(struct net_device=
 *dev)
 		dev->uninit(dev);
=20
 	/* Notifier chain MUST detach us from master device. */
-	BUG_TRAP(!dev->master);
+	WARN_ON(dev->master);
=20
 	/* Remove entries from kobject tree */
 	netdev_unregister_kobject(dev);
@@ -4169,9 +4169,9 @@ void netdev_run_todo(void)
=20
 		/* paranoia */
 		BUG_ON(atomic_read(&dev->refcnt));
-		BUG_TRAP(!dev->ip_ptr);
-		BUG_TRAP(!dev->ip6_ptr);
-		BUG_TRAP(!dev->dn_ptr);
+		WARN_ON(dev->ip_ptr);
+		WARN_ON(dev->ip6_ptr);
+		WARN_ON(dev->dn_ptr);
=20
 		if (dev->destructor)
 			dev->destructor(dev);
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 2d3035d..7552495 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -123,7 +123,7 @@ void reqsk_queue_destroy(struct request_sock_queue =
*queue)
 		}
 	}
=20
-	BUG_TRAP(lopt->qlen =3D=3D 0);
+	WARN_ON(lopt->qlen !=3D 0);
 	if (lopt_size > PAGE_SIZE)
 		vfree(lopt);
 	else
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e411567..4e0c922 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1200,7 +1200,7 @@ int skb_copy_bits(const struct sk_buff *skb, int =
offset, void *to, int len)
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + skb_shinfo(skb)->frags[i].size;
 		if ((copy =3D end - offset) > 0) {
@@ -1229,7 +1229,7 @@ int skb_copy_bits(const struct sk_buff *skb, int =
offset, void *to, int len)
 		for (; list; list =3D list->next) {
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			if ((copy =3D end - offset) > 0) {
@@ -1475,7 +1475,7 @@ int skb_store_bits(struct sk_buff *skb, int offse=
t, const void *from, int len)
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + frag->size;
 		if ((copy =3D end - offset) > 0) {
@@ -1503,7 +1503,7 @@ int skb_store_bits(struct sk_buff *skb, int offse=
t, const void *from, int len)
 		for (; list; list =3D list->next) {
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			if ((copy =3D end - offset) > 0) {
@@ -1552,7 +1552,7 @@ __wsum skb_checksum(const struct sk_buff *skb, in=
t offset,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + skb_shinfo(skb)->frags[i].size;
 		if ((copy =3D end - offset) > 0) {
@@ -1581,7 +1581,7 @@ __wsum skb_checksum(const struct sk_buff *skb, in=
t offset,
 		for (; list; list =3D list->next) {
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			if ((copy =3D end - offset) > 0) {
@@ -1629,7 +1629,7 @@ __wsum skb_copy_and_csum_bits(const struct sk_buf=
f *skb, int offset,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + skb_shinfo(skb)->frags[i].size;
 		if ((copy =3D end - offset) > 0) {
@@ -1662,7 +1662,7 @@ __wsum skb_copy_and_csum_bits(const struct sk_buf=
f *skb, int offset,
 			__wsum csum2;
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			if ((copy =3D end - offset) > 0) {
@@ -2373,7 +2373,7 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatte=
rlist *sg, int offset, int len)
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + skb_shinfo(skb)->frags[i].size;
 		if ((copy =3D end - offset) > 0) {
@@ -2397,7 +2397,7 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatte=
rlist *sg, int offset, int len)
 		for (; list; list =3D list->next) {
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			if ((copy =3D end - offset) > 0) {
diff --git a/net/core/stream.c b/net/core/stream.c
index 4a0ad15..a6b3437 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -192,13 +192,13 @@ void sk_stream_kill_queues(struct sock *sk)
 	__skb_queue_purge(&sk->sk_error_queue);
=20
 	/* Next, the write queue. */
-	BUG_TRAP(skb_queue_empty(&sk->sk_write_queue));
+	WARN_ON(!skb_queue_empty(&sk->sk_write_queue));
=20
 	/* Account for returned memory. */
 	sk_mem_reclaim(sk);
=20
-	BUG_TRAP(!sk->sk_wmem_queued);
-	BUG_TRAP(!sk->sk_forward_alloc);
+	WARN_ON(sk->sk_wmem_queued);
+	WARN_ON(sk->sk_forward_alloc);
=20
 	/* It is _impossible_ for the backlog to contain anything
 	 * when we get here.  All user references to this socket
diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index c77aff9..53c6b67 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -27,7 +27,6 @@
=20
 #include <linux/dmaengine.h>
 #include <linux/socket.h>
-#include <linux/rtnetlink.h> /* for BUG_TRAP */
 #include <net/tcp.h>
 #include <net/netdma.h>
=20
@@ -71,7 +70,7 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan=
,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + skb_shinfo(skb)->frags[i].size;
 		copy =3D end - offset;
@@ -100,7 +99,7 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *cha=
n,
 		for (; list; list =3D list->next) {
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			copy =3D end - offset;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 32617e0..743d85f 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -164,7 +164,7 @@ static inline bool dccp_loss_free(const u64 s1, con=
st u64 s2, const u64 ndp)
 {
 	s64 delta =3D dccp_delta_seqno(s1, s2);
=20
-	BUG_TRAP(delta >=3D 0);
+	WARN_ON(delta < 0);
 	return (u64)delta <=3D ndp + 1;
 }
=20
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 08392ed..df2f110 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -413,7 +413,7 @@ static int dccp_rcv_request_sent_state_process(stru=
ct sock *sk,
=20
 		/* Stop the REQUEST timer */
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
-		BUG_TRAP(sk->sk_send_head !=3D NULL);
+		WARN_ON(sk->sk_send_head =3D=3D NULL);
 		__kfree_skb(sk->sk_send_head);
 		sk->sk_send_head =3D NULL;
=20
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 2622ace..a835b88 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -283,7 +283,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 in=
fo)
 		 * ICMPs are not backlogged, hence we cannot get an established
 		 * socket here.
 		 */
-		BUG_TRAP(!req->sk);
+		WARN_ON(req->sk);
=20
 		if (seq !=3D dccp_rsk(req)->dreq_iss) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index b74e8b2..da50912 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -186,7 +186,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct=
 inet6_skb_parm *opt,
 		 * ICMPs are not backlogged, hence we cannot get an established
 		 * socket here.
 		 */
-		BUG_TRAP(req->sk =3D=3D NULL);
+		WARN_ON(req->sk !=3D NULL);
=20
 		if (seq !=3D dccp_rsk(req)->dreq_iss) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index a0b5600..b622d97 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -327,7 +327,7 @@ int dccp_disconnect(struct sock *sk, int flags)
 	inet_csk_delack_init(sk);
 	__sk_dst_reset(sk);
=20
-	BUG_TRAP(!inet->num || icsk->icsk_bind_hash);
+	WARN_ON(inet->num && !icsk->icsk_bind_hash);
=20
 	sk->sk_error_report(sk);
 	return err;
@@ -981,7 +981,7 @@ adjudge_to_death:
 	 */
 	local_bh_disable();
 	bh_lock_sock(sk);
-	BUG_TRAP(!sock_owned_by_user(sk));
+	WARN_ON(sock_owned_by_user(sk));
=20
 	/* Have we already been destroyed by a softirq or backlog? */
 	if (state !=3D DCCP_CLOSED && sk->sk_state =3D=3D DCCP_CLOSED)
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 3608d53..6a5b961 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -106,7 +106,7 @@ static void dccp_retransmit_timer(struct sock *sk)
 	 *	-- Acks     in client-PARTOPEN state (sec. 8.1.5)
 	 *	-- CloseReq in server-CLOSEREQ state (sec. 8.3)
 	 *	-- Close    in   node-CLOSING  state (sec. 8.3)                */
-	BUG_TRAP(sk->sk_send_head !=3D NULL);
+	WARN_ON(sk->sk_send_head =3D=3D NULL);
=20
 	/*
 	 * More than than 4MSL (8 minutes) has passed, a RESET(aborted) was
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index dd919d8..a107f49 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -148,10 +148,10 @@ void inet_sock_destruct(struct sock *sk)
 		return;
 	}
=20
-	BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc));
-	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
-	BUG_TRAP(!sk->sk_wmem_queued);
-	BUG_TRAP(!sk->sk_forward_alloc);
+	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
+	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(sk->sk_wmem_queued);
+	WARN_ON(sk->sk_forward_alloc);
=20
 	kfree(inet->opt);
 	dst_release(sk->sk_dst_cache);
@@ -341,7 +341,7 @@ lookup_protocol:
 	answer_flags =3D answer->flags;
 	rcu_read_unlock();
=20
-	BUG_TRAP(answer_prot->slab !=3D NULL);
+	WARN_ON(answer_prot->slab =3D=3D NULL);
=20
 	err =3D -ENOBUFS;
 	sk =3D sk_alloc(net, PF_INET, GFP_KERNEL, answer_prot);
@@ -661,8 +661,8 @@ int inet_accept(struct socket *sock, struct socket =
*newsock, int flags)
=20
 	lock_sock(sk2);
=20
-	BUG_TRAP((1 << sk2->sk_state) &
-		 (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT | TCPF_CLOSE));
+	WARN_ON(!((1 << sk2->sk_state) &
+		  (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT | TCPF_CLOSE)));
=20
 	sock_graft(sk2, newsock);
=20
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 2e667e2..91d3d96 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -138,8 +138,8 @@ void in_dev_finish_destroy(struct in_device *idev)
 {
 	struct net_device *dev =3D idev->dev;
=20
-	BUG_TRAP(!idev->ifa_list);
-	BUG_TRAP(!idev->mc_list);
+	WARN_ON(idev->ifa_list);
+	WARN_ON(idev->mc_list);
 #ifdef NET_REFCNT_DEBUG
 	printk(KERN_DEBUG "in_dev_finish_destroy: %p=3D%s\n",
 	       idev, dev ? dev->name : "NIL");
@@ -399,7 +399,7 @@ static int inet_set_ifa(struct net_device *dev, str=
uct in_ifaddr *ifa)
 	}
 	ipv4_devconf_setall(in_dev);
 	if (ifa->ifa_dev !=3D in_dev) {
-		BUG_TRAP(!ifa->ifa_dev);
+		WARN_ON(ifa->ifa_dev);
 		in_dev_hold(in_dev);
 		ifa->ifa_dev =3D in_dev;
 	}
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index bb81c95..0c1ae68 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -167,7 +167,7 @@ tb_not_found:
 success:
 	if (!inet_csk(sk)->icsk_bind_hash)
 		inet_bind_hash(sk, tb, snum);
-	BUG_TRAP(inet_csk(sk)->icsk_bind_hash =3D=3D tb);
+	WARN_ON(inet_csk(sk)->icsk_bind_hash !=3D tb);
 	ret =3D 0;
=20
 fail_unlock:
@@ -260,7 +260,7 @@ struct sock *inet_csk_accept(struct sock *sk, int f=
lags, int *err)
 	}
=20
 	newsk =3D reqsk_queue_get_child(&icsk->icsk_accept_queue, sk);
-	BUG_TRAP(newsk->sk_state !=3D TCP_SYN_RECV);
+	WARN_ON(newsk->sk_state =3D=3D TCP_SYN_RECV);
 out:
 	release_sock(sk);
 	return newsk;
@@ -386,7 +386,7 @@ struct request_sock *inet_csk_search_req(const stru=
ct sock *sk,
 		    ireq->rmt_addr =3D=3D raddr &&
 		    ireq->loc_addr =3D=3D laddr &&
 		    AF_INET_FAMILY(req->rsk_ops->family)) {
-			BUG_TRAP(!req->sk);
+			WARN_ON(req->sk);
 			*prevp =3D prev;
 			break;
 		}
@@ -539,14 +539,14 @@ EXPORT_SYMBOL_GPL(inet_csk_clone);
  */
 void inet_csk_destroy_sock(struct sock *sk)
 {
-	BUG_TRAP(sk->sk_state =3D=3D TCP_CLOSE);
-	BUG_TRAP(sock_flag(sk, SOCK_DEAD));
+	WARN_ON(sk->sk_state !=3D TCP_CLOSE);
+	WARN_ON(!sock_flag(sk, SOCK_DEAD));
=20
 	/* It cannot be in hash table! */
-	BUG_TRAP(sk_unhashed(sk));
+	WARN_ON(!sk_unhashed(sk));
=20
 	/* If it has not 0 inet_sk(sk)->num, it must be bound */
-	BUG_TRAP(!inet_sk(sk)->num || inet_csk(sk)->icsk_bind_hash);
+	WARN_ON(inet_sk(sk)->num && !inet_csk(sk)->icsk_bind_hash);
=20
 	sk->sk_prot->destroy(sk);
=20
@@ -629,7 +629,7 @@ void inet_csk_listen_stop(struct sock *sk)
=20
 		local_bh_disable();
 		bh_lock_sock(child);
-		BUG_TRAP(!sock_owned_by_user(child));
+		WARN_ON(sock_owned_by_user(child));
 		sock_hold(child);
=20
 		sk->sk_prot->disconnect(child, O_NONBLOCK);
@@ -647,7 +647,7 @@ void inet_csk_listen_stop(struct sock *sk)
 		sk_acceptq_removed(sk);
 		__reqsk_free(req);
 	}
-	BUG_TRAP(!sk->sk_ack_backlog);
+	WARN_ON(sk->sk_ack_backlog);
 }
=20
 EXPORT_SYMBOL_GPL(inet_csk_listen_stop);
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 0546a0b..6c52e08 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -134,8 +134,8 @@ void inet_frag_destroy(struct inet_frag_queue *q, s=
truct inet_frags *f,
 	struct sk_buff *fp;
 	struct netns_frags *nf;
=20
-	BUG_TRAP(q->last_in & INET_FRAG_COMPLETE);
-	BUG_TRAP(del_timer(&q->timer) =3D=3D 0);
+	WARN_ON(!(q->last_in & INET_FRAG_COMPLETE));
+	WARN_ON(del_timer(&q->timer) !=3D 0);
=20
 	/* Release all fragment data. */
 	fp =3D q->fragments;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 115f537..4498190 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -305,7 +305,7 @@ unique:
 	inet->num =3D lport;
 	inet->sport =3D htons(lport);
 	sk->sk_hash =3D hash;
-	BUG_TRAP(sk_unhashed(sk));
+	WARN_ON(!sk_unhashed(sk));
 	__sk_add_node(sk, &head->chain);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	write_unlock(lock);
@@ -342,7 +342,7 @@ void __inet_hash_nolisten(struct sock *sk)
 	rwlock_t *lock;
 	struct inet_ehash_bucket *head;
=20
-	BUG_TRAP(sk_unhashed(sk));
+	WARN_ON(!sk_unhashed(sk));
=20
 	sk->sk_hash =3D inet_sk_ehashfn(sk);
 	head =3D inet_ehash_bucket(hashinfo, sk->sk_hash);
@@ -367,7 +367,7 @@ static void __inet_hash(struct sock *sk)
 		return;
 	}
=20
-	BUG_TRAP(sk_unhashed(sk));
+	WARN_ON(!sk_unhashed(sk));
 	list =3D &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
 	lock =3D &hashinfo->lhash_lock;
=20
@@ -450,7 +450,7 @@ int __inet_hash_connect(struct inet_timewait_death_=
row *death_row,
 			 */
 			inet_bind_bucket_for_each(tb, node, &head->chain) {
 				if (tb->ib_net =3D=3D net && tb->port =3D=3D port) {
-					BUG_TRAP(!hlist_empty(&tb->owners));
+					WARN_ON(hlist_empty(&tb->owners));
 					if (tb->fastreuse >=3D 0)
 						goto next_port;
 					if (!check_established(death_row, sk,
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_soc=
k.c
index 75c2def..d985bd6 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -86,7 +86,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock =
*tw, struct sock *sk,
 			hashinfo->bhash_size)];
 	spin_lock(&bhead->lock);
 	tw->tw_tb =3D icsk->icsk_bind_hash;
-	BUG_TRAP(icsk->icsk_bind_hash);
+	WARN_ON(!icsk->icsk_bind_hash);
 	inet_twsk_add_bind_node(tw, &tw->tw_tb->owners);
 	spin_unlock(&bhead->lock);
=20
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 38d38f0..2152d22 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -488,8 +488,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_=
buff *prev,
 		qp->q.fragments =3D head;
 	}
=20
-	BUG_TRAP(head !=3D NULL);
-	BUG_TRAP(FRAG_CB(head)->offset =3D=3D 0);
+	WARN_ON(head =3D=3D NULL);
+	WARN_ON(FRAG_CB(head)->offset !=3D 0);
=20
 	/* Allocate a new buffer for the datagram. */
 	ihlen =3D ip_hdrlen(head);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 465544f..d533a89 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -118,7 +118,7 @@ static int ip_dev_loopback_xmit(struct sk_buff *new=
skb)
 	__skb_pull(newskb, skb_network_offset(newskb));
 	newskb->pkt_type =3D PACKET_LOOPBACK;
 	newskb->ip_summed =3D CHECKSUM_UNNECESSARY;
-	BUG_TRAP(newskb->dst);
+	WARN_ON(!newskb->dst);
 	netif_rx(newskb);
 	return 0;
 }
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index a75807b..ee1bbf9 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -293,7 +293,7 @@ static void ipcomp_free_tfms(struct crypto_comp **t=
fms)
 			break;
 	}
=20
-	BUG_TRAP(pos);
+	WARN_ON(!pos);
=20
 	if (--pos->users)
 		return;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0b491bf..1ab341e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1096,7 +1096,7 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied=
)
 #if TCP_DEBUG
 	struct sk_buff *skb =3D skb_peek(&sk->sk_receive_queue);
=20
-	BUG_TRAP(!skb || before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq));
+	WARN_ON(skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq));
 #endif
=20
 	if (inet_csk_ack_scheduled(sk)) {
@@ -1358,7 +1358,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *=
sk, struct msghdr *msg,
 				goto found_ok_skb;
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
-			BUG_TRAP(flags & MSG_PEEK);
+			WARN_ON(!(flags & MSG_PEEK));
 			skb =3D skb->next;
 		} while (skb !=3D (struct sk_buff *)&sk->sk_receive_queue);
=20
@@ -1421,8 +1421,8 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *=
sk, struct msghdr *msg,
=20
 			tp->ucopy.len =3D len;
=20
-			BUG_TRAP(tp->copied_seq =3D=3D tp->rcv_nxt ||
-				 (flags & (MSG_PEEK | MSG_TRUNC)));
+			WARN_ON(tp->copied_seq !=3D tp->rcv_nxt &&
+				!(flags & (MSG_PEEK | MSG_TRUNC)));
=20
 			/* Ugly... If prequeue is not empty, we have to
 			 * process it before releasing socket, otherwise
@@ -1844,7 +1844,7 @@ adjudge_to_death:
 	 */
 	local_bh_disable();
 	bh_lock_sock(sk);
-	BUG_TRAP(!sock_owned_by_user(sk));
+	WARN_ON(sock_owned_by_user(sk));
=20
 	/* Have we already been destroyed by a softirq or backlog? */
 	if (state !=3D TCP_CLOSE && sk->sk_state =3D=3D TCP_CLOSE)
@@ -1973,7 +1973,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	memset(&tp->rx_opt, 0, sizeof(tp->rx_opt));
 	__sk_dst_reset(sk);
=20
-	BUG_TRAP(!inet->num || icsk->icsk_bind_hash);
+	WARN_ON(inet->num && !icsk->icsk_bind_hash);
=20
 	sk->sk_error_report(sk);
 	return err;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 655d797..d32e3e6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1629,10 +1629,10 @@ advance_sp:
 out:
=20
 #if FASTRETRANS_DEBUG > 0
-	BUG_TRAP((int)tp->sacked_out >=3D 0);
-	BUG_TRAP((int)tp->lost_out >=3D 0);
-	BUG_TRAP((int)tp->retrans_out >=3D 0);
-	BUG_TRAP((int)tcp_packets_in_flight(tp) >=3D 0);
+	WARN_ON((int)tp->sacked_out < 0);
+	WARN_ON((int)tp->lost_out < 0);
+	WARN_ON((int)tp->retrans_out < 0);
+	WARN_ON((int)tcp_packets_in_flight(tp) < 0);
 #endif
 	return flag;
 }
@@ -2188,7 +2188,7 @@ static void tcp_mark_head_lost(struct sock *sk, i=
nt packets)
 	int err;
 	unsigned int mss;
=20
-	BUG_TRAP(packets <=3D tp->packets_out);
+	WARN_ON(packets > tp->packets_out);
 	if (tp->lost_skb_hint) {
 		skb =3D tp->lost_skb_hint;
 		cnt =3D tp->lost_cnt_hint;
@@ -2617,7 +2617,7 @@ static void tcp_fastretrans_alert(struct sock *sk=
, int pkts_acked, int flag)
 	/* E. Check state exit conditions. State can be terminated
 	 *    when high_seq is ACKed. */
 	if (icsk->icsk_ca_state =3D=3D TCP_CA_Open) {
-		BUG_TRAP(tp->retrans_out =3D=3D 0);
+		WARN_ON(tp->retrans_out !=3D 0);
 		tp->retrans_stamp =3D 0;
 	} else if (!before(tp->snd_una, tp->high_seq)) {
 		switch (icsk->icsk_ca_state) {
@@ -2979,9 +2979,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, i=
nt prior_fackets)
 	}
=20
 #if FASTRETRANS_DEBUG > 0
-	BUG_TRAP((int)tp->sacked_out >=3D 0);
-	BUG_TRAP((int)tp->lost_out >=3D 0);
-	BUG_TRAP((int)tp->retrans_out >=3D 0);
+	WARN_ON((int)tp->sacked_out < 0);
+	WARN_ON((int)tp->lost_out < 0);
+	WARN_ON((int)tp->retrans_out < 0);
 	if (!tp->packets_out && tcp_is_sack(tp)) {
 		icsk =3D inet_csk(sk);
 		if (tp->lost_out) {
@@ -3884,7 +3884,7 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 			int i;
=20
 			/* RCV.NXT must cover all the block! */
-			BUG_TRAP(!before(tp->rcv_nxt, sp->end_seq));
+			WARN_ON(before(tp->rcv_nxt, sp->end_seq));
=20
 			/* Zap this SACK, by moving forward any other SACKS. */
 			for (i=3Dthis_sack+1; i < num_sacks; i++)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a82df63..a2b06d0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -418,7 +418,7 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 		/* ICMPs are not backlogged, hence we cannot get
 		   an established socket here.
 		 */
-		BUG_TRAP(!req->sk);
+		WARN_ON(req->sk);
=20
 		if (seq !=3D tcp_rsk(req)->snt_isn) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 328e0cf..5ab6ba1 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -287,7 +287,7 @@ static void tcp_retransmit_timer(struct sock *sk)
 	if (!tp->packets_out)
 		goto out;
=20
-	BUG_TRAP(!tcp_write_queue_empty(sk));
+	WARN_ON(tcp_write_queue_empty(sk));
=20
 	if (!tp->snd_wnd && !sock_flag(sk, SOCK_DEAD) &&
 	    !((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV))) {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 74d543d..a7842c5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -313,8 +313,10 @@ static void in6_dev_finish_destroy_rcu(struct rcu_=
head *head)
 void in6_dev_finish_destroy(struct inet6_dev *idev)
 {
 	struct net_device *dev =3D idev->dev;
-	BUG_TRAP(idev->addr_list=3D=3DNULL);
-	BUG_TRAP(idev->mc_list=3D=3DNULL);
+
+	WARN_ON(idev->addr_list !=3D NULL);
+	WARN_ON(idev->mc_list !=3D NULL);
+
 #ifdef NET_REFCNT_DEBUG
 	printk(KERN_DEBUG "in6_dev_finish_destroy: %s\n", dev ? dev->name : "=
NIL");
 #endif
@@ -517,8 +519,9 @@ static void addrconf_fixup_forwarding(struct ctl_ta=
ble *table, int *p, int old)
=20
 void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 {
-	BUG_TRAP(ifp->if_next=3D=3DNULL);
-	BUG_TRAP(ifp->lst_next=3D=3DNULL);
+	WARN_ON(ifp->if_next !=3D NULL);
+	WARN_ON(ifp->lst_next !=3D NULL);
+
 #ifdef NET_REFCNT_DEBUG
 	printk(KERN_DEBUG "inet6_ifa_finish_destroy\n");
 #endif
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3d828bc..0843c4d 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -153,7 +153,7 @@ lookup_protocol:
 	answer_flags =3D answer->flags;
 	rcu_read_unlock();
=20
-	BUG_TRAP(answer_prot->slab !=3D NULL);
+	WARN_ON(answer_prot->slab =3D=3D NULL);
=20
 	err =3D -ENOBUFS;
 	sk =3D sk_alloc(net, PF_INET6, GFP_KERNEL, answer_prot);
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index 87801cc..16d43f2 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -98,7 +98,7 @@ struct request_sock *inet6_csk_search_req(const struc=
t sock *sk,
 		    ipv6_addr_equal(&treq->rmt_addr, raddr) &&
 		    ipv6_addr_equal(&treq->loc_addr, laddr) &&
 		    (!treq->iif || treq->iif =3D=3D iif)) {
-			BUG_TRAP(req->sk =3D=3D NULL);
+			WARN_ON(req->sk !=3D NULL);
 			*prevp =3D prev;
 			return req;
 		}
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 00a8a5f..1646a56 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -28,7 +28,7 @@ void __inet6_hash(struct sock *sk)
 	struct hlist_head *list;
 	rwlock_t *lock;
=20
-	BUG_TRAP(sk_unhashed(sk));
+	WARN_ON(!sk_unhashed(sk));
=20
 	if (sk->sk_state =3D=3D TCP_LISTEN) {
 		list =3D &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
@@ -202,7 +202,7 @@ unique:
 	 * in hash table socket with a funny identity. */
 	inet->num =3D lport;
 	inet->sport =3D htons(lport);
-	BUG_TRAP(sk_unhashed(sk));
+	WARN_ON(!sk_unhashed(sk));
 	__sk_add_node(sk, &head->chain);
 	sk->sk_hash =3D hash;
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 08ea2de..52dddc2 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -287,7 +287,7 @@ static int fib6_dump_node(struct fib6_walker_t *w)
 			w->leaf =3D rt;
 			return 1;
 		}
-		BUG_TRAP(res!=3D0);
+		WARN_ON(res =3D=3D 0);
 	}
 	w->leaf =3D NULL;
 	return 0;
@@ -778,7 +778,7 @@ out:
 			pn->leaf =3D fib6_find_prefix(info->nl_net, pn);
 #if RT6_DEBUG >=3D 2
 			if (!pn->leaf) {
-				BUG_TRAP(pn->leaf !=3D NULL);
+				WARN_ON(pn->leaf =3D=3D NULL);
 				pn->leaf =3D info->nl_net->ipv6.ip6_null_entry;
 			}
 #endif
@@ -942,7 +942,7 @@ struct fib6_node * fib6_locate(struct fib6_node *ro=
ot,
=20
 #ifdef CONFIG_IPV6_SUBTREES
 	if (src_len) {
-		BUG_TRAP(saddr!=3DNULL);
+		WARN_ON(saddr =3D=3D NULL);
 		if (fn && fn->subtree)
 			fn =3D fib6_locate_1(fn->subtree, saddr, src_len,
 					   offsetof(struct rt6_info, rt6i_src));
@@ -996,9 +996,9 @@ static struct fib6_node *fib6_repair_tree(struct ne=
t *net,
 		RT6_TRACE("fixing tree: plen=3D%d iter=3D%d\n", fn->fn_bit, iter);
 		iter++;
=20
-		BUG_TRAP(!(fn->fn_flags&RTN_RTINFO));
-		BUG_TRAP(!(fn->fn_flags&RTN_TL_ROOT));
-		BUG_TRAP(fn->leaf=3D=3DNULL);
+		WARN_ON(fn->fn_flags & RTN_RTINFO);
+		WARN_ON(fn->fn_flags & RTN_TL_ROOT);
+		WARN_ON(fn->leaf !=3D NULL);
=20
 		children =3D 0;
 		child =3D NULL;
@@ -1014,7 +1014,7 @@ static struct fib6_node *fib6_repair_tree(struct =
net *net,
 			fn->leaf =3D fib6_find_prefix(net, fn);
 #if RT6_DEBUG >=3D 2
 			if (fn->leaf=3D=3DNULL) {
-				BUG_TRAP(fn->leaf);
+				WARN_ON(!fn->leaf);
 				fn->leaf =3D net->ipv6.ip6_null_entry;
 			}
 #endif
@@ -1025,16 +1025,17 @@ static struct fib6_node *fib6_repair_tree(struc=
t net *net,
 		pn =3D fn->parent;
 #ifdef CONFIG_IPV6_SUBTREES
 		if (FIB6_SUBTREE(pn) =3D=3D fn) {
-			BUG_TRAP(fn->fn_flags&RTN_ROOT);
+			WARN_ON(!(fn->fn_flags & RTN_ROOT));
 			FIB6_SUBTREE(pn) =3D NULL;
 			nstate =3D FWS_L;
 		} else {
-			BUG_TRAP(!(fn->fn_flags&RTN_ROOT));
+			WARN_ON(fn->fn_flags & RTN_ROOT);
 #endif
 			if (pn->right =3D=3D fn) pn->right =3D child;
 			else if (pn->left =3D=3D fn) pn->left =3D child;
 #if RT6_DEBUG >=3D 2
-			else BUG_TRAP(0);
+			else
+				WARN_ON(1);
 #endif
 			if (child)
 				child->parent =3D pn;
@@ -1154,14 +1155,14 @@ int fib6_del(struct rt6_info *rt, struct nl_inf=
o *info)
=20
 #if RT6_DEBUG >=3D 2
 	if (rt->u.dst.obsolete>0) {
-		BUG_TRAP(fn=3D=3DNULL);
+		WARN_ON(fn !=3D NULL);
 		return -ENOENT;
 	}
 #endif
 	if (fn =3D=3D NULL || rt =3D=3D net->ipv6.ip6_null_entry)
 		return -ENOENT;
=20
-	BUG_TRAP(fn->fn_flags&RTN_RTINFO);
+	WARN_ON(!(fn->fn_flags & RTN_RTINFO));
=20
 	if (!(rt->rt6i_flags&RTF_CACHE)) {
 		struct fib6_node *pn =3D fn;
@@ -1266,7 +1267,7 @@ static int fib6_walk_continue(struct fib6_walker_=
t *w)
 			w->node =3D pn;
 #ifdef CONFIG_IPV6_SUBTREES
 			if (FIB6_SUBTREE(pn) =3D=3D fn) {
-				BUG_TRAP(fn->fn_flags&RTN_ROOT);
+				WARN_ON(!(fn->fn_flags & RTN_ROOT));
 				w->state =3D FWS_L;
 				continue;
 			}
@@ -1281,7 +1282,7 @@ static int fib6_walk_continue(struct fib6_walker_=
t *w)
 				continue;
 			}
 #if RT6_DEBUG >=3D 2
-			BUG_TRAP(0);
+			WARN_ON(1);
 #endif
 		}
 	}
@@ -1323,7 +1324,7 @@ static int fib6_clean_node(struct fib6_walker_t *=
w)
 			}
 			return 0;
 		}
-		BUG_TRAP(res=3D=3D0);
+		WARN_ON(res !=3D 0);
 	}
 	w->leaf =3D rt;
 	return 0;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6407c64..6811901 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -116,7 +116,7 @@ static int ip6_dev_loopback_xmit(struct sk_buff *ne=
wskb)
 	__skb_pull(newskb, skb_network_offset(newskb));
 	newskb->pkt_type =3D PACKET_LOOPBACK;
 	newskb->ip_summed =3D CHECKSUM_UNNECESSARY;
-	BUG_TRAP(newskb->dst);
+	WARN_ON(!newskb->dst);
=20
 	netif_rx(newskb);
 	return 0;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index ee6de42..fca7166 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -306,7 +306,7 @@ static void ipcomp6_free_tfms(struct crypto_comp **=
tfms)
 			break;
 	}
=20
-	BUG_TRAP(pos);
+	WARN_ON(!pos);
=20
 	if (--pos->users)
 		return;
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index ad1cc5b..31295c8 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -164,8 +164,8 @@ static int mip6_destopt_output(struct xfrm_state *x=
, struct sk_buff *skb)
 			calc_padlen(sizeof(*dstopt), 6));
=20
 	hao->type =3D IPV6_TLV_HAO;
+	BUILD_BUG_ON(sizeof(*hao) !=3D 18);
 	hao->length =3D sizeof(*hao) - 2;
-	BUG_TRAP(hao->length =3D=3D 16);
=20
 	len =3D ((char *)hao - (char *)dstopt) + sizeof(*hao);
=20
@@ -174,7 +174,7 @@ static int mip6_destopt_output(struct xfrm_state *x=
, struct sk_buff *skb)
 	memcpy(&iph->saddr, x->coaddr, sizeof(iph->saddr));
 	spin_unlock_bh(&x->lock);
=20
-	BUG_TRAP(len =3D=3D x->props.header_len);
+	WARN_ON(len !=3D x->props.header_len);
 	dstopt->hdrlen =3D (x->props.header_len >> 3) - 1;
=20
 	return 0;
@@ -317,7 +317,7 @@ static int mip6_destopt_init_state(struct xfrm_stat=
e *x)
 	x->props.header_len =3D sizeof(struct ipv6_destopt_hdr) +
 		calc_padlen(sizeof(struct ipv6_destopt_hdr), 6) +
 		sizeof(struct ipv6_destopt_hao);
-	BUG_TRAP(x->props.header_len =3D=3D 24);
+	WARN_ON(x->props.header_len !=3D 24);
=20
 	return 0;
 }
@@ -380,7 +380,7 @@ static int mip6_rthdr_output(struct xfrm_state *x, =
struct sk_buff *skb)
 	rt2->rt_hdr.segments_left =3D 1;
 	memset(&rt2->reserved, 0, sizeof(rt2->reserved));
=20
-	BUG_TRAP(rt2->rt_hdr.hdrlen =3D=3D 2);
+	WARN_ON(rt2->rt_hdr.hdrlen !=3D 2);
=20
 	memcpy(&rt2->addr, &iph->daddr, sizeof(rt2->addr));
 	spin_lock_bh(&x->lock);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilt=
er/nf_conntrack_reasm.c
index cf20bc4..52d06dd 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -416,8 +416,8 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, str=
uct net_device *dev)
=20
 	fq_kill(fq);
=20
-	BUG_TRAP(head !=3D NULL);
-	BUG_TRAP(NFCT_FRAG6_CB(head)->offset =3D=3D 0);
+	WARN_ON(head =3D=3D NULL);
+	WARN_ON(NFCT_FRAG6_CB(head)->offset !=3D 0);
=20
 	/* Unfragmented part is taken from the first segment. */
 	payload_len =3D ((head->data - skb_network_header(head)) -
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 6ab957e..89184b5 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -473,8 +473,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, st=
ruct sk_buff *prev,
 		fq->q.fragments =3D head;
 	}
=20
-	BUG_TRAP(head !=3D NULL);
-	BUG_TRAP(FRAG6_CB(head)->offset =3D=3D 0);
+	WARN_ON(head =3D=3D NULL);
+	WARN_ON(FRAG6_CB(head)->offset !=3D 0);
=20
 	/* Unfragmented part is taken from the first segment. */
 	payload_len =3D ((head->data - skb_network_header(head)) -
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ae45f98..cff778b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -421,7 +421,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct =
inet6_skb_parm *opt,
 		/* ICMPs are not backlogged, hence we cannot get
 		 * an established socket here.
 		 */
-		BUG_TRAP(req->sk =3D=3D NULL);
+		WARN_ON(req->sk !=3D NULL);
=20
 		if (seq !=3D tcp_rsk(req)->snt_isn) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index f0fc46c..d628df9 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -96,8 +96,8 @@ static void pfkey_sock_destruct(struct sock *sk)
 		return;
 	}
=20
-	BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc));
-	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
+	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
=20
 	atomic_dec(&pfkey_socks_nr);
 }
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 98bfe27..b0eacc0 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -158,9 +158,10 @@ static void netlink_sock_destruct(struct sock *sk)
 		printk(KERN_ERR "Freeing alive netlink socket %p\n", sk);
 		return;
 	}
-	BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc));
-	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
-	BUG_TRAP(!nlk_sk(sk)->groups);
+
+	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
+	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(nlk_sk(sk)->groups);
 }
=20
 /* This lock without WQ_FLAG_EXCLUSIVE is good on UP and it is _very_ =
bad on
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d56cae1..c718e7e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -260,8 +260,8 @@ static inline struct packet_sock *pkt_sk(struct soc=
k *sk)
=20
 static void packet_sock_destruct(struct sock *sk)
 {
-	BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc));
-	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
+	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
=20
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		printk("Attempt to release alive packet socket: %p\n", sk);
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 4b2682f..32e4891 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -660,9 +660,9 @@ static void rxrpc_sock_destructor(struct sock *sk)
=20
 	rxrpc_purge_queue(&sk->sk_receive_queue);
=20
-	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
-	BUG_TRAP(sk_unhashed(sk));
-	BUG_TRAP(!sk->sk_socket);
+	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(!sk_unhashed(sk));
+	WARN_ON(sk->sk_socket);
=20
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		printk("Attempt to release alive rxrpc socket: %p\n", sk);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 74e662c..d308c19 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -41,7 +41,7 @@ void tcf_hash_destroy(struct tcf_common *p, struct tc=
f_hashinfo *hinfo)
 			return;
 		}
 	}
-	BUG_TRAP(0);
+	WARN_ON(1);
 }
 EXPORT_SYMBOL(tcf_hash_destroy);
=20
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 32c3f9d..38015b4 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -116,7 +116,7 @@ static void tcf_police_destroy(struct tcf_police *p=
)
 			return;
 		}
 	}
-	BUG_TRAP(0);
+	WARN_ON(1);
 }
=20
 static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] =3D {
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 527db25..246f906 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -345,7 +345,7 @@ static int u32_delete_key(struct tcf_proto *tp, str=
uct tc_u_knode* key)
 			}
 		}
 	}
-	BUG_TRAP(0);
+	WARN_ON(1);
 	return 0;
 }
=20
@@ -368,7 +368,7 @@ static int u32_destroy_hnode(struct tcf_proto *tp, =
struct tc_u_hnode *ht)
 	struct tc_u_common *tp_c =3D tp->data;
 	struct tc_u_hnode **hn;
=20
-	BUG_TRAP(!ht->refcnt);
+	WARN_ON(ht->refcnt);
=20
 	u32_clear_hnode(tp, ht);
=20
@@ -380,7 +380,7 @@ static int u32_destroy_hnode(struct tcf_proto *tp, =
struct tc_u_hnode *ht)
 		}
 	}
=20
-	BUG_TRAP(0);
+	WARN_ON(1);
 	return -ENOENT;
 }
=20
@@ -389,7 +389,7 @@ static void u32_destroy(struct tcf_proto *tp)
 	struct tc_u_common *tp_c =3D tp->data;
 	struct tc_u_hnode *root_ht =3D xchg(&tp->root, NULL);
=20
-	BUG_TRAP(root_ht !=3D NULL);
+	WARN_ON(root_ht =3D=3D NULL);
=20
 	if (root_ht && --root_ht->refcnt =3D=3D 0)
 		u32_destroy_hnode(tp, root_ht);
@@ -407,7 +407,7 @@ static void u32_destroy(struct tcf_proto *tp)
 		while ((ht =3D tp_c->hlist) !=3D NULL) {
 			tp_c->hlist =3D ht->next;
=20
-			BUG_TRAP(ht->refcnt =3D=3D 0);
+			WARN_ON(ht->refcnt !=3D 0);
=20
 			kfree(ht);
 		}
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index f1d2f8e..14954bf 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1175,7 +1175,7 @@ static void cbq_unlink_class(struct cbq_class *th=
is)
 				this->tparent->children =3D NULL;
 		}
 	} else {
-		BUG_TRAP(this->sibling =3D=3D this);
+		WARN_ON(this->sibling !=3D this);
 	}
 }
=20
@@ -1699,7 +1699,7 @@ static void cbq_destroy_class(struct Qdisc *sch, =
struct cbq_class *cl)
 {
 	struct cbq_sched_data *q =3D qdisc_priv(sch);
=20
-	BUG_TRAP(!cl->filters);
+	WARN_ON(cl->filters);
=20
 	tcf_destroy_chain(&cl->filter_list);
 	qdisc_destroy(cl->q);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4ac7e3a..e33802f 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -746,5 +746,5 @@ void dev_shutdown(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, shutdown_scheduler_queue, &noop_qdisc);
 	shutdown_scheduler_queue(dev, &dev->rx_queue, NULL);
-	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
+	WARN_ON(timer_pending(&dev->watchdog_timer));
 }
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 30c999c..75a4095 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -524,7 +524,7 @@ htb_change_class_mode(struct htb_sched *q, struct h=
tb_class *cl, long *diff)
  */
 static inline void htb_activate(struct htb_sched *q, struct htb_class =
*cl)
 {
-	BUG_TRAP(!cl->level && cl->un.leaf.q && cl->un.leaf.q->q.qlen);
+	WARN_ON(cl->level || !cl->un.leaf.q || !cl->un.leaf.q->q.qlen);
=20
 	if (!cl->prio_activity) {
 		cl->prio_activity =3D 1 << (cl->un.leaf.aprio =3D cl->un.leaf.prio);
@@ -542,7 +542,7 @@ static inline void htb_activate(struct htb_sched *q=
, struct htb_class *cl)
  */
 static inline void htb_deactivate(struct htb_sched *q, struct htb_clas=
s *cl)
 {
-	BUG_TRAP(cl->prio_activity);
+	WARN_ON(!cl->prio_activity);
=20
 	htb_deactivate_prios(q, cl);
 	cl->prio_activity =3D 0;
@@ -757,7 +757,7 @@ static struct htb_class *htb_lookup_leaf(struct rb_=
root *tree, int prio,
 		u32 *pid;
 	} stk[TC_HTB_MAXDEPTH], *sp =3D stk;
=20
-	BUG_TRAP(tree->rb_node);
+	WARN_ON(!tree->rb_node);
 	sp->root =3D tree->rb_node;
 	sp->pptr =3D pptr;
 	sp->pid =3D pid;
@@ -777,7 +777,7 @@ static struct htb_class *htb_lookup_leaf(struct rb_=
root *tree, int prio,
 				*sp->pptr =3D (*sp->pptr)->rb_left;
 			if (sp > stk) {
 				sp--;
-				BUG_TRAP(*sp->pptr);
+				WARN_ON(!*sp->pptr);
 				if (!*sp->pptr)
 					return NULL;
 				htb_next_rb_node(sp->pptr);
@@ -792,7 +792,7 @@ static struct htb_class *htb_lookup_leaf(struct rb_=
root *tree, int prio,
 			sp->pid =3D cl->un.inner.last_ptr_id + prio;
 		}
 	}
-	BUG_TRAP(0);
+	WARN_ON(1);
 	return NULL;
 }
=20
@@ -810,7 +810,7 @@ static struct sk_buff *htb_dequeue_tree(struct htb_=
sched *q, int prio,
=20
 	do {
 next:
-		BUG_TRAP(cl);
+		WARN_ON(!cl);
 		if (!cl)
 			return NULL;
=20
@@ -1185,7 +1185,7 @@ static void htb_parent_to_leaf(struct htb_sched *=
q, struct htb_class *cl,
 {
 	struct htb_class *parent =3D cl->parent;
=20
-	BUG_TRAP(!cl->level && cl->un.leaf.q && !cl->prio_activity);
+	WARN_ON(cl->level || !cl->un.leaf.q || cl->prio_activity);
=20
 	if (parent->cmode !=3D HTB_CAN_SEND)
 		htb_safe_rb_erase(&parent->pq_node, q->wait_pq + parent->level);
@@ -1205,7 +1205,7 @@ static void htb_parent_to_leaf(struct htb_sched *=
q, struct htb_class *cl,
 static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 {
 	if (!cl->level) {
-		BUG_TRAP(cl->un.leaf.q);
+		WARN_ON(!cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index ec2a0a3..8472b8b 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -464,7 +464,7 @@ static void sctp_association_destroy(struct sctp_as=
sociation *asoc)
 		spin_unlock_bh(&sctp_assocs_id_lock);
 	}
=20
-	BUG_TRAP(!atomic_read(&asoc->rmem_alloc));
+	WARN_ON(atomic_read(&asoc->rmem_alloc));
=20
 	if (asoc->base.malloced) {
 		kfree(asoc);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 70ceb16..24eb214 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -227,7 +227,7 @@ static void __unix_remove_socket(struct sock *sk)
=20
 static void __unix_insert_socket(struct hlist_head *list, struct sock =
*sk)
 {
-	BUG_TRAP(sk_unhashed(sk));
+	WARN_ON(!sk_unhashed(sk));
 	sk_add_node(sk, list);
 }
=20
@@ -350,9 +350,9 @@ static void unix_sock_destructor(struct sock *sk)
=20
 	skb_queue_purge(&sk->sk_receive_queue);
=20
-	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
-	BUG_TRAP(sk_unhashed(sk));
-	BUG_TRAP(!sk->sk_socket);
+	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(!sk_unhashed(sk));
+	WARN_ON(sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		printk("Attempt to release alive unix socket: %p\n", sk);
 		return;
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 23a2cc0..96036cf 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -718,7 +718,7 @@ int skb_icv_walk(const struct sk_buff *skb, struct =
hash_desc *desc,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
=20
-		BUG_TRAP(start <=3D offset + len);
+		WARN_ON(start > offset + len);
=20
 		end =3D start + skb_shinfo(skb)->frags[i].size;
 		if ((copy =3D end - offset) > 0) {
@@ -748,7 +748,7 @@ int skb_icv_walk(const struct sk_buff *skb, struct =
hash_desc *desc,
 		for (; list; list =3D list->next) {
 			int end;
=20
-			BUG_TRAP(start <=3D offset + len);
+			WARN_ON(start > offset + len);
=20
 			end =3D start + list->len;
 			if ((copy =3D end - offset) > 0) {
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 72fddaf..4c6914e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -538,7 +538,7 @@ EXPORT_SYMBOL(xfrm_state_alloc);
=20
 void __xfrm_state_destroy(struct xfrm_state *x)
 {
-	BUG_TRAP(x->km.state =3D=3D XFRM_STATE_DEAD);
+	WARN_ON(x->km.state !=3D XFRM_STATE_DEAD);
=20
 	spin_lock_bh(&xfrm_state_lock);
 	list_del(&x->all);
--=20
1.5.2.2

