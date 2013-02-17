From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 1/4] ipv6: introduce new type ipv6_addr_props to hold ipv6 address type and scope
Date: Sun, 17 Feb 2013 02:47:18 +0100
Message-ID: <20130217014718.GA28547@order.stressinduktion.org>
References: <20130216191008.GA23272@order.stressinduktion.org> <512013B8.3000608@linux-ipv6.org> <512016E8.30305@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, brian.haley@hp.com
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39727 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791Ab3BQBrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 20:47:19 -0500
Content-Disposition: inline
In-Reply-To: <512016E8.30305@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 17, 2013 at 08:31:52AM +0900, YOSHIFUJI Hideaki wrote:
> >> -extern int __ipv6_addr_type(const struct in6_addr *addr);
> >> -static inline int ipv6_addr_type(const struct in6_addr *addr)
> >> +struct ipv6_addr_props {
> >> +	u16 type;
> >> +	s16 scope;
> >> +};
> >> +
> >> +extern struct ipv6_addr_props __ipv6_addr_props(const struct in6_addr *addr);
> >> +static inline unsigned int ipv6_addr_type(const struct in6_addr *addr)
> >>  {
> >> -	return __ipv6_addr_type(addr) & 0xffff;
> >> +	return __ipv6_addr_props(addr).type;
> >>  }
> >>  
> >>  static inline int ipv6_addr_scope(const struct in6_addr *addr)
> >>  {
> >> -	return __ipv6_addr_type(addr) & IPV6_ADDR_SCOPE_MASK;
> >> +	return __ipv6_addr_props(addr).scope;
> >>  }
> >>  
> > 
> > NAK.  This does not return correct value as before.
> > If you are going to covert this, please do not try to
> > change usage of inlines.  
> 
> I meant
> 
> struct ipv6_addrtype {
> 	__u16 type;
> 	__s16 scope;
> };
> 
> struct ipv6_addrtype __ipv6_addr_type(const struct in6_addr *addr);
> int ipv6_addr_type(const struct in6_addr *addr)
> {
> 	return __ipv6_addr_type(addr).type;
> }
> 
> And most users should not be touched except for it type name
> (int => struct addrtype).

Sorry, I am a bit confused. The missing '& IPV6_ADDR_SCOPE_MASK' is clearly a
bug. I implied a bitmask for the IPV6_ADDR_SCOPE_* macros. But I don't
understand to what you do refer in your second mail.
