From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Fri, 21 May 2010 11:16:32 +1000
Message-ID: <20100521011632.GA23849@gondor.apana.org.au>
References: <20100519.200522.140743640.davem@davemloft.net> <20100520033446.GA6434@gondor.apana.org.au> <1274332507.2658.31.camel@edumazet-laptop> <20100520052059.GC7443@gondor.apana.org.au> <1274333779.2658.43.camel@edumazet-laptop> <20100520054642.GA7836@gondor.apana.org.au> <20100520172918.GA17613@shamino.rdu.redhat.com> <20100520231630.GA22593@gondor.apana.org.au> <20100521003939.GA2223@localhost.localdomain> <20100521010211.GA23671@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@redhat.com, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:47962 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752696Ab0EUBQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 21:16:46 -0400
Content-Disposition: inline
In-Reply-To: <20100521010211.GA23671@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 21, 2010 at 11:02:11AM +1000, Herbert Xu wrote:
> 
> That's what I meant above.  My patch will make tun.c to the
> classid update every time it sends out a packet.

Here it is:

tun: Update classid on packet injection

This patch makes tun update its socket classid every time we
inject a packet into the network stack.  This is so that any
updates made by the admin to the process writing packets to
tun is effected.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4326520..a8a9aa8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -525,6 +525,8 @@ static inline struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
 	struct sk_buff *skb;
 	int err;
 
+	sock_update_classid(sk);
+
 	/* Under a page?  Don't bother with paged skb. */
 	if (prepad + len < PAGE_SIZE || !linear)
 		linear = len;
diff --git a/net/core/sock.c b/net/core/sock.c
index 8f7fdf8..4969bd1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1055,6 +1055,7 @@ void sock_update_classid(struct sock *sk)
 	if (classid && classid != sk->sk_classid)
 		sk->classid = classid;
 }
+EXPORT_SYMBOL(sock_update_classid);
 #endif
 
 /**

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
