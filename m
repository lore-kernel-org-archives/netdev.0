From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] I.MX6: Fix Ethernet PHY mode on Ventana boards
Date: Tue, 8 Dec 2015 15:41:38 +0100
Message-ID: <20151208144138.GB13328@lunn.ch>
References: <m3egeyct8o.fsf@t19.piap.pl>
 <CAJ+vNU0bNzuDJ971VS4r0gt4+zJj4GkXWE_qzoC0bs7s4OdU1Q@mail.gmail.com>
 <m3zixlav0p.fsf@t19.piap.pl>
 <CAJ+vNU0RsXB7j4F5+M8d0Z06=eS1pkMRnyYOfimNPkXe-TfKbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Ha??asa <khalasa@piap.pl>,
	netdev <netdev@vger.kernel.org>, Shawn Guo <shawnguo@kernel.org>,
	Fabio Estevam <Fabio.Estevam@freescale.com>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32889 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755329AbbLHOll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 09:41:41 -0500
Content-Disposition: inline
In-Reply-To: <CAJ+vNU0RsXB7j4F5+M8d0Z06=eS1pkMRnyYOfimNPkXe-TfKbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This may be a stupid question but what does the Marvell phy driver
> offer that the generic phy driver does not?

It reliably configures the RGMII delays :-)

No need to depend on your bootloader doing it.

It allows interrupts to be used instead of polling the PHY all the
time, assuming you have the interrupt wired up.  There are
peculiarities for enabling autoneg which is knows about. It might put
the LEDs into a well known state, but that depends on the model. It
might enable auto-crossover on some PHYs. It has some errata
workarounds, support for WOL. You can put a list of register writes in
DT which will be performed when auto neg is enabled. This could be
used for example to configure the LEDs.

Not yet posted, but i have a patch to add HWMON support to read the
temperature sensor in some of the PHYs.

	    Andrew
