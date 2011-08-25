From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 12:15:26 +0200
Message-ID: <4E5620BE.3050102@arndnet.de>
References: <1314226834.6797.5.camel@edumazet-laptop>  <1314229310-8074-1-git-send-email-hagen@jauu.net>  <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>  <1314250134.6797.24.camel@edumazet-laptop>  <4033BFEE-C432-4D94-8372-BA166AF2AA26@comsys.rwth-aachen.de>  <1314260805.2387.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E560BFD.5020301@arndnet.de>  <1314263389.2387.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E5619DA.6070902@arndnet.de> <1314266562.2387.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>,
	Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.unitix.de ([176.9.2.175]:56279 "EHLO mail2.unitix.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120Ab1HYKP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 06:15:29 -0400
In-Reply-To: <1314266562.2387.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Am 25.08.2011 12:02, schrieb Eric Dumazet:
> Le jeudi 25 ao=FBt 2011 =E0 11:46 +0200, Arnd Hannemann a =E9crit :
>> Hi Eric,
>>
>> Am 25.08.2011 11:09, schrieb Eric Dumazet:
>=20
>>> Maybe we should refine the thing a bit, to not reverse backoff unle=
ss
>>> rto is > some_threshold.
>>>
>>> Say 10s being the value, that would give at most 92 tries.
>>
>> I personally think that 10s would be too large and eliminate the ben=
efit of the
>> algorithm, so I would prefer a different solution.
>>
>> In case of one bulk data TCP session, which was transmitting hundred=
s of packets/s
>> before the connectivity disruption those worst case rate of 5 packet=
/s really
>> seems conservative enough.
>>
>> However in case of a lot of idle connections, which were transmittin=
g only
>> a number of packets per minute. We might increase the rate drastical=
ly for
>> a certain period until it throttles down. You say that we have a pro=
blem here
>> correct?
>>
>> Do you think it would be possible without much hassle to use a kind =
of "global"
>> rate limiting only for these probe packets of a TCP connection?
>>
>>> I mean, what is the gain to be able to restart a frozen TCP session=
 with
>>> a 1sec latency instead of 10s if it was blocked more than 60 second=
s ?
>>
>> I'm afraid it does a lot, especially in highly dynamic environments.=
 You
>> don't have just the additional latency, you may actually miss the fu=
ll
>> period where connectivity was there, and then just retransmit into t=
he next
>> connectivity disrupted period.
>=20
> Problem with this is that with short and synchronized timers, all
> sessions will flood at the same time and you'll get congestion this
> time.

Why do you think the timers are "syncronized"? If you have congestion
then you will do exponential backoff.

> The reason for exponential backoff is also to smooth the restarts of
> sessions, because timers are randomized.

If the RTO of these sessions were "randomized" they keep this randomiza=
tion,
even if backoffs are reverted, at least they should.

Best regards
Arnd
