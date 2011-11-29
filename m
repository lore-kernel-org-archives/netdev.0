From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 08:02:18 +0100
Message-ID: <1322550138.2970.70.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	 <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43174 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab1K2HCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 02:02:23 -0500
Received: by eaak14 with SMTP id k14so2666698eaa.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 23:02:22 -0800 (PST)
In-Reply-To: <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 05:23 +0100, Dave Taht a =C3=A9crit :
> > In this test 100 netperf TCP_STREAMs were started to saturate the l=
ink.
> > A single instance of a netperf TCP_RR was run with high priority se=
t.
> > Queuing discipline in pfifo_fast, NIC is e1000 with TX ring size se=
t to
> > 1024.  tps for the high priority RR is listed.
> >
> > No BQL, tso on: 3000-3200K bytes in queue: 36 tps
> > BQL, tso on: 156-194K bytes in queue, 535 tps
>=20
> > No BQL, tso off: 453-454K bytes int queue, 234 tps
> > BQL, tso off: 66K bytes in queue, 914 tps
>=20
>=20
> Jeeze. Under what circumstances is tso a win? I've always
> had great trouble with it, as some e1000 cards do it rather badly.
>=20
> I assume these are while running at GigE speeds?
>=20
> What of 100Mbit? 10GigE? (I will duplicate your tests
> at 100Mbit, but as for 10gigE...)
>=20

TSO on means a low priority 65Kbytes packet can be in TX ring right
before the high priority packet. If you cant afford the delay, you lose=
=2E

There is no mystery here.

If you want low latencies :
- TSO must be disabled so that packets are at most one ethernet frame.=20
- You adjust BQL limit to small value
- You even can lower MTU to get even more better latencies.

If you want good throughput from your [10]GigE and low cpu cost, TSO
should be enabled.

If you want to be smart, you could have a dynamic behavior :

Let TSO on as long as no high priority low latency producer is running
(if low latency packets are locally generated)
