From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 19:11:14 +0100
Message-ID: <1345659074.2709.80.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
	 <503437D4.8090706@zytor.com>
	 <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120821.193446.1534561579811962053.davem@davemloft.net>
	 <503450E2.2040504@zytor.com>
	 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>
	 <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
	 <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>
	 <20120822143054.GD9803@kvack.org>
	 <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com>
	 <5034F725.2090802@zytor.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
	 <1345650689.2709.32.camel@bwh-desktop.uk.solarflarecom.com>
	 <50350098.6030100@zytor.com>
	 <1345653844.2709.51.camel@bwh-desktop.uk.solarflarecom.com>
	 <CA+55aFxMD-Jn3fPgum7a+3EhNiWB-Mjv+1yamR7ELHwroA_+7Q@mail.gmail.com>
	 <1345655343.2709.56.camel@bwh-desktop.uk.solarflarecom.com>
	 <50351304.20608@zytor.com>
	 <1345656446.2709.65.camel@bwh-desktop.uk.solarflarecom.com>
	 <CA+55aFzcqhHU_+uR33=q+49jK97e=EofFF7g7Z0K1RU_PGwMTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	David Laight <David.Laight@aculab.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35610 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758439Ab2HVSLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 14:11:18 -0400
In-Reply-To: <CA+55aFzcqhHU_+uR33=q+49jK97e=EofFF7g7Z0K1RU_PGwMTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 10:54 -0700, Linus Torvalds wrote:
> On Wed, Aug 22, 2012 at 10:27 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > If this is right, how can it be safe to use readq/writeq at all?
> 
> Pray.
> 
> Or don't care about ordering: use hardware that is well-designed and
> doesn't have crap interfaces that are fragile.

Well the whole point of having the two 32-bit generic implementations is
that hardware may care about the order!  How can it be right that a
64-bit implementation assumes it doesn't?

> If you care about ordering, you need to do them as two separate
> accesses, and have a fence in between. Which, quite frankly, sounds
> like the right model for you *anyway*, since then you could use
> write-combining memory and you might even go faster, despite an
> explicit fence and thus a minimum of 2 transactions.

Yes, which unfortunately is no better than we have at the moment.

> Seriously. If you care that deeply about the ordering of the bytes you
> write out, MAKE THAT ORDERING VERY EXPLICIT IN THE SOURCE CODE. Don't
> say "oh, with this hack, I win 100ns". You need to ask yourself: what
> do you care about more? Going really fast on some machine that you can
> test, or being safe?

I have to care quite a lot about both. :-)  But yes, safety first.

> With PCIe, it's *probably* fine to just say "we expect 64-bit accesses
> to make it through unmolested".

I have to hope so.

> The 128-bit case I really don't know about. It probably works too. But
> while I'd call the 64-bit case almost certain (in the absence of truly
> crap hardware), the 128-bit case I have a hard time judging how
> certain it is going to be.

Right, I think it's been made pretty clear that it's going to be
dependent on more than just architecture.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
