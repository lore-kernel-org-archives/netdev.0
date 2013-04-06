From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: PROBLEM: IPv6 TCP-Connections resetting
Date: Sat, 06 Apr 2013 11:18:01 +0200
Message-ID: <4796401.BXlLaoS7qO@cpaasch-mac>
References: <20130405174828.310a02c3@trediske.ws.office.manitu.net> <20130406043534.GC30194@order.stressinduktion.org> <1460015.zN3jPXiAbD@cpaasch-mac>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Tetja Rediske <tetja@tetja.de>, djduanjiong@gmail.com,
	netdev@vger.kernel.org, steffen.klassert@secunet.com,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:35779 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1163074Ab3DFJSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 05:18:05 -0400
Received: by mail-wg0-f46.google.com with SMTP id l18so4348579wgh.1
        for <netdev@vger.kernel.org>; Sat, 06 Apr 2013 02:18:03 -0700 (PDT)
In-Reply-To: <1460015.zN3jPXiAbD@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 06 April 2013 11:14:44 Christoph Paasch wrote:
> From: Christoph Paasch <christoph.paasch@uclouvain.be>

Argh...
Sorry, my e-mail client messed up the patch. Here the resend:


------

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Sat, 6 Apr 2013 10:21:01 +0200
Subject: [PATCH] ipv6/tcp: Stop processing ICMPv6 redirect messages

Upon reception of an ICMPv6 Redirect message, we should not continue
inside tcp_v6_err. Otherwise, an error will be reported or request-socks
will be closed.

Adds also some parantheses to respect codingstyle guidelines.

Reported-by: Tetja Rediske <tetja@tetja.de>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv6/tcp_ipv6.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1033d2b..24434c5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -386,6 +386,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		if (dst)
 			dst->ops->redirect(dst, sk, skb);
+		goto out;
 	}
 
 	if (type == ICMPV6_PKT_TOOBIG) {
@@ -441,16 +442,18 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			sk->sk_error_report(sk);		/* Wake people up to see the error (see connect in sock.c) */
 
 			tcp_done(sk);
-		} else
+		} else {
 			sk->sk_err_soft = err;
+		}
 		goto out;
 	}
 
 	if (!sock_owned_by_user(sk) && np->recverr) {
 		sk->sk_err = err;
 		sk->sk_error_report(sk);
-	} else
+	} else {
 		sk->sk_err_soft = err;
+	}
 
 out:
 	bh_unlock_sock(sk);
-- 
1.8.1.227.g44fe835



-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
UCLouvain
--
