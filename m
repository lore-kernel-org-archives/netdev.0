From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] tcp: make local functions static
Date: Sun, 29 Dec 2013 11:39:51 -0800
Message-ID: <20131229113951.6ef99f27@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36272 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072Ab3L2TkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 14:40:03 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so10668335pdj.12
        for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 11:40:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following are only used in one file:
  tcp_connect_init
  tcp_set_rto

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 include/net/tcp.h     |    3 ---
 net/ipv4/tcp_input.c  |    2 +-
 net/ipv4/tcp_output.c |    2 +-
 3 files changed, 2 insertions(+), 5 deletions(-)

--- a/include/net/tcp.h	2013-12-24 15:15:26.685742315 -0800
+++ b/include/net/tcp.h	2013-12-24 15:16:00.241291333 -0800
@@ -468,7 +468,6 @@ struct sk_buff *tcp_make_synack(struct s
 				struct tcp_fastopen_cookie *foc);
 int tcp_disconnect(struct sock *sk, int flags);
 
-void tcp_connect_init(struct sock *sk);
 void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
 int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size);
 void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
@@ -623,8 +622,6 @@ static inline u32 __tcp_set_rto(const st
 	return (tp->srtt >> 3) + tp->rttvar;
 }
 
-void tcp_set_rto(struct sock *sk);
-
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
 {
 	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
--- a/net/ipv4/tcp_input.c	2013-12-24 15:15:26.685742315 -0800
+++ b/net/ipv4/tcp_input.c	2013-12-24 15:16:00.245291279 -0800
@@ -766,7 +766,7 @@ static void tcp_update_pacing_rate(struc
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
  * routine referred to above.
  */
-void tcp_set_rto(struct sock *sk)
+static void tcp_set_rto(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	/* Old crap is replaced with new one. 8)
--- a/net/ipv4/tcp_output.c	2013-12-24 15:15:26.685742315 -0800
+++ b/net/ipv4/tcp_output.c	2013-12-24 15:16:00.245291279 -0800
@@ -2777,7 +2777,7 @@ struct sk_buff *tcp_make_synack(struct s
 EXPORT_SYMBOL(tcp_make_synack);
 
 /* Do all connect socket setups that can be done AF independent. */
-void tcp_connect_init(struct sock *sk)
+static void tcp_connect_init(struct sock *sk)
 {
 	const struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
