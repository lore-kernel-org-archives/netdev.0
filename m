From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit to upper layer
Date: Thu, 12 Mar 2009 15:34:27 +0100
Message-ID: <20090312143427.GJ11935@one.firstfloor.org>
References: <1236761624.2567.442.camel@ymzhang> <877i2wfh1l.fsf@basil.nowhere.org> <1236845792.2567.484.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49690 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355AbZCLOO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 10:14:57 -0400
Content-Disposition: inline
In-Reply-To: <1236845792.2567.484.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 04:16:32PM +0800, Zhang, Yanmin wrote:
> 
> > Seems very inconvenient to have to configure this by hand.
> A little, but not too much, especially when we consider there is interrupt binding.

Interrupt binding is something popular for benchmarks, but most users
don't (and shouldn't need to) care. Having it work well out of the box
without special configuration is very important.

> 
> >  How about
> > auto selecting one that shares the same LLC or somesuch?
> There are 2 kinds of LLC sharing here.
> 1) RX/TX share the LLC;
> 2) All RX share the LLC of some cpus and TX share the LLC of other cpus.
> 
> Item 1) is important, but sometimes item 2) is also important when the sending speed is
> very high and huge data is on flight which flushes cpu cache quickly.
> It's hard to distinguish the 2 different scenarioes automatically.

Why is it hard if you know the CPUs?

> >  and just use the hash function on the
> > NIC.
> Sorry. I can't understand what the hash function of NIC is. Perhaps NIC hardware has something
> like hash function to decide the RX queue number based on SRC/DST?

There's a Microsoft spec for a standard hash function that does this
on NICs and all the serious ones support it these days. The hash 
is normally used to select a MSI-X target based on the input header.

I think if that works your manual target shouldn't be necessary.

> >  The trick here would
> > be to try to avoid reordering inside streams as far as possible,
> It's not to solve reorder issue. The start point is 10G NIC is very fast. We need some cpu

Point was that any solution shouldn't add more reordering. But when a RSS
hash is used there is no reordering on stream basis.

-Andi 

-- 
ak@linux.intel.com -- Speaking for myself only.
