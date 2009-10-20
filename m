From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: tcp: Try to catch MSG_PEEK bug
Date: Tue, 20 Oct 2009 14:41:06 +0900
Message-ID: <20091020054106.GA5507@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49327 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751186AbZJTFlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 01:41:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

tcp: Try to catch MSG_PEEK bug

This patch tries to print out more information when we hit the
MSG_PEEK bug in tcp_recvmsg.  It's been around since at least
2005 and it's about time that we finally fix it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheer,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 64d0af6..fb881d5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1405,7 +1405,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				goto found_ok_skb;
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
-			WARN_ON(!(flags & MSG_PEEK));
+			if (WARN_ON(!(flags & MSG_PEEK)))
+				printk(KERN_INFO "recvmsg bug 2: copied %X "
+				       "seq %X\n", *seq, TCP_SKB_CB(skb)->seq);
 		}
 
 		/* Well, if we have backlog, try to process it now yet. */
