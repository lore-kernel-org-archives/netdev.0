From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/8] posix clocks: introduce a syscall for clock tuning.
Date: Fri, 24 Sep 2010 10:55:14 -0700
Message-ID: <1285350914.3514.3.camel@localhost.localdomain>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	 <b94ef1cd9c04ef3ad5964408bd0af7251add78de.1285261534.git.richard.cochran@omicron.at>
	 <1285271331.2587.56.camel@localhost.localdomain>
	 <20100924072946.GA5043@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
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
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100924072946.GA5043-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-09-24 at 09:29 +0200, Richard Cochran wrote:
> On Thu, Sep 23, 2010 at 12:48:51PM -0700, john stultz wrote:
> > So I'd still split this patch up a little bit more.
> > 
> > 1) Patch that implements the ADJ_SETOFFSET  (*and its implementation*)
> > in do_adjtimex.
> > 
> > 2) Patch that adds the new syscall and clock_id multiplexing.
> > 
> > 3) Patches that wire it up to the rest of the architectures (there's
> > still a bunch missing here).
> 
> I was not sure what the policy is about adding syscalls. Is it the
> syscall author's responsibility to add it into every arch?
> 
> The last time (see a2e2725541fad7) the commit only added half of some
> archs, and ignored others. In my patch, the syscall *really* works on
> the archs that are present in the patch.
> 
> (Actually, I did not test blackfin, since I don't have one, but I
> included it since I know they have a PTP hardware clock.)

I'm not sure about policy, but I think for completeness sake you should
make sure every arch supports a new syscall. You're not expected to be
able to test every one, but getting the basic support patch sent to
maintainers should be done.

> > > +static inline int common_clock_adj(const clockid_t which_clock, struct timex *t)
> > > +{
> > > +	if (CLOCK_REALTIME == which_clock)
> > > +		return do_adjtimex(t);
> > > +	else
> > > +		return -EOPNOTSUPP;
> > > +}
> > 
> > 
> > Would it make sense to point to the do_adjtimex() in the k_clock
> > definition for CLOCK_REALTIME rather then conditionalizing it here?
> 
> But what about CLOCK_MONOTONIC_RAW, for example?

-EOPNOTSUPP

> Does it make sense to allow it to be adjusted?

No. I think only CLOCK_REALTIME would make sense of the existing clocks.

I'm just suggesting you conditionalize it from the function pointer,
rather then in the common function.

thanks
-john
