From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock
 tuning.
Date: Thu, 9 Sep 2010 23:16:56 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009092244390.2477@localhost6.localdomain6>
References: <cover.1283504065.git.richard.cochran@omicron.at> <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at> <alpine.LFD.2.00.1009091159260.2477@localhost6.localdomain6> <20100909133449.GB2823@riccoc20.at.omicron.at>
 <alpine.LFD.2.00.1009092102150.2477@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.1009092102150.2477-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2010, Thomas Gleixner wrote:
> On Thu, 9 Sep 2010, Richard Cochran wrote:
> 
> > On Thu, Sep 09, 2010 at 12:49:27PM +0200, Thomas Gleixner wrote:
> > > On Fri, 3 Sep 2010, Richard Cochran wrote:
> > > > In addition, the POSIX clock code has been augmented to offer a
> > > > dynamic clock creation method. Instead of registering a hard
> > > > coded clock ID, modules may call create_posix_clock(), which
> > > > returns a new clock ID.
> > > 
> > > This has been discussed for years and I still fail to see the
> > > requirement for this. The only result is that it allows folks to
> > > create their special purpose clock stuff and keep it out of tree
> > > instead of fixing the problems they have with the existing clock
> > > infrastructure in the kernel.
> > 
> > Do you have any pointers to this discussion?
> 
> Not out of the box. Need to ask the oracle of google [ I wonder if
> this expression is politically correct today :) ]
> 
> My personal stance on this is clear: Assign fixed ID.
> 
> The point is, that if we provide something like CLOCK_PTP, then we can
> abstract the real hardware drivers behind this clock id and we get a
> consistent feature set for these drivers and a consistent behaviour on
> the user space interface. There still might be a hardware driver which
> cannot provide a specific feature, but there is nothing wrong to
> return -ENOSYS in such a case.

Hmm. Talked to John Stultz about this and got enlightened that there
might be more than one of these beasts. That changes the story
slightly.
 
So yes, I've been wrong as usual and we'll need some way of assigning
those ids dynamically, but I'm still opposed to providing an
unconfined "give me one of those id's" interface for public
consumption.

I'd rather see a controlled environment for device classes like PTP
clocks. That would have a couple of advantages:

 - clear association of the device to a well defined functionality

 - avoidance of duplicated code

 - consistent sysfs interfaces for functionality which is device class
   specific

 - simpler identification for interested applications

 - preventing the random spread of clock id consumers

So the clock device class code would provide the interface for these
class specific hardware drivers and consult the posix timer core code
to give out an id.

And that would apply to any other class of clock devices which do not
fall into the general clocksource category (e.g. RTCs, audio clocks
..)

Thoughts ?

	 tglx
