From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Remove seq_rtt ptr from clean_rtx_queue args
Date: Fri, 21 Dec 2007 16:19:19 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712211617020.7301@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1054537258-1198246759=:7301"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43948 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757301AbXLUOTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:19:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1054537258-1198246759=:7301
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


While checking Gavin's patch I noticed that the returned seq_rtt
is not used by the caller.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
I think it shouldn't introduce new conflicts between net-2.6.25 and 
net-2.6 (tested with git-am -3 to both).

 net/ipv4/tcp_input.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0f0c1c9..a020e83 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2638,8 +2638,7 @@ static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
  * is before the ack sequence we can discard it as it's confirmed to have
  * arrived at the other end.
  */
-static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
-			       int prior_fackets)
+static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2803,7 +2802,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 		}
 	}
 #endif
-	*seq_rtt_p = seq_rtt;
 	return flag;
 }
 
@@ -3044,7 +3042,6 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
 	u32 prior_in_flight;
 	u32 prior_fackets;
-	s32 seq_rtt;
 	int prior_packets;
 	int frto_cwnd = 0;
 
@@ -3111,7 +3108,7 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	prior_in_flight = tcp_packets_in_flight(tp);
 
 	/* See if we can take anything off of the retransmit queue. */
-	flag |= tcp_clean_rtx_queue(sk, &seq_rtt, prior_fackets);
+	flag |= tcp_clean_rtx_queue(sk, prior_fackets);
 
 	if (tp->frto_counter)
 		frto_cwnd = tcp_process_frto(sk, flag);
-- 
1.5.0.6

---696243703-1054537258-1198246759=:7301--
