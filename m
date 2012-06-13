From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: Re: [PATCH net-next 3/4] 6lowpan: the two bytes of u16 tag needs to
 be stored/accessed the other way around
Date: Wed, 13 Jun 2012 00:42:32 -0400
Message-ID: <20120613004232.11a64aac@dualbox>
References: <20120611003953.0725d77a@dualbox>
 <CAJmB2rB20UL_8u1PmJM67dQJ1FaW09irJhz6-OusZwWkgs0kLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:49131 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237Ab2FMEnI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 00:43:08 -0400
In-Reply-To: <CAJmB2rB20UL_8u1PmJM67dQJ1FaW09irJhz6-OusZwWkgs0kLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alexander,

Please see my response inline.

Le Tue, 12 Jun 2012 22:07:12 +0400,
Alexander Smirnov <alex.bluesman.smirnov@gmail.com> a =C3=A9crit :

> 2012/6/11 Tony Cheneau <tony.cheneauh@amnesiak.org>:
> > Or else, tag values, as displayed with a trafic analyser, such a
> > Wireshark, are not properly displayed (e.g. 0x01 00 insted of 0x00
> > 01, and so on). ---
> > =C2=A0net/ieee802154/6lowpan.c | =C2=A0 =C2=A06 +++---
> > =C2=A01 files changed, 3 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> > index af4f29b..af2f12e 100644
> > --- a/net/ieee802154/6lowpan.c
> > +++ b/net/ieee802154/6lowpan.c
> > @@ -307,7 +307,7 @@ static u16 lowpan_fetch_skb_u16(struct sk_buff
> > *skb)
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!pskb_may_pull(skb, 2));
> >
> > - =C2=A0 =C2=A0 =C2=A0 ret =3D skb->data[0] | (skb->data[1] << 8);
> > + =C2=A0 =C2=A0 =C2=A0 ret =3D (skb->data[0] << 8) | skb->data[1];
>=20
> This function aimed to obtain u16 from skb, why did you change the
> byte-order here instead of 'tag' variable byte-shifting?=20
This probably reflects my lack of practice in writing/reading network
code. I witnessed in my network that the byte order was wrong when
sending/receiving packet (using Wireshark) and though it would be a
quick fix. Also, I assumed skb->data would store data using network
ordering, so that skb->data[0] would have been the MSB and
skb->data[1] would have been the LSB. I'll look more into that.

> Will this
> code work properly on the both little and big-endian machines?
I haven't checked that. But, just for clarification, if my changes are
not working properly on both architectures, it means that the original
code doesn't either, right?

> Please
> rework this to keep order properly for all the architectures.
I will read some more network code to see how it is handled in other
part of the kernel and rewrite the patch accordingly (if at all
needed).=20

Thank you for your advises.

> > =C2=A0 =C2=A0 =C2=A0 =C2=A0skb_pull(skb, 2);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> > =C2=A0}
> > @@ -1002,8 +1002,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* first fragment header */
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0head[0] =3D LOWPAN_DISPATCH_FRAG1 | (pay=
load_length & 0x7);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0head[1] =3D (payload_length >> 3) & 0xff=
;
> > - =C2=A0 =C2=A0 =C2=A0 head[2] =3D tag & 0xff;
> > - =C2=A0 =C2=A0 =C2=A0 head[3] =3D tag >> 8;
> > + =C2=A0 =C2=A0 =C2=A0 head[2] =3D tag >> 8;
> > + =C2=A0 =C2=A0 =C2=A0 head[3] =3D tag & 0xff;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D lowpan_fragment_xmit(skb, head, =
header_length, 0, 0);
> >
> > --
> > 1.7.3.4
> >
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Regards,
	Tony
