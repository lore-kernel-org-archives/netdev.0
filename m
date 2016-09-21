From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Wed, 21 Sep 2016 12:20:30 +0200
Message-ID: <20160921122030.408c97f1@griffin>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org>
        <20160920202556.GA6713@localhost.localdomain>
        <20160920204556.GA7555@localhost.localdomain>
        <alpine.LFD.2.20.1609201655200.9311@knanqh.ubzr>
        <alpine.DEB.2.20.1609202300140.5476@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        John Stultz <john.stultz@linaro.org>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1609202300140.5476@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2016 23:09:52 +0200 (CEST), Thomas Gleixner wrote:
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

Ouch. So, after the hassle to remove the VXLAN and GENEVE configs from
tons of drivers, we'll add another one instead? That's just silly. If
we did this for every thing we support in NICs, we would end up with
something completely unmanageable.

PTP should be really configured by a single switch.

Btw., your suggestion does not work, select is not recursive.

> We have already drivers following that scheme. That way you make the PTP
> support in the driver conditional on DRIVER_X_PTP and have no hassle with
> modules and dependencies.

We've recently got rid of some of those, thankfully. Caused more harm
than good.

 Jiri
