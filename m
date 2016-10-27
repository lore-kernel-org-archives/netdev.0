From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 2/5] Documentation: devicetree: net: add NS2 bindings to
 amac
Date: Thu, 27 Oct 2016 17:21:07 -0400
Message-ID: <20161027212106.GA25693@broadcom.com>
References: <1477510561-17035-1-git-send-email-jon.mason@broadcom.com>
 <1477510561-17035-3-git-send-email-jon.mason@broadcom.com>
 <20161027091757.GC12841@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34387 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942133AbcJ0VVR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 17:21:17 -0400
Received: by mail-pf0-f174.google.com with SMTP id n85so24220000pfi.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 14:21:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161027091757.GC12841@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 11:17:57AM +0200, Andrew Lunn wrote:
> On Wed, Oct 26, 2016 at 03:35:58PM -0400, Jon Mason wrote:
> > Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> > ---
> >  Documentation/devicetree/bindings/net/brcm,amac.txt | 7 +++++--
> >  1 file changed, 5 insertions(+), 2 deletions(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/brcm,amac.txt b/Documentation/devicetree/bindings/net/brcm,amac.txt
> > index ba5ecc1..f92caee 100644
> > --- a/Documentation/devicetree/bindings/net/brcm,amac.txt
> > +++ b/Documentation/devicetree/bindings/net/brcm,amac.txt
> > @@ -2,15 +2,18 @@ Broadcom AMAC Ethernet Controller Device Tree Bindings
> >  -------------------------------------------------------------
> >  
> >  Required properties:
> > - - compatible:	"brcm,amac" or "brcm,nsp-amac"
> > + - compatible:	"brcm,amac", "brcm,nsp-amac", or "brcm,ns2-amac"
> >   - reg:		Address and length of the GMAC registers,
> >  		Address and length of the GMAC IDM registers
> > +		Address and length of the NIC Port Manager registers (optional)
> >   - reg-names:	Names of the registers.  Must have both "amac_base" and
> > -		"idm_base"
> > +		"idm_base". "nicpm_base" is optional (required for NS2)
> >   - interrupts:	Interrupt number
> >  
> >  Optional properties:
> >  - mac-address:	See ethernet.txt file in the same directory
> > +- brcm,enet-phy-lane-swap:
> > +		boolean; Swap the PHY lanes (needed on some SKUs of NS2)
> 
> Maybe i'm missing something here, but the patch to the PHY swapped the
> lanes. This seems to be a PHY property, not a MAC property. And it
> swapped them unconditionally....

It swapped them based on (from patch 1/5)
       if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54810 &&
           phydev->dev_flags & PHY_BRCM_EXP_LANE_SWAP)

That flag is being set in the driver based on whether the lanes need
to be swapped (which depends on the SKU of NS2).  The only SKU of NS2
we have upstream right now has it swapped, but one that should be
pushed out in the next few weeks will not have this flag present.
There is no way to detect it, and having a separate compat string
seemed overkill.

Thanks,
Jon

> 
> 	Andrew
