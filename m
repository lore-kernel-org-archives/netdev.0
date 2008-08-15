From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for	iptables nat routing
Date: Fri, 15 Aug 2008 20:32:35 +1000
Message-ID: <20080815103235.GA31963@gondor.apana.org.au>
References: <E1KTrAo-0001YG-00@gondolin.me.apana.org.au> <1218778238.23510.22.camel@2710p.home> <20080815073343.GA20644@gondor.apana.org.au> <20080815081442.GA20971@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54418 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751865AbYHOKct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 06:32:49 -0400
Content-Disposition: inline
In-Reply-To: <20080815081442.GA20971@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 06:14:42PM +1000, Herbert Xu wrote:
> 
> It's OK, I can reproduce it now.

This fixes it for me.

loopback: Enable TSO

This patch enables TSO since the loopback device is naturally
capable of handling packets of any size.  This also means that
we won't enable GSO on lo which is good until GSO is fixed to
preserve netfilter state as netfilter treats loopback packets
in a special way.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'll work on the netfilter state preservation next.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 49f6bc0..c11e621 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -234,9 +231,7 @@ static void loopback_setup(struct net_device *dev)
 	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		= IFF_LOOPBACK;
 	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
-#ifdef LOOPBACK_TSO
 		| NETIF_F_TSO
-#endif
 		| NETIF_F_NO_CSUM
 		| NETIF_F_HIGHDMA
 		| NETIF_F_LLTX
