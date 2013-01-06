From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 03:32:06 +0100
Message-ID: <20130106023206.GX16031@1wt.eu>
References: <20130105232913.GQ16031@1wt.eu> <1357430523.1678.4901.camel@edumazet-glaptop> <20130106005053.GS16031@1wt.eu> <1357435276.1678.5067.camel@edumazet-glaptop> <20130106013027.GV16031@1wt.eu> <1357436430.1678.5111.camel@edumazet-glaptop> <1357437086.1678.5135.camel@edumazet-glaptop> <1357438591.1678.5205.camel@edumazet-glaptop> <20130106021824.GW16031@1wt.eu> <1357438933.1678.5223.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:37521 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755300Ab3AFCcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2013 21:32:12 -0500
Content-Disposition: inline
In-Reply-To: <1357438933.1678.5223.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 05, 2013 at 06:22:13PM -0800, Eric Dumazet wrote:
> On Sun, 2013-01-06 at 03:18 +0100, Willy Tarreau wrote:
> > On Sat, Jan 05, 2013 at 06:16:31PM -0800, Eric Dumazet wrote:
> > > On Sat, 2013-01-05 at 17:51 -0800, Eric Dumazet wrote:
> > > > On Sat, 2013-01-05 at 17:40 -0800, Eric Dumazet wrote:
> > > > > On Sun, 2013-01-06 at 02:30 +0100, Willy Tarreau wrote:
> > > > > 
> > > > > > Ah interesting because these were some of the mm patches that I had
> > > > > > tried to revert.
> > > > > 
> > > > > Hmm, or we should fix __skb_splice_bits()
> > > > > 
> > > > > I'll send a patch.
> > > > > 
> > > > 
> > > > Could you try the following ?
> > > 
> > > Or more exactly...
> > 
> > The first one did not change a iota unfortunately. I'm about to
> > spot the commit causing the loopback regression. It's a few patches
> > before the first one you pointed. It's almost finished and I test
> > your patch below immediately after.
> 
> I bet you are going to find commit
> 69b08f62e17439ee3d436faf0b9a7ca6fffb78db
> (net: use bigger pages in __netdev_alloc_frag )
> 
> Am I wrong ?

Yes this time you guessed wrong :-) Well maybe it's participating
to the issue.

It's 0cf833ae (net: loopback: set default mtu to 64K). And I could
reproduce it with 3.6 by setting loopback's MTU to 65536 by hand.
The trick is that once the MTU has been set to this large a value,
even when I set it back to 16kB the problem persists.

Now I'm retrying your other patch to see if it brings the 10GE back
to full speed.

Willy
