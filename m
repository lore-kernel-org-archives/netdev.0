From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: Fwd: [RFC v3] net: Introduce recvmmsg socket syscall
Date: Tue, 15 Sep 2009 11:11:10 -0300
Message-ID: <20090915141110.GG22743@ghostprotocols.net>
References: <9b2db90b0908060014r6a1763e8t1b3ee9310e012c25@mail.gmail.com> <9b2db90b0908060015v45d31060me94cf436f4a25e42@mail.gmail.com> <20090914230902.GC22743@ghostprotocols.net> <9b2db90b0909150137j16c46340o89b55af62f7b613e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, Ziv Ayalon <ziv@final.co.il>
To: Nir Tzachar <nir.tzachar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754344AbZIOOLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 10:11:15 -0400
Content-Disposition: inline
In-Reply-To: <9b2db90b0909150137j16c46340o89b55af62f7b613e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 15, 2009 at 11:37:36AM +0300, Nir Tzachar escreveu:
> On Tue, Sep 15, 2009 at 2:09 AM, Arnaldo Carvalho de
> Melo<acme@ghostprotocols.net> wrote:
> > Em Thu, Aug 06, 2009 at 10:15:26AM +0300, Nir Tzachar escreveu:
> >> Hello.
> >>
> >> Is there anything new with this patch? What are the plans for merging
> >> it upstream?
> >
> > I'm doing perf runs using a test app using recvmsg, then with the first
> > patch, that introduces recvmmsg, then with the second, that locks the
> > series of unlocked_recvmmsg calls just once, will try to get this posted
> > here soon.
> >
> > I'd really appreciate if the people interested in this could try it and
> > post numbers too, to get this ball rolling again.
> >
> > As for getting it upstream, well, posting numbers here would definetely
> > help with that :-)
> 
> Ok, here are some crude results:
> 
> Setup:
> linux 2.6.29.2 with the third version of the patch, running on an
> Intel Xeon X3220 2.4GHz quad core, with 4Gbyte of ram, running Ubuntu
> 9.04

Which NIC? 10 Gbit/s?
 
> Application:
> A financial application, subscribing to quotes from a stock exchange.
> Typical traffic is small (around 50-100 bytes) multicast packets in
> large volumes. The application just receives  the quotes and pass them
> along.

Exactly what made me work on this patch :-)
 
> The test:
> Run two version of the application, head to head. one version using
> recvmsg and the other recvmmsg. The data is passed to a third
> application measuring the latency of the data.
> 
> Results:
> On general, the recvmmsg beats the pants off the regular recvmsg by a
> whole millisecond (which might not sound much, but is _really_ a lot
> for us ;). The exact distribution fluctuates between half a milli and
> 2 millis, but the average is 1 milli.

Do you have any testcase using publicly available software? Like qpidd,
etc? I'll eventually have to do that, for now I'm just using that
recvmmsg tool I posted, now with a recvmsg mode, then collecting 'perf
record' with and without callgraphs to post here. The client is just
pktgen spitting datagrams as if there is no tomorrow :-)
 
> Conclusions:
> We would _really_ like to see this patch go upstream. It gives an
> important performance boost in out use cases.

Great! I'll work on the lower layer unlocked_recvmmsg followup patch
addressing the concerns raised when I first posted it and we should see
some more gains.
 
> We are willing to perform more accurate tests if needed, and would
> appreciate the feedback on how to conduct them.

Showing that we get latency improvements is complementary to what I'm
doing, that is for now just showing the performance improvements and
showing what gives this improvement (perf counters runs).

If you could come up with a testcase that you could share with us,
perhaps using one of these AMQP implementations, that would be great
too.
 
> Cheers,
> Nir.

Thanks a lot for sharing your results with us!

- Arnaldo
