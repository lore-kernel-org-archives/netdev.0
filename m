From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix crashes on RX path
Date: Tue, 26 Oct 2010 10:42:57 -0700 (PDT)
Message-ID: <20101026.104257.245396217.davem@davemloft.net>
References: <1287727917.9059.117.camel@edumazet-laptop>
	<20101022065231.GA7036@ff.dom.local>
	<20101022085248.GA8571@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, eminak71@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, avorontsov@mvista.com,
	afleming@freescale.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48153
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752527Ab0JZRme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:42:34 -0400
In-Reply-To: <20101022085248.GA8571@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 22 Oct 2010 08:52:48 +0000

> On Fri, Oct 22, 2010 at 06:52:31AM +0000, Jarek Poplawski wrote:
>> On Fri, Oct 22, 2010 at 08:11:57AM +0200, Eric Dumazet wrote:
> ...
>> > Gianfar claims to be multiqueue, but only one cpu can run gfar_poll()
>> > and call gfar_clean_tx_ring() / gfar_clean_rx_ring()
>> > 
>> > If not, there would be more bugs than only rx_recycle thing
>> 
>> I didn't find what prevents running gfar_poll on many cpus and don't
>> claim there is no more bugs around.
> 
> On the other hand, I don't see your point in the code below either.
> These're only per gfargrp queues - not per device, aren't they?

I am still not at the point where I feel confortable applying this bug
fix, in fact I am very far from that.

None of the logic is consistent in what we are saying causes the
problem.

Anything that would make the RX recycling code racy and corrupt
recycling queue of the gianfar driver, would also corrupt all of the
other RX side and other driver state.

The NAPI state is unary for gianfar, and inside of that singular
->poll() instance it iterates over the queues.

The only asynchronous path could be netpoll, but again that would
break lots of other things.

I want to be shown a code path that results in the recycle SKB
queue getting accessed in parallel on two cpus without protection
so we can understand what it is that we are fixing.

On another note, I also agree that removing this RX recycling crud
wouldn't be a bad idea.  In addition to the MTU changing concerns Eric
Dumazet brought up, there are many other (less broken) ways to achieve
whatever performance gains recycling gives these devices.

Thanks.

