From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about __alloc_skb() speedup
Date: Sat, 04 Dec 2010 15:49:19 +0100
Message-ID: <1291474159.2806.97.camel@edumazet-laptop>
References: <20101203101450.GA9573@Desktop-Junchang>
	 <1291373429.2897.96.camel@edumazet-laptop>
	 <20101204141826.GA5830@Desktop-Junchang>
	 <1291474058.2806.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44037 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab0LDOtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:49:24 -0500
Received: by wyb28 with SMTP id 28so10497010wyb.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:49:23 -0800 (PST)
In-Reply-To: <1291474058.2806.96.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 d=C3=A9cembre 2010 =C3=A0 15:47 +0100, Eric Dumazet a =C3=A9=
crit :
> Le samedi 04 d=C3=A9cembre 2010 =C3=A0 22:18 +0800, Junchang Wang a =C3=
=A9crit :
>=20
> > I added the prefetchw() in pktgen as follows:
> >=20
> > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> > index 2953b2a..512f1ae 100644
> > --- a/net/core/pktgen.c
> > +++ b/net/core/pktgen.c
> > @@ -2660,6 +2660,7 @@ static struct sk_buff *fill_packet_ipv4(struc=
t net_device *odev,
> >  		sprintf(pkt_dev->result, "No memory");
> >  		return NULL;
> >  	}
> > +	prefetchw(skb->data);
> > =20
> >  	skb_reserve(skb, datalen);
> > =20
> > This time, I can check it without rebooting the system. The perform=
ance=20
> > gain is 4%-5%(stable). Does 4% worth submitting it to the kernel?
>=20
> Yes I believe so, pktgen being very specific, but I have few question=
s :
>=20
> Is it with SLUB or SLAB ?
>=20
> How many buffers in TX ring on you nic (ethtool -g eth0) ?
>=20
> What is the datalen value here ? (you prefetch, then advance skb->dat=
a)
>=20
> 32 or 64bit kernel ?
>=20
> How many pps do you get before and after patch ?
>=20
> Thanks
>=20

Also, dont forget to include the prefetchw() in fill_packet_ipv6() as
well when submitting your patch.


