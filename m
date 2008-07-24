From: "martin capitanio" <martin@capitanio.org>
Subject: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Thu, 24 Jul 2008 22:23:46 +0200 (MEST)
Message-ID: <200807242023.m6OKNkwL013279@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@vger.kernel.org, netdev@vger.kernel.org,
	c4p7n1@capitanio.org
To: "=?iso-8859-1?q?=43=e9=64=72=69=63=20=41=75=67=6f=6e=6e=65=74?="
	<cedric.augonnet@gmail.com>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Mario Limonciello" <Mario_Limonciello@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from em-p00-ob.rzone.de ([81.169.146.224]:60682 "EHLO
	em-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbYGXUXu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 16:23:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- original message --------

Subject: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Sent: Thu, 24 Jul 2008
=46rom: C=E9dric Augonnet<cedric.augonnet@gmail.com>

> Hi all,
>=20
> >        case RTL_GIGA_MAC_VER_04:
> >                rtl8169sb_hw_phy_config(ioaddr);
> >                break;
> > +       case RTL_GIGA_MAC_VER_13:
> > +       case RTL_GIGA_MAC_VER_16:
> > +               rtl8101_hw_phy_config(ioaddr);
>=20
> Should not there be a "break;" here or is it intended to go through
> the next case as well?

Good question. If you can read c code and are willing to spend your tim=
e,
the answer may be buried here:

LINUX driver for kernel 2.6.X and 2.4.X (Support x86 and x64)
ftp://152.104.238.19/cn/nic/r8101-1.007.00.tar.bz2

>=20
> >        case RTL_GIGA_MAC_VER_18:
> >                rtl8168cp_hw_phy_config(ioaddr);
> >                break;
>=20
> Perhaps i missed something obvious, sorry if that's the case ...

No, there is nothing obvious, even in the Hsinchu Science Park ;-)

static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
{
	struct phy_reg phy_reg_init[] =3D {
		{ 0x1f, 0x0000 },
		{ 0x1d, 0x0f00 },
		{ 0x1f, 0x0002 },
		{ 0x0c, 0x1ec8 },
		{ 0x1f, 0x0000 }
	};

	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
}

        Martin Capitanio

