From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [EXT] Re: [PATCH net-next 09/13] net: mvpp2: dynamic
 reconfiguration of the PHY mode
Date: Fri, 25 Aug 2017 09:19:55 +0100
Message-ID: <20170825081955.GC20805@n2100.armlinux.org.uk>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
 <20170824155241.GF28443@kwain>
 <20170824160124.GA18700@lunn.ch>
 <20170824161945.GG28443@kwain>
 <de67e234a7ff43b49346be5cea2466eb@IL-EXCH01.marvell.com>
 <20170824171418.GI28443@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Chulski <stefanc@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kishon@ti.com" <kishon@ti.com>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "miquel.raynal@free-electrons.com" <miquel.raynal@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824171418.GI28443@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2017 at 07:14:18PM +0200, Antoine Tenart wrote:
> On Thu, Aug 24, 2017 at 05:08:29PM +0000, Stefan Chulski wrote:
> > > > Imagine phylib is using the copper Ethernet PHY, but the MAC is using
> > > > the SFP port. Somebody pulls out the copper cable, phylib says the
> > > > link is down, turns the carrier off and calls the callback. Not good,
> > > > since your SFP cable is still plugged in...  Ethtool is
> > > > returning/setting stuff in the Copper Ethernet PHY, when in fact you
> > > > intend to be setting SFP settings.
> > > 
> > > I see what could be the issue but I do not understand one aspect though:
> > > how could we switch from one PHY to another, as there's only one output
> > > between the SoC (and so a given GoP#) and the board. So if a given PHY can
> > > handle multiple modes I see, but in the other case a muxing somewhere would
> > > be needed? Or did I miss something?
> > 
> > I think PHY name and PHY mode struct that describe here both MAC to
> > PHY and PHY to PHY connection create confusion...  Serdes IP lane
> > doesn't care if connector is SFP, RJ45 or direct attached cable.
> > mvpp22_comphy_init only configures MAC to PHY
> > connection. SFI for 10G(KR in mainline), SGMII for 1G and HS_SGMII for
> > 2.5G.
> 
> So maybe one confusion was to name them PHY_MODE_10GKR and
> PHY_MODE_SGMII. It could be PHY_MODE_10G and PHY_MODE_1G instead.

SGMII mode supports 100M and 10M as well using data repetition, so 1G
makes it look like those speeds are not supported.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
