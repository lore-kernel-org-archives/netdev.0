From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH NET-NEXT 01/10] clocksource: allow usage independent of
	timekeeping.c
Date: Wed, 04 Feb 2009 07:09:30 -0800
Message-ID: <1233760170.15119.76.camel@desktop>
References: <1233752517-30010-1-git-send-email-patrick.ohly@intel.com>
	 <1233752517-30010-2-git-send-email-patrick.ohly@intel.com>
	 <1233756235.15119.54.camel@desktop> <1233758796.15940.198.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fifo99.com ([67.223.236.141]:36989 "EHLO fifo99.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756726AbZBDPJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 10:09:32 -0500
In-Reply-To: <1233758796.15940.198.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-04 at 15:46 +0100, Patrick Ohly wrote:
> Hi Daniel!
> 
> Thanks for looking at this. I think the previous discussion of this
> patch under the same subject on LKML already addressed your concerns,
> but I'll also reply in detail below.
> 
> On Wed, 2009-02-04 at 14:03 +0000, Daniel Walker wrote:
> > On Wed, 2009-02-04 at 14:01 +0100, Patrick Ohly wrote:
> > 
> > >  /**
> > > + * struct cyclecounter - hardware abstraction for a free running counter
> > > + *	Provides completely state-free accessors to the underlying hardware.
> > > + *	Depending on which hardware it reads, the cycle counter may wrap
> > > + *	around quickly. Locking rules (if necessary) have to be defined
> > > + *	by the implementor and user of specific instances of this API.
> > > + *
> > > + * @read:		returns the current cycle value
> > > + * @mask:		bitmask for two's complement
> > > + *			subtraction of non 64 bit counters,
> > > + *			see CLOCKSOURCE_MASK() helper macro
> > > + * @mult:		cycle to nanosecond multiplier
> > > + * @shift:		cycle to nanosecond divisor (power of two)
> > > + */
> > > +struct cyclecounter {
> > > +	cycle_t (*read)(const struct cyclecounter *cc);
> > > +	cycle_t mask;
> > > +	u32 mult;
> > > +	u32 shift;
> > > +};
> > 
> > Where are these defined? I don't see any in created in your code.
> 
> What do you mean with "these"? cycle_t? That type is defined in
> clocksource.h. This patch intentionally adds these definitions to the
> existing file because of the large conceptual overlap.

No, your creating a new structure here that wasn't declared. I was
referring to "struct cyclecounter". I did look up one of your prior
submission (Dec. 15) and reviewed that.

> In an earlier revision of the patch I had adapted clocksource itself so
> that it could be used outside of the time keeping code; John wanted me
> to use these smaller structs instead that you now find in the current
> patch.

Well, I think your original idea was better.. I don't think we need the
duplication of underlying clocksource mechanics.

> Eventually John wants to refactor clocksource so that it uses them and
> just adds additional elements in clocksource. Right now clocksource is a
> mixture of different concepts. Breaking out cyclecounter and timecounter
> is a first step towards that cleanup.

The problem I see is that your putting off the cleanup of struct
clocksource with duplication.. It should go in reverse , you should use
clocksources for your patch set. Which will motivate John to clean up
the clocksource structure.

There's a whole other issue which is that we have many architectures
already declaring struct clocksource for it's most basic usage. So I
think we want clocksource to be the base "cycle counter" structure (in
name and usage). Almost everything else in struct clocksource is
specific to generic timekeeping and could be factored out easily.

Daniel

