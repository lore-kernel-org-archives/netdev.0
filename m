From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: Fwd: [RFC v3] net: Introduce recvmmsg socket syscall
Date: Tue, 15 Sep 2009 17:52:07 -0300
Message-ID: <20090915205207.GI22743@ghostprotocols.net>
References: <9b2db90b0908060014r6a1763e8t1b3ee9310e012c25@mail.gmail.com> <9b2db90b0908060015v45d31060me94cf436f4a25e42@mail.gmail.com> <20090914230902.GC22743@ghostprotocols.net> <9b2db90b0909150137j16c46340o89b55af62f7b613e@mail.gmail.com> <20090915141110.GG22743@ghostprotocols.net> <9b2db90b0909151120l71498303w26cfd657c9f18092@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, Ziv Ayalon <ziv@final.co.il>
To: Nir Tzachar <nir.tzachar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756797AbZIOUwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 16:52:14 -0400
Content-Disposition: inline
In-Reply-To: <9b2db90b0909151120l71498303w26cfd657c9f18092@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 15, 2009 at 09:20:13PM +0300, Nir Tzachar escreveu:
> >> Setup:
> >> linux 2.6.29.2 with the third version of the patch, running on an
> >> Intel Xeon X3220 2.4GHz quad core, with 4Gbyte of ram, running Ubuntu
> >> 9.04
> >
> > Which NIC? 10 Gbit/s?
> 
> 1G. We do not care as much for throughput as we do about latency...

OK, but anyway the 10 Gbit/s cards I've briefly played with all
exhibited lower latencies than all 1 gbit/s ones, in fact I've heard
about people moving to 10 Gbit/s not for the bw, but for the lower
latencies :-)
 
> 
> >> Results:
> >> On general, the recvmmsg beats the pants off the regular recvmsg by a
> >> whole millisecond (which might not sound much, but is _really_ a lot
> >> for us ;). The exact distribution fluctuates between half a milli and
> >> 2 millis, but the average is 1 milli.
> >
> > Do you have any testcase using publicly available software? Like qpidd,
> > etc? I'll eventually have to do that, for now I'm just using that
> > recvmmsg tool I posted, now with a recvmsg mode, then collecting 'perf
> > record' with and without callgraphs to post here. The client is just
> > pktgen spitting datagrams as if there is no tomorrow :-)
> 
> No. This was on a live, production system.

Wow :-)
> 
> > Showing that we get latency improvements is complementary to what I'm
> > doing, that is for now just showing the performance improvements and
> > showing what gives this improvement (perf counters runs).
> 
> We are more latency oriented, and, naturally, concentrate on this
> aspect of the problem. Producing numbers here is much more easier....
> I can easily come up with a test application which just measures the
> latency of processing packets, by employing a sending loop between two
> hosts.
> 
> > If you could come up with a testcase that you could share with us,
> > perhaps using one of these AMQP implementations, that would be great
> > too.
> 
> Well, in our experience, AMQP and other solutions have latency issues.
> Moreover, the receiving end of our application is a regular multicast
> stream. I will implement the simple latency test I mentioned earlier,
> and post some results soon.

OK.

And here are some callgraphs for a very simple app (attached) that stops
after receiving 1 million datagrams, collected with the perf tools in
the kernel. No packets per sec numbers besides the fact that the
recvmmsg test run collected way less samples (finished quicker).

Client is pktgen sending 100 byte datagrams over a single tg3 1 Gbit/s
NIC, server is running over a bnx2 1 Gbit/s link as well, just a sink:

With recvmmsg, batch of 8 datagrams, no timeout:

http://oops.ghostprotocols.net:81/acme/perf.recvmmsg.step1.cg.data.txt.bz2

And with recvmsg:

http://oops.ghostprotocols.net:81/acme/perf.recvmsg.step1.cg.data.txt.bz2

Notice where we are spending time in the recvmmsg case... :-)

- Arnaldo
