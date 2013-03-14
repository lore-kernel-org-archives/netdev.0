From: Loic Domaigne <loic.domaigne@googlemail.com>
Subject: Re: RFC: [PATCH 3/3] usb: cdc_ncm: MirrorLink booster for N60x,70x
Date: Thu, 14 Mar 2013 23:15:37 +0100
Message-ID: <20130314221537.GA4468@feynman.loic.net>
References: <20130308210324.GA4796@feynman.loic.net>
 <87fw04es1p.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:42419 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064Ab3CNWPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 18:15:43 -0400
Content-Disposition: inline
In-Reply-To: <87fw04es1p.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 09, 2013 at 12:22:42PM +0100, Bj=F8rn Mork wrote:
> Loic Domaigne <loic.domaigne@googlemail.com> writes:
>=20
> > +			/* The Nokia N60x,70x (productId 0x1419) needs:
> > +			 * - Jumbo Frame (MTU 8kB)
> > +			 * - Disable TX batching to improve latency
> > +			 */
> > +			if (dev !=3D NULL)
> > +				/* called during NCM bind */
> > +				dev->hard_mtu =3D 8192+ETH_HLEN;
> > +			else {
> > +				/* called during NCM setup */
> > +				pr_info(KBUILD_MODNAME ":  jambit MirrorLink booster for "
> > +					"Nokia 60x,70x family");
> > +				ctx->tx_max_datagrams  =3D 1;
> > +				ctx->max_datagram_size =3D 8192+ETH_HLEN;
> > +			}
>=20
> This looks really strange to me at first glance.  An important part o=
f
> the NCM protocol is the ability for the host to request these values
> from the device,=20

Your questions are legitimate.

This has been ages since I wrote this patch. My answers might not be
absolutely accurate.

Regarding tx_max_datagrams, this could be I guess communicated by the d=
evice=20
using the NTB Parameter structure / wNtbOutMaxDatagrams. Of course, Err=
ata K=20
kicks in... IIRC the device answered "no limitation". Hence I construct=
ed NTBs=20
with 2 or more datagrams and sent them to the device. The device reacte=
d=20
properly.


> and the only real point of using NCM in the first place
> is the bundling.  If the device has higher performance without bundli=
ng,
> then why the h is it using NCM?

Because MirrorLink specifies this protocol.


> And if it really wants jumbo datagrams, then why doesn't it say so wh=
en
> the driver ask?

IIRC, the driver (at that time) was only setting the MTU if the device =
provided
the *optional* {get|set}MaxDatagramSize capability. Which is not the ca=
se here.
So the driver assumed 1514 bytes.

I don't remember anymore what the device is passing us through the ENFD=
=2E That
something I'll need to doublecheck.

> Are the above values based on some perceived performance, or are ther=
e
> actual measurements behind this?   Yes, sure the latency will drop wi=
th
> no bundling, but that is sort of the trade-off you chose when you cho=
se
> NCM...

Yes, we have hard numbers for MirrorLink use cases.


> > @@ -1269,5 +1320,7 @@ module_exit(cdc_ncm_exit);
> >  #endif
> > =20
> >  MODULE_AUTHOR("Hans Petter Selasky");
> > +MODULE_AUTHOR("Loic Domaigne");
> >  MODULE_DESCRIPTION("USB CDC NCM host driver");
> > +MODULE_DESCRIPTION("MirrorLink Booster by jambit GmbH");
> >  MODULE_LICENSE("Dual BSD/GPL");
>=20
> I do not think this is appropriate at all for a device specific bug
> workaround...

We absolutely don't cling to those lines.

Their sole purpose was to help me checking that the 'patched' driver is=
 used.
It was planned to tweak other devices (again within the MirrorLink) con=
text,
but I got other assignments.


Thanks Bj=F8rn for your comments!=20

Cheers,
Loic
