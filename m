From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: RFC6298 supersedes RFC2988bis
Date: Fri, 13 Apr 2012 07:48:40 +0200
Message-ID: <1334296120.5300.8404.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:38590 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326Ab2DMFso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 01:48:44 -0400
Received: by wgbds11 with SMTP id ds11so5520137wgb.1
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 22:48:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updates some comments to track RFC6298

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
Cc: Tom Herbert <therbert@google.com>
---
BTW, one side effect of the TCP_TIMEOUT_INIT change (3 -> 1) is
inet_csk_reqsk_queue_prune() latency is 200% worse:

It fires every 200ms and scans 40% of hash table each time, listener
socket held.

 include/net/tcp.h               |    2 +-
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/tcp_input.c            |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f75a04d..057f016 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -123,7 +123,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #endif
 #define TCP_RTO_MAX	((unsigned)(120*HZ))
 #define TCP_RTO_MIN	((unsigned)(HZ/5))
-#define TCP_TIMEOUT_INIT ((unsigned)(1*HZ))	/* RFC2988bis initial RTO value	*/
+#define TCP_TIMEOUT_INIT ((unsigned)(1*HZ))	/* RFC6298 2.1 initial RTO value	*/
 #define TCP_TIMEOUT_FALLBACK ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value, now
 						 * used as a fallback RTO for the
 						 * initial data transmission if no
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 19d66ce..c12396f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -514,7 +514,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 
 	/* Normally all the openreqs are young and become mature
 	 * (i.e. converted to established socket) for first timeout.
-	 * If synack was not acknowledged for 3 seconds, it means
+	 * If synack was not acknowledged for 1 second, it means
 	 * one of the following things: synack was lost, ack was lost,
 	 * rtt is high or nobody planned to ack (i.e. synflood).
 	 * When server is a bit loaded, queue is populated with old
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e886e2f..9147c27 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -933,7 +933,7 @@ static void tcp_init_metrics(struct sock *sk)
 	tcp_set_rto(sk);
 reset:
 	if (tp->srtt == 0) {
-		/* RFC2988bis: We've failed to get a valid RTT sample from
+		/* RFC6298: 5.7 We've failed to get a valid RTT sample from
 		 * 3WHS. This is most likely due to retransmission,
 		 * including spurious one. Reset the RTO back to 3secs
 		 * from the more aggressive 1sec to avoid more spurious
@@ -943,7 +943,7 @@ reset:
 		inet_csk(sk)->icsk_rto = TCP_TIMEOUT_FALLBACK;
 	}
 	/* Cut cwnd down to 1 per RFC5681 if SYN or SYN-ACK has been
-	 * retransmitted. In light of RFC2988bis' more aggressive 1sec
+	 * retransmitted. In light of RFC6298 more aggressive 1sec
 	 * initRTO, we only reset cwnd when more than 1 SYN/SYN-ACK
 	 * retransmission has occurred.
 	 */
