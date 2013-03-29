From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] net: frag queue per hash bucket locking
Date: Fri, 29 Mar 2013 15:22:59 -0400 (EDT)
Message-ID: <20130329.152259.696287122868561280.davem@davemloft.net>
References: <1364513982.15753.57.camel@edumazet-glaptop>
	<20130329003308.GD20223@order.stressinduktion.org>
	<1364583693.3232.257.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, fw@strlen.de, dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756255Ab3C2TXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:23:00 -0400
In-Reply-To: <1364583693.3232.257.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 29 Mar 2013 20:01:33 +0100

> On Fri, 2013-03-29 at 01:33 +0100, Hannes Frederic Sowa wrote:
>> On Thu, Mar 28, 2013 at 04:39:42PM -0700, Eric Dumazet wrote:
>> > On Fri, 2013-03-29 at 00:30 +0100, Hannes Frederic Sowa wrote:
>> > > On Thu, Mar 28, 2013 at 01:22:44PM -0700, Eric Dumazet wrote:
>> > > > On Thu, 2013-03-28 at 19:57 +0100, Hannes Frederic Sowa wrote:
>> > > > 
>> > > > > I assume that it has to do with the usage of this code in
>> > > > > ipv6/netfilter/nf_conntrack_reasm.c, which could be invoked from process
>> > > > > context, if I read it correctly.
>> > > > 
>> > > > Then there would be a possible deadlock in current code.
>> > > 
>> > > Netfilter currently does a local_bh_disable() before entering inet_fragment
>> > > (and later enables it, again).
>> > > 
>> > 
>> > Good, so no need for the _bh() as I suspected.
>> 
>> Ack.
>> 
>> I replaced the _bh spin_locks with plain spinlocks and tested the code
>> with sending fragments and receiving fragments (netfilter and reassmbly
>> logic) with lockdep and didn't get any splats. Looks good so far.
> 
> Well, it's great to see, that you are working on solving my patch
> proposal.  While I'm on Easter vacation ;-)  Much appreciated.
> I'm officially back from vacation Tuesday, and I'll repost then (after
> testing it on my 10G testlab).

Jesper, when you do this, please just put the whole of the excellent
description text you had in the "0/3" posting from this series into
the commit message for the respun patch #3.

Thanks.
