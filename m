From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] NIU support for skb->rxhash
Date: Thu, 22 Apr 2010 13:43:18 +0200
Message-ID: <1271936598.7895.5304.camel@edumazet-laptop>
References: <20100422.042157.99869295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:50250 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab0DVLn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 07:43:28 -0400
Received: by bwz25 with SMTP id 25so9500249bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 04:43:27 -0700 (PDT)
In-Reply-To: <20100422.042157.99869295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 04:21 -0700, David Miller a =C3=A9crit :
> But it turns out using it is largely pointless since the only way to
> get the hash value(s) is through a structure which is prepended to th=
e
> packet data (so we take a cache miss on the packet data anyways)
> instead of being able to fetch it out of the RX descriptors :-/
>=20
> If anyone out there is trying to design sane hardware, please put the
> following into your RX descriptors:
>=20
> 1) ethernet protocol type (u16)
> 2) a flag bit indicating if the packet destination matched one
>    of the programmed unicast MAC addresses
> 3) a flag bit indicating "multicast"
> 4) a flag bit indicating "broadcast"
> 5) at least 32-bits of the computed flow hash (u32)
>=20
> kthx, bye!

Then, our stack also touch all 256 bytes of skb structure itself.

offsetof(struct sk_buff, next)    =3D0x0
offsetof(struct sk_buff, rxhash)  =3D0xa8
offsetof(struct sk_buff, dev)     =3D0x20
offsetof(struct sk_buff, len)     =3D0x68
offsetof(struct sk_buff, protocol)=3D0x7e
offsetof(struct sk_buff, network_header)=3D0xc0
offsetof(struct sk_buff, data)    =3D0xd8
offsetof(struct sk_buff, head)    =3D0xd0

Time for a reordering I guess ;)


