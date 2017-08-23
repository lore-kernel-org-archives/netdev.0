From: Stefan Chulski <stefanc@marvell.com>
Subject: RE: [EXT] Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY
 address when connecting to the PHY
Date: Wed, 23 Aug 2017 10:40:46 +0000
Message-ID: <f6d8907b057241c7a72da0a0255cfd23@IL-EXCH01.marvell.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-4-antoine.tenart@free-electrons.com>
 <20170726160806.GF12049@lunn.ch> <20170728014905.GC24728@kwain>
 <20170728042153.GH18666@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:57068 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753728AbdHWKl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 06:41:29 -0400
In-Reply-To: <20170728042153.GH18666@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Friday, July 28, 2017 7:22 AM
> To: Antoine Tenart <antoine.tenart@free-electrons.com>
> Cc: davem@davemloft.net; jason@lakedaemon.net; gregory.clement@free-
> electrons.com; sebastian.hesselbarth@gmail.com; thomas.petazzoni@free-
> electrons.com; Nadav Haklai <nadavh@marvell.com>; linux@armlinux.org.uk;
> mw@semihalf.com; Stefan Chulski <stefanc@marvell.com>;
> netdev@vger.kernel.org; linux-arm-kernel@lists.infradead.org
> Subject: [EXT] Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY address
> when connecting to the PHY
> 
> External Email
> 
> ----------------------------------------------------------------------
> On Thu, Jul 27, 2017 at 06:49:05PM -0700, Antoine Tenart wrote:
> > Hi Andrew,
> >
> > On Wed, Jul 26, 2017 at 06:08:06PM +0200, Andrew Lunn wrote:
> > > On Mon, Jul 24, 2017 at 03:48:33PM +0200, Antoine Tenart wrote:
> > > >
> > > > +	if (priv->hw_version != MVPP22)
> > > > +		return 0;
> > > > +
> > > > +	/* Set the SMI PHY address */
> > > > +	if (of_property_read_u32(port->phy_node, "reg", &phy_addr)) {
> > > > +		netdev_err(port->dev, "cannot find the PHY address\n");
> > > > +		return -EINVAL;
> > > > +	}
> > > > +
> > > > +	writel(phy_addr, priv->iface_base +
> > > > +MVPP22_SMI_PHY_ADDR(port->gop_id));
> > > >  	return 0;
> > > >  }
> > >
> > > You could use phy_dev->mdiodev->addr, rather than parse the DT.
> >
> > OK.
> >
> > > Why does the MAC need to know this address? The phylib and PHY
> > > driver should be the only thing accessing the PHY, otherwise you are
> > > asking for trouble.
> >
> > This is part of the SMI/xSMI interface. I added into the mvpp2 driver
> > and not in the mvmdio one because the GoP port number must be known to
> > set this register (so that would be even less clean to do it).
> 
> Hi Antoine
> 
> It is still not clear to my why you need to program the address into the
> hardware. Is the hardware talking to the PHY?
> 
>     Andrew

Hi Andrew,

This register configures SMI(Serial Management Interface) hardware unit, not PPv2(Packet Processor) hardware unit.
The SB incorporates the following SMI management interfaces:
MDC - Serial Management Interface Clock , MDIO - Serial Management Interface Data and complies with IEEE 802.3 Clause 22.

SMI interface used for:

1. PHY register read/write.
The device provides a mechanism for PHY registers read and write access.

2. Auto-Negotiation with PHY devices connected to the GMAC ports.
The device uses a standard master Serial Management Interface for reading from/writing to the PHY
registers. In addition, the PHY polling unit performs Auto-Negotiation status update with PHY devices attached
to the Network ports via the Master SMI Interface.
The device polls the Status register of each PHY in a round-robin manner.
If the device detects a change in the link from down to up on 1 of the ports, it performs a series of
register reads from the PHY and updates the Auto-Negotiation results in the device's registers. The
Port MAC Status register is updated with these results only if Auto-Negotiation is enabled.

So SMI interface should know GoP(MAC) id.

Regards,
Stefan.
