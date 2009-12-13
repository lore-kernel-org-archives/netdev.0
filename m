From: Julia Lawall <julia@diku.dk>
Subject: Re: question about drivers/net/cpmac.c
Date: Sun, 13 Dec 2009 13:43:26 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912131343110.24267@ask.diku.dk>
References: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk>
 <Pine.LNX.4.64.0912131143571.24267@ask.diku.dk> <1260705119.4532.609.camel@localhost>
 <200912131319.59229.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-1091082278-1260708206=:24267"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:37853 "HELO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750731AbZLMMna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 07:43:30 -0500
In-Reply-To: <200912131319.59229.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-1091082278-1260708206=:24267
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Sun, 13 Dec 2009, Florian Fainelli wrote:

> Le dimanche 13 d=E9cembre 2009 12:51:59, Ben Hutchings a =E9crit :
> > On Sun, 2009-12-13 at 12:00 +0100, Julia Lawall wrote:
> > > On Sun, 13 Dec 2009, David Miller wrote:
> > > > From: Julia Lawall <julia@diku.dk>
> > > > Date: Sun, 13 Dec 2009 11:22:54 +0100 (CET)
> > > >
> > > > > The function __devinit cpmac_probe in the file drivers/net/cpma=
c.c
> > > > > contains the following code:
> > > > >
> > > > > memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
> > > > >
> > > > > Is it correct that the size of the pointer is what is wanted?
> > > >
> > > > Everything that does sizeof(netdev->dev_addr) is a bug.
> > > >
> > > > At some point we changed netdev->dev_addr from an array of chars =
to a
> > > > pointer to a dynamically allocated buffer.
> > > >
> > > > So these cases worked before that change and need to be updated
> > > > in order to be correct.
> > > >
> > > > Looking quickly there are a couple of these things under
> > > > drivers/net
> > >
> > > Fixed how?  I looked a bit to find where the field was initialized,=
 but
> > > it is just initialized to a field of something else, so it was not =
so
> > > clear what the size should be.
> >=20
> > [...]
> >=20
> > The size should be dev->addr_len (assuming that has already been
> > initialised) which will be ETH_ALEN for Ethernet devices.
>=20
> From arch/mips/include/asm/mach-ar7/ar7.h:
>=20
> struct plat_cpmac_data {
> [..]
>         char dev_addr[6];
> };
>=20
> So this should be fine to either use ETH_ALEN or sizeof(pdata->dev_addr=
).

Thanks.  I will send a patch later today.

julia
---511516320-1091082278-1260708206=:24267--
