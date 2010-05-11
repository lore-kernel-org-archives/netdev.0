From: Bijay Singh <Bijay.Singh@guavus.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Tue, 11 May 2010 08:23:46 +0000
Message-ID: <62F5C4BA-4DDC-4805-8156-F5749BAA586A@guavus.com>
References: <1273085598.2367.233.camel@edumazet-laptop>
 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
 <1273147586.2357.63.camel@edumazet-laptop>
 <20100506.220443.135536330.davem@davemloft.net>
 <1273210329.2222.42.camel@edumazet-laptop> <20100507101451.1b4286b7@nehalam>
 <1273252893.2261.84.camel@edumazet-laptop> <20100507103639.4f1a51fa@nehalam>
 <1273268446.2325.53.camel@edumazet-laptop>
 <D1C2B1EC-ABE8-4D87-9227-6D0F1C1C8B77@guavus.com>
 <1273504693.2221.17.camel@edumazet-laptop>
 <AAFABD0F-C66F-44C2-8BDC-FB489EA8655F@guavus.com>
 <1273559267.2339.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	"<bhaskie@gmail.com>" <bhaskie@gmail.com>,
	"<bhutchings@solarflare.com>" <bhutchings@solarflare.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [204.232.241.167] ([204.232.241.167]:43122 "EHLO mx1.guavus.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752555Ab0EKIXw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 04:23:52 -0400
In-Reply-To: <1273559267.2339.6.camel@edumazet-laptop>
Content-Language: en-US
Content-ID: <c58ae71b-e9a8-49bd-9ee7-a1f77c020854>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I need MD5 for my BGP sessions and need the jumbo packets for the IS-IS=
 peering. MTU of 1500 results in LSPs higher that 1500 getting dropped =
at the peering router.=20

On 11-May-2010, at 11:57 AM, Eric Dumazet wrote:

> Le mardi 11 mai 2010 =E0 04:08 +0000, Bijay Singh a =E9crit :
>> Hi Eric,
>>=20
>> I guess that makes me the enviable one. So I am keen to test out thi=
s feature
>=20
>> completely, as long as I know what to do as a next step, directions,=
 patches.
>>=20
>=20
> MTU > 4000 is not reliable because of high order allocations on typic=
al
> NICS. I am afraid you need NIC able to deliver page fragments.
>=20
> Its working here (32bit kernel) with a tg3 NIC, but I got following
> message :
>=20
> ifconfig eth3 mtu 9000
> ...
> [51492.936500] 167731 total pagecache pages
> [51492.936500] 0 pages in swap cache
> [51492.936500] Swap cache stats: add 0, delete 0, find 0/0
> [51492.936500] Free swap  =3D 4192928kB
> [51492.936500] Total swap =3D 4192928kB
> [51492.936500] 1114110 pages RAM
> [51492.936500] 885761 pages HighMem
> [51492.936500] 77073 pages reserved
> [51492.936500] 134483 pages shared
> [51492.936500] 159131 pages non-shared
> [51492.953027] tg3 0000:14:04.1: eth3: Using a smaller RX standard ri=
ng.
> Only 183 out of 511 buffers were allocated successfully
>=20
> $ ethtool -g eth3
> Ring parameters for eth3:
> Pre-set maximums:
> RX:		511
> RX Mini:	0
> RX Jumbo:	0
> TX:		511
> Current hardware settings:
> RX:		183
> RX Mini:	0
> RX Jumbo:	0
> TX:		511
>=20
> $ cat /proc/buddyinfo
> Node 0, zone      DMA      5      2      1      1      2      2      =
2      1      0      1      0=20
> Node 0, zone   Normal   4285   1823    248     73      9      5      =
0      0      0      0      0=20
> Node 0, zone  HighMem     97    199    921    583    383    261    15=
5    117     69     41    649=20
>=20
> I know that if I try to stress RX path, I'll get failures.
>=20
> Could you explain me why you need both big MTUS and TCP-MD5 ?
>=20
>=20
>=20

