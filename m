From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Thu, 18 Dec 2008 21:49:21 -0600
Message-ID: <1229658561.3726.602.camel@calx>
References: <1229638581.3726.546.camel@calx>
	 <Pine.LNX.4.64.0812190028560.12061@wrl-59.cs.helsinki.fi>
	 <1229644234.3726.577.camel@calx>
	 <20081218.161513.241236470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:52005 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281AbYLSDuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 22:50:04 -0500
In-Reply-To: <20081218.161513.241236470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-12-18 at 16:15 -0800, David Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Thu, 18 Dec 2008 17:50:34 -0600
> 
> > If you want, we can instead say "Peer %d unexpectedly shrunk window...".
> > So long as the scary bit is gone, I don't care.
> 
> Since we have established that the blame is equally possible to
> be the local as the remote system, something like:
> 
> 	TCP: Unexpected shrink of advertised window detected ...
> 
> is probably the best.

How's this:

The original message was unhelpful and extremely alarming to our poor
users, despite its charm. Make it less frightening.

Signed-off-by: Matt Mackall <mpm@selenic.com>

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index cc4e6d2..0170e91 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -299,14 +299,14 @@ static void tcp_retransmit_timer(struct sock *sk)
 #ifdef TCP_DEBUG
 		struct inet_sock *inet = inet_sk(sk);
 		if (sk->sk_family == AF_INET) {
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer %pI4:%u/%u shrinks window %u:%u. Repaired.\n",
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI4:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
 			       &inet->daddr, ntohs(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (sk->sk_family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer %pI6:%u/%u shrinks window %u:%u. Repaired.\n",
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI6:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
 			       &np->daddr, ntohs(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}


-- 
Mathematics is the supreme nostalgia of our time.

