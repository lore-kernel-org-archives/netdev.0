From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 17 Aug 2010 12:52:32 +0200
Message-ID: <20100817105232.GA9079@riccoc20.at.omicron.at>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	<201008162159.39734.arnd@arndb.de>
	<20100817083216.GA3330@riccoc20.at.omicron.at>
	<201008170925.55592.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201008170925.55592.arnd-r2nGTMty4D4@public.gmane.org>
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

On Tue, Aug 17, 2010 at 09:25:55AM +0000, Arnd Bergmann wrote:
> Another difference is that we generally use ioctl for devices that can
> be enumerated, while syscalls are for system services that are not tied to
> a specific device. This argument works both ways for PTP IMHO: On the one
> hand you want to have a reliable clock that you can use without knowing
> where it comes from, on the other you might have multiple PTP sources that
> you need to differentiate.

Yes, I agree. In normal use, there will be only one PTP clock in a
system. However, for research purposes, it would be nice to have more
than one.

I've been looking at offering the PTP clock as a posix clock, and it
is not as hard as I first thought. The PTP clock or clocks just have
to be registered as one of the posix_clocks[MAX_CLOCKS] in
posix-timers.c.

My suggestion would be to reserve three clock ids in time.h,
CLOCK_PTP0, CLOCK_PTP1, and CLOCK_PTP2. The first one would be the
same as CLOCK_REALTIME, for SW timestamping, and the other two would
allow two different PTP clocks at the same time, for the research use
case.

Using the clock id will bring another advantage, since it will then be
possible for user space to specify the desired timestamp source for
SO_TIMESTAMPING.

Richard
