From: Florian Fainelli <florian@openwrt.org>
Subject: Re: alchemy/gpr: au1000_eth regression with v2.6.37rc2
Date: Thu, 18 Nov 2010 23:30:07 +0100
Message-ID: <201011182330.08488.florian@openwrt.org>
References: <4CE58593.50509@grandegger.com>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Linux-MIPS" <linux-mips@linux-mips.org>, Netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4CE58593.50509@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Wolfgang,

Le Thursday 18 November 2010 20:59:15, Wolfgang Grandegger a =E9crit :
> Hello,
>=20
> I just realized that the v2.6.37-rc2 kernel does not boot any more on
> the Alchemy GPR board. It works fine with v2.6.36. It hangs in the
> probe function of the au1000_eth driver when probing the second
> ethernet port (eth1):
>=20
>   au1000_eth_mii: probed
>   au1000-eth au1000-eth.0: (unregistered net_device): attached PHY dr=
iver
> [Generic PHY] (mii_bus:phy_addr=3D0:00, irq=3D-1) au1000-eth au1000-e=
th.0:
> eth0: Au1xx0 Ethernet found at 0x10500000, irq 35 au1000_eth: au1000_=
eth
> version 1.7 Pete Popov <ppopov@embeddedalley.com> ... hangs ...
>=20
> Similar messages should follow for eth1. I narrowed down (bisect'ed) =
the
> problem to commit:
>=20
>   commit d0e7cb5d401695809ba8c980124ab1d8c66efc8b
>   Author: Florian Fainelli <florian@openwrt.org>
>   Date:   Wed Sep 8 11:15:13 2010 +0000
>=20
>     au1000-eth: remove volatiles, switch to I/O accessors
>=20
>     Remove all the volatile keywords where they were used, switch to =
using
> the proper readl/writel accessors.
>=20
>     Signed-off-by: Florian Fainelli <florian@openwrt.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> The kernel actually hangs when accessing "&aup->mac->mii_control" in
> au1000_mdio_read(), but only for eth1. Any idea what does go wrong?

I do not understand so far while it hangs only for eth1. My device only=
 has=20
one ethernet MAC, so I could not notice the problem. Looking at this cl=
ose,=20
there are a couple of u32 const* usages in au1000_mdio_{read,write} whi=
ch are=20
looking wrong to me now. Can you try to remove these?

>=20
> In principle, I do not want to access the MII regs of the MAC because
> eth0 and eth1 are connected to switches. But that's not possible, eve=
n
> with "aup->phy_static_config=3D1" and "aup->phy_addr=3D0".

If you think this is another issue, I will fix it in another patch.
--
=46lorian
