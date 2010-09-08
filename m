From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel Panic on OOM with 10 HTB rules
Date: Wed, 08 Sep 2010 19:25:36 +0200
Message-ID: <4C87C710.8080804@gmail.com>
References: <AANLkTinQbuN4Y6yUgHhjhOkLGe3GPk9aN5z1gasvQ-zW@mail.gmail.com>	 <1283949778.2748.5.camel@edumazet-laptop>	 <AANLkTimDW-tuTJagnpkFq3TX4t+c_-9UUyG8z-bwPuJ1@mail.gmail.com> <1283957137.2748.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anand Raj Manickam <anandrm@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46393 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab0IHRZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 13:25:43 -0400
In-Reply-To: <1283957137.2748.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 09/08/2010 04:45 PM:

> Le mercredi 08 septembre 2010 =C3=A0 19:39 +0530, Anand Raj Manickam =
a
> =C3=A9crit :
>>
>> imq0      Link encap:UNSPEC  HWaddr
>> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>>           UP RUNNING NOARP  MTU:16000  Metric:1
>>           RX packets:129112 errors:0 dropped:0 overruns:0 frame:0
>>           TX packets:129114 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 txqueuelen:11000
>>           RX bytes:31060964 (29.6 MiB)  TX bytes:31062207 (29.6 MiB)
>>
> If you cannot switch to 64bit kernel, then you are forced to use lowe=
r
> queue lengths (I see your imq devices use insane 11000 txqueuelen)
>=20
> Each frame use 4K, maybe 16K, it depends on MTU.
>=20
> even if we dont take into account other needs :
> 11000 * 16K =3D 170 Mbytes per imqX
> 1000 * 4K =3D 4Mbytes per ethX
>=20
> 170M * 8 -> memory overflow
>=20

You should consider that htb creates by default one queue per class
with txqueuelen limit each. This should probably explain why your
problems start when you classify to many classes.

Jarek P.
