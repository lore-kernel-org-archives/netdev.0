From: Michael Heimpold <mhei@heimpold.de>
Subject: Re: [PATCH v2 net-next] net: ethernet: enc28j60: add device tree support
Date: Mon, 25 Apr 2016 20:41:43 +0200
Message-ID: <3251118.0hjDSTMnSh@kerker>
References: <31567588.rB9VrggOb6@wuerfel> <1461533283-24852-1-git-send-email-mhei@heimpold.de> <20160425132326.GA17445@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jonathan Cameron <jic23@kernel.org>,
	"Andrew F . Davis" <afd@ti.com>, Mark Brown <broonie@kernel.org>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:29128 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933058AbcDYSlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 14:41:49 -0400
In-Reply-To: <20160425132326.GA17445@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am Monday 25 April 2016, 08:23:26 schrieb Rob Herring:
> On Sun, Apr 24, 2016 at 11:28:03PM +0200, Michael Heimpold wrote:
> > The following patch adds the required match table for device tree support
> > (and while at, fix the indent). It's also possible to specify the
> > MAC address in the DT blob.
> > 
> > Also add the corresponding binding documentation file.
> > 
> > Signed-off-by: Michael Heimpold <mhei@heimpold.de>
> > ---
> > 
> > v2: * took care of Arnd Bergmann's review comments
> > 
> >       - allow to specify MAC address via DT
> >       - unconditionally define DT id table
> >     
> >     * increased the driver version minor number
> >     * driver author's email address bounces, removed from address list
> >  
> >  .../devicetree/bindings/net/microchip-enc28j60.txt | 50
> >  ++++++++++++++++++++++
> Matching the compatible string is preferred here: microchip,enc28j60.txt
> 

Ok, will change in next round.

> >  drivers/net/ethernet/microchip/enc28j60.c          | 20 +++++++--
> >  2 files changed, 67 insertions(+), 3 deletions(-)
> >  create mode 100644
> >  Documentation/devicetree/bindings/net/microchip-enc28j60.txt> 
> > diff --git a/Documentation/devicetree/bindings/net/microchip-enc28j60.txt
> > b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt new file
> > mode 100644
> > index 0000000..847a97b
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt
> > @@ -0,0 +1,50 @@
> > +* Microchip ENC28J60
> > +
> > +This is a standalone 10 MBit ethernet controller with SPI interface.
> > +
> > +For each device connected to a SPI bus, define a child node within
> > +the SPI master node.
> > +
> > +Required properties:
> > +- compatible: Should be "microchip,enc28j60"
> > +- reg: Specify the SPI chip select the ENC28J60 is wired to
> > +- interrupts: Specify the interrupt and interrupt type (usually falling
> > edge) +
> > +Optional properties:
> > +- interrupt-parent: Specify the pHandle of the source interrupt
> 
> This is required in the sense that either the node or a parent node must
> define it. In this case, since the SPI controller likely has a different
> parent, you will pretty much always need it defined in this node.

Understand. I think I should then move it to the required properties?
BTW: I orientated on the qca-qca7000-spi.txt as this is a SPI ethernet
device, too. Maybe we should also clarify this topic for this binding...

> > +- spi-max-frequency: Maximum frequency of the SPI bus when accessing the
> > ENC28J60. +  According to the ENC28J80 datasheet, the chip allows a
> > maximum of 20 MHz, however, +  board designs may need to limit this
> > value.
> > +- local-mac-address: See ethernet.txt in the same directory.
> > +
> > +
> > +Example (for NXP i.MX28 with pin control stuff for GPIO irq):
> > +
> > +        ssp2: ssp@80014000 {
> > +                compatible = "fsl,imx28-spi";
> > +                pinctrl-names = "default";
> > +                pinctrl-0 = <&spi2_pins_b &spi2_sck_cfg>;
> > +                status = "okay";
> > +
> > +                enc28j60: ethernet@0 {
> > +                        compatible = "microchip,enc28j60";
> > +                        pinctrl-names = "default";
> > +                        pinctrl-0 = <&enc28j60_pins>;
> 
> Need to document using the pinctrl binding.

Would it be enough, when I list both properties above and refer to
the pinctrl binding?
I wondered whether there are other possibilities to wire the irq,
but I guess that using GPIO line is the usual way to do, so I'd add
this to required properties, too.

Thanks for your feedback, regards

Michael
> 
> > +                        reg = <0>;
> > +                        interrupt-parent = <&gpio3>;
> > +                        interrupts = <3 IRQ_TYPE_EDGE_FALLING>;
> > +                        spi-max-frequency = <12000000>;
> > +                };
> > +        };
> > +
