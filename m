From: James Morris <jmorris@namei.org>
Subject: [PATCH/RFC] Remove spurious sk_filter() call from IPv6
Date: Tue, 25 Oct 2005 12:48:14 -0400 (EDT)
Message-ID: <Pine.LNX.4.63.0510251242070.17321@excalibur.intercode>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?iso-2022-jp?Q?YOSHIFUJI_Hideaki_=2F_=B5=C8=C6=A3=B1=D1=CC=C0?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It seems that the IPv6 input path has an extra call to sk_filter().

First, the correct call to sk_filter() in tcp_v6_rcv(), matching the IPv4 
code.

Then, again in tcp_v6_do_rcv(), which often results in a somewhat already 
processed skb being passed to sk_filter().

As far as I can tell, we should remove this second call, as it is both 
incorrect and uncecessary.

Please review and apply if ok.

Signed-off-by: James Morris <jmorris@namei.org>


---

 net/ipv6/tcp_ipv6.c |    3 ---
 1 files changed, 3 deletions(-)

diff -purN -X dontdiff linux-2.6.14-rc5.o/net/ipv6/tcp_ipv6.c linux-2.6.14-rc5.ipv6/net/ipv6/tcp_ipv6.c
--- linux-2.6.14-rc5.o/net/ipv6/tcp_ipv6.c	2005-10-21 00:43:33.000000000 -0400
+++ linux-2.6.14-rc5.ipv6/net/ipv6/tcp_ipv6.c	2005-10-25 12:44:23.000000000 -0400
@@ -1451,9 +1451,6 @@ static int tcp_v6_do_rcv(struct sock *sk
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);
 
-	if (sk_filter(sk, skb, 0))
-		goto discard;
-
 	/*
 	 *	socket locking is here for SMP purposes as backlog rcv
 	 *	is currently called with bh processing disabled.
