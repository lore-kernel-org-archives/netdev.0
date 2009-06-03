From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: tun: Only wake up writers
Date: Wed, 3 Jun 2009 13:33:03 +1000
Message-ID: <20090603033303.GA7889@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33971 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751985AbZFCDdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 23:33:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

tun: Only wake up writers

Recently net/core/sock.c was updated so that when we free an skb
that has been transmitted we only wake up writers instead of waking
up both readers and writers.

This patch does the same thing for tun as this code is identical
to that in net/core/sock.c

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 735bf41..7ca43b8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -841,7 +841,9 @@ static void tun_sock_write_space(struct sock *sk)
 		return;
 
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible_sync(sk->sk_sleep);
+		wake_up_interruptible_sync_poll(sk->sk_sleep,
+						POLLOUT | POLLWRNORM |
+						POLLWRBAND);
 
 	if (!test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
 		return;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
