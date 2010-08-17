From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 17 Aug 2010 13:36:29 +0200
Message-ID: <201008171336.29375.arnd@arndb.de>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	<201008170925.55592.arnd@arndb.de>
	<20100817105232.GA9079@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20100817105232.GA9079-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
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

On Tuesday 17 August 2010, Richard Cochran wrote:
> On Tue, Aug 17, 2010 at 09:25:55AM +0000, Arnd Bergmann wrote:
> > Another difference is that we generally use ioctl for devices that can
> > be enumerated, while syscalls are for system services that are not tied to
> > a specific device. This argument works both ways for PTP IMHO: On the one
> > hand you want to have a reliable clock that you can use without knowing
> > where it comes from, on the other you might have multiple PTP sources that
> > you need to differentiate.
> 
> Yes, I agree. In normal use, there will be only one PTP clock in a
> system. However, for research purposes, it would be nice to have more
> than one.
> 
> I've been looking at offering the PTP clock as a posix clock, and it
> is not as hard as I first thought. The PTP clock or clocks just have
> to be registered as one of the posix_clocks[MAX_CLOCKS] in
> posix-timers.c.

Ok sounds good.

> My suggestion would be to reserve three clock ids in time.h,
> CLOCK_PTP0, CLOCK_PTP1, and CLOCK_PTP2. The first one would be the
> same as CLOCK_REALTIME, for SW timestamping, and the other two would
> allow two different PTP clocks at the same time, for the research use
> case.

I don't think there is a point in making exactly two independent sources
available. The clockid_t space is not really limited, so we could define
an arbitrary range of ids for ptp sources that could be used simultaneously,
as long as we have space more more ids with a fixed number.

Would it be reasonable to assume that on a machine with a large number
of NICs, you'd want a separate ptp source for each of them for timestamping?
Or would you preferably define just one source in such a setup?

I think both could be done with the use of class device attributes in
sysfs for configuration. Maybe you can have one CLOCK_PTP value for one
global PTP source and use sysfs to configure which device that is.

If you also need simultaneous access to the specific clocks, you could
have run-time configured clockid numbers in a sysfs attribute for each
ptp class device.

> Using the clock id will bring another advantage, since it will then be
> possible for user space to specify the desired timestamp source for
> SO_TIMESTAMPING.

God point.

	Arnd
