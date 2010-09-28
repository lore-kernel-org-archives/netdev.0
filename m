From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Tue, 28 Sep 2010 08:34:49 +0200
Message-ID: <20100928063449.GA7224@riccoc20.at.omicron.at>
References: <alpine.DEB.2.00.1009231533040.7522@router.home>
 <1285278136.2587.154.camel@localhost.localdomain>
 <alpine.DEB.2.00.1009271038150.9258@router.home>
 <20100927.101423.702773873740300798.imp@bsdimp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, giometti-k2GhghHVRtY@public.gmane.org,
	peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org
To: "M. Warner Losh" <imp-uzTCJ5RojNnQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100927.101423.702773873740300798.imp-uzTCJ5RojNnQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 10:14:23AM -0600, M. Warner Losh wrote:
> 
> This is a common error that I've seen repeated in this thread.  The
> only reason that it has historically been important is because when
> you are doing timestamping in software based on an interrupt, that
> stuff does matter.

Yes, thanks for your helpful explanation.

To further illustrate how small the effect of running the servo in
user space is, consider the following.

It is true that delays and jitter in the time to process the received
packet negatively affect the clock servo loop. However, the effect in
our case will be quite small.

John Eidson's book [1] presents a rigorous servo model that includes
an analysis of the delay from the time the samples (timestamps) are
taken until the corrective action is performed by the PTP software.

For PTP, the sample time is at the sender (the remote host, the master
clock). The master sends *two* packets, where the second one (the so
called follow-up packet) contains the hardware time stamp of the first
one. So, the computational delay includes the time spent by the sender
in its PTP stack preparing the second packet, the time the packet
spends in transit, and the time in the receiver's PTP stack and servo.

According to Eidson's analysis, a delay of up to 10 milliseconds would
be acceptable, even with a sample rate of 10 Hz. Therefore, saving a
few dozen microseconds by placing the servo (and PTP stack) into the
kernel is not worth the effort.

Richard


[1] title =     {Measurement, control, and communication using IEEE 1588},
    author =    {J. C. Eidson},
    year =      2006,
    publisher = {Springer-Verlag},
