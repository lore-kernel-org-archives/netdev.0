From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Tue, 20 Sep 2016 18:47:02 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1609201833010.9311@knanqh.ubzr>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org> <20160920202556.GA6713@localhost.localdomain> <20160920204556.GA7555@localhost.localdomain> <alpine.LFD.2.20.1609201655200.9311@knanqh.ubzr> <alpine.DEB.2.20.1609202300140.5476@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Richard Cochran <richardcochran@gmail.com>,
        John Stultz <john.stultz@linaro.org>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1609202300140.5476@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2016, Thomas Gleixner wrote:

> I think the whole approach is wrong because it makes the PTP split at the
> wrong level.
> 
> Currently we have:
> 
> 	  DRIVER_X
> 	  tristate "Driver X"
> 	  select PTP
> 
> In order to make POSIX_CLOCK configurable we should have
> 
>        	  PTP
> 	  tristate "PTP"
> 	  select POSIX_CLOCK
> 
> Now if you want to distangle PTP from a driver then you split it at the
> driver level and not at the PTP level:
> 
>       	  DRIVER_X
> 	  tristate "Driver X"
> 
> 	  DRIVER_X_PTP
> 	  bool "Enable PTP support"
> 	  default y if !MAKE_IT_TINY
> 	  depends on DRIVER_X
> 	  select PTP
> 
> We have already drivers following that scheme. That way you make the PTP
> support in the driver conditional on DRIVER_X_PTP and have no hassle with
> modules and dependencies.

I beg to disagree.

There are way more drivers than subsystems and if you had to go around 
unselecting all NIC drivers for CONFIG_ETHERNET to be turned off, and 
with CONFIG_ETHERNET=n you'd finally be able to turn networking off, 
then this would be a nightmare.

IMHO it is much nicer for the poor user configuring the kernel to have a 
single configuration prompt for PTP support, and then have whatever 
driver that can provide a PTP clock just do it (or omit it) based on 
that single prompt.  Prompting for PTP support for each individual 
ethernet driver is silly.


Nicolas
