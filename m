From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH net-next v2 05/14] net: mvpp2: do not force the link mode
Date: Mon, 28 Aug 2017 10:38:37 +0200
Message-ID: <CAPv3WKfSGfSAfade163-Q29SR5mxkV19LmYRxVdRBbfW-e-xfg@mail.gmail.com>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
 <20170825144821.31129-6-antoine.tenart@free-electrons.com>
 <20170825224312.GD20805@n2100.armlinux.org.uk> <20170828065545.GC2568@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>,
        "David S. Miller" <davem@davemloft.net>, kishon@ti.com,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        =?UTF-8?Q?Gregory_Cl=C3=A9ment?=
        <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        nadavh@marvell.com, linux-kernel@vger.kernel.org,
        Stefan Chulski <stefanc@marvell.com>,
        =?UTF-8?Q?Miqu=C3=A8l_Raynal?= <miquel.raynal@free-electrons.com>,
        netdev <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828065545.GC2568@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Antoine,

2017-08-28 8:55 GMT+02:00 Antoine Tenart <antoine.tenart@free-electrons.com>:
> Hi Russell,
>
> On Fri, Aug 25, 2017 at 11:43:13PM +0100, Russell King - ARM Linux wrote:
>> On Fri, Aug 25, 2017 at 04:48:12PM +0200, Antoine Tenart wrote:
>> > The link mode (speed, duplex) was forced based on what the phylib
>> > returns. This should not be the case, and only forced by ethtool
>> > functions manually. This patch removes the link mode enforcement from
>> > the phylib link_event callback.
>>
>> So how does RGMII work (which has no in-band signalling between the PHY
>> and MAC)?
>>
>> phylib expects the network driver to configure it according to the PHY
>> state at link_event time - I think you need to explain more why you
>> think that this is not necessary.
>
> Good catch, this won't work properly with RGMII. This could be done
> out-of-band according to the spec, but that would use PHY polling and we
> do not want that (the same concern was raised by Andrew on another
> patch).
>
> I'll keep this mode enforcement for RGMII then.
>

Can you be 100% sure that when using SGMII with PHY's (like Marvell
Alaska 88E1xxx series), is in-band link information always available?
I'd be very cautious with such assumption and use in-band management
only when set in the DT, like mvneta. I think phylib can properly can
do its work when MDIO connection is provided on the board.

Did you check the change also on A375?

Best regards,
Marcin
