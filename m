From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Sun, 13 Nov 2011 23:00:57 +0100
Message-ID: <1321221657.17837.51.camel@edumazet-laptop>
References: <1320673364.3020.21.camel@bwh-desktop>
	 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111109.163708.2156133928191684256.davem@davemloft.net>
	 <1320876183.3272.8.camel@edumazet-laptop>
	 <1320884940.5825.34.camel@edumazet-laptop>
	 <1320937526.307.0.camel@lb-tlvb-eilong.il.broadcom.com>
	 <1320938878.2310.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320942423.307.10.camel@lb-tlvb-eilong.il.broadcom.com>
	 <1320943512.10042.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321210419.3101.1.camel@lb-tlvb-eilong.il.broadcom.com>
	 <1321213338.17837.38.camel@edumazet-laptop>
	 <1321214895.3101.3.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33954 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337Ab1KMWBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 17:01:02 -0500
Received: by wyh15 with SMTP id 15so5340433wyh.19
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2011 14:01:01 -0800 (PST)
In-Reply-To: <1321214895.3101.3.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 13 novembre 2011 =C3=A0 22:08 +0200, Eilon Greenstein a =C3=
=A9crit :
> On Sun, 2011-11-13 at 11:42 -0800, Eric Dumazet wrote:
> > Le dimanche 13 novembre 2011 =C3=A0 20:53 +0200, Eilon Greenstein a=
 =C3=A9crit :
> >=20
> > > I=E2=80=99m not sure I=E2=80=99m following the math over here. As=
suming L1 is 64 bytes,
> > > we need up to 63 bytes to align the start address (assuming SLOB =
is
> > > being used) and additional (up to) 63 bytes at the end. That can =
sum up
> > > to 126 bytes  am I missing something?
> > >=20
> >=20
> > What do you really mean by aligning the end ?
>=20
> I mean padding it to full cache line.
>=20
> > How can both start and end of a frame can be aligned ?
>=20
> The packet will start at aligned address and (using padding) will end=
 at
> cache line boundaries.
>=20

OK, so hardware adds up to 63 bytes of padding at the end of the packet=
=2E

> > If hardware needs extra room after the end of frame, then we alread=
y
> > have it (since we store struct skb_shared_info here)
>=20
> We have some space in there, but as far as I can tell it's not up to =
63
> bytes, right? We will overrun the dataref.
>=20

OK then we need using build_skb() for this driver :)

http://lists.openwall.net/netdev/2011/07/11/19

This way, we build the skb_shared_info content _after_ frame is
delivered by device.
