From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux kernel patch: elide fib_validate_source() completely when possible - bad side effect?
Date: Thu, 23 Jan 2014 15:20:58 +0100
Message-ID: <20140123142058.GK7269@order.stressinduktion.org>
References: <52DCF1440200005D000477FD@gwia2.atlnz.lc> <alpine.LFD.2.11.1401222222010.1855@ja.home.ssi.bg> <20140123020224.GG7269@order.stressinduktion.org> <20140122.185305.1125981867482223830.davem@davemloft.net> <20140123030329.GI7269@order.stressinduktion.org> <alpine.LFD.2.11.1401231056530.2682@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	gregory.hoggarth@alliedtelesis.co.nz, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60479 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095AbaAWOU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 09:20:59 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1401231056530.2682@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian,

On Thu, Jan 23, 2014 at 11:47:33AM +0200, Julian Anastasov wrote:
> On Thu, 23 Jan 2014, Hannes Frederic Sowa wrote:
> 
> > E.g. we register all local registered broadcast addresses in a structure
> > like inet_addr_lst so we only need to check if the packet would leave
> > this host with a broadcast hardware address. If the packet is forwarded
> > the router must do the same check as only it knows the local broadcast
> > addresses. I hope this is correct. ;)
> 
> 	Now when we can override the local table with ip
> rules or to prepend route in local table, we can not be
> sure that the broadcast routes are returned in all cases,
> users can add unicast routes for such addresses.
> 
> 	I don't remember for useful case where one may need to
> override broadcast routes but adding such exceptions looks
> risky.

The check I envisioned would only actually block the ifa_broadcast of only the
incoming interface as source address. So we wouldn't depend on the view of the
routing tables at all.

But I have no strong opinion on that.

Greetings,

  Hannes
