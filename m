From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug? GRE tunnel periodically won't transmit some packets
Date: Tue, 08 Nov 2011 11:25:38 +0100
Message-ID: <1320747938.2487.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111108070819.C643236221@apps0.cs.toronto.edu>
	 <1320737641.8976.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Siebenmann <cks@cs.toronto.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48658 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab1KHKZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 05:25:42 -0500
Received: by bke11 with SMTP id 11so233383bke.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 02:25:41 -0800 (PST)
In-Reply-To: <1320737641.8976.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 novembre 2011 =C3=A0 08:34 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le mardi 08 novembre 2011 =C3=A0 02:08 -0500, Chris Siebenmann a =C3=A9=
crit :
>=20
> >  Let me know if you want a full dump of 'ip link show' (with or
> > without verbosity).
> >=20
> > 	- cks
>=20
> Oh yes, I meant "ip -s -s link show dev extun"
>=20
> to get detailed infos :
>=20
> # ip -s -s link show dev ppp0
> 8: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc
> pfifo_fast state UNKNOWN qlen 3
>     link/ppp=20
>     RX: bytes  packets  errors  dropped overrun mcast  =20
>     21120910   21103    0       0       0       0     =20
>     RX errors: length  crc     frame   fifo    missed
>                0        0       0       0       0     =20
>     TX: bytes  packets  errors  dropped carrier collsns=20
>     1310652    13736    0       0       0       0     =20
>     TX errors: aborted fifo    window  heartbeat
>                0        0       0       0     =20
>=20


Hmm, by the way, I see the default device queue length of ppp is 3

You might have packet drops at the ppp0 device itself

ip -s -s link show dev ppp0 ; tc -s -d qdisc show dev ppp0

You could try to increase ppp0 queue length or install a classifier wit=
h
128 packet limit.

ifconfig ppp0 txqueuelen 32

or :

tc qdisc add dev ppp0 root sfq
