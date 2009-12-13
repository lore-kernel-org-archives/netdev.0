From: Florian Fainelli <florian@openwrt.org>
Subject: Re: question about drivers/net/cpmac.c
Date: Sun, 13 Dec 2009 13:19:51 +0100
Message-ID: <200912131319.59229.florian@openwrt.org>
References: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk> <Pine.LNX.4.64.0912131143571.24267@ask.diku.dk> <1260705119.4532.609.camel@localhost>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julia Lawall <julia@diku.dk>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:35407 "HELO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753032AbZLMMUH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 07:20:07 -0500
Received: by ewy19 with SMTP id 19so2494243ewy.21
        for <netdev@vger.kernel.org>; Sun, 13 Dec 2009 04:20:05 -0800 (PST)
In-Reply-To: <1260705119.4532.609.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 13 d=C3=A9cembre 2009 12:51:59, Ben Hutchings a =C3=A9crit =
:
> On Sun, 2009-12-13 at 12:00 +0100, Julia Lawall wrote:
> > On Sun, 13 Dec 2009, David Miller wrote:
> > > From: Julia Lawall <julia@diku.dk>
> > > Date: Sun, 13 Dec 2009 11:22:54 +0100 (CET)
> > >
> > > > The function __devinit cpmac_probe in the file drivers/net/cpma=
c.c
> > > > contains the following code:
> > > >
> > > > memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
> > > >
> > > > Is it correct that the size of the pointer is what is wanted?
> > >
> > > Everything that does sizeof(netdev->dev_addr) is a bug.
> > >
> > > At some point we changed netdev->dev_addr from an array of chars =
to a
> > > pointer to a dynamically allocated buffer.
> > >
> > > So these cases worked before that change and need to be updated
> > > in order to be correct.
> > >
> > > Looking quickly there are a couple of these things under
> > > drivers/net
> >
> > Fixed how?  I looked a bit to find where the field was initialized,=
 but
> > it is just initialized to a field of something else, so it was not =
so
> > clear what the size should be.
>=20
> [...]
>=20
> The size should be dev->addr_len (assuming that has already been
> initialised) which will be ETH_ALEN for Ethernet devices.

=46rom arch/mips/include/asm/mach-ar7/ar7.h:

struct plat_cpmac_data {
[..]
        char dev_addr[6];
};

So this should be fine to either use ETH_ALEN or sizeof(pdata->dev_addr=
).
--=20
Best regards, Florian Fainelli
Email: florian@openwrt.org
Web: http://openwrt.org
IRC: [florian] on irc.freenode.net
-------------------------------
