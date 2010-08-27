From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 16:02:05 +0200
Message-ID: <20100827140205.GA3293@riccoc20.at.omicron.at>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100827134154.50eef56c-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
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

On Fri, Aug 27, 2010 at 01:41:54PM +0100, Alan Cox wrote:
> > The master node in a PTP network probably takes its time from a
> > precise external time source, like GPS. The GPS provides a 1 PPS
> > directly to the PTP clock hardware, which latches the PTP hardware
> > clock time on the PPS edge. This provides one sample as input to a
> > clock servo (in the PTPd) that, in turn, regulates the PTP clock
> > hardware.
> 
> A PTP clock is TAI, Unix time is UTC.

But TAI and UTC progress at the same rate, and UTC differs from TAI by
a constant offset. In fact, the needed conversion is provided by the
protocol, so it is not hard to take a 1 PPS from GPS and set the PTP
clock to TAI.

> > This is the core issue and source of misunderstanding, in my view. The
> > fact of the matter is, the current generation of computers has
> > multiple clocks, and these are usually unsynchronized. I think we
> > should not try too hard to cover up or work around this. It is a fact
> > of life.
> 
> In this case I don't think you can. Their divergence is rather difficult
> to handle unless you have a GPS to hand.
> 
> But all this talk of "PTP this" and "PTP that" is not helpful. Any
> interface for additional time sources should be generic with PTP being
> one use case.

To tell the truth, my original motivation for the patch set was to
support PTP clocks and applications. I don't think that is such a bad
idea. After all, the adjtimex interface was added just to support NTP.

At the same time, I can understand the desire to have a generic
hardware clock adjustment API. Let me see if I can understand and
summarize what people are asking for:

	  clock_adjtime(clockid_t id, struct timex *t);

and struct timex gets some new fields at the end.

Using the call, NTPd can call clock_adjtime(CLOCK_REALTIME) and PTPd
can call clock_realtime(CLOCK_PTP) and everyone is happy, no?

Thanks,
Richard
