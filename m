From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: many sockets, slow sendto
Date: Mon, 30 Apr 2007 21:59:06 +0200
Message-ID: <46364A8A.7090702@cosmosbay.com>
References: <20070430.002643.68156452.davem@davemloft.net>	<20070430.195604.26499662.yoshfuji@linux-ipv6.org>	<20070430144715.b0c03c83.dada1@cosmosbay.com> <20070501.044317.47815539.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, zacco@fw.hu, baruch@ev-en.org,
	netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:59680 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423551AbXD3T7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 15:59:21 -0400
In-Reply-To: <20070501.044317.47815539.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E a =C3=A9crit :
> In article <20070430144715.b0c03c83.dada1@cosmosbay.com> (at Mon, 30 =
Apr 2007 14:47:15 +0200), Eric Dumazet <dada1@cosmosbay.com> says:
>=20
>> Also, I am not sure we need to use all 128 bits of IPV6 address, may=
be the 64 low order bits are enough ?
>=20
> Well, maybe, but in IPv6, auto-configured addresses on an interface h=
ave
> the same 64-bit LSBs.  So, I'd keep as-is so far.
>=20

Hum... then maybe ipv6_addr_hash() in include/net/addrconf.h should be =
changed=20
as well

static __inline__ u8 ipv6_addr_hash(const struct in6_addr *addr)
{
         __u32 word;

         /*
          * We perform the hash function over the last 64 bits of the a=
ddress
          * This will include the IEEE address token on links that supp=
ort it.
          */

         word =3D (__force u32)(addr->s6_addr32[2] ^ addr->s6_addr32[3]=
);
         word ^=3D (word >> 16);
         word ^=3D (word >> 8);

         return ((word ^ (word >> 4)) & 0x0f);
}


