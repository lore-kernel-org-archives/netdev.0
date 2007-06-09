From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: networking busted in current -git ???
Date: Sat, 09 Jun 2007 11:16:14 +1000
Message-ID: <E1HwpYs-0008HD-00@gondolin.me.apana.org.au>
References: <1181339007.6675.12.camel@heimdal.trondhjem.org>
Cc: arekm@maven.pl, florin@iucha.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: trond.myklebust@fys.uio.no (Trond Myklebust)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3381 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750795AbXFIBRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 21:17:16 -0400
In-Reply-To: <1181339007.6675.12.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> It appears to be something in the latest dump from davem to Linus, but I
> haven't yet had time to identify what.

You want this patch which should hit the tree soon.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
[IPV4]: Do not remove idev when addresses are cleared

Now that we create idev before addresses are added, it no longer makes
sense to remove them when addresses are all deleted.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 354e800..0cf813f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -327,12 +327,8 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 		}
 
 	}
-	if (destroy) {
+	if (destroy)
 		inet_free_ifa(ifa1);
-
-		if (!in_dev->ifa_list)
-			inetdev_destroy(in_dev);
-	}
 }
 
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
