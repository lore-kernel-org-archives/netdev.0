From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [PATCH] ipv6: Check dest prefix length on original route not
 copied one in rt6_alloc_cow().
Date: Wed, 14 Dec 2011 08:16:02 +0800
Message-ID: <4EE7EAC2.2030600@intel.com>
References: <20111213.173551.163815101446083653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30669 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329Ab1LNAQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Dec 2011 19:16:04 -0500
In-Reply-To: <20111213.173551.163815101446083653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2011 06:35 AM, David Miller wrote:
> 
> After commit 8e2ec639173f325977818c45011ee176ef2b11f6 ("ipv6: don't
> use inetpeer to store metrics for routes.") the test in rt6_alloc_cow()
> for setting the ANYCAST flag is now wrong.
> 
> 'rt' will always now have a plen of 128, because it is set explicitly
> to 128 by ip6_rt_copy.
> 
> So to restore the semantics of the test, check the destination prefix
> length of 'ort'.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> 
> Committed to 'net'.
> 
>  net/ipv6/route.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 3399dd3..b582a0a 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -728,7 +728,7 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
>  		int attempts = !in_softirq();
>  
>  		if (!(rt->rt6i_flags&RTF_GATEWAY)) {
> -			if (rt->rt6i_dst.plen != 128 &&
> +			if (ort->rt6i_dst.plen != 128 &&
>  			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
>  				rt->rt6i_flags |= RTF_ANYCAST;
>  			ipv6_addr_copy(&rt->rt6i_gateway, daddr);

My fault, sorry!

Yan, Zheng
