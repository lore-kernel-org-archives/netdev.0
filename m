From: David Miller <davem@davemloft.net>
Subject: Re: SACK scoreboard
Date: Tue, 08 Jan 2008 23:16:18 -0800 (PST)
Message-ID: <20080108.231618.133599422.davem@davemloft.net>
References: <p73sl17pwfy.fsf@bingen.suse.de>
	<20080108.223925.105105455.davem@davemloft.net>
	<20080109070318.GA8581@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ilpo.jarvinen@helsinki.fi,
	lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751128AbYAIHQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:16:19 -0500
In-Reply-To: <20080109070318.GA8581@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 9 Jan 2008 08:03:18 +0100

> Also even freeing a lot of objects doesn't have to be
> that expensive.  I suspect the most cost is in taking
> the slab locks, but that could be batched.

We're touching SKB struct members, doing atomics on them, etc. for
objects we haven't referenced for at least two RTTs so are guarenteed
to be cache cold.

Let's say best case we can get it down to 2 cache line misses, and as
a very aggressive goal we can get the cost down to 100 cycles.  For
500,000 packets this is 500 million cpu cycles to free them all up.

That's 1/4 of a second even on a 2 GHZ cpu.

And yes there are inherent costs in handling TCP windows that are
500,000 packets in size.  But, that freeing cost should be spread
throughout the handling of the RTT feedback, not handled all at once.

> Your hand waved numbers on inline sizes there were definitely worse 
> than mine. 

Your primary objective seems to be "being right", and that's fine but
realize that it makes discussing anything with you about as fun as
picking one's toe nails with an ice axe.

Eventually you will be ignored by most folks who get fed up by this
style of argument.

So, have fun being right rather than being pleasant to work with.
