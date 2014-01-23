From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux kernel patch: elide fib_validate_source() completely when possible - bad side effect?
Date: Thu, 23 Jan 2014 04:03:29 +0100
Message-ID: <20140123030329.GI7269@order.stressinduktion.org>
References: <52DCF1440200005D000477FD@gwia2.atlnz.lc> <alpine.LFD.2.11.1401222222010.1855@ja.home.ssi.bg> <20140123020224.GG7269@order.stressinduktion.org> <20140122.185305.1125981867482223830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: ja@ssi.bg, gregory.hoggarth@alliedtelesis.co.nz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59435 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbaAWDDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 22:03:31 -0500
Content-Disposition: inline
In-Reply-To: <20140122.185305.1125981867482223830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 06:53:05PM -0800, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 23 Jan 2014 03:02:24 +0100
> 
> > On Wed, Jan 22, 2014 at 11:04:52PM +0200, Julian Anastasov wrote:
> >> 	I don't remember someone mentioning about such
> >> side-effect, I guess it is overlooked. IMHO, it is not a good
> >> reason to restore the old behavior. Lets see other opinions.
> > 
> > A routing lookup to check for broadcast is much too expansive, I agree. But
> > can't we just check skb->pkt_type == PACKET_BROADCAST?
> 
> We can't universally know what a broadcast is, because the prefix of
> every network is a local piece of information.
> 
> We might not have the route necessary to know the source address is
> a broadcast if the packet came through more than 1 hop already.

But in this case we only need those local pieces.

E.g. we register all local registered broadcast addresses in a structure
like inet_addr_lst so we only need to check if the packet would leave
this host with a broadcast hardware address. If the packet is forwarded
the router must do the same check as only it knows the local broadcast
addresses. I hope this is correct. ;)
