From: Stefan Chulski <stefanc@marvell.com>
Subject: RE: [EXT] Re: [PATCH net-next 09/13] net: mvpp2: dynamic
 reconfiguration of the PHY mode
Date: Thu, 24 Aug 2017 17:08:29 +0000
Message-ID: <de67e234a7ff43b49346be5cea2466eb@IL-EXCH01.marvell.com>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch> <20170824155241.GF28443@kwain>
 <20170824160124.GA18700@lunn.ch> <20170824161945.GG28443@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "kishon@ti.com" <kishon@ti.com>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "miquel.raynal@free-electrons.com" <miquel.raynal@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824161945.GG28443@kwain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Imagine phylib is using the copper Ethernet PHY, but the MAC is using
> > the SFP port. Somebody pulls out the copper cable, phylib says the
> > link is down, turns the carrier off and calls the callback. Not good,
> > since your SFP cable is still plugged in...  Ethtool is
> > returning/setting stuff in the Copper Ethernet PHY, when in fact you
> > intend to be setting SFP settings.
> 
> I see what could be the issue but I do not understand one aspect though:
> how could we switch from one PHY to another, as there's only one output
> between the SoC (and so a given GoP#) and the board. So if a given PHY can
> handle multiple modes I see, but in the other case a muxing somewhere would
> be needed? Or did I miss something?

I think PHY name and PHY mode struct that describe here both MAC to PHY and PHY to PHY connection create confusion...
Serdes IP lane doesn't care if connector is SFP, RJ45 or direct attached cable. mvpp22_comphy_init only configures MAC to PHY
connection. SFI for 10G(KR in mainline), SGMII for 1G and HS_SGMII for 2.5G.

Regards,
Stefan.
