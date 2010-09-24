From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/8] posix clocks: introduce a syscall for clock tuning.
Date: Fri, 24 Sep 2010 09:29:46 +0200
Message-ID: <20100924072946.GA5043@riccoc20.at.omicron.at>
References: <cover.1285261533.git.richard.cochran@omicron.at>
 <b94ef1cd9c04ef3ad5964408bd0af7251add78de.1285261534.git.richard.cochran@omicron.at>
 <1285271331.2587.56.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1285271331.2587.56.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2010 at 12:48:51PM -0700, john stultz wrote:
> On Thu, 2010-09-23 at 19:31 +0200, Richard Cochran wrote:
> > A new syscall is introduced that allows tuning of a POSIX clock. The
> > syscall is implemented for four architectures: arm, blackfin, powerpc,
> > and x86.
> > 
> > The new syscall, clock_adjtime, takes two parameters, the clock ID,
> > and a pointer to a struct timex. The semantics of the timex struct
> > have been expanded by one additional mode flag, which allows an
> > absolute offset correction. When specificied, the clock offset is
> > immediately corrected by adding the given time value to the current
> > time value.
> 
> 
> So I'd still split this patch up a little bit more.
> 
> 1) Patch that implements the ADJ_SETOFFSET  (*and its implementation*)
> in do_adjtimex.
> 
> 2) Patch that adds the new syscall and clock_id multiplexing.
> 
> 3) Patches that wire it up to the rest of the architectures (there's
> still a bunch missing here).

I was not sure what the policy is about adding syscalls. Is it the
syscall author's responsibility to add it into every arch?

The last time (see a2e2725541fad7) the commit only added half of some
archs, and ignored others. In my patch, the syscall *really* works on
the archs that are present in the patch.

(Actually, I did not test blackfin, since I don't have one, but I
included it since I know they have a PTP hardware clock.)

> > +static inline int common_clock_adj(const clockid_t which_clock, struct timex *t)
> > +{
> > +	if (CLOCK_REALTIME == which_clock)
> > +		return do_adjtimex(t);
> > +	else
> > +		return -EOPNOTSUPP;
> > +}
> 
> 
> Would it make sense to point to the do_adjtimex() in the k_clock
> definition for CLOCK_REALTIME rather then conditionalizing it here?

But what about CLOCK_MONOTONIC_RAW, for example?

Does it make sense to allow it to be adjusted?

Thanks,
Richard
