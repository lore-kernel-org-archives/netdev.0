From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 03/10] net/fec: add mac field into platform data and
 consolidate fec_get_mac
Date: Wed, 29 Dec 2010 19:08:29 +0800
Message-ID: <20101229110828.GE19347@freescale.com>
References: <1293548155-16328-1-git-send-email-shawn.guo@freescale.com>
 <1293548155-16328-4-git-send-email-shawn.guo@freescale.com>
 <20101229065329.GB31010@jasper.tkos.co.il>
 <20101229103014.GD19347@freescale.com>
 <20101229103758.GU14221@pengutronix.de>
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
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:58563
	"EHLO DB3EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751883Ab0L2LGa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 06:06:30 -0500
Received: from mail113-db3 (localhost.localdomain [127.0.0.1])	by
 mail113-db3-R.bigfish.com (Postfix) with ESMTP id F0F9410C80EE	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 11:06:27 +0000 (UTC)
Received: from DB3EHSMHS008.bigfish.com (unknown [10.3.81.250])	by
 mail113-db3.bigfish.com (Postfix) with ESMTP id 6DE38110004C	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 11:06:27 +0000 (UTC)
Received: from az33smr01.freescale.net (az33smr01.freescale.net
 [10.64.34.199])	by de01egw02.freescale.net (8.14.3/8.14.3) with ESMTP id
 oBTB6NTT017242	for <netdev@vger.kernel.org>; Wed, 29 Dec 2010 04:06:25 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu.ap.freescale.net [10.192.242.196])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id oBTB6MZj021891	for
 <netdev@vger.kernel.org>; Wed, 29 Dec 2010 05:06:23 -0600 (CST)
Content-Disposition: inline
In-Reply-To: <20101229103758.GU14221@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On Wed, Dec 29, 2010 at 11:37:58AM +0100, Uwe Kleine-K=F6nig wrote:
> Hello,
>=20
> On Wed, Dec 29, 2010 at 06:30:15PM +0800, Shawn Guo wrote:
> > Sorry, Baruch.  I missed two comments in the last reply.
> >=20
> > On Wed, Dec 29, 2010 at 08:53:30AM +0200, Baruch Siach wrote:
> > > Hi Shawn,
> > >=20
> > > Please add netdev@vger.kernel.org to the Cc of all your fec drive=
r patches.
> > >=20
> > I was aware of this after I sent out the patch set last night.
> > Can I just resend all the patches in v2 and get netdev@vger.kernel.=
org
> > included?
> [I just added netdev for this reply.  I think adding it for v2 is OK
> then.  For those interested, the whole series can be found at
>=20
> 	http://thread.gmane.org/gmane.linux.ports.arm.kernel/100902
>=20
> .]
> =20
Thanks.

> > > On Tue, Dec 28, 2010 at 10:55:48PM +0800, Shawn Guo wrote:
> > [...]
> > > > +	/*
> > > > +	 * try to get mac address in following order:
> > > > +	 *
> > > > +	 * 1) kernel command line fec_mac=3Dxx:xx:xx...
> > > > +	 */
> > > > +	iap =3D fec_mac_default;
> > > > +
> > > > +	/*
> > > > +	 * 2) from flash or fuse (via platform data)
> > > > +	 */
> > >=20
> > > Again, how do you handle the dual MAC case?
> > >=20
> > For the platform data case, the following patch reads both mac
> > addresses.
> >=20
> > [PATCH 09/10] ARM: mx28: read fec mac address from ocotp
> >=20
> > +static int __init mx28evk_fec_get_mac(void)
> > +{
> > +       int i, ret;
> > +       u32 val;
> > +
> > +       /*
> > +        * OCOTP only stores the last 4 octets for each mac address=
,
> > +        * so hard-coding the first two octets as Freescale OUI (00=
:04:9f)
> > +        * is needed.
> > +        */
> > +       for (i =3D 0; i < 2; i++) {
> > +               ret =3D mxs_read_ocotp(0x20 + i * 0x10, 1, &val);
> > +               if (ret)
> > +                       goto error;
> > +
> > +               mx28_fec_pdata[i].mac[0] =3D 0x00;
> > +               mx28_fec_pdata[i].mac[1] =3D 0x04;
> > +               mx28_fec_pdata[i].mac[2] =3D (val >> 24) & 0xff;
> > +               mx28_fec_pdata[i].mac[3] =3D (val >> 16) & 0xff;
> > +               mx28_fec_pdata[i].mac[4] =3D (val >> 8) & 0xff;
> > +               mx28_fec_pdata[i].mac[5] =3D (val >> 0) & 0xff;
> uuh.  Is ((val >> 24) & 0xff) supposed to be 0x9f?  If not this might
> have unwanted effects (practical, don't know about legal ones).
Yes, it is 0x9f.

--=20
Regards,
Shawn

