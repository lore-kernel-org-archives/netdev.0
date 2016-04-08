From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Fri, 8 Apr 2016 15:43:38 -0700
Message-ID: <CAOCOHw5R=PnkafRqx2eGKKm10eLgD4H3u7TjbbhdZMbqVR7LrA@mail.gmail.com>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
	<20151231231039.GA8886@rob-hp-laptop>
	<56ABADEA.40801@codeaurora.org>
	<CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
	<5706B4EF.2050600@codeaurora.org>
	<20160407201009.GA16136@lunn.ch>
	<5706D493.8020700@codeaurora.org>
	<20160408005317.GA28125@lunn.ch>
	<5708013F.90207@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-msm <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sagar Dharia <sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5708013F.90207-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 8, 2016 at 12:06 PM, Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> Andrew Lunn wrote:
>
>> There are two different things here. One is configuring the pin to be
>> a GPIO. The second is using the GPIO as a GPIO. In this case,
>> bit-banging the MDIO bus.
>>
>> The firmware could be doing the configuration, setting the pin as a
>> GPIO. However, the firmware cannot be doing the MDIO bit-banging to
>> make an MDIO bus available. Linux has to do that.
>>
>> Or it could be we have all completely misunderstood the hardware, and
>> we are not doing bit-banging GPIO MDIO. There is a real MDIO
>> controller there, we don't use these pins as GPIOs, etc....
>
>
> Actually, I think there is a misunderstanding.
>
> On the FSM9900 SOC (which uses device-tree), the two pins that connect to
> the external PHY are gpio pins.  However, the driver needs to reprogram the
> pinmux so that those pins are wired to the Emac controller.  That's what the
> the gpio code in this driver is doing: it's just configuring the pins so
> that they connect directly between the Emac and the external PHY.  After
> that, they are no longer GPIO pins, and you cannot use the "GPIO controlled
> MDIO bus".  There is no MDIO controller on the SOC.  The external PHY is
> controlled directly from the Emac and also from the internal PHY.  It is
> screwy, I know, but that's what Gilad was trying to explain.
>

It sounds like you're trying to say that the pins used can be are
muxed as GPIO or MDIO, in the TLMM.

In the downstream kernel this is often seen with the drivers calling
gpio_request() to "reserve" said pins, but all you should do is
described the desired configuration and muxing in the pinctrl node,
reference that from your driver and simply ignore the fact that those
pins could have been used as GPIO pins.

Regards,
Bjorn
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
