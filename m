From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V9 08/13] posix clocks: cleanup the CLOCK_DISPTACH macro
Date: Fri, 14 Jan 2011 08:48:37 +0100
Message-ID: <20110114074837.GA8077@riccoc20.at.omicron.at>
References: <cover.1294917347.git.richard.cochran@omicron.at>
 <90b2beef441615d01c93fcad029c44af4e505c5f.1294917348.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1101131745400.2678@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1101131745400.2678-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2011 at 06:03:24PM +0100, Thomas Gleixner wrote:
> On Thu, 13 Jan 2011, Richard Cochran wrote:
> >  int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *ts);
> >  int posix_cpu_clock_get(const clockid_t which_clock, struct timespec *ts);
> > -int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *ts);
> > +int posix_cpu_clock_set(const clockid_t which_clock, struct timespec *ts);
> 
> Shouldn't we change the clock_set function to have *ts const in all places ?

Yes, your are right.

> > @@ -293,6 +261,11 @@ static __init int init_posix_timers(void)
> >  		.clock_adj = do_posix_clock_noadjtime,
> >  		.timer_create = no_timer_create,
> >  		.nsleep = no_nsleep,
> > +		/* defaults: */
> > +		.nsleep_restart	= common_nsleep_restart,
> > +		.timer_del	= common_timer_del,
> > +		.timer_get	= common_timer_get,
> > +		.timer_set	= common_timer_set,
> 
> Hmm, we do not need to set functional entries for clocks which neither
> implement timer_create nor nsleep.

I know, but I wanted to be really pendantic about what the previous
code was, and what the new code does.

Before: By leaving the k_clock function pointer NULL, the clock
        selects common_xyz. This common function may or may make
        sense for that clock.

After:  By leaving the k_clock function pointer NULL, the clock will
        return EINVAL for that syscall.

Maybe it would be better to leave the cleaning up of the common crud
as a follow up patch. What do you think?

Richard
