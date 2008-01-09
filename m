From: Andi Kleen <andi@firstfloor.org>
Subject: Re: SACK scoreboard
Date: Wed, 9 Jan 2008 08:03:18 +0100
Message-ID: <20080109070318.GA8581@one.firstfloor.org>
References: <4783AA29.3080406@psc.edu> <20080108.144456.173014334.davem@davemloft.net> <p73sl17pwfy.fsf@bingen.suse.de> <20080108.223925.105105455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, jheffner@psc.edu, ilpo.jarvinen@helsinki.fi,
	lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50606 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbYAIHAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:00:49 -0500
Content-Disposition: inline
In-Reply-To: <20080108.223925.105105455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It adds severe spikes in CPU utilization that are even moderate
> line rates begins to affect RTTs.
> 
> Or do you think it's OK to process 500,000 SKBs while locked
> in a software interrupt.

You can always push it into a work queue.  Even put it to
other cores if you want. 

In fact this is already done partly for the ->completion_queue.
Wouldn't be a big change to queue it another level down.

Also even freeing a lot of objects doesn't have to be
that expensive. I suspect the most cost is in taking
the slab locks, but that could be batched. Without
that the kmem_free fast path isn't particularly
expensive, as long as the headers are still in cache.

Long ago I had sk_buff optimized for the routing case so that freeing
can be all done with a single cache line. That is 
long gone, but could be probably restored.

But asking for protocol changes just to work around such a
internal implementation detail is ... <I miss words> 

> Perhaps you have another broken awk script to prove this :-)

Your hand waved numbers on inline sizes there were definitely worse 
than mine. 

-Andi

