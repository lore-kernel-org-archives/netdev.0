From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPROUTE]: Add support for multipath route realms
Date: Tue, 25 Jul 2006 10:21:45 +0200
Message-ID: <44C5D499.9050809@trash.net>
References: <E1G5I8b-00063u-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62134 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932148AbWGYIVs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 04:21:48 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G5I8b-00063u-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>[IPROUTE]: Add support for multipath route realms
>>
>>Routing realms exist per nexthop, but iproute currently only allows to send
>>a single route realm, which is refused by the kernel for multipath routes.
>>Add support for specifying per nexthop realms. Old kernels only return the
>>first realm back to userspace when dumping, so the others can't be displayed,
>>besides that it will also behave correctly on old kernels.
>>
>>old kernel:
>>
>>1.2.3.4 realm 1
>>       nexthop dev dummy0 weight 1
>>       nexthop dev dummy1 weight 1
>>       nexthop dev dummy2 weight 1
>>       nexthop dev dummy3 weight 1
>>
>>new kernel:
>>
>>1.2.3.4
>>       nexthop realm 1 dev dummy0 weight 1
>>       nexthop realm 2 dev dummy1 weight 1
>>       nexthop realm 3 dev dummy2 weight 1
>>       nexthop realm 4 dev dummy3 weight 1
> 
> 
> This really looks like papering over fundamental brokenness of
> IP_ROUTE_MULTIPATH_CACHED since you wouldn't otherwise get these
> entries in the routing cache.
> 
> This reminds me that I better revisit the reasons that people gave
> for actually using IP_ROUTE_MULTIPATH_CACHED the last time we tried
> to get rid of it.


Actually it has nothing to do with MULTIPATH_CACHED, it didn't even
use it in these tests unless I seriously mixed something up. The
realm can be used by netfilter to find out which nexthop was chosen
and bind the connection to this nexthop manually using CONNMARK
and MARK.

