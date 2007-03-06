From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [UDP6]: Restore sk_filter optimisation
Date: Tue, 6 Mar 2007 12:20:10 +1100
Message-ID: <20070306012010.GA25763@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1098 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933760AbXCFBUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 20:20:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[UDP6]: Restore sk_filter optimisation

This reverts the changeset

    [IPV6]: UDPv6 checksum.

    We always need to check UDPv6 checksum because it is mandatory.

The sk_filter optimisation has nothing to do whether we verify the
checksum.  It simply postpones it to the point when the user calls
recv or poll.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0ad4719..4474480 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -279,8 +279,10 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 		}
 	}
 
-	if (udp_lib_checksum_complete(skb))
-		goto drop;
+	if (sk->sk_filter) {
+		if (udp_lib_checksum_complete(skb))
+			goto drop;
+	}
 
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
