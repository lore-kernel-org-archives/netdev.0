From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 03/10] net/fec: add mac field into platform data and
 consolidate fec_get_mac
Date: Wed, 29 Dec 2010 20:00:42 +0800
Message-ID: <20101229120041.GG19347@freescale.com>
References: <1293548155-16328-1-git-send-email-shawn.guo@freescale.com>
 <1293548155-16328-4-git-send-email-shawn.guo@freescale.com>
 <20101229065329.GB31010@jasper.tkos.co.il>
 <20101229103014.GD19347@freescale.com>
 <20101229103758.GU14221@pengutronix.de>
 <20101229110828.GE19347@freescale.com>
 <20101229111019.GA14221@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Baruch Siach <baruch@tkos.co.il>, <davem@davemloft.net>,
	<gerg@snapgear.com>, <eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<s.hauer@pengutronix.de>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:21607
	"EHLO VA3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751255Ab0L2L6j convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 06:58:39 -0500
Received: from mail164-va3 (localhost.localdomain [127.0.0.1])	by
 mail164-va3-R.bigfish.com (Postfix) with ESMTP id 463F3166017B	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 11:58:38 +0000 (UTC)
Received: from VA3EHSMHS030.bigfish.com (unknown [10.7.14.239])	by
 mail164-va3.bigfish.com (Postfix) with ESMTP id 0189871804E	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 11:58:38 +0000 (UTC)
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw01.freescale.net (8.14.3/8.14.3) with ESMTP id oBTBwa6x027310	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 04:58:36 -0700 (MST)
Received: from ubuntu.localdomain (ubuntu.ap.freescale.net [10.192.242.196])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id oBTCGJvE016159	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 06:16:19 -0600 (CST)
Content-Disposition: inline
In-Reply-To: <20101229111019.GA14221@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On Wed, Dec 29, 2010 at 12:10:19PM +0100, Uwe Kleine-K=F6nig wrote:
> Hi Shawn,
>=20
> On Wed, Dec 29, 2010 at 07:08:29PM +0800, Shawn Guo wrote:
> > On Wed, Dec 29, 2010 at 11:37:58AM +0100, Uwe Kleine-K=F6nig wrote:
> > > On Wed, Dec 29, 2010 at 06:30:15PM +0800, Shawn Guo wrote:
> > > > > On Tue, Dec 28, 2010 at 10:55:48PM +0800, Shawn Guo wrote:
> > > > [...]
> > > > > > +	/*
> > > > > > +	 * try to get mac address in following order:
> > > > > > +	 *
> > > > > > +	 * 1) kernel command line fec_mac=3Dxx:xx:xx...
> > > > > > +	 */
> > > > > > +	iap =3D fec_mac_default;
> > > > > > +
> > > > > > +	/*
> > > > > > +	 * 2) from flash or fuse (via platform data)
> > > > > > +	 */
> > > > >=20
> > > > > Again, how do you handle the dual MAC case?
> > > > >=20
> > > > For the platform data case, the following patch reads both mac
> > > > addresses.
> > > >=20
> > > > [PATCH 09/10] ARM: mx28: read fec mac address from ocotp
> > > >=20
> > > > +static int __init mx28evk_fec_get_mac(void)
> > > > +{
> > > > +       int i, ret;
> > > > +       u32 val;
> > > > +
> > > > +       /*
> > > > +        * OCOTP only stores the last 4 octets for each mac add=
ress,
> > > > +        * so hard-coding the first two octets as Freescale OUI=
 (00:04:9f)
> > > > +        * is needed.
> > > > +        */
> > > > +       for (i =3D 0; i < 2; i++) {
> > > > +               ret =3D mxs_read_ocotp(0x20 + i * 0x10, 1, &val=
);
> > > > +               if (ret)
> > > > +                       goto error;
> > > > +
> > > > +               mx28_fec_pdata[i].mac[0] =3D 0x00;
> > > > +               mx28_fec_pdata[i].mac[1] =3D 0x04;
> > > > +               mx28_fec_pdata[i].mac[2] =3D (val >> 24) & 0xff=
;
> > > > +               mx28_fec_pdata[i].mac[3] =3D (val >> 16) & 0xff=
;
> > > > +               mx28_fec_pdata[i].mac[4] =3D (val >> 8) & 0xff;
> > > > +               mx28_fec_pdata[i].mac[5] =3D (val >> 0) & 0xff;
> > > uuh.  Is ((val >> 24) & 0xff) supposed to be 0x9f?  If not this m=
ight
> > > have unwanted effects (practical, don't know about legal ones).
> > Yes, it is 0x9f.
> Then maybe hardcode that, or at least warn if it's not?
>=20
Will hard-code it.

--=20
Regards,
Shawn

