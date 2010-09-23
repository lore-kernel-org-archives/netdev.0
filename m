From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 14:15:09 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009231402420.2962@router.home>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<alpine.DEB.2.00.1009231238170.2962@router.home>
	<1285268380.2587.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1285268380.2587.11.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2010, john stultz wrote:

> This was my initial gut reaction as well, but in the end, I agree with
> Richard that in the case of one or multiple PTP hardware clocks, we
> really can't abstract over the different time domains.

My (arguably still superficial) review of the source does not show
anything that would make me reach that conclusion.

> I really don't think the PTP clock can be used as a clocksource sanely.
>
> First, the hardware access is much to slow for system timekeeping.

The HPET or pit timesource are also quite slow these days. You only need
access periodically to essentially tune the TSC ratio.

> Second, there is the problem that the system time is a software clock,
> and adjustments made (like freq) are made in the layer that interprets
> the underlying hardware cycle counter. Adjustments made in PTP (in order
> to sync the network timestamps) are made at the hardware level.

>From what I can see the PTP clocks are periodic hardware cycle counters
like any other clock that we currently support. If its configurable enough
then setup a hardware cycle counter that mimics nanoseconds since the
epoch as closely as possible and use that to sync the TSC rate to. Makes
it very easy.

> This would cause a disconnect between the hardware freq understood by
> the system time management code and the actual hardware freq.

We can switch underlying clocks for system time already. We can adapt to a
different hw frequency. But then I do not know why adjust the freq? I
thought the point was that the periodic clock was network synchronized and
can be used as "the" master clock for multiple machines?

> Richard, I'd actually strike this paragraph from the rational, as I feel
> it has the tendency to confuse as it suggests having the PHC as a
> clocksource is feasible when really it isn't. Or alternatively, maybe
> express more clearly why its not feasible, so it doesn't just seem like
> a minor design choice.

Sorry but I still feel that this is pretty much a misguided approach that
creates unnecessary layers in the kernel. The trivial easy approach was
not done (copy a driver from drivers/clocksource, modify so that it
programs access to a centralized periodic ptp signal and uses it for
system sync).
