From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Fri, 18 Mar 2016 20:12:42 +0100
Message-ID: <20160318191242.GQ4292@pengutronix.de>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de>
 <56EC2525.8000706@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58584 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751661AbcCRTMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 15:12:55 -0400
Content-Disposition: inline
In-Reply-To: <56EC2525.8000706@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sebastian,

On Fri, Mar 18, 2016 at 04:56:21PM +0100, Sebastian Frias wrote:
> On 03/18/2016 01:54 PM, Uwe Kleine-K=F6nig wrote:
> > From a driver perspecitive, it would be nice if devm_gpiod_get_opti=
onal
> > returned NULL iff the respective gpio isn't specified even with
> > GPIOLIB=3Dn, but this isn't sensible either because it would result=
 in
> > quite some gpiolib code to not being conditionally compiled on
> > CONFIG_GPIOLIB any more.
>=20
> Let's say that was the case, what would the PHY code do?

With reset gpios it might not be that critical, but consider an optiona=
l
enable gpio. (Optional in the sense, that some device have it and other=
s
don't, e.g. because the pin is pulled into active level by hardware.)

Now you do:

	gpiod =3D gpiod_get_optional("enable");

and if gpiod now is an error pointer, you must assume that you cannot
operate the device. And even with GPIOLIB=3Dn (and gpiod =3D ERR_PTR(-E=
NOSYS))
you cannot ignore the error. For consistency I'd recommend to do the
same for reset even though there is a chance to get a working device.

> What would you think of making at803x_link_change_notify() print a
> message every time it should do a reset but does not has a way to do =
it?

Then this question is obsolete because the device doesn't probe.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
