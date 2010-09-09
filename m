From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock
 tuning.
Date: Thu, 9 Sep 2010 23:31:52 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009092327300.2477@localhost6.localdomain6>
References: <cover.1283504065.git.richard.cochran@omicron.at>  <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at>  <alpine.LFD.2.00.1009091159260.2477@localhost6.localdomain6>
 <1284066084.2762.172.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1284066084.2762.172.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2010, john stultz wrote:
> On Thu, 2010-09-09 at 12:49 +0200, Thomas Gleixner wrote:
> > But what I see is an approach which tries to implement disconnected
> > special purpose clocks which have the ability to be adjusted
> > independently. What's the purpose of this ? Why can't we just use the
> > existing clocks and make PTP work on them ?
> 
> So this too was my initial gut response. It seems ridiculous to expose
> two clock_ids (CLOCK_REALTIME and CLOCK_PTP)that conceptually represent
> the same thing (ie: number of seconds,nanoseconds since 1970).
> 
> It doesn't help that one of the use cases that Richard suggests is "for
> example in an embedded control application. The userland software can
> simply ignore the wrong system time." 
> 
> As someone who's spent a *lot* of time trying to fix the "wrong system
> time" these use cases reek of work-around solutions instead of properly
> fixing whatever keeps the system time from being accurately sycned.
> 
> However, as I've worked on understanding the issue, I realize that there
> is some validity to needing to expose more then one hardware clock the
> conceptually is the same as CLOCK_REALTIME. And that most of my gut
> reaction to this was me being a bit oversensitive. :)

Yup. It still scares me that we might end up with a dozen different
notions of ONE second elapsed on the same machine :)

> However, since there may be multiple PTP clocks or audio clocks or
> whatever, allocating static clockids for each type isn't quite useful,

Yeah, I corrected myself on that one, but I really want to see some
confinement into well defined clock classes rather than the "hooray
here is my clock of the day" approach.

Thanks,

	tglx
