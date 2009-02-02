From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ipv4: Delete redundant sk_family assignment
Date: Mon, 2 Feb 2009 17:19:18 +1100
Message-ID: <20090202061918.GA23990@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40029 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751449AbZBBGTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 01:19:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

Here's a random clean-up that I did while working on tun accounting.

ipv4: Delete redundant sk_family assignment

sk_alloc now sets sk_family so this is redundant.  In fact it caught
my eye because sock_init_data already uses sk_family so this is too
late anyway.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d6770f2..7b3ca13 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -369,7 +369,6 @@ lookup_protocol:
 	sock_init_data(sock, sk);
 
 	sk->sk_destruct	   = inet_sock_destruct;
-	sk->sk_family	   = PF_INET;
 	sk->sk_protocol	   = protocol;
 	sk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
