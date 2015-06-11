From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bridge: fix multicast router rlist endless loop
Date: Wed, 10 Jun 2015 22:08:47 -0700 (PDT)
Message-ID: <20150610.220847.2245026709731181581.davem@davemloft.net>
References: <1433842349-28089-1-git-send-email-nikolay@cumulusnetworks.com>
	<1433870637-15844-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	herbert@gondor.apana.org.au, razor@blackwall.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbbFKFIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 01:08:48 -0400
In-Reply-To: <1433870637-15844-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue,  9 Jun 2015 10:23:57 -0700

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
> ---
> v2: implement Herbert's suggestion and add the check to
>     br_multicast_add_router instead of changing the sysfs caller.

Applied and queued up for -stable, thanks.
