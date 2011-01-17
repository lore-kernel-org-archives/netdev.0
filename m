From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Mon, 17 Jan 2011 19:52:05 +0800
Message-ID: <20110117115204.GB23185@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
 <20110113144805.GS24920@pengutronix.de>
 <20110114054838.GA14491@freescale.com>
 <20110114075223.GC24920@pengutronix.de>
 <20110114130849.GA27583@freescale.com>
 <19763.64214.220441.325208@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, <gerg@snapgear.com>,
	<B32542@freescale.com>, <netdev@vger.kernel.org>,
	<s.hauer@pengutronix.de>, <jamie@shareable.org>,
	<baruch@tkos.co.il>, <w.sang@pengutronix.de>,
	<r64343@freescale.com>, <eric@eukrea.com>,
	<bryan.wu@canonical.com>, <jamie@jamieiles.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:14585
	"EHLO DB3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751428Ab1AQLs7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jan 2011 06:48:59 -0500
Received: from mail79-db3 (localhost.localdomain [127.0.0.1])	by
 mail79-db3-R.bigfish.com (Postfix) with ESMTP id 9E6D214A8576	for
 <netdev@vger.kernel.org>; Mon, 17 Jan 2011 11:48:56 +0000 (UTC)
Received: from DB3EHSMHS002.bigfish.com (unknown [10.3.81.254])	by
 mail79-db3.bigfish.com (Postfix) with ESMTP id 2975B13E0052	for
 <netdev@vger.kernel.org>; Mon, 17 Jan 2011 11:48:56 +0000 (UTC)
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.14.3/8.14.3) with ESMTP id p0HBmnTZ004844	for
 <netdev@vger.kernel.org>; Mon, 17 Jan 2011 04:48:49 -0700 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id
 p0HBmmYl020178	for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 05:48:48 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <19763.64214.220441.325208@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lothar,

On Mon, Jan 17, 2011 at 09:16:22AM +0100, Lothar Wa=DFmann wrote:
> Hi,
>=20
> Shawn Guo writes:
> > On Fri, Jan 14, 2011 at 08:52:23AM +0100, Uwe Kleine-K=F6nig wrote:
> > > On Fri, Jan 14, 2011 at 01:48:40PM +0800, Shawn Guo wrote:
> > > > Hi Uwe,
> > > >=20
> > > > On Thu, Jan 13, 2011 at 03:48:05PM +0100, Uwe Kleine-K=F6nig wr=
ote:
> > > >=20
> > > > [...]
> > > >=20
> > > > > > +/* Controller is ENET-MAC */
> > > > > > +#define FEC_QUIRK_ENET_MAC           (1 << 0)
> > > > > does this really qualify to be a quirk?
> > > > >=20
> > > > My understanding is that ENET-MAC is a type of "quirky" FEC
> > > > controller.
> > > >=20
> > > > > > +/* Controller needs driver to swap frame */
> > > > > > +#define FEC_QUIRK_SWAP_FRAME         (1 << 1)
> > > > > IMHO this is a bit misnamed.  FEC_QUIRK_NEEDS_BE_DATA or simi=
lar would
> > > > > be more accurate.
> > > > >=20
> > > > When your make this change, you may want to pick a better name =
for
> > > > function swap_buffer too.
> > > >=20
> > > > [...]
> > > >=20
> > > > > > +static void *swap_buffer(void *bufaddr, int len)
> > > > > > +{
> > > > > > +     int i;
> > > > > > +     unsigned int *buf =3D bufaddr;
> > > > > > +
> > > > > > +     for (i =3D 0; i < (len + 3) / 4; i++, buf++)
> > > > > > +             *buf =3D cpu_to_be32(*buf);
> > > > > if len isn't a multiple of 4 this accesses bytes behind len. =
 Is this
> > > > > generally OK here?  (E.g. because skbs always have a length t=
hat is a
> > > > > multiple of 4?)
> > > > The len may not be a multiple of 4.  But I believe bufaddr is a=
lways
> > > > a buffer allocated in a length that is a multiple of 4, and the=
 1~3
> > > > bytes exceeding the len very likely has no data that matters.  =
But
> > > > yes, it deserves a safer implementation.
> > > Did you test what happens if bufaddr isn't aligned?  Does it work=
 at all
> > > then?
> > >=20
> > I see many calls passing a len that is not a multiple of 4, but it
> > works good.
> >=20
> That does not prove anything, actually.
>=20
> Anyway "bufaddr isn't aligned" !=3D "len is not a multiple of 4".
> Is there any guarantee that the function cannot be called with a
> non-aligned buffer address?
>=20
Oops, I misunderstood the comment.  With bounce buffer alignment
handling removed, the driver stops working.  But at least, mx28
fec driver can work with FEC_ALIGNMENT 0x3 and not necessarily with
0xf.=20

I hope this is what you intended to know.

--=20
Regards,
Shawn

