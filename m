From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: Crashes in -next due to 'phy: add support for a reset-gpio
 specification'
Date: Mon, 23 May 2016 07:25:17 +0200
Message-ID: <20160523052517.GE23704@pengutronix.de>
References: <573BF177.6090507@roeck-us.net>
 <20160522101051.GA23704@pengutronix.de>
 <5741D323.8010509@roeck-us.net>
 <20160522182112.GC23704@pengutronix.de>
 <57425790.3010902@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Walleij <linus.walleij@linaro.org>,
	linux-gpio@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58219 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752746AbcEWFZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 01:25:26 -0400
Content-Disposition: inline
In-Reply-To: <57425790.3010902@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Guenter,

On Sun, May 22, 2016 at 06:06:24PM -0700, Guenter Roeck wrote:
> On 05/22/2016 11:21 AM, Uwe Kleine-K=F6nig wrote:
> >On Sun, May 22, 2016 at 08:41:23AM -0700, Guenter Roeck wrote:
> >>I am not exactly in favor of forcing GPIOLIB to be enabled for ever=
y
> >>system with Ethernet support, just because a few of them may requir=
e
> >>a gpio based phy reset. The same is true, really, for every other
> >>driver using _optional gpiolib functions.
> >>
> >>Personally, I think that the _optional functions in gpiolib _should=
_
> >>return no error if gpiolib is not configured. After all, those
> >>gpio pins _are_ supposed to be optional. gpiolib should be enabled
> >>for affected configurations, ie on systems with gpio support which
> >>do need the optional gpio pins. Forcing gpiolib to be enabled even
> >>in systems with no gpio support seems to be a bit heavy-handed.
> >>It just bloats the kernel on such systems with no added benefit.
> >
> >That's wrong. The usage of gpio_get_optional and friends means that =
the
> >gpio is optional for the *driver*, that is there are devices that ma=
ke
> >use of said gpio and others don't. For the devices where the gpio is
> >specified its usage is not optional. So it must not be ignored e.g. =
by
> >GPIOLIB=3Dn configurations.
>=20
> Hi Uwe,
>=20
> I understand what you are saying, I just have a different perspective=
=2E
> From your point of view, you consider it unacceptable if optional GPI=
O
> pins are made unavailable by changing the configuration to GPIOLIB=3D=
n.
> Ok, but that position has number of drawbacks.
>=20
> Playing the system this way only works if the optional GPIO pins
> are the only GPIO pins in use by the system. In almost all cases, thi=
s
> will not be the case. Disabling GPIOLIB in systems really needing it
> is simply not a realistic option.
>=20
> As such, disabling GPIOLIB to "disable" optional GPIO pins is in most=
 cases
> quite heavy-handed. Whoever wants to "disable" those optional pins ca=
n simply
> disable them by removing the respective lines from the devicetree fil=
e,
> or from the ACPI DSDT. Much easier to do, with less side effects.

Yeah, I agree. I don't see where the idea comes from to disable GPIOLIB
to make a driver work and it seems from your reply that is was mine.
Note I didn't want to imply this. Also I expect that returning NULL in
gpiod_get_optional breaks a few setups and I consider this worse enough
to accept that the driver failes for many devices that would work just
fine with NULL. The reason is that it's easier to debug as the code
fails at a place that is related to the GPIO in question and not at som=
e
obscure point later in time.

> So, in summary, the current approach of mandating that GPIOLIB=3Dy to=
 be able
> to use drivers with optional GPIO pins only has the effect of unneces=
sarily
> increasing the code size for platforms with no GPIO support. Nothing =
else.
> It doesn't prevent users from "disabling" optional GPIO pins. There a=
re other
> means to do that, from manipulating the devicetree file to manipulati=
ng
> the DSDT to disabling ACPI (yes, that works too).

I don't know about ACPI, so I cannot comment here.

> >enable that part of GPIOLIB such that the _optional variants do the
> >following with GPIOLIB=3Dn:
> >
> >	if a GPIO is specified:
> >		return -ENOSYS
> >	else:
> >		return NULL
> >
>=20
> Sure. I thought about it, and had a brief look into the gpiolib code.=
 It would
> require a substantial part of the gpiolib code to be enabled, and as =
mentioned
> it would still be inconsistent as it really only applies to devicetre=
e and
> lookup table based configurations, but not to ACPI.
>=20
> The potential gain of ensuring that GPIOLIB is not accidentally disab=
led
> just doesn't seem to be worth the effort and the cost, at least not t=
o me.
> Any platform which needs GPIOLIB should just have and keep it enabled=
,
> and I don't really see it as such a big deal to expect users to keep =
that
> in mind.
>=20
> On the other side, I do dislike the notion of enforcing GPIOLIB=3Dy j=
ust because
> some driver(s) used by a platform use optional gpio pins.
>=20
> I understand that the current approach is what it is. I just don't
> agree with it, and I don't think it is particularly useful or
> beneficial. But it isn't really worth arguing about either, so let's
> just agree to disagree.

That's fine.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
