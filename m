From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 16:41:15 +0100
Message-ID: <1345650075.2709.22.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	 <503437D4.8090706@zytor.com>
	 <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120821.193446.1534561579811962053.davem@davemloft.net>
	 <503450E2.2040504@zytor.com>
	 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
	 <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
	 <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>
	 <CA+55aFxoWLad9vtfAzQ7qXWcspL92D5s5+MFJ-HfyH3LVqfpaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27004 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757612Ab2HVPlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 11:41:19 -0400
In-Reply-To: <CA+55aFxoWLad9vtfAzQ7qXWcspL92D5s5+MFJ-HfyH3LVqfpaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 07:50 -0700, Linus Torvalds wrote:
> On Wed, Aug 22, 2012 at 7:24 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > Sorry, I'll paste it below.
> 
> The thing you pasted isn't actually the thing in the subject line.
> It's just you *using* it.
> 
> I wanted to see what that "writeo()" looks like for x86-64.
> 
> But I got google to find it for me by looking for "__raw_writeo", so I
> can see the patch now. It looks like it might work. Does it really
> help performance despite always doing those TS games in CR0 for each
> access?

I haven't run the experiment myself, but my colleagues observed a net
reduction of 100s of nanoseconds of latency.  That may not sound like
much, but for a small packet traversing an uncongested twinax link it's
around 5-10% of the total latency from the descriptor pointer write to
DMA completion on the peer.

Later, you wrote:
> Btw, are we even certain that a 128-bit PCIe write is going to remain
> atomic across a bus (ie over various PCIe bridges etc)?

I don't think PCIe bridges are allowed to split up TLPs (this is why the
PCI core has to be so careful about programming Max Payload Size).  What
happens between the processor core and the host bridge is another
matter, though.

> Do you you
> care? Is it just a "one transaction is cheaper than two", and it
> doesn't really have any ordering constraints? If the thing gets split
> into two 64-bit transactions (in whatever order) by a bridge on the
> way, would that be ok?

We care if the two transactions are not in ascending address order;
that's why we had to abandon write combining.

> We've seen buses split accesses before (ie 64-bit writes on 32-bit
> PCI).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
