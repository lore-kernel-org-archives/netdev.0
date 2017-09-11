From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 10/10] net: stmmac: dwmac-sun8i: Handle
 integrated/external MDIOs
Date: Mon, 11 Sep 2017 18:11:24 +0200
Message-ID: <20170911161124.GD27599@lunn.ch>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-11-clabbe.montjoie@gmail.com>
 <20170908130520.GA11248@lunn.ch>
 <20170908132632.GA3037@Red>
 <20170908140020.GC25219@lunn.ch>
 <20170908140832.GB3037@Red>
 <20170908141736.GF25219@lunn.ch>
 <20170908142825.GC3037@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37299 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750957AbdIKQLg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 12:11:36 -0400
Content-Disposition: inline
In-Reply-To: <20170908142825.GC3037@Red>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 08, 2017 at 04:28:25PM +0200, Corentin Labbe wrote:
> On Fri, Sep 08, 2017 at 04:17:36PM +0200, Andrew Lunn wrote:
> > > > Do you know why the reset times out/fails?
> > > > 
> > > 
> > > Because there are nothing connected to it.
> > 
> > That should not be an issue. A read should just return 0xffff.  And it
> > should return 0xffff fast. The timing of the MDIO protocol is fixed. A
> > read or a write takes a fixed number of cycles, independent of if
> > there is a device there or not. The bus data line has a pullup, so if
> > you try to access a missing device, you automatically read 0xffff.
> > 
> 
> Perhaps, but the reality is that with nothing connected to it, the reset of the MAC timeout.
> Certainly, the MAC does not support finding no PHY.

Are you sure this is not because of the clock and reset?

+                               #address-cells = <1>;
+                               #size-cells = <0>;
+                               int_mii_phy: ethernet-phy@1 {
+                                       compatible = "ethernet-phy-ieee802.3-c22";
+                                       reg = <1>;
+                                       clocks = <&ccu CLK_BUS_EPHY>;
+                                       resets = <&ccu RST_BUS_EPHY>;

The way you describe it here, the clock and reset are for the PHY. But
maybe it is actually for the bus? I can understand a bus timing out if
it has no clock, or it is held in reset. Try enabling the clock and
reset when the internal bus is selected, not when the PHY on the bus
is selected.

	Andrew
