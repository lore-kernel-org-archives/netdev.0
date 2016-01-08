From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: Support for non-HW interrupt devices
Date: Fri, 8 Jan 2016 22:36:40 +0100
Message-ID: <20160108213640.GA28440@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40493795@CHN-SV-EXMX02.mchp-main.com>
 <20160108004238.GD4389@lunn.ch>
 <568F1A1B.1040808@gmail.com>
 <20160108192436.GB26321@lunn.ch>
 <56901B96.8020606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Woojung.Huh@microchip.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44284 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754560AbcAHVgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 16:36:43 -0500
Content-Disposition: inline
In-Reply-To: <56901B96.8020606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sounds good, I will send some patches shortly which really fix the PHY
> state machine not to poll PHYs configured with PHY_IGNORE_INTERRUPT and
> fixing phy_mac_interrupt() to be callable in hard IRQ context (finally).

This last be could be interesting. One of the things i needed to do
was change request_irq to request_threaded_irq(). Because i need to do
MDIO reads to determine what PHY causes the interrupts, the code is in
thread context when it actually fires the interrupt.

The core IRQ code is happy to turn an interrupt context interrupt into
a threaded context interrupt, but it cannot do it the other way
around.

Using threaded interrupts would also allow the phylib code to be
simplified, but i didn't get that far yet.

	    Andrew
