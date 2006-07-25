From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 11:42:30 +0400
Message-ID: <20060725074226.GA16682@2ka.mipt.ru>
References: <20060725055127.GA5103@2ka.mipt.ru> <20060724.234853.112197982.davem@davemloft.net> <20060725065921.GB30561@2ka.mipt.ru> <20060725.003344.125313848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: rdreier@cisco.com, ak@suse.de, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:7308 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751454AbWGYHqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 03:46:50 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060725.003344.125313848.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 25, 2006 at 12:33:44AM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Tue, 25 Jul 2006 10:59:21 +0400
> 
> > As a side completely unrelated to either my or others work note :) - 
> > I think it is a nanooptimisation - we get a bit of performance here, 
> > and lose those bit in other place.
> > When bag is filled, there is no much sence of rearranging some stuff
> > inside to be able to place another one - it is better to buy new bag.
> 
> It is a matter of what the viewpoint is, I suppose.

Definitely.

> I think in this specific case it might turn out to be
> better for the scheduler to respond to what the device
> throws at it, rather than the other way around.  And
> in that case we need no feedback from scheduler to
> cpu demux engine.

That's exactly one bit lose/gain - if CPU is loafing - we get a gain,
and lose otherwise - so instead of generally predictible steady behaviour 
we can end up with bursty shapes.

Actually without real tests all it is just a handwaving, so let's see when
modern NICs get that capability, so network softirq scheduling would be 
changed accordingly.

-- 
	Evgeniy Polyakov
