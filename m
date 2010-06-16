From: Pedro Garcia <pedro.netdev@dondevamos.com>
Subject: Re: [PATCH] =?UTF-8?Q?vlan=5Fdev=3A=20VLAN=20=30=20should=20be=20treated?=
 =?UTF-8?Q?=20as=20=22no=20vlan=20tag=22=20=28=38=30=32=2E=31p=20packet=29?=
Date: Wed, 16 Jun 2010 15:28:55 +0200
Message-ID: <6b5ed8108cebb1865c85e03d3244b6ed@dondevamos.com>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>	 <1276466190.14011.223.camel@localhost>	 <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>	 <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>	 <4C1662C3.3070708@trash.net> <1276542772.2444.13.camel@edumazet-laptop>	 <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com> <1276679284.2632.22.camel@edumazet-laptop> <4C18B898.4000307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Patrick McHardy <kaber@trash.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 13.Red-213-97-209.staticIP.rima-tde.net ([213.97.209.13]:36806
	"EHLO smtp1.dondevamos.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754787Ab0FPN26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 09:28:58 -0400
In-Reply-To: <4C18B898.4000307@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jun 2010 13:42:16 +0200, Patrick McHardy <kaber@trash.net>
wrote:
> Eric Dumazet wrote:
>> Le mercredi 16 juin 2010 =C3=A0 10:49 +0200, Pedro Garcia a =C3=A9cr=
it :
>>> Here it is again. I added the modifications in
>>> http://kerneltrap.org/mailarchive/linux-netdev/2010/5/23/6277868 fo=
r HW
>>> accelerated incoming packets (it did not apply cleanly on the last
>>> version of
>>> the kernel, so I applied manually). Now, if the VLAN 0 is not
>>> explicitly created by the user, VLAN 0 packets will be treated as n=
o
>>> VLAN (802.1p packets), instead of dropping them.
>>>
>>> The patch is now for two files: vlan_core (accel) and vlan_dev (non
>>> accel)
>>>
>>> I can not test on HW accelerated devices, so if someone can check i=
t I
>>> will appreciate (even though in the thread above it looked like yes=
).
>>> For non accel I tessted in 2.6.26. Now the patch is for
>>> net-next-2.6, and it compiles OK, but I a have to setup a test
>>> environment to check it is still OK (should, but better to test).
>>>
>>> Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>
>>>    =20
>>
>> OK, the patch itself is correct.
>>  =20
>=20
> Yes, looks fine to me as well.
>=20
>> Now, could you please send it again with a proper changelog ?
>>
>> In this changelog, please explain why patch is needed, and
>> keep lines short (< 72 chars), like the one you did in your first ma=
il.
>>
>> I'll then add my Signed-off-by, since I wrote the accelerated part ;=
)
>>
>> Note : I wonder if another patch is needed, in case 8021q module is
>> _not_ loaded. We probably should accept vlan 0 frames in this case ?
>>  =20
>=20
> I agree that this would be best for consistency, but that would mean
> adding more special cases to __netif_receive_skb().

In my understanding, 802.1p is a "subset" of 802.1q, and they share the=
=20
protocol number. We can do a 802.1p module, but in the end it will end
up reusing most of the code in 802.1q.

In any case defining a VLAN 0 ends up usually in problems with which ta=
ble=20
the ARP entries get stored in. This patch solves the problem to whom=20
is not using VLAN 0 explicitly, but if somebody is using VLAN 0 tagging
it will work (whatever "work" means) as before.

Probably a definitive fix would be not to allow the definition of VLAN =
0=20
in 802.1q module and provide some other way to tag priority packets wit=
hout
using a subinterface (maybe in the same module or a new 8021p one). I a=
m=20
having a look at the kernel to see what happens if we load two modules =
for=20
the same protocol.=20

By the way, the changelog I have to write is just the text before the=20
patch?


Pedro
