From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 14:24:05 +0000
Message-ID: <1322576645.7454.48.camel@deadeye>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	 <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	 <1322550138.2970.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>, Tom Herbert <therbert@google.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55508 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755233Ab1K2OYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 09:24:17 -0500
In-Reply-To: <1322550138.2970.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-29 at 08:02 +0100, Eric Dumazet wrote:
> Le mardi 29 novembre 2011 =C3=A0 05:23 +0100, Dave Taht a =C3=A9crit =
:
> > > In this test 100 netperf TCP_STREAMs were started to saturate the=
 link.
> > > A single instance of a netperf TCP_RR was run with high priority =
set.
> > > Queuing discipline in pfifo_fast, NIC is e1000 with TX ring size =
set to
> > > 1024.  tps for the high priority RR is listed.
> > >
> > > No BQL, tso on: 3000-3200K bytes in queue: 36 tps
> > > BQL, tso on: 156-194K bytes in queue, 535 tps
> >=20
> > > No BQL, tso off: 453-454K bytes int queue, 234 tps
> > > BQL, tso off: 66K bytes in queue, 914 tps
> >=20
> >=20
> > Jeeze. Under what circumstances is tso a win? I've always
> > had great trouble with it, as some e1000 cards do it rather badly.
> >=20
> > I assume these are while running at GigE speeds?
> >=20
> > What of 100Mbit? 10GigE? (I will duplicate your tests
> > at 100Mbit, but as for 10gigE...)
> >=20
>=20
> TSO on means a low priority 65Kbytes packet can be in TX ring right
> before the high priority packet. If you cant afford the delay, you lo=
se.
>=20
> There is no mystery here.
>=20
> If you want low latencies :
> - TSO must be disabled so that packets are at most one ethernet frame=
=2E=20
[...]

Not if you separate hardware queues by priority (and your high priority
packets are non-TCP or PuSHed).

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
