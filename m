From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 10/13] bridge: Add multicast_router sysfs entries
Date: Tue, 9 Mar 2010 20:26:13 +0800
Message-ID: <20100309122613.GA12453@gondor.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au> <E1Nl2Dj-0006wU-LU@gondolin.me.apana.org.au> <20100226164211.1a02a31b@nehalam> <20100309122526.GA12403@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39810 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750934Ab0CIM0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 07:26:17 -0500
Content-Disposition: inline
In-Reply-To: <20100309122526.GA12403@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 09, 2010 at 08:25:26PM +0800, Herbert Xu wrote:
> 
> commit 0eff6a003b34eec7f7216a8cd93cb545e25196b1
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Tue Mar 9 20:21:20 2010 +0800
> 
>     bridge-utils: Add IGMP snooping support

And you need this patch on top to make setting values work:

commit de7d2ed12184b629511f8a5dfceb50cf1f73d52d
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue Mar 9 20:23:00 2010 +0800

    bridge-utils: Fix sysfs path in br_set
    
    The sysfs path was missing the "bridge" component.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/libbridge/libbridge_devif.c b/libbridge/libbridge_devif.c
index 180c2f9..126027f 100644
--- a/libbridge/libbridge_devif.c
+++ b/libbridge/libbridge_devif.c
@@ -311,7 +311,8 @@ int br_set(const char *bridge, const char *name,
 	char path[SYSFS_PATH_MAX];
 	FILE *f;
 
-	snprintf(path, SYSFS_PATH_MAX, SYSFS_CLASS_NET "%s/%s", bridge, name);
+	snprintf(path, SYSFS_PATH_MAX, SYSFS_CLASS_NET "%s/bridge/%s", bridge,
+		 name);
 
 	f = fopen(path, "w");
 	if (f) {

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
