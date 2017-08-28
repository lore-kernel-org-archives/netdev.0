From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next v2 05/14] net: mvpp2: do not force the link mode
Date: Mon, 28 Aug 2017 12:06:24 +0100
Message-ID: <20170828110624.GG20805@n2100.armlinux.org.uk>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
 <20170825144821.31129-6-antoine.tenart@free-electrons.com>
 <20170825224312.GD20805@n2100.armlinux.org.uk>
 <20170828065545.GC2568@kwain>
 <CAPv3WKfSGfSAfade163-Q29SR5mxkV19LmYRxVdRBbfW-e-xfg@mail.gmail.com>
 <20170828085152.GF20805@n2100.armlinux.org.uk>
 <20170828094051.GE2568@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin Wojtas <mw@semihalf.com>,
        "David S. Miller" <davem@davemloft.net>, kishon@ti.com,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory =?iso-8859-1?Q?Cl=E9ment?=
        <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        nadavh@marvell.com, linux-kernel@vger.kernel.org,
        Stefan Chulski <stefanc@marvell.com>,
        =?iso-8859-1?Q?Miqu=E8l?= Raynal
        <miquel.raynal@free-electrons.com>, netdev <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828094051.GE2568@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2017 at 11:40:51AM +0200, Antoine Tenart wrote:
> On Mon, Aug 28, 2017 at 09:51:52AM +0100, Russell King - ARM Linux wrote:
> > On Mon, Aug 28, 2017 at 10:38:37AM +0200, Marcin Wojtas wrote:
> > >
> > > Can you be 100% sure that when using SGMII with PHY's (like Marvell
> > > Alaska 88E1xxx series), is in-band link information always available?
> > > I'd be very cautious with such assumption and use in-band management
> > > only when set in the DT, like mvneta. I think phylib can properly can
> > > do its work when MDIO connection is provided on the board.
> > 
> > There is another issue to be aware of: if you're wanting to use flow
> > control autonegotiation, that is not carried across SGMII's in-band
> > signalling.  If you want to use SGMII's in-band signalling for the
> > duplex and speed information, you still need phylib's notification
> > to properly set the flow control.
> > 
> > <plug>
> > Switching mvpp2 to use phylink (which is needed for the 1G SFP slot on
> > mcbin) will handle all this for you - dealing with both in-band and
> > out-of-band negotiation methods, and combining them in the appropriate
> > manner for the selected operation mode.
> > </plug>
> 
> So probably the best move here is to remove this patch, and wait for the
> phylink support in the PPv2 driver.

I've nothing on that specifically for the mvpp2 driver - what I have is
for mvneta and the Marvell mvpp2x driver, with GMAC support extracted
from mvneta (that last bit is rather dirty at the moment so not
published anywhere, and doesn't cater for PP v2.1 at all.)

I ought to have posted the mvneta part of the phylink patches, but I
didn't get around to it early enough in this cycle - there are probably
quite a number of conflicts with net-next now, so I think it's too late
to submit it for mainline.

I know Andrew has already looked at them in my git tree as part of the
review of phylink when that was merged - which should be adequate to
give an example of how to implement it for the mainline PP v2 driver.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
