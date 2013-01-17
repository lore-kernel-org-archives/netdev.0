From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv4: Remove output route check in ipv4_mtu
Date: Thu, 17 Jan 2013 07:31:00 +0100
Message-ID: <20130117063100.GF18940@secunet.com>
References: <20130116063645.GC18940@secunet.com>
 <alpine.LFD.2.00.1301160915030.1621@ja.ssi.bg>
 <20130116095909.GD18940@secunet.com>
 <alpine.LFD.2.00.1301162236320.1760@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	luky-37@hotmail.com, pupilla@libero.it, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53608 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927Ab3AQGbD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 01:31:03 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1301162236320.1760@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2013 at 11:01:39PM +0200, Julian Anastasov wrote:
> 
> On Wed, 16 Jan 2013, Steffen Klassert wrote:
> > 
> > Not absolutely sure what you want to do if the mtu is locked.
> > But if you don't want to genetate a nh exception and don't update
> > rt->rt_pmtu in this case, rt->rt_pmtu is never set on routes with
> > locked mtu. We probably would not need to change ipv4_mtu() to the
> > above variant.
> 
> 	Yes, we have to exit __ip_rt_update_pmtu if
> fib_mtu is locked. Then rt_pmtu should stay 0 and
> your variant of ipv4_mtu should be ok. I hope you
> can simply extend your patch with such additional
> check in __ip_rt_update_pmtu:
> 
> 	if (dst_metric_locked(dst, RTAX_MTU))
> 		return;
> 

That's what I had in mind. I'll do that with an additional
patch, it's a another issue.

Thanks for the input!
