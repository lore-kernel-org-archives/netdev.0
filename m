From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/2] net: dsa: introduce STPID switch tagging handling code
Date: Tue, 10 Aug 2010 16:05:52 +0200
Message-ID: <20100810140552.GV8876@mail.wantstofly.org>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org> <20100721150251.GL21121@mail.wantstofly.org> <AANLkTim1gbnH99GC_dVL8uevRgCRsn7dvAJ_rX-2Xgon@mail.gmail.com> <20100721153531.GN21121@mail.wantstofly.org> <AANLkTinPtd2xXzq0MpR517OsbZWUZjdp25x8FndhQ2CP@mail.gmail.com> <AANLkTinNiE1BE=HuwVG2Tom922XJXxQDB-JMsPYimPTk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karl Beldan <karl.beldan@gmail.com>, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:45316 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757541Ab0HJOFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 10:05:53 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinNiE1BE=HuwVG2Tom922XJXxQDB-JMsPYimPTk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 29, 2010 at 01:50:45PM -0400, Mike Frysinger wrote:

> >>> >> + =A0 =A0 source_port =3D dsa_header[1] & 0x03;
> >>> >> + =A0 =A0 if (source_port >=3D DSA_MAX_PORTS || ds->ports[sour=
ce_port] =3D=3D NULL)
> >>> >> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_drop;
> >>> >> +
> >>> >> + =A0 =A0 if (((dsa_header[0] & ETH_P_8021QH) =3D=3D ETH_P_802=
1QH) &&
> >>> >
> >>> > This is bogus -- what it does is:
> >>> >
> >>> > =A0 =A0 =A0 =A0if ((dsa_header[0] & 0x81) =3D=3D 0x81)
> >>> >
> >>> > It doesn't look like you need to mask here at all.
> >>>
> >>> where does it say dsa_header[0] will always have 0x81 set ?
> >>
> >> Eh?
> >>
> >> This code is checking whether the packet has a STPID tag on it or =
not.
> >> A STPID tag exists if the first 12 nibbles are 0x810.
> >>
> >> You are checking whether the first 8 nibbles of this are equal to =
0x81
> >> by doing:
> >>
> >> =A0 =A0 =A0 =A0if ((byte & 0x81) =3D=3D 0x81)
> >>
> >> What if the first byte is 0x93? =A0Or 0xc5?
> >
> > that was my point. =A0should it be masking or doing a raw compare ?
>=20
> and the answer is ... ?  so i can send an updated patch ;)

=46rom what I understand, you should just be checking for equality with
0x81 in the first byte, as that is what indicates presence of the STPID
tag.

Is the hardware you're doing this on available somewhere for me to
try things out on?
