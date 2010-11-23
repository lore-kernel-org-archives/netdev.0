From: Florian Fainelli <florian@openwrt.org>
Subject: Re: alchemy/gpr: au1000_eth regression with v2.6.37rc2
Date: Tue, 23 Nov 2010 16:33:49 +0100
Message-ID: <201011231633.50040.florian@openwrt.org>
References: <4CE58593.50509@grandegger.com> <201011191146.01454.florian@openwrt.org> <4CEBD751.7090807@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Linux-MIPS" <linux-mips@linux-mips.org>, Netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4CEBD751.7090807@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Wolfgang,

On Tuesday 23 November 2010 16:01:37 Wolfgang Grandegger wrote:
> Hi Florian,
>=20
> On 11/19/2010 11:46 AM, Florian Fainelli wrote:
> > Hello Wolfgang,
> >=20
> > On Friday 19 November 2010 11:29:45 Wolfgang Grandegger wrote:
> >> Hello Florian,
> >>=20
> >> On 11/18/2010 11:30 PM, Florian Fainelli wrote:
> >>> Hello Wolfgang,
> >>>=20
> >>> Le Thursday 18 November 2010 20:59:15, Wolfgang Grandegger a =C3=A9=
crit :
> >>>> Hello,
> >>>>=20
> >>>> I just realized that the v2.6.37-rc2 kernel does not boot any mo=
re on
> >>>> the Alchemy GPR board. It works fine with v2.6.36. It hangs in t=
he
> >>>> probe function of the au1000_eth driver when probing the second
> >>>>=20
> >>>> ethernet port (eth1):
> >>>>   au1000_eth_mii: probed
> >>>>   au1000-eth au1000-eth.0: (unregistered net_device): attached P=
HY
> >>>>   driver
> >>>>=20
> >>>> [Generic PHY] (mii_bus:phy_addr=3D0:00, irq=3D-1) au1000-eth au1=
000-eth.0:
> >>>> eth0: Au1xx0 Ethernet found at 0x10500000, irq 35 au1000_eth:
> >>>> au1000_eth version 1.7 Pete Popov <ppopov@embeddedalley.com> ...
> >>>> hangs ...
> >>>>=20
> >>>> Similar messages should follow for eth1. I narrowed down (bisect=
'ed)
> >>>> the
> >>>>=20
> >>>> problem to commit:
> >>>>   commit d0e7cb5d401695809ba8c980124ab1d8c66efc8b
> >>>>   Author: Florian Fainelli <florian@openwrt.org>
> >>>>   Date:   Wed Sep 8 11:15:13 2010 +0000
> >>>>  =20
> >>>>     au1000-eth: remove volatiles, switch to I/O accessors
> >>>>    =20
> >>>>     Remove all the volatile keywords where they were used, switc=
h to
> >>>>     using
> >>>>=20
> >>>> the proper readl/writel accessors.
> >>>>=20
> >>>>     Signed-off-by: Florian Fainelli <florian@openwrt.org>
> >>>>     Signed-off-by: David S. Miller <davem@davemloft.net>
> >>>>=20
> >>>> The kernel actually hangs when accessing "&aup->mac->mii_control=
" in
> >>>> au1000_mdio_read(), but only for eth1. Any idea what does go wro=
ng?
> >>>=20
> >>> I do not understand so far while it hangs only for eth1. My devic=
e only
> >>> has one ethernet MAC, so I could not notice the problem. Looking =
at
> >>> this close, there are a couple of u32 const* usages in
> >>> au1000_mdio_{read,write} which are looking wrong to me now. Can y=
ou try
> >>> to remove these?
> >>=20
> >> That did not help.
> >=20
> > I suspected it, but thanks for the confirmation.
> >=20
> >>>> In principle, I do not want to access the MII regs of the MAC be=
cause
> >>>> eth0 and eth1 are connected to switches. But that's not possible=
, even
> >>>> with "aup->phy_static_config=3D1" and "aup->phy_addr=3D0".
> >>>=20
> >>> If you think this is another issue, I will fix it in another patc=
h.
> >>=20
> >> Accessing the MII registers of the MAC should not hang the system =
even
> >> if I do not need to. First I want to  understand why. Looks like a=
 wired
> >> optimizer issue.
> >=20
> > I definitively agree, furthermore since there is a timeout for read=
 and
> > write operations. I will look at the assembly and see if I can see
> > anything different.
>=20
> The attached patch fixes the issue. It's caused by a simple porting
> error. I'm going to prepare a proper patch later today.

Nasty and simple enough not to be noticed at compile time. Thanks for=20
debugging this. Feel free to add my:

Acked-by: Florian Fainelli <florian@openwrt.org>
--
=46lorian
