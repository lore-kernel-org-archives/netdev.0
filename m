From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: Re: [PATCH] net: phy: micrel: Add KSZ8041FTL fiber mode support
Date: Thu, 14 Jul 2016 15:16:16 +0200
Message-ID: <1468502176.2260.31.camel@pengutronix.de>
References: <1468491528-17515-1-git-send-email-p.zabel@pengutronix.de>
	 <d7474fed-89cb-1089-5b52-f8964cd7f840@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:54321 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbcGNNQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 09:16:19 -0400
In-Reply-To: <d7474fed-89cb-1089-5b52-f8964cd7f840@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

Am Donnerstag, den 14.07.2016, 14:35 +0300 schrieb Sergei Shtylyov:
> Hello.
> 
> On 7/14/2016 1:18 PM, Philipp Zabel wrote:
> 
> > We can't detect the FXEN (fiber mode) bootstrap pin, so configure
> > it via a boolean device tree property "fxen". If it is enabled,
> > auto-negotiation is not supported. The only available modes are
> > 100base-fx (full duplex and half duplex).
> >
> > Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
> > ---
> > I didn't see a way to reliably detect whether the PHY is set to fiber
> > mode in the datasheet [1], so this patch adds a device tree property
> > to enforce fiber mode (disable auto-negotiation, set speed to 100).
> >
> > [1] http://ww1.microchip.com/downloads/en/DeviceDoc/ksz8041tl-ftl-mll.pdf
> > ---
> >  .../devicetree/bindings/net/micrel-ksz8041.txt     | 24 ++++++++++++++++
> >  drivers/net/phy/micrel.c                           | 32 ++++++++++++++++++++--
> >  include/linux/micrel_phy.h                         |  1 +
> >  3 files changed, 55 insertions(+), 2 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz8041.txt
> >
> > diff --git a/Documentation/devicetree/bindings/net/micrel-ksz8041.txt b/Documentation/devicetree/bindings/net/micrel-ksz8041.txt
> > new file mode 100644
> > index 0000000..4bce38d2
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/micrel-ksz8041.txt
> 
>     I think your text should be added to micrel.txt instead.

Thank you for the comments. Since FXEN may be relevant for PHYs other
than KSZ8041FTL, too, I'll move it into micrel.txt as you suggest.

> > @@ -0,0 +1,24 @@
> > +Micrel KSZ8041 Gigabit Ethernet PHY
> > +
> > +The KSZ8041FTL variant supports fiber mode, enabled by the FXEN boot
> > +strapping pin. It can't be determined from the PHY registers whether
> > +the PHY is in fiber mode, so a boolean device tree property can be
> > +used to describe this.
> > +
> > +Optional properties:
> > + - fxen : KSZ8041FTL is strapped to fiber mode. Auto-negotiation is disabled
> 
>     It should be named micrel,fxen.

Ok, I'll rename it.

regards
Philipp
