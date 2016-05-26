From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Thu, 26 May 2016 21:00:00 +0200
Message-ID: <20160526190000.GE3331@pengutronix.de>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de>
 <CACRpkdY3kmOiqVsnBWq8DyDDm-gLjcH4wQ+TTr1+Rp+jYLz+SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	=?utf-8?B?UGF3ZcWC?= Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACRpkdY3kmOiqVsnBWq8DyDDm-gLjcH4wQ+TTr1+Rp+jYLz+SQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 26, 2016 at 11:00:55AM +0200, Linus Walleij wrote:
> On Thu, May 12, 2016 at 8:42 PM, Uwe Kleine-K=F6nig
> <u.kleine-koenig@pengutronix.de> wrote:
>=20
> > [added Linus Walleij to Cc, there is a question for you/him below]
> (...)
> >> +void mdio_device_reset(struct mdio_device *mdiodev, int value)
> >> +{
> >> +     if (mdiodev->reset)
> >> +             gpiod_set_value(mdiodev->reset, value);
> >
> > Before v4.6-rc1~108^2~91 it was not necessary to check for the firs=
t
> > parameter being non-NULL before calling gpiod_set_value. Linus, did=
 you
> > change this on purpose?
>=20
> Not really. And AFAICT it is still not necessary: what changed is tha=
t
> an error message will be printed by VALIDATE_DESC() if you do that.
> And that is proper I guess? I think it's sloppy code to randomly pass=
 in
> NULL to a call and just expect it to bail out, it seems more like
> exercising the error path than something you'd normally rely on.
>=20
> Or am I getting things wrong?

is the following sloppy?:

	somegpio =3D gpiod_get_optional(dev, "some", GPIOD_OUT_LOW);
	if (IS_ERR(somegpio))
		return PTR_ERR(somegpio);
	gpiod_set_value(somegpio, 1);

If not (as I assume) you really changed something as this might trigger
the warning.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
