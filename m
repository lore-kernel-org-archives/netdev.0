From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/2] net: dsa: introduce STPID switch tagging handling code
Date: Wed, 21 Jul 2010 17:35:31 +0200
Message-ID: <20100721153531.GN21121@mail.wantstofly.org>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org> <20100721150251.GL21121@mail.wantstofly.org> <AANLkTim1gbnH99GC_dVL8uevRgCRsn7dvAJ_rX-2Xgon@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karl Beldan <karl.beldan@gmail.com>, netdev@vger.kernel.org,
	Graf Yang <graf.yang@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org,
	"David S. Miller" <davem@davemloft.net>
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:57105 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab0GUPfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 11:35:34 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTim1gbnH99GC_dVL8uevRgCRsn7dvAJ_rX-2Xgon@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 11:29:30AM -0400, Mike Frysinger wrote:

> >> + =A0 =A0 source_port =3D dsa_header[1] & 0x03;
> >> + =A0 =A0 if (source_port >=3D DSA_MAX_PORTS || ds->ports[source_p=
ort] =3D=3D NULL)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_drop;
> >> +
> >> + =A0 =A0 if (((dsa_header[0] & ETH_P_8021QH) =3D=3D ETH_P_8021QH)=
 &&
> >
> > This is bogus -- what it does is:
> >
> > =A0 =A0 =A0 =A0if ((dsa_header[0] & 0x81) =3D=3D 0x81)
> >
> > It doesn't look like you need to mask here at all.
>=20
> where does it say dsa_header[0] will always have 0x81 set ?

Eh?

This code is checking whether the packet has a STPID tag on it or not.
A STPID tag exists if the first 12 nibbles are 0x810.

You are checking whether the first 8 nibbles of this are equal to 0x81
by doing:

	if ((byte & 0x81) =3D=3D 0x81)

What if the first byte is 0x93?  Or 0xc5?
