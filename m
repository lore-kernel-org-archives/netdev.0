From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH NET-NEXT 01/10] clocksource: allow usage independent of
	timekeeping.c
Date: Wed, 04 Feb 2009 12:06:22 -0800
Message-ID: <1233777982.6994.51.camel@localhost.localdomain>
References: <1233752517-30010-1-git-send-email-patrick.ohly@intel.com>
	 <1233752517-30010-2-git-send-email-patrick.ohly@intel.com>
	 <1233756235.15119.54.camel@desktop> <1233758796.15940.198.camel@ecld0pohly>
	 <1233760170.15119.76.camel@desktop>
	 <1233775542.6994.13.camel@localhost.localdomain>
	 <1233776421.15119.125.camel@desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Daniel Walker <dwalker@fifo99.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:33869 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbZBDUGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 15:06:38 -0500
In-Reply-To: <1233776421.15119.125.camel@desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-04 at 11:40 -0800, Daniel Walker wrote:
> On Wed, 2009-02-04 at 11:25 -0800, john stultz wrote:
> > On Wed, 2009-02-04 at 07:09 -0800, Daniel Walker wrote:
> > > On Wed, 2009-02-04 at 15:46 +0100, Patrick Ohly wrote:
> > > > In an earlier revision of the patch I had adapted clocksource itself so
> > > > that it could be used outside of the time keeping code; John wanted me
> > > > to use these smaller structs instead that you now find in the current
> > > > patch.
> > > 
> > > Well, I think your original idea was better.. I don't think we need the
> > > duplication of underlying clocksource mechanics.
> > > 
> > > > Eventually John wants to refactor clocksource so that it uses them and
> > > > just adds additional elements in clocksource. Right now clocksource is a
> > > > mixture of different concepts. Breaking out cyclecounter and timecounter
> > > > is a first step towards that cleanup.
> > > 
> > > The problem I see is that your putting off the cleanup of struct
> > > clocksource with duplication.. It should go in reverse , you should use
> > > clocksources for your patch set. Which will motivate John to clean up
> > > the clocksource structure.
> > 
> > I strongly disagree. Misusing a established structure for unintended use
> > is just bad. What Patrick wants to use the counters for has very
> > different semantics then how clocksources are used.
> 
> I don't think it's at all bad to reuse an established system like that,
> especially when the purposed one is largely duplication of the other..

The duplication is only at a very low level. He could not reuse the
established clocksource system without really breaking its semantics.

> The issue is more that struct clocksource has been loaded up with too
> many timekeeping specific ornaments .. I would think a good clean up
> would be just to remove those from the structure.

I do agree. And I gave it a quick attempt and its not quite trivial.
There is some timekeeping ornaments that are required in the clocksource
(the two notions of mult, the flags values, etc). Trying to best split
this out I think will take some care.

> > I think having a bit of redundancy in two structures is good motivation
> > for me to clean up the clocksources to use cyclecounters.
> 
> I'm not sure what kind of clean up you have in mind. Given that
> clocksources are used across many architectures, do you really want to
> do a mass name change for all of them? Not to mention most people see
> clocksources as cycle counters , so you would just add confusion in
> addition to code flux.

No matter what we do, we will have to touch the arch code in some way.
Right now I suspect the arch code will still define clocksources, but we
can refactor clocksources to use cyclecounters internally. 

> If your going to end up merging this new cycle counter structure with
> clocksources anyway, why wouldn't we do it now instead of doing
> temporary duplication ..

Patrick could have created his own NICcounter infrastructure somewhere
far away from the generic time code and no one would gripe (much like
sched_clock in many cases).  I think he's doing the right thing by
establishing a base structure that we can reuse in the
clocksource/timekeeping code. 

Doing that conversion well so the code is more readable as well as
removing structure duplication will take some time and will touch a lot
of historically delicate time code, so it will need additional time to
sit in testing trees before we push it upward. 

I see no reason to block his code in the meantime.

thanks
-john

