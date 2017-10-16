From: Rodney Cummings <rodney.cummings@ni.com>
Subject: RE: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
Date: Mon, 16 Oct 2017 15:23:42 +0000
Message-ID: <CY1PR0401MB1536F870727AFA21BFC31115924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        David Laight <David.Laight@ACULAB.COM>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am concerned about this proposed change.

According to IEEE Std 802.1Q, a "higher layer entity" (i.e. end station) th=
at is internal to the bridge (i.e. switch) can use the same individual glob=
al MAC address that the switch is using. That behavior is common.

Use of a local semi-random MAC address is dangerous on Ethernet. Local MAC =
addresses can only be safely used in very narrow use cases, most of which a=
re Wi-Fi. Generally speaking, local MAC addresses can be duplicated in the =
network, which causes many Ethernet protocols to break down. Therefore, gen=
eral-purpose implementations like DSA cannot use a local MAC address in a r=
eliable manner.

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Vivien Didelot
> Sent: Friday, October 13, 2017 1:18 PM
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org; kernel@savoirfairelinux.com; David S.
> Miller <davem@davemloft.net>; Florian Fainelli <f.fainelli@gmail.com>;
> Andrew Lunn <andrew@lunn.ch>; David Laight <David.Laight@ACULAB.COM>;
> Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Subject: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
>=20
> An Ethernet switch may support having a MAC address, which can be used
> as the switch's source address in transmitted full-duplex Pause frames.
>=20
> If a DSA switch supports the related .set_addr operation, the DSA core
> sets the master's MAC address on the switch.
>=20
> This won't make sense anymore in a multi-CPU ports system, because there
> won't be a unique master device assigned to a switch tree.
>=20
> Moreover this operation is confusing because it makes the user think
> that it could be used to program the switch with the MAC address of the
> CPU/management port such that MAC address learning can be disabled on
> said port, but in fact, that's not how it is currently used.
>=20
> To fix this, assign a random MAC address at setup time in the mv88e6060
> and mv88e6xxx drivers before removing .set_addr completely from DSA.
>=20
> Changes in v3:
>   - include fix for mv88e6060 switch MAC address setter.
>=20
> Changes in v2:
>   - remove .set_addr implementation from drivers and use a random MAC.
>=20
> Vivien Didelot (5):
>   net: dsa: mv88e6xxx: setup random mac address
>   net: dsa: mv88e6060: fix switch MAC address
>   net: dsa: mv88e6060: setup random mac address
>   net: dsa: dsa_loop: remove .set_addr
>   net: dsa: remove .set_addr
>=20
>  drivers/net/dsa/dsa_loop.c       |  8 --------
>  drivers/net/dsa/mv88e6060.c      | 37 ++++++++++++++++++++++++++--------=
-
> --
>  drivers/net/dsa/mv88e6xxx/chip.c | 33 +++++++++++++++++----------------
>  include/net/dsa.h                |  1 -
>  net/dsa/dsa2.c                   |  6 ------
>  net/dsa/legacy.c                 |  6 ------
>  6 files changed, 43 insertions(+), 48 deletions(-)
>=20
> --
> 2.14.2
