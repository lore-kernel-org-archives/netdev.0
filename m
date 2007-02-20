From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP] Cleanup: struct *sock argument renamed: sp -> sk
Date: Tue, 20 Feb 2007 17:17:02 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0702201712370.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1855305832-1171984622=:19465"
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56722 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965028AbXBTPRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 10:17:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1855305832-1171984622=:19465
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

In general, TCP code uses "sk" for struct sock pointer.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_ipv4.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ba74bb..f6793b4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2293,13 +2293,13 @@ static void get_openreq4(struct sock *sk
 		req);
 }
 
-static void get_tcp4_sock(struct sock *sp, char *tmpbuf, int i)
+static void get_tcp4_sock(struct sock *sk, char *tmpbuf, int i)
 {
 	int timer_active;
 	unsigned long timer_expires;
-	struct tcp_sock *tp = tcp_sk(sp);
-	const struct inet_connection_sock *icsk = inet_csk(sp);
-	struct inet_sock *inet = inet_sk(sp);
+	struct tcp_sock *tp = tcp_sk(sk);
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	__be32 dest = inet->daddr;
 	__be32 src = inet->rcv_saddr;
 	__u16 destp = ntohs(inet->dport);
@@ -2311,9 +2311,9 @@ static void get_tcp4_sock(struct sock *s
 	} else if (icsk->icsk_pending == ICSK_TIME_PROBE0) {
 		timer_active	= 4;
 		timer_expires	= icsk->icsk_timeout;
-	} else if (timer_pending(&sp->sk_timer)) {
+	} else if (timer_pending(&sk->sk_timer)) {
 		timer_active	= 2;
-		timer_expires	= sp->sk_timer.expires;
+		timer_expires	= sk->sk_timer.expires;
 	} else {
 		timer_active	= 0;
 		timer_expires = jiffies;
@@ -2321,17 +2321,17 @@ static void get_tcp4_sock(struct sock *s
 
 	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
 			"%08X %5d %8d %lu %d %p %u %u %u %u %d",
-		i, src, srcp, dest, destp, sp->sk_state,
+		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
-		sp->sk_state == TCP_LISTEN ? sp->sk_ack_backlog :
+		sk->sk_state == TCP_LISTEN ? sk->sk_ack_backlog :
 					     (tp->rcv_nxt - tp->copied_seq),
 		timer_active,
 		jiffies_to_clock_t(timer_expires - jiffies),
 		icsk->icsk_retransmits,
-		sock_i_uid(sp),
+		sock_i_uid(sk),
 		icsk->icsk_probes_out,
-		sock_i_ino(sp),
-		atomic_read(&sp->sk_refcnt), sp,
+		sock_i_ino(sk),
+		atomic_read(&sk->sk_refcnt), sk,
 		icsk->icsk_rto,
 		icsk->icsk_ack.ato,
 		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
-- 
1.4.2
---696243703-1855305832-1171984622=:19465--
