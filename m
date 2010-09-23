From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 22:34:17 +0100
Message-ID: <20100923223417.4ed62e5b@lxorguk.ukuu.org.uk>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<alpine.DEB.2.00.1009231238170.2962@router.home>
	<1285268380.2587.11.camel@localhost.localdomain>
	<alpine.DEB.2.00.1009231402420.2962@router.home>
	<1285273684.2587.92.camel@localhost.localdomain>
	<alpine.DEB.2.00.1009231533040.7522@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
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
In-Reply-To: <alpine.DEB.2.00.1009231533040.7522-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> There is no other scalable time source available for fast timer access
> than the time stamp counter in the cpu. Other time source require
> memory accesses which is inherently slower.

On what hardware ?

> An accurate other time source is used to adjust this clock. NTP does that
> via the clock interfaces from user space which has its problems with
> accuracy. PTP can provide the network synced time access
> that would a more accurate calibration of the time.

Accuracy does not require speed of access. Accuracy requires predictible
latency of access.

> Userland code would introduce latencies that would make sub microsecond
> time sync very difficult.

You can take a multiple micro-second I/O stall or SMI trap on a PC so you
already lost the battle on the platform you seem to be discussing.

> You dont need the user APIs if you directly use the PTP time source to
> steer the system clock. In fact I think you have to do it in kernel space
> since user space latencies will degrade accuracy otherwise.

PTP is not a 'time source' it is one or more source of time. The
distinction is rather important.

> It implies clock tuning in userspace for a potential sub microsecond
> accurate clock. The clock accuracy will be limited by user space
> latencies and noise. You wont be able to discipline the system clock
> accurately.

Noise matters, latency doesn't. And the kernel is getting more and more
real time support all the time.
