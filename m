From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4] inetpeer: Get rid of volatile from peer_total
Date: Mon, 10 Jul 2006 09:07:11 +1000
Message-ID: <20060709230711.GA19901@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22801 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932517AbWGIXHS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 19:07:18 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

Just joining on the fun on volatile :)

[IPV4] inetpeer: Get rid of volatile from peer_total

The variable peer_total is protected by a lock.  The volatile marker
makes no sense.  This shaves off 20 bytes on i386.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 2160874..03ff62e 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -86,7 +86,7 @@ static struct inet_peer *peer_root = pee
 static DEFINE_RWLOCK(peer_pool_lock);
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
 
-static volatile int peer_total;
+static int peer_total;
 /* Exported for sysctl_net_ipv4.  */
 int inet_peer_threshold = 65536 + 128;	/* start to throw entries more
 					 * aggressively at this stage */
