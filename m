From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Fri, 13 May 2016 06:06:53 +0200
Message-ID: <20160513040653.GA24461@lunn.ch>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de>
 <f1fae99f-2464-8a42-deb8-c27cccf8df12@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, grant.likely@linaro.org,
	robh+dt@kernel.org, devicetree@vger.kernel.org,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	frowand.list@gmail.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux-kernel@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f1fae99f-2464-8a42-deb8-c27cccf8df12@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>+	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
> >>+	/* Deassert the reset signal */
> >>+	if (!IS_ERR(gpiod))
> >>+		gpiod_direction_output(gpiod, 0);
> >
> >This is wrong I think. You must only ignore -ENODEV, all other error
> 
>    At least -ENOSYS should also be ignored (it's returned when
> gpiolib is not configured), right? When does -ENODEV gets returned
> (it's not easy to follow)?
> 
> >codes should be passed to the caller.
> 
>    The caller doesn't care anyway...

It should do. What if fwnode_get_named_gpiod() returns -EPROBE_DEFER
because the GPIO driver has not been loaded yet?

	Andrew
