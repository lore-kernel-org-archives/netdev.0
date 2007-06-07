From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.22-rc4-mm2: Assigning IP address fails
Date: Fri, 8 Jun 2007 08:54:52 +1000
Message-ID: <20070607225452.GA17211@gondor.apana.org.au>
References: <20070606220313.8f7c1fab.akpm@linux-foundation.org> <20070607214609.GB8204@nineveh.local> <20070607150653.b83bfc0f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joseph Fannin <jfannin@gmail.com>, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4495 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933414AbXFGWzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:55:47 -0400
Content-Disposition: inline
In-Reply-To: <20070607150653.b83bfc0f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 07, 2007 at 03:06:53PM -0700, Andrew Morton wrote:
>
> >     I'm not able to bring an ethernet interface down and back up again
> > with this if avahi-autoipd is installed on my Ubuntu boxes.  I've seen
> > it on three different computers with different NIC hardware.

Sorry, it was my patch.  This patch should fix it.

[IPV4]: Do not remove idev when addresses are cleared

Now that we create idev before addresses are added, it no longer makes
sense to remove them when addresses are all deleted.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
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
