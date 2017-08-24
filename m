From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Thu, 24 Aug 2017 18:04:01 +0100
Message-ID: <20170824170401.GA20805@n2100.armlinux.org.uk>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
 <20170824155241.GF28443@kwain>
 <20170824160124.GA18700@lunn.ch>
 <20170824161945.GG28443@kwain>
 <20170824165743.GB18700@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824165743.GB18700@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2017 at 06:57:43PM +0200, Andrew Lunn wrote:
> > I see what could be the issue but I do not understand one aspect though:
> > how could we switch from one PHY to another, as there's only one output
> > between the SoC (and so a given GoP#) and the board. So if a given PHY
> > can handle multiple modes I see, but in the other case a muxing
> > somewhere would be needed? Or did I miss something?
> 
> I think we need a hardware diagram...
> 
> How are the RJ45, copper PHY, SFP module connected to the SoC?
> 
> Somewhere there must be a mux, to select between copper and
> fibre. Where is that mux?

In the 88x3310 PHY:

                     .------- RJ45
MVPP2 ----- 88x3310 PHY
                     `------- SFP+

Here's the commentry I've provided at the very top of the 88x3310 driver
which describes all these modes:

 * There appears to be several different data paths through the PHY which
 * are automatically managed by the PHY.  The following has been determined
 * via observation and experimentation:
 *
 *       SGMII PHYXS -- BASE-T PCS -- 10G PMA -- AN -- Copper (for <= 1G)
 *  10GBASE-KR PHYXS -- BASE-T PCS -- 10G PMA -- AN -- Copper (for 10G)
 *  10GBASE-KR PHYXS -- BASE-R PCS -- Fiber
 *
 * If both the fiber and copper ports are connected, the first to gain
 * link takes priority and the other port is completely locked out.

It's not a copper-only PHY, it's just like most other PHYs out there
that support multiple connections, like the 88e151x series that support
both RJ45 and fibre and can auto-switch between them.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
