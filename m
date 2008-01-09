From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: SACK scoreboard
Date: Wed, 9 Jan 2008 12:47:26 +0300
Message-ID: <20080109094725.GA22140@2ka.mipt.ru>
References: <4783AA29.3080406@psc.edu> <20080108.144456.173014334.davem@davemloft.net> <p73sl17pwfy.fsf@bingen.suse.de> <20080108.223925.105105455.davem@davemloft.net> <20080109070318.GA8581@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jheffner@psc.edu,
	ilpo.jarvinen@helsinki.fi, lachlan.andrew@gmail.com,
	netdev@vger.kernel.org, quetchen@caltech.edu
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51412 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbYAIJsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 04:48:03 -0500
Content-Disposition: inline
In-Reply-To: <20080109070318.GA8581@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Wed, Jan 09, 2008 at 08:03:18AM +0100, Andi Kleen (andi@firstfloor.org) wrote:
> > It adds severe spikes in CPU utilization that are even moderate
> > line rates begins to affect RTTs.
> > 
> > Or do you think it's OK to process 500,000 SKBs while locked
> > in a software interrupt.
> 
> You can always push it into a work queue.  Even put it to
> other cores if you want. 
> 
> In fact this is already done partly for the ->completion_queue.
> Wouldn't be a big change to queue it another level down.
> 
> Also even freeing a lot of objects doesn't have to be
> that expensive. I suspect the most cost is in taking
> the slab locks, but that could be batched. Without
> that the kmem_free fast path isn't particularly
> expensive, as long as the headers are still in cache.

Postponing freeing of the skb has major drawbacks. Some time ago I
made a patch to postpone skb freeing behind rcu and got 2.5 times slower
connection speed on some machines with decreased CPU usage though.
So, queueing solution has to be proven with real data and although it
looks good in one situation, it can be really bad in another.

For interested reader: results of the RCUfication of the kfree_skbmem()
http://tservice.net.ru/~s0mbre/blog/devel/networking/2006/12/05

-- 
	Evgeniy Polyakov
