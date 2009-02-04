From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [PATCH NET-NEXT 01/10] clocksource: allow usage independent of
	timekeeping.c
Date: Wed, 04 Feb 2009 16:24:34 +0100
Message-ID: <1233761074.15940.230.camel@ecld0pohly>
References: <1233752517-30010-1-git-send-email-patrick.ohly@intel.com>
	 <1233752517-30010-2-git-send-email-patrick.ohly@intel.com>
	 <1233756235.15119.54.camel@desktop> <1233758796.15940.198.camel@ecld0pohly>
	 <1233760170.15119.76.camel@desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Daniel Walker <dwalker@fifo99.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58421 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752261AbZBDPYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 10:24:39 -0500
In-Reply-To: <1233760170.15119.76.camel@desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-04 at 15:09 +0000, Daniel Walker wrote:
> On Wed, 2009-02-04 at 15:46 +0100, Patrick Ohly wrote:
> > On Wed, 2009-02-04 at 14:03 +0000, Daniel Walker wrote:
> > > On Wed, 2009-02-04 at 14:01 +0100, Patrick Ohly wrote:
> > >
> > > >  /**
> > > > + * struct cyclecounter - hardware abstraction for a free running counter
> > > > + *       Provides completely state-free accessors to the underlying hardware.
> > > > + *       Depending on which hardware it reads, the cycle counter may wrap
> > > > + *       around quickly. Locking rules (if necessary) have to be defined
> > > > + *       by the implementor and user of specific instances of this API.
> > > > + *
> > > > + * @read:                returns the current cycle value
> > > > + * @mask:                bitmask for two's complement
> > > > + *                       subtraction of non 64 bit counters,
> > > > + *                       see CLOCKSOURCE_MASK() helper macro
> > > > + * @mult:                cycle to nanosecond multiplier
> > > > + * @shift:               cycle to nanosecond divisor (power of two)
> > > > + */
> > > > +struct cyclecounter {
> > > > + cycle_t (*read)(const struct cyclecounter *cc);
> > > > + cycle_t mask;
> > > > + u32 mult;
> > > > + u32 shift;
> > > > +};
> > >
> > > Where are these defined? I don't see any in created in your code.
> >
> > What do you mean with "these"? cycle_t? That type is defined in
> > clocksource.h. This patch intentionally adds these definitions to the
> > existing file because of the large conceptual overlap.
> 
> No, your creating a new structure here that wasn't declared. I was
> referring to "struct cyclecounter".

Sorry, I still don't see the problem. I'm declaring and defining struct
cyclecounter here. Why should it also be declared (= "struct
cyclecounter;") elsewhere?

>  I did look up one of your prior
> submission (Dec. 15) and reviewed that.

Right, I saw that a bit later.

> > In an earlier revision of the patch I had adapted clocksource itself so
> > that it could be used outside of the time keeping code; John wanted me
> > to use these smaller structs instead that you now find in the current
> > patch.
> 
> Well, I think your original idea was better.. I don't think we need the
> duplication of underlying clocksource mechanics.

Please discuss this with John. I'd prefer to not get caught in the
cross-fire of a discussion that I don't know enough about :-/

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

