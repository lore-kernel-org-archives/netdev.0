From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 03/10] net/fec: add mac field into platform data and
	consolidate fec_get_mac
Date: Wed, 29 Dec 2010 12:10:19 +0100
Message-ID: <20101229111019.GA14221@pengutronix.de>
References: <1293548155-16328-1-git-send-email-shawn.guo@freescale.com> <1293548155-16328-4-git-send-email-shawn.guo@freescale.com> <20101229065329.GB31010@jasper.tkos.co.il> <20101229103014.GD19347@freescale.com> <20101229103758.GU14221@pengutronix.de> <20101229110828.GE19347@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Baruch Siach <baruch@tkos.co.il>, davem@davemloft.net,
	gerg@snapgear.com, eric@eukrea.com, bryan.wu@canonical.com,
	r64343@freescale.com, B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50232 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab0L2LKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 06:10:43 -0500
Content-Disposition: inline
In-Reply-To: <20101229110828.GE19347@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shawn,

On Wed, Dec 29, 2010 at 07:08:29PM +0800, Shawn Guo wrote:
> On Wed, Dec 29, 2010 at 11:37:58AM +0100, Uwe Kleine-K=F6nig wrote:
> > On Wed, Dec 29, 2010 at 06:30:15PM +0800, Shawn Guo wrote:
> > > > On Tue, Dec 28, 2010 at 10:55:48PM +0800, Shawn Guo wrote:
> > > [...]
> > > > > +	/*
> > > > > +	 * try to get mac address in following order:
> > > > > +	 *
> > > > > +	 * 1) kernel command line fec_mac=3Dxx:xx:xx...
> > > > > +	 */
> > > > > +	iap =3D fec_mac_default;
> > > > > +
> > > > > +	/*
> > > > > +	 * 2) from flash or fuse (via platform data)
> > > > > +	 */
> > > >=20
> > > > Again, how do you handle the dual MAC case?
> > > >=20
> > > For the platform data case, the following patch reads both mac
> > > addresses.
> > >=20
> > > [PATCH 09/10] ARM: mx28: read fec mac address from ocotp
> > >=20
> > > +static int __init mx28evk_fec_get_mac(void)
> > > +{
> > > +       int i, ret;
> > > +       u32 val;
> > > +
> > > +       /*
> > > +        * OCOTP only stores the last 4 octets for each mac addre=
ss,
> > > +        * so hard-coding the first two octets as Freescale OUI (=
00:04:9f)
> > > +        * is needed.
> > > +        */
> > > +       for (i =3D 0; i < 2; i++) {
> > > +               ret =3D mxs_read_ocotp(0x20 + i * 0x10, 1, &val);
> > > +               if (ret)
> > > +                       goto error;
> > > +
> > > +               mx28_fec_pdata[i].mac[0] =3D 0x00;
> > > +               mx28_fec_pdata[i].mac[1] =3D 0x04;
> > > +               mx28_fec_pdata[i].mac[2] =3D (val >> 24) & 0xff;
> > > +               mx28_fec_pdata[i].mac[3] =3D (val >> 16) & 0xff;
> > > +               mx28_fec_pdata[i].mac[4] =3D (val >> 8) & 0xff;
> > > +               mx28_fec_pdata[i].mac[5] =3D (val >> 0) & 0xff;
> > uuh.  Is ((val >> 24) & 0xff) supposed to be 0x9f?  If not this mig=
ht
> > have unwanted effects (practical, don't know about legal ones).
> Yes, it is 0x9f.
Then maybe hardcode that, or at least warn if it's not?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
