From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 11:59:40 -0700
Message-ID: <1285268380.2587.11.camel@localhost.localdomain>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	 <alpine.DEB.2.00.1009231238170.2962@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009231238170.2962-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-23 at 12:53 -0500, Christoph Lameter wrote:
> On Thu, 23 Sep 2010, Richard Cochran wrote:
> >     In contrast to the standard Linux system clock, a PHC is
> >     adjustable in hardware, for example using frequency compensation
> >     registers or a VCO. The ability to directly tune the PHC is
> >     essential to reap the benefit of hardware timestamping.
> 
> There is a reason for not being able to shift posix clocks: The system has
> one time base. The various clocks are contributing to maintaining that
> sytem wide time.
> 
> I do not understand why you want to maintain different clocks running at
> different speeds. Certainly interesting for some uses I guess that I
> do not have the energy to imagine right now. But can we get the PTP killer
> feature of synchronized accurate system time first?

This was my initial gut reaction as well, but in the end, I agree with
Richard that in the case of one or multiple PTP hardware clocks, we
really can't abstract over the different time domains.



> > 3.3 Synchronizing the Linux System Time
> > ========================================
> >
> >    One could offer a PHC as a combined clock source and clock event
> >    device. The advantage of this approach would be that it obviates
> >    the need for synchronization when the PHC is selected as the system
> >    timer. However, some PHCs, namely the PHY based clocks, cannot be
> >    used in this way.
> 
> Why not? Do PHY based clock not at least provide a counter that increments
> in synchronized intervals throughout the network?

I really don't think the PTP clock can be used as a clocksource sanely.

First, the hardware access is much to slow for system timekeeping.

Second, there is the problem that the system time is a software clock,
and adjustments made (like freq) are made in the layer that interprets
the underlying hardware cycle counter. Adjustments made in PTP (in order
to sync the network timestamps) are made at the hardware level. 

This would cause a disconnect between the hardware freq understood by
the system time management code and the actual hardware freq.

Richard, I'd actually strike this paragraph from the rational, as I feel
it has the tendency to confuse as it suggests having the PHC as a
clocksource is feasible when really it isn't. Or alternatively, maybe
express more clearly why its not feasible, so it doesn't just seem like
a minor design choice.

thanks
-john
