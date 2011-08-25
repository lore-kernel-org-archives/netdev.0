From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 10:26:45 +0200
Message-ID: <1314260805.2387.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314226834.6797.5.camel@edumazet-laptop>
	 <1314229310-8074-1-git-send-email-hagen@jauu.net>
	 <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>
	 <1314250134.6797.24.camel@edumazet-laptop>
	 <4033BFEE-C432-4D94-8372-BA166AF2AA26@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>,
	Hannemann Arnd <arnd@arndnet.de>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47237 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab1HYI0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:26:45 -0400
Received: by wwf5 with SMTP id 5so2102477wwf.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 01:26:43 -0700 (PDT)
In-Reply-To: <4033BFEE-C432-4D94-8372-BA166AF2AA26@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 ao=C3=BBt 2011 =C3=A0 09:28 +0200, Alexander Zimmermann a =C3=
=A9crit :
> Hi Eric,
>=20
> Am 25.08.2011 um 07:28 schrieb Eric Dumazet:

> > Real question is : do we really want to process ~1000 timer interru=
pts
> > per tcp session, ~2000 skb alloc/free/build/handling, possibly ~100=
0 ARP
> > requests, only to make tcp revover in ~1sec when connectivity retur=
ns
> > back. This just doesnt scale.
>=20
> maybe a stupid question, but 1000?. With an minRTO of 200ms and a max=
imum
> probing time of 120s, we 600 retransmits in a worst-case-senario
> (assumed that we get for every rot retransmission an icmp). No?

Where is asserted the "max probing time of 120s" ?=20

It is not the case on my machine :
I have way more retransmits than that, even if spaced by 1600 ms

07:16:13.389331 write(3, "\350F\235JC\357\376\363&\3\374\270R\21L\26\32=
4{\37p\342\244i\304\356\241I:\301\332\222\26"..., 48) =3D 48
07:16:13.389417 select(7, [3 4], [], NULL, NULL) =3D 1 (in [3])
07:31:39.901311 read(3, 0xff8c4c90, 8192) =3D -1 EHOSTUNREACH (No route=
 to host)

Old kernels where performing up to 15 retries, doing exponential backof=
f.

Now its kind of unlimited, according to experimental results.
