From: "Adam Langley" <agl@imperialviolet.org>
Subject: [PATCH] tcp: (whitespace only) fix confusing indentation
Date: Thu, 7 Aug 2008 18:37:12 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069060@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:39457 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbYHHBlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 21:41:16 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1220812wfd.4
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 18:41:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The indentation in part of tcp_minisocks makes it look like one of the if
statements is much more important than it actually is.

Signed-off-by: Adam Langley <agl@imperialviolet.org>
---

 net/ipv4/tcp_minisocks.c |  138 +++++++++++++++++++++++-----------------------
 1 files changed, 68 insertions(+), 70 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6d286f5..f976fc5 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -618,89 +618,87 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 	/* In sequence, PAWS is OK. */
 
 	if (tmp_opt.saw_tstamp && !after(TCP_SKB_CB(skb)->seq, tcp_rsk(req)->rcv_isn + 1))
-			req->ts_recent = tmp_opt.rcv_tsval;
+		req->ts_recent = tmp_opt.rcv_tsval;
 
-		if (TCP_SKB_CB(skb)->seq == tcp_rsk(req)->rcv_isn) {
-			/* Truncate SYN, it is out of window starting
-			   at tcp_rsk(req)->rcv_isn + 1. */
-			flg &= ~TCP_FLAG_SYN;
-		}
+	if (TCP_SKB_CB(skb)->seq == tcp_rsk(req)->rcv_isn) {
+		/* Truncate SYN, it is out of window starting
+		   at tcp_rsk(req)->rcv_isn + 1. */
+		flg &= ~TCP_FLAG_SYN;
+	}
 
-		/* RFC793: "second check the RST bit" and
-		 *	   "fourth, check the SYN bit"
-		 */
-		if (flg & (TCP_FLAG_RST|TCP_FLAG_SYN)) {
-			TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
-			goto embryonic_reset;
-		}
+	/* RFC793: "second check the RST bit" and
+	 *	   "fourth, check the SYN bit"
+	 */
+	if (flg & (TCP_FLAG_RST|TCP_FLAG_SYN)) {
+		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
+		goto embryonic_reset;
+	}
 
-		/* ACK sequence verified above, just make sure ACK is
-		 * set.  If ACK not set, just silently drop the packet.
-		 */
-		if (!(flg & TCP_FLAG_ACK))
-			return NULL;
-
-		/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
-		if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
-		    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
-			inet_rsk(req)->acked = 1;
-			return NULL;
-		}
+	/* ACK sequence verified above, just make sure ACK is
+	 * set.  If ACK not set, just silently drop the packet.
+	 */
+	if (!(flg & TCP_FLAG_ACK))
+		return NULL;
 
-		/* OK, ACK is valid, create big socket and
-		 * feed this segment to it. It will repeat all
-		 * the tests. THIS SEGMENT MUST MOVE SOCKET TO
-		 * ESTABLISHED STATE. If it will be dropped after
-		 * socket is created, wait for troubles.
-		 */
-		child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb,
-								 req, NULL);
-		if (child == NULL)
-			goto listen_overflow;
+	/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
+	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+	    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
+		inet_rsk(req)->acked = 1;
+		return NULL;
+	}
+
+	/* OK, ACK is valid, create big socket and
+	 * feed this segment to it. It will repeat all
+	 * the tests. THIS SEGMENT MUST MOVE SOCKET TO
+	 * ESTABLISHED STATE. If it will be dropped after
+	 * socket is created, wait for troubles.
+	 */
+	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
+	if (child == NULL)
+		goto listen_overflow;
 #ifdef CONFIG_TCP_MD5SIG
-		else {
-			/* Copy over the MD5 key from the original socket */
-			struct tcp_md5sig_key *key;
-			struct tcp_sock *tp = tcp_sk(sk);
-			key = tp->af_specific->md5_lookup(sk, child);
-			if (key != NULL) {
-				/*
-				 * We're using one, so create a matching key on the
-				 * newsk structure. If we fail to get memory then we
-				 * end up not copying the key across. Shucks.
-				 */
-				char *newkey = kmemdup(key->key, key->keylen,
-						       GFP_ATOMIC);
-				if (newkey) {
-					if (!tcp_alloc_md5sig_pool())
-						BUG();
-					tp->af_specific->md5_add(child, child,
-								 newkey,
-								 key->keylen);
-				}
+	else {
+		/* Copy over the MD5 key from the original socket */
+		struct tcp_md5sig_key *key;
+		struct tcp_sock *tp = tcp_sk(sk);
+		key = tp->af_specific->md5_lookup(sk, child);
+		if (key != NULL) {
+			/*
+			 * We're using one, so create a matching key on the
+			 * newsk structure. If we fail to get memory then we
+			 * end up not copying the key across. Shucks.
+			 */
+			char *newkey = kmemdup(key->key, key->keylen,
+					       GFP_ATOMIC);
+			if (newkey) {
+				if (!tcp_alloc_md5sig_pool())
+					BUG();
+				tp->af_specific->md5_add(child, child, newkey,
+							 key->keylen);
 			}
 		}
+	}
 #endif
 
-		inet_csk_reqsk_queue_unlink(sk, req, prev);
-		inet_csk_reqsk_queue_removed(sk, req);
+	inet_csk_reqsk_queue_unlink(sk, req, prev);
+	inet_csk_reqsk_queue_removed(sk, req);
 
-		inet_csk_reqsk_queue_add(sk, req, child);
-		return child;
+	inet_csk_reqsk_queue_add(sk, req, child);
+	return child;
 
-	listen_overflow:
-		if (!sysctl_tcp_abort_on_overflow) {
-			inet_rsk(req)->acked = 1;
-			return NULL;
-		}
+listen_overflow:
+	if (!sysctl_tcp_abort_on_overflow) {
+		inet_rsk(req)->acked = 1;
+		return NULL;
+	}
 
-	embryonic_reset:
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_EMBRYONICRSTS);
-		if (!(flg & TCP_FLAG_RST))
-			req->rsk_ops->send_reset(sk, skb);
+embryonic_reset:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_EMBRYONICRSTS);
+	if (!(flg & TCP_FLAG_RST))
+		req->rsk_ops->send_reset(sk, skb);
 
-		inet_csk_reqsk_queue_drop(sk, req, prev);
-		return NULL;
+	inet_csk_reqsk_queue_drop(sk, req, prev);
+	return NULL;
 }
 
 /*
