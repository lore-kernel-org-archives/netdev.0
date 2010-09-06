From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Mon, 6 Sep 2010 08:33:27 +0200
Message-ID: <20100906063327.GA4549@riccoc20.at.omicron.at>
References: <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	<AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	<20100817085324.GB3330@riccoc20.at.omicron.at>
	<1282090963.1734.97.camel@localhost>
	<20100818071942.GA4096@riccoc20.at.omicron.at>
	<1282176776.2865.100.camel@localhost.localdomain>
	<20100819055518.GA4084@riccoc20.at.omicron.at>
	<1282594125.3111.344.camel@localhost.localdomain>
	<20100827123849.GC11657@riccoc20.at.omicron.at>
	<1282948239.2268.155.camel@jstultz-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1282948239.2268.155.camel@jstultz-laptop>
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

On Fri, Aug 27, 2010 at 03:30:39PM -0700, John Stultz wrote:
> On Fri, 2010-08-27 at 14:38 +0200, Richard Cochran wrote:
> > We have not introduced new PPS interface. We use existing PPS subsystem.
> 
> Doesn't the pps subsystem have its own way to control the pps signal
> interrupt? I'm not totally sure here, but given your point above that
> having multiple pps events it seems like they should be selectable. It
> seems something that we'd want to control via the global pps interface,
> rather then having a pps-enable flag on every random bit of hardware
> that can support it.

The PPS subsystem offers no way to disable PPS interrupts. 

> > > Same for the timestamps and periodic output (ie: and how do they differ
> > > from reading or setting a timer on CLOCK_PTP?)
> > 
> > The posix timer calls won't work:
> > 
> > I have a PTP hardware clocks with multiple external timestamp
> > channels. Using timer_gettime, how can I specify (or decode) the
> > channel of interest to me?
> 
> I guess I'm not following you here. Again, I'm not super familiar with
> the hardware involved. Could you clarify a bit more? What do you mean by
> external timestamp? Is this what is used on the packet timestamping? 

No, the packet timestamp occurs in the PHY, MAC, or on the MII bus and
is an essential feature to support the PTP.

An external timestamp is just a wire going into the clock and is an
optional feature to make the clock more useful. The clock can latch
the current time value when an edge is dectected on the wire. Using
external timestamps, you correlate real world events with the absolute
time in the clock.

Typically, a clock offers two or more such input channels (wires), but
timer_gettime does not offer a way to differentiate between them, and
thus is not suitable.

> The posix clock id interface is frustrating because the flat static
> enumeration is really limiting.
> 
> I wonder if a dynamic enumeration for posix clocks would be possibly a
> way to go?

I am perfectly happy with this.

> In other words, a driver registers a clock with the system, and the
> system reserves a clock_id for it from the designated available pool and
> assigns it back. Then userland could query the driver via something like
> sysfs to get the clockid for the hardware. 
> 
> Would that maybe work? 

I have now posted a sample implementation of this idea. Do you like it?

> > The sysfs will include one class device for each PTP clock. Each clock
> > has a sysfs attribute with the corresponding clock id.
> 
> Do you mean the clock_id # in the posix clocks namespace?

Yes.

> > I would also be happy with the character device idea already
> > posted. Just pick one of the two, and I'll resubmit the patch set...
> 
> Personally, with regard to exposing the ptp clock to userland I'm more
> comfortable via the chardev. However, the posix clocks/timer api is
> really close to what you need, so I'm not totally set against it. And
> maybe the dynamic enumeration would resolve my main problems with it?

Okay, I have posted a draft of the dynamic idea. Can you support it?

> That said, with the chardev method, I don't like the idea of duplicating
> the existing time apis via a systemtime device. Dropping that from your
> earlier patch would ease the majority of my objections.

Well, the clock interface needs to offer basic services:

1. Set time
2. Get time
3. Jump offset
4. Adjust frequency

This is similar to what the posix clock and ntp API offer. Using a
chardev, should I make the ioctls really different, just for the
purpose of being different?

To me, it makes more sense to offer a familiar interface.

I was perfectly happy with the chardev idea. In fact, that is the way
I first implemented it. Now, I have also gone ahead and implemented
the dynamic posix clock idea, too.

> > At this point I would just like to go forward with one of the two
> > proposed APIs. I had modelled the character device on the posix clock
> > calls in order to make it immediately familar, and I think it is a
> > viable approach. After the lkml discussion, I think it is even cleaner
> > and nicer to just offer a new clock id.

I would like to repeat the sentiment in this last paragraph! I already
implemented and would be content with either form for the new clock
control API:

1. Character device
2. POSIX clock with dynamic ids

Please, just take your pick ;^)

Thanks,
Richard
