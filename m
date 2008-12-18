From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Thu, 18 Dec 2008 16:16:21 -0600
Message-ID: <1229638581.3726.546.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:43397 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746AbYLRWQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 17:16:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These debug messages are uninformative and extremely alarming. Rather
than reporting a peer as a treacherous attacker, report it more
correctly as simply broken. 

Signed-off-by: Matt Mackall <mpm@selenic.com>

diff -r 320a7bd38b8d net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	Mon Oct 27 17:33:24 2008 -0500
+++ b/net/ipv4/tcp_timer.c	Thu Dec 18 16:06:39 2008 -0600
@@ -299,14 +299,14 @@
 #ifdef TCP_DEBUG
 		struct inet_sock *inet = inet_sk(sk);
 		if (sk->sk_family == AF_INET) {
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer " NIPQUAD_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Broken peer " NIPQUAD_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",
 			       NIPQUAD(inet->daddr), ntohs(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (sk->sk_family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer " NIP6_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Broken peer " NIP6_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",
 			       NIP6(np->daddr), ntohs(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}

-- 
Mathematics is the supreme nostalgia of our time.

