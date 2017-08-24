From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Thu, 24 Aug 2017 17:59:47 +0100
Message-ID: <20170824165947.GZ20805@n2100.armlinux.org.uk>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
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
In-Reply-To: <20170824145609.GJ8022@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2017 at 04:56:09PM +0200, Andrew Lunn wrote:
> On Thu, Aug 24, 2017 at 10:38:19AM +0200, Antoine Tenart wrote:
> > This patch adds logic to reconfigure the comphy/gop when the link status
> > change at runtime. This is very useful on boards such as the mcbin which
> > have SFP and Ethernet ports connected to the same MAC port: depending on
> > what the user connects the driver will automatically reconfigure the
> > link mode.
> 
> Hi Antoine
> 
> I would expect each of these external Ethernet ports to have its own
> Ethernet PHY. Don't you need to disconnect from one Ethernet phy and
> connect to the other Ethernet PHY when you change external Ethernet
> port?

I think you're all getting confused.  The link mode has very little to
do with whether you're using SFP+ or whether you're using the RJ45 at
10G speeds.  The link mode has everything to do with the speed at which
the link is negotiated at.

So please, put SFP+ out of your minds for this - SFP+ isn't the reason
why you need to switch the MAC link mode.

In all cases, the mvpp2 to 88x3310 link ends up in one of two modes:
1. SGMII for RJ45 speeds less than 10G.  Autonegotiation on SGMII
    at the mvpp2 end *must* be enabled for the PHY to work.

2. 10Gbase-R for 10G speeds, whether that be for SFP+ or RJ45 at 10G.
   Note: mcbin does not support SFP (1G) modules on the SFP+ ports.

The 88x3310 driver in the kernel knows about these combinations and
sets the phy interface parameter correctly depending on whether the
PHY has configured itself for copper at whatever speed or SFP+.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
