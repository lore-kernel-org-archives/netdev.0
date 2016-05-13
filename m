From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Fri, 13 May 2016 22:44:36 +0200
Message-ID: <20160513204436.GC7600@lunn.ch>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de>
 <5735995B.8030802@ti.com>
 <b9bcc192-f97b-304e-77b2-894c4528ddb6@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Quadros <rogerq@ti.com>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, grant.likely@linaro.org,
	robh+dt@kernel.org, devicetree@vger.kernel.org,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	frowand.list@gmail.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux-kernel@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37837 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932254AbcEMUot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 16:44:49 -0400
Content-Disposition: inline
In-Reply-To: <b9bcc192-f97b-304e-77b2-894c4528ddb6@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Another issue is that on some boards we have one reset line tied to
> >multiple PHYs.How do we prevent multiple resets being taking place when each of
> >the PHYs are registered?
> 
>    My patch just doesn't address this case -- it's about the
> individual resets only.

This actually needs to be addresses a layer above. What you have is a
bus reset, not a device reset. So the gpio line is associated to the
mdio bus, not a PHY. Either your MDIO driver needs to handle the gpio
line, or in __mdio_register(), before it starts looking at the
children.

	Andrew
