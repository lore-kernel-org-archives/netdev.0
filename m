From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Tue, 22 Mar 2016 20:42:24 +0100
Message-ID: <20160322194224.GF6191@pengutronix.de>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de>
 <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de>
 <56EFEDAD.9030903@laposte.net>
 <20160321135457.GX4292@pengutronix.de>
 <56F0150F.8080804@laposte.net>
 <20160321201229.GA6191@pengutronix.de>
 <56F157EF.5080307@laposte.net>
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
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58108 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751352AbcCVTmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 15:42:33 -0400
Content-Disposition: inline
In-Reply-To: <56F157EF.5080307@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sebastian,

On Tue, Mar 22, 2016 at 03:34:23PM +0100, Sebastian Frias wrote:
> I think we are in a deadlock :-)
> I'm going to reply inline below, but I will also send a different ema=
il
> to Daniel with a small recap.
> I think he should share the intent of the "reset" mechanism he
> introduced, in particular if it is mandatory.

The things I said in my mail are valid in general, not only for the
at803x phy.

Let me repeat them once more:

Preconditions:
 - Some of the devices a given driver handles have a reset line and
   others don't.
 - A non-empty subset (maybe all) of the devices that have a reset line
   require that this reset line is used.

Then the way to handle this in the driver should be done as follows:

  unless reset_handling_not_necessary():
    gpio =3D gpiod_get_optional("reset")
    if IS_ERR(gpio):
      return PTR_ERR(gpio)

Checking for -ENOSYS or GPIOLIB=3Dn is not allowed because the device
you're currently handling might need the GPIO, so you must not continue
without the ability to control the line.

So the options you have (as you have a phy that doesn't need the reset
handling):

 - enable GPIOLIB (either in your .config or introduce a Kconfig
   dependency)
 - improve reset_handling_not_necessary() to return true for your case

There is nothing else.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
