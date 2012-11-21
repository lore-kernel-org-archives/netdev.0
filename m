From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 8139cp: set ring address before enabling receiver
Date: Wed, 21 Nov 2012 20:18:55 +0000
Message-ID: <1353529135.2619.36.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120602235020.2C0A57C006C@ra.kernel.org>
	 <1353517042.26346.130.camel@shinybook.infradead.org>
	 <50AD1972.5080403@pobox.com>
	 <1353527481.26346.150.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34891 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756286Ab2KUUS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 15:18:59 -0500
In-Reply-To: <1353527481.26346.150.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 19:51 +0000, David Woodhouse wrote:
> On Wed, 2012-11-21 at 13:12 -0500, Jeff Garzik wrote:
> >=20
> > What sticks out at me from the commit message?
> >=20
> > It was not tested on the famously quirky 8139 hardware at all.
> >=20
> > While I have not looked at the 8139C+ data sheet in a while, someti=
mes=20
> > the hardware _did_ have a strange init order.
> >=20
> > As this works in a simulator but fails on real hardware, it seems l=
ike=20
> > an obvious regression caused by an untested [on read hardware] patc=
h.
>=20
> The data sheet (v1.6, from http://realtek.info/pdf/rtl8139cp.pdf ) sa=
ys
> in =C2=A76.33 (C+ Command Register):
>  "Enable C+ mode functions in C+CR register first,
>  =3D> Enable transmit/receive in Command register (offset 37h),
>  =3D> Configure other related registers (ex. Descriptor start address=
,
>     TCR, RCR, ...)."
>
> I understand the concern expressed in the offending commit message ab=
out
> DMA happening to invalid addresses, and I'll look at the data sheet
> harder to see when the DMA actually starts happening. But it definite=
ly
> seems that our current code isn't doing what the data sheet says.
>=20
> I wonder if I can find one of these lying around and stick it in a
> machine with an IOMMU...

You might be able to avoid disaster by doing:

1. Set MAC filter to drop everything
2. Enable RX DMA
3. Set RX DMA ring address
4. Set MAC filter according to current flags & multicast list

I'm assuming, knowing nothing about this particular hardware, that the
MAC filter register(s) will accept writes before RX DMA is enabled.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
