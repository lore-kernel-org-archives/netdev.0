From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netns: timer allocation
Date: Mon, 21 Jul 2008 16:28:14 -0700 (PDT)
Message-ID: <20080721.162814.38681521.davem@davemloft.net>
References: <20080721134426.6769f40c@extreme>
	<20080721.134739.262598027.davem@davemloft.net>
	<20080721140751.4796d6c5@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753118AbYGUX2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 19:28:14 -0400
In-Reply-To: <20080721140751.4796d6c5@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Jul 2008 14:07:51 -0700

> FIB timer list is a trivial size structure, avoid indirection and just
> put it in existing ns.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Sigh.. part 1 patch was not refreshed.

Sigh, really, 3 times?

+ git apply --check --whitespace=error-all diff
error: patch failed: net/ipv6/ip6_fib.c:661
error: net/ipv6/ip6_fib.c: patch does not apply

Would it kill you to just clone out a fresh net-2.6 tree and actually
try to apply the patch before sending it to me?

You're asking me to do that 3+ times.  So you can do it once, right?
:)

> --- a/net/ipv6/ip6_fib.c	2008-07-21 14:06:22.000000000 -0700
> +++ b/net/ipv6/ip6_fib.c	2008-07-21 14:06:32.000000000 -0700
> @@ -661,16 +661,16 @@ static int fib6_add_rt2node(struct fib6_
>  
>  static __inline__ void fib6_start_gc(struct net *net, struct rt6_info *rt)
>  {
> -	if (!timer_pending(net->ipv6.ip6_fib_timer) &&
> +	if (!timer_pending(&net->ipv6.ip6_fib_timer) &&
>  	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
> -		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
> +		mod_timer(&net->ipv6.ip6_fib_timer, jiffies +
>  			  net->ipv6.sysctl.ip6_rt_gc_interval);
>  }
>  

In net-2.6 those mod_timer() lines read:

		mod_timer(net->ipv6.ip6_fib_timer,
			  jiffies + net->ipv6.sysctl.ip6_rt_gc_interval);

the jiffies starts on the second line, not the first.

Something is seriously wrong with whatever tree you're generating
these patches against.
