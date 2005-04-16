From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4482] New: natsemi: incorrect initialization of IPv6 Neighbor-discovery multicast
Date: Sat, 16 Apr 2005 16:24:16 +1000
Message-ID: <20050416062416.GA29177@gondor.apana.org.au>
References: <20050413103642.172d3976.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PEIAKu/WMn1b1Hv9"
Cc: netdev@oss.sgi.com, svallet@gmail.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050413103642.172d3976.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 13, 2005 at 05:36:42PM +0000, Andrew Morton wrote:
> 
>            Summary: natsemi: incorrect initialization of IPv6 Neighbor-
>                     discovery multicast

I've got a pair of FA312 cards and this problem has bothered me
for ages.  This has finally prompted me to do something about it :)

Turns out that somebody wasn't following the documentation.  We were
doing 16-bit writes to 32-bit registers which led to some addresses
working and others not so lucky.

This patch should fix the problem.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=natsemi-1

===== drivers/net/natsemi.c 1.74 vs edited =====
--- 1.74/drivers/net/natsemi.c	2005-03-03 16:00:42 +11:00
+++ edited/drivers/net/natsemi.c	2005-04-16 16:20:29 +10:00
@@ -2433,9 +2433,9 @@
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptMulticast | AcceptMyPhys;
 		for (i = 0; i < 64; i += 2) {
-			writew(HASH_TABLE + i, ioaddr + RxFilterAddr);
-			writew((mc_filter[i+1]<<8) + mc_filter[i],
-				ioaddr + RxFilterData);
+			writel(HASH_TABLE + i, ioaddr + RxFilterAddr);
+			writel((mc_filter[i + 1] << 8) + mc_filter[i],
+			       ioaddr + RxFilterData);
 		}
 	}
 	writel(rx_mode, ioaddr + RxFilterAddr);

--PEIAKu/WMn1b1Hv9--
