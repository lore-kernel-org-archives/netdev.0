From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Pv-drivers] rps and pvdrivers
Date: Sat, 04 Sep 2010 15:51:51 +0200
Message-ID: <1283608311.3402.30.camel@edumazet-laptop>
References: <AANLkTimrHh1ZasO=GWUOT9YJbu2EqeAx6OkRXPUSSNJ6@mail.gmail.com>
	 <8B1F619C9F5F454E81D90D3C161698D70337A49A5A@EXCH-MBX-3.vmware.com>
	 <AANLkTi=o8GYdLyY8EzfRno39O2kUSh3wSp9raZCUp_Zz@mail.gmail.com>
	 <1283583095.2320.11.camel@edumazet-laptop>
	 <AANLkTimC4z7mCKwyK8=LaacjTtZGEGN_BYsFMydQiwBk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bhavesh Davda <bhavesh@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"therbert@google.com" <therbert@google.com>
To: Chetan Loke <chetanloke@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60076 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051Ab0IDNv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 09:51:57 -0400
Received: by fxm13 with SMTP id 13so1794384fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 06:51:56 -0700 (PDT)
In-Reply-To: <AANLkTimC4z7mCKwyK8=LaacjTtZGEGN_BYsFMydQiwBk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 septembre 2010 =C3=A0 09:38 -0400, Chetan Loke a =C3=A9cri=
t :

> I see. Ok then that's whats happening. I guess I will have to look at
> the napi/ksoftirq/rps block in detail to understand this. But I would
> think that even w/o the rps settings I should still get the same
> numbers as compared to non-rps case, correct?
>=20
> On a VM(virtual machine) using a 1G vNIC I can capture ~250K
> pkts/sec(even higher in some cases). But I can't go beyond 100K
> pkts/sec on a 10G vNIC because ksoftirqd consumes 1-cpu 100% of the
> time. That's why I thought of switching to the 2.6.35 kernel to see i=
f
> I could scale on 10G.
>=20
> It's possible that a VM cannot handle that much load. So I tried
> sending only 10% of line-rate(10G) which is 1G. It still doesn't work=
=2E
> I still can't capture that many pkts.

If packets have same rxhash, (same src IP, dst IP, src port, dst port),
they are directed on a single CPU, and this might explain you cannot
handle the load, RPS or not.

cat /proc/net/softnet_stat

RPS is good to handle multiple flows, because it can distribute load on
several cpus. But with a single flow, I guess it might be not that
useful.



