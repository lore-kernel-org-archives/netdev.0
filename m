From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Fri, 24 Sep 2010 15:57:13 +0100
Message-ID: <20100924155713.45be6513@lxorguk.ukuu.org.uk>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<1285270733.2587.46.camel@localhost.localdomain>
	<20100924135001.GB3113@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
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
In-Reply-To: <20100924135001.GB3113-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > Instead, I think having the id hanging off the class driver is much
> > better, as it allows mapping the actual hardware to the id more clearly.
> > 
> > So I'd drop the "timesource" listing. And maybe change "id" to
> > "clock_id" so its a little more clear what the id is for.
> 
> Okay, I will drop /sys/class/timesource (hope Alan Cox agrees :)

It makes sense to hang anything off the physical id

> I threw it out there mostly for the sake of discussion. I imagined
> that there could be other properties in that directory, like time
> scale (TAI, UTC, etc). But it seems like we don't really need anything
> in that direction.

They can still hang off the physical device. Thats really a detail

> > interrupts are awfully frequent, so systems concerned with power-saving
> > and deep idles probably would like something that could be done at a
> > more coarse interval.
> 
> We could always make the pulse rate programmable, for power-saving
> applications.

I would expect the kernel drivers to be responsible for
- Turning off when they can
- Picking rates that are power optimal for the requirement

The latter is a bit interesting as I don't see anything in any of the
timer APIs to express accuracy (a problem we have in kernel too).
Historically it simply hasn't mattered.
