From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Thu, 26 May 2016 11:00:55 +0200
Message-ID: <CACRpkdY3kmOiqVsnBWq8DyDDm-gLjcH4wQ+TTr1+Rp+jYLz+SQ@mail.gmail.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
	<3641492.klKRrvS8tr@wasted.cogentembedded.com>
	<20160512184233.GJ30822@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	=?UTF-8?Q?Pawe=C5=82_Moll?= <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160512184233.GJ30822@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2016 at 8:42 PM, Uwe Kleine-K=C3=B6nig
<u.kleine-koenig@pengutronix.de> wrote:

> [added Linus Walleij to Cc, there is a question for you/him below]
(...)
>> +void mdio_device_reset(struct mdio_device *mdiodev, int value)
>> +{
>> +     if (mdiodev->reset)
>> +             gpiod_set_value(mdiodev->reset, value);
>
> Before v4.6-rc1~108^2~91 it was not necessary to check for the first
> parameter being non-NULL before calling gpiod_set_value. Linus, did y=
ou
> change this on purpose?

Not really. And AFAICT it is still not necessary: what changed is that
an error message will be printed by VALIDATE_DESC() if you do that.
And that is proper I guess? I think it's sloppy code to randomly pass i=
n
NULL to a call and just expect it to bail out, it seems more like
exercising the error path than something you'd normally rely on.

Or am I getting things wrong?

Yours,
Linus Walleij
