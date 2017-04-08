From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: davinci_mdio: add GPIO reset logic
Date: Sat, 8 Apr 2017 17:10:50 +0200
Message-ID: <20170408151050.GA30797@lunn.ch>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <20170408.065545.2057882592764132853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rogerq@ti.com, tony@atomide.com, nsekhar@ti.com, jsarha@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170408.065545.2057882592764132853.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 08, 2017 at 06:55:45AM -0700, David Miller wrote:
> From: Roger Quadros <rogerq@ti.com>
> Date: Wed, 5 Apr 2017 11:33:57 +0300
> 
> > Some boards [1] leave the PHYs at an invalid state
> > during system power-up or reset thus causing unreliability
> > issues with the PHY like not being detected by the mdio bus
> > or link not functional. To work around these boards have
> > a GPIO connected to the PHY's reset pin.
> > 
> > Implement GPIO reset handling for such cases.
> > 
> > [1] - am572x-idk, am571x-idk, a437x-idk.
> > 
> > Signed-off-by: Roger Quadros <rogerq@ti.com>
> > Signed-off-by: Sekhar Nori <nsekhar@ti.com>
> 
> I have not seen a resolution in this discussion.
> 
> My understanding is that there are several cases (single MDIO bus whose
> reset does a reset on all that MDIO bus's PHYs, etc.) and it's unclear
> how to handle all such cases cleanly.

I see it falling into two cases.

1) We have a GPIO which resets one PHY. In this case, the GPIO is a
PHY property, it should be documented in
Documentation/devicetree/bindings/net/phy.txt. Hopefully there is
nothing PHY driver specific here, so all the handling can be placed in
the core PHY code.

2) We have one or more GPIOs which reset more than one PHY. In this
case, the GPIOs are MDIO bus properties. Again, there should not be
anything which is MDIO bus driver specific, so all the handling can be
placed in the core MDIO bus code.

       Andrew
