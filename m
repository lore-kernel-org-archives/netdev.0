From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] dsa: mv88e6xxx.c: Hardware reset the chip
 if available
Date: Thu, 19 Nov 2015 03:25:14 +0100
Message-ID: <20151119022514.GE25930@lunn.ch>
References: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
 <1447889365-25256-3-git-send-email-andrew@lunn.ch>
 <564D2F16.1020701@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36970 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756537AbbKSCZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 21:25:20 -0500
Content-Disposition: inline
In-Reply-To: <564D2F16.1020701@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is a general query about what is the preferred method of allocating gpios.
> The gpiod* family of functions provided similar functionality and automatically
> deal with active low / high outputs, direction, inital value  etc...
> I raise this more for knowledge on what method I should use for my patches.

I first tried using gpiod, but failed. The API requires that the gpios
be in the root of the device's subtree in the DT blob. But here the
gpios are associated to a switch, and the switch part of the subtree
is one level down. gpiod has no way to get them from there.

> Other than that the concept looks good and something I has been
> looking at adding.

Please feel free to test it on your hardware and send a Tested-by :-)

> Would it be worth considering placing the chip in reset on driver
> remove?  I have an battery powered hardware platform using one of
> this marvell devices and for certain configurations we don't need
> the switch active. So unloading the module to place the device in
> reset and would save power.  Reloading would reinitialise the port.

I think we first need to get module unload/load working reliably.
This is being worked on. But i'm not against this in principle.  Power
saving in general needs working on for Marvall devices. There is no
suspend/resume support for example. It would also be good to ensure
the PHYs are powered off when not needed, etc.

    Andrew
