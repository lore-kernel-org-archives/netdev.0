From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE
Date: Wed, 1 Oct 2014 22:18:05 -0700
Message-ID: <CAA93jw5orK2FeD20zcFpXGkqGa=kF8E-vGtkdUs7vr54R5AE6g@mail.gmail.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<542A8EF9.10403@mojatatu.com>
	<20140930.142038.235338672810639160.davem@davemloft.net>
	<542BFEF3.7020302@mojatatu.com>
	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>
	<542C1F1F.90404@mojatatu.com>
	<20141001192840.5679a671@redhat.com>
	<542C4E0D.4050404@mojatatu.com>
	<20141001214700.18b16387@redhat.com>
	<542C5E8B.7070204@mojatatu.com>
	<20141001223229.6cbaac07@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:50918 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaJBFSG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 01:18:06 -0400
Received: by mail-oi0-f54.google.com with SMTP id v63so1366247oia.41
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 22:18:05 -0700 (PDT)
In-Reply-To: <20141001223229.6cbaac07@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > I'm monitoring backlog of qdiscs, and I always see >1 backlog, I n=
ever
>> > saw a standing queue of 1 packet in my testing.  Either the backlo=
g
>> > area is high 100-200 packets, or 0 backlog.  (With fake pktgen/tra=
fgen
>> > style tests, it's possible to cause 1000 backlog).
>>
>> It would be nice to actually collect such stats. Monitoring the back=
log
>> via dumping qdisc stats is a good start - but actually keeping trace=
s
>> of average bulk size is more useful.

I am not huge on averages. Network theorists tend to think about things=
 in
terms of fluid models. Van Jacobson's analogy of a water fountain's
operation is very profound...

While it is nearly impossible for a conventional Van Neuman time sliced
CPU + network to actually act that way, things like BQL and dedicated
pipelining systems like those in DPDK are getting closer to that ideal.

An example of where averages let you down is on the classic 5 minute
data reduction things like mrtg do, where you might see `60% of the
bandwidth (capacity/5 minutes) in use, yet still see drops because
over shorter intervals (capacity/10ms) you have bursts arriving.

=46ar better to sample queue occupancy at the highest rate you can
manage without heisenbugging the results and look at the detailed
curves.

> I usually also monitors the BQL limits during these tests.
>
>  grep -H . /sys/class/net/eth4/queues/tx-*/byte_queue_limits/{infligh=
t,limit}
>
> To Toke:
>  Perhaps we could convince Toke, to add a netperf-wrapper recorder fo=
r
> the BQL inflight and limit?  (It would be really cool to plot togethe=
r)

I just added a command line mode and support for timestamped limit and
inflight output to bqlmon

Get it here:

https://github.com/dtaht/bqlmon

That should be sufficient for netperf-wrapper to poll it efficiently.
As to how to graph it,
I suppose finding the max(limit) across the entire sample set and
scaling inflight appropriately would be good.

What test(s) would be best to combine it with? rrul? tcp_square_wave?

--=20
Dave T=C3=A4ht

https://www.bufferbloat.net/projects/make-wifi-fast
