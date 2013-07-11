From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] ipv6: only static routes qualify for equal cost multipathing
Date: Thu, 11 Jul 2013 22:02:06 +0200
Message-ID: <20130711200206.GA12611@order.stressinduktion.org>
References: <20130711170231.GA11078@order.stressinduktion.org> <20130711.114419.1045272869172136221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:40029 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756506Ab3GKUCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 16:02:07 -0400
Content-Disposition: inline
In-Reply-To: <20130711.114419.1045272869172136221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 11, 2013 at 11:44:19AM -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 11 Jul 2013 19:02:31 +0200
> 
> > +	for (rt = rt0; rt && !(rt->rt6i_flags & RTF_EXPIRES);
> > +	     rt = (struct rt6_info *)rt->dst.from);
> > +	return !(rt && (rt->rt6i_flags & RTF_EXPIRES));
> 
> Please make this logic clearer, something like:
> 
> 
> 	for (rt = rt0; rt; rt = (struct rt6_info *)rt->dst.from) {
> 		if (rt->rt6i_flags & RTF_EXPIRES)
> 			return false;
> 	}
> 	return true;

Ok, I'll revisit this. The reason for this loop (which was taken from
rt6_update_expires) is, that it was only valid to dereference dst.from if
RTF_EXPIRES was not set (before commit ecd9883 ("ipv6: fix race condition
regarding dst->expires and dst->from") dst.from and dst.expires were a
union). I tried to keep this (possible) invariant.

I'll check if this is still needed.

Greetings,

  Hannes
