From: Rick Jones <rick.jones2@hp.com>
Subject: Re: rps testing questions
Date: Tue, 18 Jan 2011 11:10:36 -0800
Message-ID: <4D35E5AC.6000804@hp.com>
References: <AANLkTin1pC=auiFBt83YomdhVgUO8uSdvq=tPaDu0=3U@mail.gmail.com>	<1295269713.3700.5.camel@localhost>  <4D35DAB0.9030201@hp.com> <1295375676.3537.83.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mi wake <wakemi.wake@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:30099 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345Ab1ARTKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 14:10:39 -0500
In-Reply-To: <1295375676.3537.83.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Tue, 2011-01-18 at 10:23 -0800, Rick Jones wrote:
>=20
>>Ben Hutchings wrote:
>>
>>>On Mon, 2011-01-17 at 17:43 +0800, mi wake wrote:
>=20
> [...]
>=20
>>>>I do ab and tbench testing also find there is less tps with enable
>>>>rps.but,there is more cpu using when with enable rps.when with enab=
le
>>>>rps =EF=BC=8Csoftirqs is blanced  on cpus.
>>>>
>>>>is there something wrong with my test=EF=BC=9F
>>>
>>>
>>>In addition to what Eric said, check the interrupt moderation settin=
gs
>>>(ethtool -c/-C options).  One-way latency for a single request/respo=
nse
>>>test will be at least the interrupt moderation value.
>>>
>>>I haven't tested RPS by itself (Solarflare NICs have plenty of hardw=
are
>>>queues) so I don't know whether it can improve latency.  However, RF=
S
>>>certainly does when there are many flows.
>>
>>Is there actually an expectation that either RPS or RFS would improve=
 *latency*?=20
>>  Multiple-stream throughput certainly, but with the additional work =
done to=20
>>spread things around, I wouldn't expect either to improve latency.
>=20
>=20
> Yes, it seems to make a big improvement to latency when many flows ar=
e
> active.=20

OK, you and I were using different definitions.  I was speaking to sing=
le-stream=20
latency, but didn't say it explicitly (I may have subconsciously though=
t it was=20
implicit given the OP used a single instance of netperf :).

happy benchmarking,

rick jones

> Tom told me that one of his benchmarks was 200 * netperf TCP_RR
> in parallel, and I've seen over 40% reduction in latency for that. Th=
at
> said, allocating more RX queues might also help (sfc currently defaul=
ts
> to one per processor package rather than one per processor thread, du=
e
> to concerns about CPU efficiency).
>=20
> Ben.
>=20

