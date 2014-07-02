From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] rcar_can: add device tree support
Date: Wed, 2 Jul 2014 11:14:37 +0100
Message-ID: <20140702101437.GC14665@leverpostej>
References: <201407020227.04235.sergei.shtylyov@cogentembedded.com>
 <53B33B45.1060205@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	Pawel Moll <Pawel.Moll@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"vksavl@gmail.com" <vksavl@gmail.com>,
	"rdunlap@infradead.org" <rdunlap@infradead.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:33894 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753123AbaGBKOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 06:14:44 -0400
Content-Disposition: inline
In-Reply-To: <53B33B45.1060205@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 01, 2014 at 11:50:45PM +0100, Marc Kleine-Budde wrote:
> On 07/02/2014 12:27 AM, Sergei Shtylyov wrote:
> > Add support of the device tree probing for the Renesas R-Car CAN controllers
> > documenting the device tree bindings as necessary.
> 
> Please put the DT documentation into a separate patch, make it the first
> one. When reposting, please put the device tree mailing list on Cc.
> 
> > Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> > 
> > ---
> > The patch is against the Dave Miller's 'net-next.git' repo ('linux-can-next.git'
> > repo still doesn't have the R-Car CAN driver for some reason).
> 
> Should be fixed now :)
> 
> > 
> >  Documentation/devicetree/bindings/net/can/rcar_can.txt |   40 +++++++++++++++++
> >  drivers/net/can/rcar_can.c                             |   28 +++++++++--
> >  2 files changed, 63 insertions(+), 5 deletions(-)
> > 
> > Index: net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
> > ===================================================================
> > --- /dev/null
> > +++ net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
> > @@ -0,0 +1,40 @@
> > +Renesas R-Car CAN controller Device Tree Bindings
> > +-------------------------------------------------
> > +
> > +Required properties:
> > +- compatible: "renesas,can-r8a7778" if CAN controller is a part of R8A7778 SoC.
> > +	      "renesas,can-r8a7779" if CAN controller is a part of R8A7779 SoC.
> > +	      "renesas,can-r8a7790" if CAN controller is a part of R8A7790 SoC.
> > +	      "renesas,can-r8a7791" if CAN controller is a part of R8A7791 SoC.
> 
> AFAIK we usually specify the first SoC with this core as the only
> compatible.

Not quite. While the driver only needs to have support for that and
DTS files should have that string in the compatible list, the other
strings can be present in the binding and earlier in the compatible list
to allow us to distinguish the variants later (without requiring changes
to DTBs).

> > +- reg: physical base address and size of the R-Car CAN register map.
> > +- interrupts: interrupt specifier for the sole interrupt.
> > +- clocks: phandle and clock specifier for the R-Car CAN clock input.
> > +- pinctrl-0: pin control group to be used for this controller.
> > +- pinctrl-names: must be "default".
> > +
> > +Optional properties:
> > +- clock-select: R-Car CAN Clock Source Select. Valid values are:
> > +		<0x0> (default) : Peripheral clock (clkp1)
> > +		<0x1> : Peripheral clock (clkp2)
> > +		<0x3> : Externally input clock

What's this for, and how does this interact with the single clock listed
above?

THanks,
Mark.
