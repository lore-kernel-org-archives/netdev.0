From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH] TCP: remove TCP_DEBUG
Date: Mon, 24 Oct 2011 16:15:10 -0200
Message-ID: <1319480110-20361-1-git-send-email-fbl@redhat.com>
References: <CAEik5nPciVMwOE-hC+oPP1gMEvRzbhFwAZHKNQnHEc0YOUXuWA@mail.gmail.com>
Cc: David Miller <davem@davemloft.net>, Dan McGee <dpmcgee@gmail.com>,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, linux-kernel@vger.kernel.org
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEik5nPciVMwOE-hC+oPP1gMEvRzbhFwAZHKNQnHEc0YOUXuWA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was enabled by default and the messages guarded
by the define are useful.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 include/net/tcp.h    |    1 -
 net/ipv4/tcp.c       |    2 --
 net/ipv4/tcp_timer.c |    2 --
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index ed0e814..e147f42 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -18,7 +18,6 @@
 #ifndef _TCP_H
 #define _TCP_H
 
-#define TCP_DEBUG 1
 #define FASTRETRANS_DEBUG 1
 
 #include <linux/list.h>
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index eefc61e..34f5db1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1193,13 +1193,11 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 	struct tcp_sock *tp = tcp_sk(sk);
 	int time_to_ack = 0;
 
-#if TCP_DEBUG
 	struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
 
 	WARN(skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq),
 	     "cleanup rbuf bug: copied %X seq %X rcvnxt %X\n",
 	     tp->copied_seq, TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt);
-#endif
 
 	if (inet_csk_ack_scheduled(sk)) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index ecd44b0..2e0f0af 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -334,7 +334,6 @@ void tcp_retransmit_timer(struct sock *sk)
 		 * connection. If the socket is an orphan, time it out,
 		 * we cannot allow such beasts to hang infinitely.
 		 */
-#ifdef TCP_DEBUG
 		struct inet_sock *inet = inet_sk(sk);
 		if (sk->sk_family == AF_INET) {
 			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI4:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
@@ -349,7 +348,6 @@ void tcp_retransmit_timer(struct sock *sk)
 			       inet->inet_num, tp->snd_una, tp->snd_nxt);
 		}
 #endif
-#endif
 		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
 			tcp_write_err(sk);
 			goto out;
-- 
1.7.6
