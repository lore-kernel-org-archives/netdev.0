From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 19:25:01 +0100
Message-ID: <20130916182501.GN12758@n2100.arm.linux.org.uk>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com> <20130915205701.5c61a444@skate> <20130916065047.GH27487@1wt.eu> <20130916175152.4e013457@skate> <20130916162209.GL12758@n2100.arm.linux.org.uk> <20130916182450.639084c6@skate> <20130916171416.GM12758@n2100.arm.linux.org.uk> <20130916174514.GF3188@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ethan Tuttle <ethan@ethantuttle.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?iso-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54962 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353Ab3IPSZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 14:25:38 -0400
Content-Disposition: inline
In-Reply-To: <20130916174514.GF3188@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 07:45:14PM +0200, Willy Tarreau wrote:
> This board has a really clean routing and placement, chips are very close.
> That does not rule out the possibility of a lacking termination, but it
> would probably affect more users.

True - though in your photographs, we can't see the tracking for the
data bus, because that's all buried in the inner board layers.
However, there is some evidence in there of trace lengths being matched
which is a good sign. :)

> On Mon, Sep 16, 2013 at 06:14:16PM +0100, Russell King - ARM Linux wrote:
> > Marginal or noisy power supplies could also be a problem - for example,
> > if the impedance of the power supply connections is too great, it may
> > work with some patterns of use but not others.
> 
> We have some margin here, I measured less than 1 Amp to boot and something
> like 6-700 mA in idle if my memory serves me correctly. The 3A PSU and its
> thicker-than-average wires seem safe. I think that Globalscale learned a
> lot from the horrible Guruplug design that all this part needs to be done
> correctly and they did a very clean job this time.

Not quite the power supply I was referring to - I'm talking about the
on-board regulators which supply the 3.3V and other lower voltages to
the SDRAM and SoC - and the quality of their decoupling.  The on-board
regulators will have a certain degree of "line" noise immunity.

If I had to guess, I'd say C366 is probably the output bulk capacitor on
the CPU core supply (which comes via BIT7, C273, L1, U19 being the
switching regulator chip.

I'd also guess one of C370, C396 or C398 supplies the SDRAM - and of
those C370 is the most likely - the resistors in the boxes marked K and
B, and R123 I suspect may be the SDRAM data bus termination (that
covers R107 to R136), though I only count a total of 30 of those
connecting to U5 pin 4 - and that point looks _well_ decoupled with lots
of capacitors (C8-C16, C287 on one side, C7, C246, C247 on the other.)
The other two?  Maybe R105/106 which are on the underside of the CPU,
though they're a long way from that well decoupled point.  R137/138?
They're up by the NAND chip and connect to ground.  Though... if one
of those is for D8...

Anyway, that's all speculation.
