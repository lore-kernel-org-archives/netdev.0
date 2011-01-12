From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V8 08/13] posix clocks: cleanup the CLOCK_DISPTACH macro
Date: Wed, 12 Jan 2011 08:37:28 +0100
Message-ID: <20110112073728.GA2935@riccoc20.at.omicron.at>
References: <cover.1293820862.git.richard.cochran@omicron.at>
 <503cd1fa268867573001cfc9bb5681ee3b5b32fa.1293820862.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1101111224280.12146@localhost6.localdomain6>
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
In-Reply-To: <alpine.LFD.2.00.1101111224280.12146-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 11, 2011 at 01:57:23PM +0100, Thomas Gleixner wrote:
> I wonder whether we should be a bit more clever here and create an
> extra entry for posix_cpu_timers in the posix_clocks array and do the
> following:
...
> That reduces the code significantly and the MAX_CLOCKS check in
> clock_get_array_id() replaces the invalid_clock() check in the
> syscalls as well. It does not matter whether we check this before or
> after copying stuff from user.

Well, this does reduce the number of LOC, but the number of
comparisons is the same. I think the code size would be also no
different.

> Adding your new stuff requires just another entry in the array, the
> setup of the function pointers and the CLOCKFD check in
> clock_get_array_id(). Everything else just falls in place.

For me, I am not sure if either version is really very pretty or easy
to understand.

My instinct is to keep the posix_cpu_X and pc_X functions out of the
array of static clock id functions, if only to make the distinction
between the legacy static ids and new dynamic ids clear.

The conclusion from the "dynamic clock as file" discussion was that we
don't want to add any more static clock ids, and new clocks should use
the new, dynamic clock API. So, we should discourage any future
attempt to add to that function array!

Having said that, if you insist on it, I won't mind reworking the
dispatch code as you suggested.

> > +
> > +#define CLOCK_DISPATCH(clock, call, arglist) dispatch_##call arglist
> > +
> 
> Can we get rid of this completely please ?

Yes, gladly.

> >  clock_nanosleep_restart(struct restart_block *restart_block)
> >  {
> > -	clockid_t which_clock = restart_block->arg0;
> > -
> 
> How does that compile ?

Because the CLOCK_DISPATCH macro, above, makes no use of the first
argument! I have removed the macro for the next round.

> >  	return CLOCK_DISPATCH(which_clock, nsleep_restart,
> >  			      (restart_block));
> >  }

Thanks,
Richard
