From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 04 Aug 2006 00:02:53 +1000
Message-ID: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
References: <1154610922.5205.38.camel@jzny2>
Cc: jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:29963 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932482AbWHCODH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 10:03:07 -0400
To: hadi@cyberus.ca
In-Reply-To: <1154610922.5205.38.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> wrote:
> 
> There is no need for tx_locking if you are already netif stopped
> (transmit path will never be entered).
> With this change under high speed forwarding i see anywhere
> between 2-4Kpps improvement on a 2 CPU environment with twoo e1000s tied
> to different CPUs forwarding between each other. Actually the
> performance improvement should be attributed to the use of
> TX_WAKE_THRESHOLD - more drivers should use that technique.

Looks good to me.

Even if we get it wrong and wake up something that we shouldn't have,
the xmit function will simply bail out and stop the queue for us.

Since this is exceedingly unlikely we should drop the locks rather
than bother about it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
