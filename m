From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 3/3] net: frag queue per hash bucket locking
Date: Fri, 29 Mar 2013 20:01:33 +0100
Message-ID: <1364583693.3232.257.camel@localhost>
References: <20130327155238.15203.6688.stgit@dragon>
	 <20130327155601.15203.25289.stgit@dragon>
	 <1364405159.15753.26.camel@edumazet-glaptop>
	 <20130328185721.GA20223@order.stressinduktion.org>
	 <1364502164.15753.56.camel@edumazet-glaptop>
	 <20130328233002.GC20223@order.stressinduktion.org>
	 <1364513982.15753.57.camel@edumazet-glaptop>
	 <20130329003308.GD20223@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754251Ab3C2TBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Mar 2013 15:01:44 -0400
In-Reply-To: <20130329003308.GD20223@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-29 at 01:33 +0100, Hannes Frederic Sowa wrote:
> On Thu, Mar 28, 2013 at 04:39:42PM -0700, Eric Dumazet wrote:
> > On Fri, 2013-03-29 at 00:30 +0100, Hannes Frederic Sowa wrote:
> > > On Thu, Mar 28, 2013 at 01:22:44PM -0700, Eric Dumazet wrote:
> > > > On Thu, 2013-03-28 at 19:57 +0100, Hannes Frederic Sowa wrote:
> > > > 
> > > > > I assume that it has to do with the usage of this code in
> > > > > ipv6/netfilter/nf_conntrack_reasm.c, which could be invoked from process
> > > > > context, if I read it correctly.
> > > > 
> > > > Then there would be a possible deadlock in current code.
> > > 
> > > Netfilter currently does a local_bh_disable() before entering inet_fragment
> > > (and later enables it, again).
> > > 
> > 
> > Good, so no need for the _bh() as I suspected.
> 
> Ack.
> 
> I replaced the _bh spin_locks with plain spinlocks and tested the code
> with sending fragments and receiving fragments (netfilter and reassmbly
> logic) with lockdep and didn't get any splats. Looks good so far.

Well, it's great to see, that you are working on solving my patch
proposal.  While I'm on Easter vacation ;-)  Much appreciated.
I'm officially back from vacation Tuesday, and I'll repost then (after
testing it on my 10G testlab).

--Jesper
