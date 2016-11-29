From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to
 PHY tunables
Date: Tue, 29 Nov 2016 01:46:53 +0100
Message-ID: <20161129004653.GA24782@lunn.ch>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
 <1480339472-5823-2-git-send-email-allan.nielsen@microsemi.com>
 <20161128141410.GF4379@lunn.ch>
 <20161128192306.GA11474@microsemi.com>
 <20161128202114.GM17704@lunn.ch>
 <fabb91cd-9fc5-d935-727e-ff57e441e919@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Allan W. Nielsen" <allan.nielsen@microsemi.com>,
        netdev@vger.kernel.org, raju.lakkaraju@microsemi.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60950 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752889AbcK2Aq4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 19:46:56 -0500
Content-Disposition: inline
In-Reply-To: <fabb91cd-9fc5-d935-727e-ff57e441e919@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > If you really do what to do this, you should look at NETIF_F_LOOPBACK
> > and consider how this concept can be applied at the PHY, not the MAC.
> > But you need the full concept, so you see things like:
> > 
> > 2: eth0: <LOOPBACK,BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
> >     link/ether 80:ee:73:83:60:27 brd ff:ff:ff:ff:ff:ff
> > 
> > Humm, i've no idea how you actually enable the MAC loopback
> > NETIF_F_LOOPBACK represents. I don't see anything with ip link set.
> 
> I am afraid you lost me on this, NETIF_F_LOOPBACK is a netdev_features_t
> bit, so it tells ethtool that this is a potential feature to be turned
> on with ethtool -K <iface>. 

Yep, i'm talking rubbish after jumping to a wrong conclusion.

> The semantics of this loopack feature are
> not defined AFAICT, but a reasonable behavior from the driver is to put
> itself in a mode where packets send by a socket-level application are
> looped through the Ethernet adapter itself. Whether this happens at the
> DMA level, the MII signals, or somewhere in the PHY, is driver specific
> unfortunately.

Yes, the interesting one might be forcedeth which writes to the PHY
BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED1000;
when the NETIF_F_LOOPBACK feature is set.

Maybe this could be generalised and made available for all MACs which
don't support MAC loopback?

What needs considering is the correct duplex and speed. We need to
ensure the MAC and PHY agree on this.
 
> Now, there is another way to toggle a loopback for a given Ethernet
> adapter which is to actually set IFF_LOOPBACK in dev->flags for this
> interface. Some drivers seem to be able to properly react to that as
> well, although I see no way this can be done looking at the iproute2 or
> ifconfig man pages..

I prefer this one, since i expect this will set LOOPBACK in

2: eth0: <LOOPBACK,BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000

making it lot more obvious something funny is going on.

       Andrew
