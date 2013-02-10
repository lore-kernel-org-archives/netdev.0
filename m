From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Sun, 10 Feb 2013 19:49:18 +0100
Message-ID: <20130210184918.GB20897@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org> <20130209121005.GB23281@order.stressinduktion.org> <5116595E.2080601@linux-ipv6.org> <20130210153230.GA21377@order.stressinduktion.org> <5117EA2D.1020106@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55759 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843Ab3BJStU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 13:49:20 -0500
Content-Disposition: inline
In-Reply-To: <5117EA2D.1020106@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2013 at 03:42:53AM +0900, YOSHIFUJI Hideaki wrote:
> Hannes Frederic Sowa wrote:
> > I was looking at getpeername et. al. where we should report the scope
> > back to the user. A common pattern is:
> > 
> >                         if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> >                                 sin->sin6_scope_id = IP6CB(skb)->iif;
> > 
> > I propose to introduce something like 'bool ipv6_addr_intf_scoped(in6_addr)'
> > and let it check for ll addresses and interface scoped addresses.
> 
> Hmm, maybe, we might want to say:
> 
> __u32 __ipv6_iface_scope_id(int type, unsigned int iface)
> {
> 	if (type == IPV6_ADDR_ANY ||
> 	    type & IPV6_ADDR_LOOPBACK ||
> 	    __ipv6_addr_src_scope(type) > IPV6_ADDR_SCOPE_LINKLOCAL)
> 		return 0;
> 	return iface;
> }
> 
> __u32 ipv6_iface_scope_id(const struct in6_addr *addr, unsigned int iface)
> {
> 	return __ipv6_iface_scope_id(__ipv6_addr_type(addr), iface);
> }
> 
> And then,
> 	sin->sin6_scope_id = __ipv6_iface_scope_id(__ipv6_addr_type(&sin->sin6_addr),
> 						   IP6CB(skb)->iif);
> or
> 	sin->sin6_scope_id = ipv6_iface_scope_id(&sin->sin6_addr, IP6CB(skb)->iif);

I like it. Will try to convert some checks and let you know how it turned out.
