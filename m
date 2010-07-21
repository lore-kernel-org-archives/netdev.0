From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/2] net: dsa: introduce STPID switch
	tagging handling code
Date: Wed, 21 Jul 2010 12:08:58 -0400
Message-ID: <AANLkTinPtd2xXzq0MpR517OsbZWUZjdp25x8FndhQ2CP@mail.gmail.com>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
	<20100721150251.GL21121@mail.wantstofly.org> <AANLkTim1gbnH99GC_dVL8uevRgCRsn7dvAJ_rX-2Xgon@mail.gmail.com>
	<20100721153531.GN21121@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karl Beldan <karl.beldan@gmail.com>, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	"David S. Miller" <davem@davemloft.net>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:45945 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755049Ab0GUQJT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 12:09:19 -0400
Received: by ewy23 with SMTP id 23so2383957ewy.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 09:09:18 -0700 (PDT)
In-Reply-To: <20100721153531.GN21121@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 11:35, Lennert Buytenhek wrote:
> On Wed, Jul 21, 2010 at 11:29:30AM -0400, Mike Frysinger wrote:
>> >> + =C2=A0 =C2=A0 source_port =3D dsa_header[1] & 0x03;
>> >> + =C2=A0 =C2=A0 if (source_port >=3D DSA_MAX_PORTS || ds->ports[s=
ource_port] =3D=3D NULL)
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_drop;
>> >> +
>> >> + =C2=A0 =C2=A0 if (((dsa_header[0] & ETH_P_8021QH) =3D=3D ETH_P_=
8021QH) &&
>> >
>> > This is bogus -- what it does is:
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((dsa_header[0] & 0x81) =3D=3D 0x81)
>> >
>> > It doesn't look like you need to mask here at all.
>>
>> where does it say dsa_header[0] will always have 0x81 set ?
>
> Eh?
>
> This code is checking whether the packet has a STPID tag on it or not=
=2E
> A STPID tag exists if the first 12 nibbles are 0x810.
>
> You are checking whether the first 8 nibbles of this are equal to 0x8=
1
> by doing:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((byte & 0x81) =3D=3D 0x81)
>
> What if the first byte is 0x93? =C2=A0Or 0xc5?

that was my point.  should it be masking or doing a raw compare ?

i have nfc as i had nothing to do with the creation of this code.  i
dont know the first thing about VLAN tags or anything else at that
level.
-mike
