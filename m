From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH] ipv4: remove parentheses in return statement
Date: Fri,  3 Aug 2012 01:43:10 -0600
Message-ID: <1343979790-17408-1-git-send-email-sakiwit@gmail.com>
Cc: Jean Sacren <sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41983 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab2HCHqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 03:46:06 -0400
Received: by yhmm54 with SMTP id m54so484254yhm.19
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2012 00:46:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is always wrong to write 'return (...)'.

After removal, realign the code where necessary.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/ipv4/devinet.c    |    4 ++--
 net/ipv4/inetpeer.c   |    2 +-
 net/ipv4/syncookies.c |    8 ++++----
 net/ipv4/tcp_input.c  |   16 ++++++++--------
 net/ipv4/tcp_output.c |    2 +-
 5 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 44bf82e..72b16e4 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -106,8 +106,8 @@ static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
 {
 	u32 val = (__force u32) addr ^ hash_ptr(net, 8);
 
-	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
-		(IN4_ADDR_HSIZE - 1));
+	return (val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
+	       (IN4_ADDR_HSIZE - 1);
 }
 
 static void inet_hash_insert(struct net *net, struct in_ifaddr *ifa)
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index e1e0a4e..8049ce0 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -96,7 +96,7 @@ static atomic_t v6_seq = ATOMIC_INIT(0);
 
 static atomic_t *inetpeer_seq_ptr(int family)
 {
-	return (family == AF_INET ? &v4_seq : &v6_seq);
+	return (family == AF_INET) ? &v4_seq : &v6_seq;
 }
 
 static inline void flush_check(struct inet_peer_base *base, int family)
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 650e152..cb9c489 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -103,10 +103,10 @@ static __u32 secure_tcp_syn_cookie(__be32 saddr, __be32 daddr, __be16 sport,
 	 * MSS into the second hash value.
 	 */
 
-	return (cookie_hash(saddr, daddr, sport, dport, 0, 0) +
-		sseq + (count << COOKIEBITS) +
-		((cookie_hash(saddr, daddr, sport, dport, count, 1) + data)
-		 & COOKIEMASK));
+	return cookie_hash(saddr, daddr, sport, dport, 0, 0) +
+	       sseq + (count << COOKIEBITS) +
+	       ((cookie_hash(saddr, daddr, sport, dport, count, 1) + data)
+		& COOKIEMASK);
 }
 
 /*
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2fd2bc9..1d220f9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3993,17 +3993,17 @@ static int tcp_disordered_ack(const struct sock *sk, const struct sk_buff *skb)
 	u32 seq = TCP_SKB_CB(skb)->seq;
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
 
-	return (/* 1. Pure ACK with correct sequence number. */
-		(th->ack && seq == TCP_SKB_CB(skb)->end_seq && seq == tp->rcv_nxt) &&
+	return /* 1. Pure ACK with correct sequence number. */
+	       (th->ack && seq == TCP_SKB_CB(skb)->end_seq && seq == tp->rcv_nxt) &&
 
-		/* 2. ... and duplicate ACK. */
-		ack == tp->snd_una &&
+	       /* 2. ... and duplicate ACK. */
+	       ack == tp->snd_una &&
 
-		/* 3. ... and does not update window. */
-		!tcp_may_update_window(tp, ack, seq, ntohs(th->window) << tp->rx_opt.snd_wscale) &&
+	       /* 3. ... and does not update window. */
+	       !tcp_may_update_window(tp, ack, seq, ntohs(th->window) << tp->rx_opt.snd_wscale) &&
 
-		/* 4. ... and sits in replay window. */
-		(s32)(tp->rx_opt.ts_recent - tp->rx_opt.rcv_tsval) <= (inet_csk(sk)->icsk_rto * 1024) / HZ);
+	       /* 4. ... and sits in replay window. */
+	       (s32)(tp->rx_opt.ts_recent - tp->rx_opt.rcv_tsval) <= (inet_csk(sk)->icsk_rto * 1024) / HZ;
 }
 
 static inline bool tcp_paws_discard(const struct sock *sk,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a7b3ec9..eac214c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1557,7 +1557,7 @@ static inline unsigned int tcp_cwnd_test(const struct tcp_sock *tp,
 	in_flight = tcp_packets_in_flight(tp);
 	cwnd = tp->snd_cwnd;
 	if (in_flight < cwnd)
-		return (cwnd - in_flight);
+		return cwnd - in_flight;
 
 	return 0;
 }
