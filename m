From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [TCP] Avoid a divide in tcp_mtu_probing()
Date: Fri, 21 Dec 2007 14:32:41 +0100
Message-ID: <20071221143241.4aa9f672.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:52356 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753966AbXLUNcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 08:32:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_mtu_to_mss() being signed, compiler might emit an integer divide
to compute tcp_mtu_to_mss()/2 .

Using a right shift is OK here and less expensive.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index ea111e9..ea85bc0 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -125,7 +125,7 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 			struct tcp_sock *tp = tcp_sk(sk);
 			int mss;
 
-			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2;
+			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low) >> 1;
 			mss = min(sysctl_tcp_base_mss, mss);
 			mss = max(mss, 68 - tp->tcp_header_len);
 			icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
