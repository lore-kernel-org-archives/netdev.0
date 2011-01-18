From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: rps testing questions
Date: Tue, 18 Jan 2011 18:34:36 +0000
Message-ID: <1295375676.3537.83.camel@bwh-desktop>
References: <AANLkTin1pC=auiFBt83YomdhVgUO8uSdvq=tPaDu0=3U@mail.gmail.com>
	 <1295269713.3700.5.camel@localhost>  <4D35DAB0.9030201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mi wake <wakemi.wake@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18396 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457Ab1ARSej convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 13:34:39 -0500
In-Reply-To: <4D35DAB0.9030201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-18 at 10:23 -0800, Rick Jones wrote:
> Ben Hutchings wrote:
> > On Mon, 2011-01-17 at 17:43 +0800, mi wake wrote:
[...]
> >>I do ab and tbench testing also find there is less tps with enable
> >>rps.but,there is more cpu using when with enable rps.when with enab=
le
> >>rps =EF=BC=8Csoftirqs is blanced  on cpus.
> >>
> >>is there something wrong with my test=EF=BC=9F
> >=20
> >=20
> > In addition to what Eric said, check the interrupt moderation setti=
ngs
> > (ethtool -c/-C options).  One-way latency for a single request/resp=
onse
> > test will be at least the interrupt moderation value.
> >=20
> > I haven't tested RPS by itself (Solarflare NICs have plenty of hard=
ware
> > queues) so I don't know whether it can improve latency.  However, R=
=46S
> > certainly does when there are many flows.
>=20
> Is there actually an expectation that either RPS or RFS would improve=
 *latency*?=20
>   Multiple-stream throughput certainly, but with the additional work =
done to=20
> spread things around, I wouldn't expect either to improve latency.

Yes, it seems to make a big improvement to latency when many flows are
active.  Tom told me that one of his benchmarks was 200 * netperf TCP_R=
R
in parallel, and I've seen over 40% reduction in latency for that.  Tha=
t
said, allocating more RX queues might also help (sfc currently defaults
to one per processor package rather than one per processor thread, due
to concerns about CPU efficiency).

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

