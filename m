From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: 802.1Q support?
Date: Tue, 13 Jan 2009 07:31:20 -0500
Message-ID: <200901130731.20538.rgetz@blackfin.uclinux.org>
References: <200901121148.26905.rgetz@blackfin.uclinux.org> <200901122143.51004.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Florian Fainelli" <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:59839 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbZAMMbf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 07:31:35 -0500
In-Reply-To: <200901122143.51004.florian@openwrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 12 Jan 2009 15:43, Florian Fainelli pondered:
> Hi Robin,
>=20
> Le Monday 12 January 2009 17:48:26 Robin Getz, vous avez =C3=A9crit=C2=
=A0:
> > I'm trying to understand the "standard" way to control a switch whi=
ch
> > supports VLAN.
> >
> > Pick any one of:
> >
> > Infineon XWAY ADM6999 (eight-port 10/100 plus one MII)
> > http://www.infineon.com/cms/en/product/channel.html?channel=3Dff808=
08112ab681
> >d0112ab68ce8d0043
> >
> > Micrel MS8993M (2 port 10/100 plus one MII)
> > http://www.micrel.com/_PDF/Ethernet/ks8993m_pb.pdf
> >
> > Broadcom BCM5325E (five port 10/100 plus one MII)
> > http://www.broadcom.com/collateral/pb/5325E-PB00-R.pdf
> >
> > Realtek (five port 10/100 plus one MII)
> > http://www1.futureelectronics.com/doc/REALTEK%20SEMICONDUCTOR/Realt=
ek%20Sem
> >iconductor%20RTL8306SD-GR.pdf
> >
> > They all have multiple MAC/PHYs which are exposed to the wire, and =
a single
> > MII interface - which normally connects directly to a SOC's MII/MAC=
=2E
> >
> > I would have thought that there would be separate drivers for these=
 in the
> > phylib, but I didn't find anything that looked like it would work. =
(or
> > expose the right interface (all the vendor specific VLAN registers)=
 so I
> > can program them properly from userspace)...
>=20
> You can check what we are doing in OpenWrt to be able to change the s=
witch=20
> configuration. There is some work going on to interface switch driver=
s as PHY=20
> drivers. See :
>=20
> https://dev.openwrt.org/browser/trunk/target/linux/generic-2.6/patche=
s-2.6.27/650-swconfig.patch
> https://dev.openwrt.org/browser/trunk/target/linux/generic-2.6/files/=
drivers/net/phy/
> https://dev.openwrt.org/browser/trunk/package/swconfig

Great - That looks like the way to go -- is there any plan in sending t=
his
to mainline?=20

It looks like it has been in your tree for ~9 months - so I imagine it=20
is working pretty well for you?

> > It is possible to hack up the specific EMAC driver to do everything=
, but
> > that doesn't seem like the right way to do it...
>=20
> Yes, you can also do it that way, though most switches could be reach=
ed using=20
> a specific PHY address like how BCM5325 switches are connected to the=
 MAC.
