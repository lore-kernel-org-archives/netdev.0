From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 6/8] ptp: Added a clock that uses the eTSEC found on the
 MPC85xx.
Date: Thu, 23 Sep 2010 15:32:50 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009231527330.7522@router.home>
References: <cover.1285261533.git.richard.cochran@omicron.at> <57b64051c816dc9cb856bbb9f38fc901c9d3d651.1285261535.git.richard.cochran@omicron.at> <alpine.DEB.2.00.1009231348150.2962@router.home> <20100923214359.3f287b11@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100923214359.3f287b11-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2010, Alan Cox wrote:

> > Please do not introduce useless additional layers for clock sync. Load
> > these ptp clocks like the other regular clock modules and make them sync
> > system time like any other clock.
>
> I don't think you understand PTP. PTP has masters, a system can need to
> be honouring multiple conflicting masters at once.

The upshot of it all has to be some synchronized notion of time regardless
of how many other things are going on under the hood. And the spec here
suggests a hardware able to generate periodic accurate events that can be
used to sync system time.

> > Really guys: I want a PTP solution! Now! And not some idiotic additional
> > kernel layers that just pass bits around because its so much fun and
> > screws up clock accurary in due to the latency noise introduced while
> > having so much fun with the bits.
>
> There are some interesting complications in putting a PTP sync
> interface in kernel.

If the PTP logic internally has to juggle multiple clocks then that is a
complication for the driver ok. In any case the driver ultimately has to
provide *one* source of time for the system to sync to.
