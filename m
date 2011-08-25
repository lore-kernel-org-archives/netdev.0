From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 12:02:42 +0200
Message-ID: <1314266562.2387.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314226834.6797.5.camel@edumazet-laptop>
	 <1314229310-8074-1-git-send-email-hagen@jauu.net>
	 <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>
	 <1314250134.6797.24.camel@edumazet-laptop>
	 <4033BFEE-C432-4D94-8372-BA166AF2AA26@comsys.rwth-aachen.de>
	 <1314260805.2387.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E560BFD.5020301@arndnet.de>
	 <1314263389.2387.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E5619DA.6070902@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>,
	Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>
To: Arnd Hannemann <arnd@arndnet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52362 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab1HYKCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 06:02:41 -0400
Received: by wwf5 with SMTP id 5so2188170wwf.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 03:02:40 -0700 (PDT)
In-Reply-To: <4E5619DA.6070902@arndnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 ao=C3=BBt 2011 =C3=A0 11:46 +0200, Arnd Hannemann a =C3=A9c=
rit :
> Hi Eric,
>=20
> Am 25.08.2011 11:09, schrieb Eric Dumazet:

> > Maybe we should refine the thing a bit, to not reverse backoff unle=
ss
> > rto is > some_threshold.
> >=20
> > Say 10s being the value, that would give at most 92 tries.
>=20
> I personally think that 10s would be too large and eliminate the bene=
fit of the
> algorithm, so I would prefer a different solution.
>=20
> In case of one bulk data TCP session, which was transmitting hundreds=
 of packets/s
> before the connectivity disruption those worst case rate of 5 packet/=
s really
> seems conservative enough.
>=20
> However in case of a lot of idle connections, which were transmitting=
 only
> a number of packets per minute. We might increase the rate drasticall=
y for
> a certain period until it throttles down. You say that we have a prob=
lem here
> correct?
>=20
> Do you think it would be possible without much hassle to use a kind o=
f "global"
> rate limiting only for these probe packets of a TCP connection?
>=20
> > I mean, what is the gain to be able to restart a frozen TCP session=
 with
> > a 1sec latency instead of 10s if it was blocked more than 60 second=
s ?
>=20
> I'm afraid it does a lot, especially in highly dynamic environments. =
You
> don't have just the additional latency, you may actually miss the ful=
l
> period where connectivity was there, and then just retransmit into th=
e next
> connectivity disrupted period.

Problem with this is that with short and synchronized timers, all
sessions will flood at the same time and you'll get congestion this
time.

The reason for exponential backoff is also to smooth the restarts of
sessions, because timers are randomized.
