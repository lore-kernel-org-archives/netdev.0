From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [TCP] Avoid two divides in __tcp_grow_window()
Date: Fri, 21 Dec 2007 15:05:51 +0100
Message-ID: <20071221150551.dccfe24f.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:52844 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756357AbXLUOFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 09:05:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_win_from_space() being signed, compiler might emit an integer divide
to compute tcp_win_from_space()/2 .

Using right shifts is OK here and less expensive.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6931946..145b51a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -289,8 +289,8 @@ static int __tcp_grow_window(const struct sock *sk, const struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	/* Optimize this! */
-	int truesize = tcp_win_from_space(skb->truesize)/2;
-	int window = tcp_win_from_space(sysctl_tcp_rmem[2])/2;
+	int truesize = tcp_win_from_space(skb->truesize) >> 1;
+	int window = tcp_win_from_space(sysctl_tcp_rmem[2]) >> 1;
 
 	while (tp->rcv_ssthresh <= window) {
 		if (truesize <= skb->len)
