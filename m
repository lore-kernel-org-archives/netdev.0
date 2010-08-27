From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 15:50:40 +0100
Message-ID: <20100827155040.0502ec1b@lxorguk.ukuu.org.uk>
References: <20100817085324.GB3330@riccoc20.at.omicron.at>
	<1282090963.1734.97.camel@localhost>
	<20100818071942.GA4096@riccoc20.at.omicron.at>
	<1282176776.2865.100.camel@localhost.localdomain>
	<20100819055518.GA4084@riccoc20.at.omicron.at>
	<1282594125.3111.344.camel@localhost.localdomain>
	<AANLkTi=nKrRHH6+9mvny718gov8Q+u7DHFikdgNY8YdX@mail.gmail.com>
	<1282874269.4371.74.camel@localhost.localdomain>
	<20100827075727.GA3818@riccoc20.at.omicron.at>
	<20100827134154.50eef56c@lxorguk.ukuu.org.uk>
	<20100827140205.GA3293@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20100827140205.GA3293-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
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

> To tell the truth, my original motivation for the patch set was to
> support PTP clocks and applications. I don't think that is such a bad

ptp *clocks*

> idea. After all, the adjtimex interface was added just to support NTP.
> 
> At the same time, I can understand the desire to have a generic
> hardware clock adjustment API. Let me see if I can understand and
> summarize what people are asking for:
> 
> 	  clock_adjtime(clockid_t id, struct timex *t);
> 
> and struct timex gets some new fields at the end.

For a new syscall you could equally make it

	(clockid_t id, void *args)

> Using the call, NTPd can call clock_adjtime(CLOCK_REALTIME) and PTPd
> can call clock_realtime(CLOCK_PTP) and everyone is happy, no?

If you only have one clock that you are calling 'the PTP clock' - but is
that a good assumption ?

I agree with your fundamental arguments as I understand them

- That it's another clock or clocks possibly not synchronized with the
  system clock

- That there should be a sensible API for doing slews and steps on other
  clocks but the systen clock.

I'm concerned about the assumption that there is a single magic PTP
clock, and calling it a PTP clock for two reasons

- There can be more than one

- PTP is just a protocol, in five years time it might be TICTOC or
  something newer and more wonderous, in some environments it'll be a
  synchronous distributed clock generation not PTP etc. Wiring PTP or
  IEE1588v2 into the clock name doesn't make sense.

I'd be happier with a model which says we have some arbitary number of
synchronization sources which may or may not have a connection to system
time, and may be using all sorts of synchronization methods. Clock in
fact seems almost a misnomer.

Alan
