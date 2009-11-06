From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 take2] ipv6: udp: Optimise multicast reception
Date: Fri, 06 Nov 2009 18:24:46 +0100
Message-ID: <4AF45BDE.4090501@gmail.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <4AF4506B.3080905@gmail.com> <4AF45796.8010409@gmail.com> <200911061919.47100.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	opurdila@ixiacom.com
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56192 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759460AbZKFRYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 12:24:48 -0500
In-Reply-To: <200911061919.47100.lgrijincu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lucian Adrian Grijincu a =E9crit :
> =CEn data de Vin 06 Noi 2009 19:06:30 Eric Dumazet a scris:
>> +       for (i =3D 0; i < count; i++) {
>> +               skb1 =3D (i =3D=3D final) ? skb : skb_clone(skb, GFP=
_ATOMIC);
>> +
>> +               if (skb1) {
>> +                       sk =3D stack[i];
>> +                       bh_lock_sock(sk);
>> +                       if (!sock_owned_by_user(sk))
>> +                               udpv6_queue_rcv_skb(sk, skb1);
>> +                       else
>> +                               sk_add_backlog(sk, skb1);
>> +                       bh_unlock_sock(sk);
>> +               }
>> +       }
>=20
> Is there any reason to continue this loop if we ever get a NULL skb1?
>=20
> If once we can't get a GFP_ATOMIC clone, are there merrits to calling=
=20
> skb_clone() like crazy (in a very tight loop) (whilst holding a spin =
lock in=20
> some cases)?
>=20

Well, because of future RCU patch, I'll need to continue the loop anywa=
y,
because sock_put() will be part of the loop.

Also, the 'final' case will at least provide the skb we already have.


