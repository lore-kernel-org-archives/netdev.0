From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Fri, 14 Jan 2011 08:52:23 +0100
Message-ID: <20110114075223.GC24920@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
 <20110113144805.GS24920@pengutronix.de>
 <20110114054838.GA14491@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de, jamie@jamieiles.com,
	jamie@shareable.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58205 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab1ANHwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 02:52:40 -0500
Content-Disposition: inline
In-Reply-To: <20110114054838.GA14491@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 01:48:40PM +0800, Shawn Guo wrote:
> Hi Uwe,
>=20
> On Thu, Jan 13, 2011 at 03:48:05PM +0100, Uwe Kleine-K=F6nig wrote:
>=20
> [...]
>=20
> > > +/* Controller is ENET-MAC */
> > > +#define FEC_QUIRK_ENET_MAC           (1 << 0)
> > does this really qualify to be a quirk?
> >=20
> My understanding is that ENET-MAC is a type of "quirky" FEC
> controller.
>=20
> > > +/* Controller needs driver to swap frame */
> > > +#define FEC_QUIRK_SWAP_FRAME         (1 << 1)
> > IMHO this is a bit misnamed.  FEC_QUIRK_NEEDS_BE_DATA or similar wo=
uld
> > be more accurate.
> >=20
> When your make this change, you may want to pick a better name for
> function swap_buffer too.
>=20
> [...]
>=20
> > > +static void *swap_buffer(void *bufaddr, int len)
> > > +{
> > > +     int i;
> > > +     unsigned int *buf =3D bufaddr;
> > > +
> > > +     for (i =3D 0; i < (len + 3) / 4; i++, buf++)
> > > +             *buf =3D cpu_to_be32(*buf);
> > if len isn't a multiple of 4 this accesses bytes behind len.  Is th=
is
> > generally OK here?  (E.g. because skbs always have a length that is=
 a
> > multiple of 4?)
> The len may not be a multiple of 4.  But I believe bufaddr is always
> a buffer allocated in a length that is a multiple of 4, and the 1~3
> bytes exceeding the len very likely has no data that matters.  But
> yes, it deserves a safer implementation.
Did you test what happens if bufaddr isn't aligned?  Does it work at al=
l
then?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
