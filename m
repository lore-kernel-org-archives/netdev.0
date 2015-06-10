From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net v2] bridge: fix multicast router rlist endless loop
Date: Wed, 10 Jun 2015 10:22:31 +0800
Message-ID: <20150610022231.GA32260@gondor.apana.org.au>
References: <1433842349-28089-1-git-send-email-nikolay@cumulusnetworks.com>
 <1433870637-15844-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org,
	Nikolay Aleksandrov <razor@blackwall.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:50740 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbbFJCWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 22:22:37 -0400
Content-Disposition: inline
In-Reply-To: <1433870637-15844-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2015 at 10:23:57AM -0700, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <razor@blackwall.org>
> 
> Since the addition of sysfs multicast router support if one set
> multicast_router to "2" more than once, then the port would be added to
> the hlist every time and could end up linking to itself and thus causing an
> endless loop for rlist walkers.
> So to reproduce just do:
> echo 2 > multicast_router; echo 2 > multicast_router;
> in a bridge port and let some igmp traffic flow, for me it hangs up
> in br_multicast_flood().
> Fix this by adding a check in br_multicast_add_router() if the port is
> already linked.
> The reason this didn't happen before the addition of multicast_router
> sysfs entries is because there's a !hlist_unhashed check that prevents
> it.
> 
> Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
> Fixes: 0909e11758bd ("bridge: Add multicast_router sysfs entries")

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
