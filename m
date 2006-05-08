From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 6/9] [I/OAT] Rename cleanup_rbuf to tcp_cleanup_rbuf and make non-static
Date: Mon, 08 May 2006 15:17:43 -0700
Message-ID: <20060508221743.15181.37962.stgit@gitlost.site>
References: <20060508221632.15181.50046.stgit@gitlost.site>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:23301 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751287AbWEHWNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:13:15 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <20060508221632.15181.50046.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Needed to be able to call tcp_cleanup_rbuf in tcp_input.c for I/OAT

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 include/net/tcp.h |    2 ++
 net/ipv4/tcp.c    |   10 +++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d0c2c2f..578cccf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -294,6 +294,8 @@ extern int			tcp_rcv_established(struct 
 
 extern void			tcp_rcv_space_adjust(struct sock *sk);
 
+extern void			tcp_cleanup_rbuf(struct sock *sk, int copied);
+
 extern int			tcp_twsk_unique(struct sock *sk,
 						struct sock *sktw, void *twp);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e2b7b80..1c0cfd7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -937,7 +937,7 @@ static int tcp_recv_urg(struct sock *sk,
  * calculation of whether or not we must ACK for the sake of
  * a window update.
  */
-static void cleanup_rbuf(struct sock *sk, int copied)
+void tcp_cleanup_rbuf(struct sock *sk, int copied)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int time_to_ack = 0;
@@ -1086,7 +1086,7 @@ int tcp_read_sock(struct sock *sk, read_
 
 	/* Clean up data we have read: This will do ACK frames. */
 	if (copied)
-		cleanup_rbuf(sk, copied);
+		tcp_cleanup_rbuf(sk, copied);
 	return copied;
 }
 
@@ -1220,7 +1220,7 @@ int tcp_recvmsg(struct kiocb *iocb, stru
 			}
 		}
 
-		cleanup_rbuf(sk, copied);
+		tcp_cleanup_rbuf(sk, copied);
 
 		if (!sysctl_tcp_low_latency && tp->ucopy.task == user_recv) {
 			/* Install new reader */
@@ -1391,7 +1391,7 @@ skip_copy:
 	 */
 
 	/* Clean up data we have read: This will do ACK frames. */
-	cleanup_rbuf(sk, copied);
+	tcp_cleanup_rbuf(sk, copied);
 
 	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
@@ -1858,7 +1858,7 @@ static int do_tcp_setsockopt(struct sock
 			    (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT) &&
 			    inet_csk_ack_scheduled(sk)) {
 				icsk->icsk_ack.pending |= ICSK_ACK_PUSHED;
-				cleanup_rbuf(sk, 1);
+				tcp_cleanup_rbuf(sk, 1);
 				if (!(val & 1))
 					icsk->icsk_ack.pingpong = 1;
 			}

