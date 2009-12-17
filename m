From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/2] udp: add non-linear uniform port allocation scheme
 option /proc/sys/net/ipv4/udp_port_randomization
Date: Thu, 17 Dec 2009 15:07:55 +0100
Message-ID: <4B2A3B3B.3000308@gmail.com>
References: <4B2933EF.9060606@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48425 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553AbZLQOIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 09:08:43 -0500
In-Reply-To: <4B2933EF.9060606@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/12/2009 20:24, Lucian Adrian Grijincu a =C3=A9crit :
>=20
> When we allocate ports with a (really) high frequency, randomization
> does more harm as some values tend to repeat with a higher frequency
> than they would if allocated uniformly, while others are selected mor=
e
> rarely.
>=20
> This patch does not allocate ports linearly as older kernels used to =
do,
> but it allocates the port with an uniform frequency.
>=20
> For example: assuming UDP_HTABLE_SIZE=3D8, hint=3D3, low=3D0, high=3D=
32
> This leads to:
>> first=3D3, last=3D3+8=3D11, rand=3D(1 | 1) * UDP_HTABLE_SIZE=3D8
>=20
> The port selection code is similar to:
>> for first in [3..11):
>>     snum =3D first
>>     do if (!good(snum)) snum+=3D8 while(snum!=3Dfirst)
>=20
> Will give the following sequence for snum (skipping `modulo 32` for
> brevity)
>   3,  3+8,  3+8+8,  3+8+8+8,
>   4,  4+8,  4+8+8,  4+8+8+8,
>  ...
>   9,  9+8,  9+8+8,  9+8+8+8,
>  10, 10+8, 10+8+8, 10+8+8+8,
>=20
> This will generate all numbers in the [low..high) interval with the
> same frequency. This leads to better performance when most ports are
> already allocated.
>=20
> Randomization is still enabled by default for normal setups that will
> most likely not encounter such situations.
>=20

I dont like this patch, I am not convinced at all by your example.

Your example is flawed, since UDP_HTABLE_SIZE >=3D 128 (128 is the mini=
mum hash size)

I cannot understand why chosing a "one" increment instead of a "random =
odd" increment
can give a more uniform allocation frequency.

If port randomization is not good enough, please make it better, not re=
verting to
plain sequential old behavior... (your application can do its own port =
allocation by the way)

BTW, net-next-2.6 is not yet open, this is not the right time to submit=
 non bug fixes patches.

Thanks
