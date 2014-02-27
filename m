From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 routing table max_size badly dimensioned compared to IPv4
Date: Thu, 27 Feb 2014 21:50:10 +0100
Message-ID: <20140227205010.GB27495@order.stressinduktion.org>
References: <20140227192403.GA13472@xs.powerdns.com> <1393531144.26794.24.camel@edumazet-glaptop2.roam.corp.google.com> <20140227200814.GA27495@order.stressinduktion.org> <1393532583.26794.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bert hubert <bert.hubert@netherlabs.nl>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57909 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbaB0UuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 15:50:12 -0500
Content-Disposition: inline
In-Reply-To: <1393532583.26794.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 27, 2014 at 12:23:03PM -0800, Eric Dumazet wrote:
> > > What kernel version do you use ?
> > > 
> > > I thought this was already solved.
> > > 
> > > Commit 957c665f37007de93ccbe45902a23143724170d0 is in linux 3.0
> > > ("ipv6: Don't put artificial limit on routing table size.")
> > 
> > The problem with DNS is that just for the DNS/UDP ping-pong we clone a
> > rt6_info and reinsert it back into the fib.
> > 
> > DST_NOCOUNT logic only ensures we can still insert new routes from user space
> > while the maximum number of routes is reached in the routing table. In case
> > the ipv6 fib is under heavy load it does not help with performance.
> > 
> > We might think about raising this limit a bit. Number of IPv6 routing entries
> > in global routing table already passed 4096. Maybe some heuristic which scales
> > this value according to available memory?
> 
> 
> Well, if we attach one dst per packet, it seems we already have a limit
> of number of packets on the host (qdisc limits + packets on TX ring
> buffers)
> 
> So DST_NOCOUNT should be used in this case. I thought David patch
> was already doing this.

We store those routes back into the routing table, so we must have a way to
count them and trigger gc at some point.

Greetings,

  Hannes
