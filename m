From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Ensure IF_READY is unset when link is not ready
Date: Thu, 08 Mar 2007 10:47:56 +1100
Message-ID: <E1HP5rQ-0008RW-00@gondolin.me.apana.org.au>
References: <20070305175924.2f46446c.mitch@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: mitch@linux.vnet.ibm.com (Mitsuru Chinen), davem@davemloft.net,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2456 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750791AbXCGXsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 18:48:22 -0500
In-Reply-To: <20070305175924.2f46446c.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitsuru Chinen <mitch@linux.vnet.ibm.com> wrote:
> 
> On linux-2.6.21-rc2 or later, IPv6 link-local address is not assigned to
> some kind of interfaces during system start-up. (I found this issue
> occures with e100, e1000 and tg3.)

Here is an alternative fix.

[IPV6]: Do not set IF_READY if device is down

Now that we add the IPv6 device at registration time we don't need
to set IF_READY in ipv6_add_dev anymore because we will always get
a NETDEV_UP event later on should the device ever become ready.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e16f1bb..a7fee6b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -342,10 +342,6 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	}
 #endif
 
-	if (netif_carrier_ok(dev))
-		ndev->if_flags |= IF_READY;
-
-
 	ipv6_mc_init_dev(ndev);
 	ndev->tstamp = jiffies;
 #ifdef CONFIG_SYSCTL
