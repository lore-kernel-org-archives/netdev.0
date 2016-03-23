From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Wed, 23 Mar 2016 11:12:07 +0100
Message-ID: <56F26BF7.3090201@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net> <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net> <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net> <20160321201229.GA6191@pengutronix.de> <56F157EF.5080307@laposte.net> <20160322194224.GF6191@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: =?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160322194224.GF6191@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uwe,

On 03/22/2016 08:42 PM, Uwe Kleine-K=F6nig wrote:
> Hello Sebastian,
>=20
> On Tue, Mar 22, 2016 at 03:34:23PM +0100, Sebastian Frias wrote:
>> I think we are in a deadlock :-)
>> I'm going to reply inline below, but I will also send a different em=
ail
>> to Daniel with a small recap.
>> I think he should share the intent of the "reset" mechanism he
>> introduced, in particular if it is mandatory.
>=20
> The things I said in my mail are valid in general, not only for the
> at803x phy.
>=20
> Let me repeat them once more:
>=20
> Preconditions:
>  - Some of the devices a given driver handles have a reset line and
>    others don't.
>  - A non-empty subset (maybe all) of the devices that have a reset li=
ne
>    require that this reset line is used.
>=20
> Then the way to handle this in the driver should be done as follows:
>=20
>   unless reset_handling_not_necessary():
>     gpio =3D gpiod_get_optional("reset")
>     if IS_ERR(gpio):
>       return PTR_ERR(gpio)
>=20
> Checking for -ENOSYS or GPIOLIB=3Dn is not allowed because the device
> you're currently handling might need the GPIO, so you must not contin=
ue
> without the ability to control the line.
>=20
> So the options you have (as you have a phy that doesn't need the rese=
t
> handling):
>=20
>  - enable GPIOLIB (either in your .config or introduce a Kconfig
>    dependency)
>  - improve reset_handling_not_necessary() to return true for your cas=
e
>=20

I will see if I can "improve reset_handling_not_necessary() to return t=
rue".

Best regards,

Sebastian
