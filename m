From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: del unreachable route when an addr is deleted
 on lo
Date: Mon, 01 Oct 2012 16:49:53 -0400 (EDT)
Message-ID: <20121001.164953.2102483401886708943.davem@davemloft.net>
References: <1348580631.26828.3047.camel@edumazet-glaptop>
	<1348653895-4027-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756092Ab2JAUtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 16:49:55 -0400
In-Reply-To: <1348653895-4027-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 26 Sep 2012 12:04:55 +0200

> When an address is added on loopback (ip -6 a a 2002::1/128 dev lo), two routes
> are added:
>  - one in the local table:
>     local 2002::1 via :: dev lo  proto none  metric 0
>  - one the in main table (for the prefix):
>     unreachable 2002::1 dev lo  proto kernel  metric 256  error -101
> 
> When the address is deleted, the route inserted in the main table remains
> because we use rt6_lookup(), which returns NULL when dst->error is set, which
> is the case here! Thus, it is better to use ip6_route_lookup() to avoid this
> kind of filter.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> v2: rt cannot be NULL, so adjust the test after ip6_route_lookup()

Applied, thanks.
