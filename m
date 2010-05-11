From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Tue, 11 May 2010 08:27:47 +0200
Message-ID: <1273559267.2339.6.camel@edumazet-laptop>
References: <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273147586.2357.63.camel@edumazet-laptop>
	 <20100506.220443.135536330.davem@davemloft.net>
	 <1273210329.2222.42.camel@edumazet-laptop>
	 <20100507101451.1b4286b7@nehalam>
	 <1273252893.2261.84.camel@edumazet-laptop>
	 <20100507103639.4f1a51fa@nehalam>
	 <1273268446.2325.53.camel@edumazet-laptop>
	 <D1C2B1EC-ABE8-4D87-9227-6D0F1C1C8B77@guavus.com>
	 <1273504693.2221.17.camel@edumazet-laptop>
	 <AAFABD0F-C66F-44C2-8BDC-FB489EA8655F@guavus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	"<bhaskie@gmail.com>" <bhaskie@gmail.com>,
	"<bhutchings@solarflare.com>" <bhutchings@solarflare.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>
To: Bijay Singh <Bijay.Singh@guavus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38842 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756906Ab0EKG2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 02:28:30 -0400
Received: by wyb32 with SMTP id 32so658583wyb.19
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 23:28:28 -0700 (PDT)
In-Reply-To: <AAFABD0F-C66F-44C2-8BDC-FB489EA8655F@guavus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 11 mai 2010 =C3=A0 04:08 +0000, Bijay Singh a =C3=A9crit :
> Hi Eric,
>=20
> I guess that makes me the enviable one. So I am keen to test out this=
 feature

>  completely, as long as I know what to do as a next step, directions,=
 patches.
>=20

MTU > 4000 is not reliable because of high order allocations on typical
NICS. I am afraid you need NIC able to deliver page fragments.

Its working here (32bit kernel) with a tg3 NIC, but I got following
message :

ifconfig eth3 mtu 9000
=2E..
[51492.936500] 167731 total pagecache pages
[51492.936500] 0 pages in swap cache
[51492.936500] Swap cache stats: add 0, delete 0, find 0/0
[51492.936500] Free swap  =3D 4192928kB
[51492.936500] Total swap =3D 4192928kB
[51492.936500] 1114110 pages RAM
[51492.936500] 885761 pages HighMem
[51492.936500] 77073 pages reserved
[51492.936500] 134483 pages shared
[51492.936500] 159131 pages non-shared
[51492.953027] tg3 0000:14:04.1: eth3: Using a smaller RX standard ring=
=2E
Only 183 out of 511 buffers were allocated successfully

$ ethtool -g eth3
Ring parameters for eth3:
Pre-set maximums:
RX:		511
RX Mini:	0
RX Jumbo:	0
TX:		511
Current hardware settings:
RX:		183
RX Mini:	0
RX Jumbo:	0
TX:		511

$ cat /proc/buddyinfo
Node 0, zone      DMA      5      2      1      1      2      2      2 =
     1      0      1      0=20
Node 0, zone   Normal   4285   1823    248     73      9      5      0 =
     0      0      0      0=20
Node 0, zone  HighMem     97    199    921    583    383    261    155 =
   117     69     41    649=20

I know that if I try to stress RX path, I'll get failures.

Could you explain me why you need both big MTUS and TCP-MD5 ?



