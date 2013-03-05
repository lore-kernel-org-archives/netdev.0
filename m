From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHi v2] net: sh_eth: Add support of device tree probe
Date: Tue, 5 Mar 2013 09:43:35 +0900
Message-ID: <20130305004335.GF9439@verge.net.au>
References: <1360803091-26400-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <20130215163251.GA2597@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>,
	"kda@linux-powerpc.org" <kda@linux-powerpc.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:50769 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758791Ab3CEAnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 19:43:39 -0500
Content-Disposition: inline
In-Reply-To: <20130215163251.GA2597@e106331-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 04:32:51PM +0000, Mark Rutland wrote:
> Hello,
> 
> I have a couple of comments on the binding and the way it's parsed.
> 
> On Thu, Feb 14, 2013 at 12:51:31AM +0000, Nobuhiro Iwamatsu wrote:
> > This adds support of device tree probe for Renesas sh-ether driver.
> > 
> > Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> > 
> > ---
> > V2: - Removed ether_setup().
> >     - Fixed typo from "sh-etn" to "sh-eth".
> > 	- Removed "needs-init" and sh-eth,endian from definition of DT.
> > 	- Changed "sh-eth,edmac-endian" instead of "sh-eth,edmac-big-endain"
> > 	  in definition of DT.
> > 
> >  Documentation/devicetree/bindings/net/sh_ether.txt |   41 +++++
> >  drivers/net/ethernet/renesas/sh_eth.c              |  156 +++++++++++++++++---
> >  2 files changed, 173 insertions(+), 24 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/net/sh_ether.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/sh_ether.txt b/Documentation/devicetree/bindings/net/sh_ether.txt
> > new file mode 100644
> > index 0000000..7415e54
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/sh_ether.txt
> > @@ -0,0 +1,41 @@
> > +* Renesas Electronics SuperH EMAC
> > +
> > +This file provides information, what the device node
> > +for the sh_eth interface contains.
> > +
> > +Required properties:
> > +- compatible:                   "renesas,sh-eth";
> > +- interrupt-parent:             The phandle for the interrupt controller that
> > +                                services interrupts for this device.
> 
> Is this really a required property?
> 
> As it's a standard property with a well-defined meaning, is it necessary to
> document?
> 
> > +- reg:                          Offset and length of the register set for the
> > +                                device.
> 
> The example below shows 2 reg values, yet this implies only one is necessary.
> 
> > +- interrupts:                   Interrupt mapping for the sh_eth interrupt
> > +                                sources (vector id).
> 
> How many interrupts are expected, what are they, and in what order should they be in?
> 
> > +- phy-mode:                     String, operation mode of the PHY interface.
> 
> What are the valid values for this?
> 
> If they're defined in another document, it'd be good to reference it.
> 
> > +- sh-eth,register-type:         String, register type of sh_eth.
> > +                                Please select "gigabit", "fast-sh4" or
> > +                                "fast-sh3-sh2".
> 
> Why are these not handled as separate versions using the compatible string to
> differentiate them?

Hi Iwamatasu-san,

Could you please address this review?
I believe it is still applicable as of v5 which you posted yesterday.
