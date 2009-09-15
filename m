From: Nir Tzachar <nir.tzachar@gmail.com>
Subject: Re: Fwd: [RFC v3] net: Introduce recvmmsg socket syscall
Date: Tue, 15 Sep 2009 21:20:13 +0300
Message-ID: <9b2db90b0909151120l71498303w26cfd657c9f18092@mail.gmail.com>
References: <9b2db90b0908060014r6a1763e8t1b3ee9310e012c25@mail.gmail.com>
	 <9b2db90b0908060015v45d31060me94cf436f4a25e42@mail.gmail.com>
	 <20090914230902.GC22743@ghostprotocols.net>
	 <9b2db90b0909150137j16c46340o89b55af62f7b613e@mail.gmail.com>
	 <20090915141110.GG22743@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, Ziv Ayalon <ziv@final.co.il>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:40937 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbZIOSUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 14:20:11 -0400
Received: by fxm17 with SMTP id 17so1772214fxm.37
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 11:20:14 -0700 (PDT)
In-Reply-To: <20090915141110.GG22743@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Setup:
>> linux 2.6.29.2 with the third version of the patch, running on an
>> Intel Xeon X3220 2.4GHz quad core, with 4Gbyte of ram, running Ubuntu
>> 9.04
>
> Which NIC? 10 Gbit/s?

1G. We do not care as much for throughput as we do about latency...


>> Results:
>> On general, the recvmmsg beats the pants off the regular recvmsg by a
>> whole millisecond (which might not sound much, but is _really_ a lot
>> for us ;). The exact distribution fluctuates between half a milli and
>> 2 millis, but the average is 1 milli.
>
> Do you have any testcase using publicly available software? Like qpidd,
> etc? I'll eventually have to do that, for now I'm just using that
> recvmmsg tool I posted, now with a recvmsg mode, then collecting 'perf
> record' with and without callgraphs to post here. The client is just
> pktgen spitting datagrams as if there is no tomorrow :-)

No. This was on a live, production system.


> Showing that we get latency improvements is complementary to what I'm
> doing, that is for now just showing the performance improvements and
> showing what gives this improvement (perf counters runs).

We are more latency oriented, and, naturally, concentrate on this
aspect of the problem. Producing numbers here is much more easier....
I can easily come up with a test application which just measures the
latency of processing packets, by employing a sending loop between two
hosts.

> If you could come up with a testcase that you could share with us,
> perhaps using one of these AMQP implementations, that would be great
> too.

Well, in our experience, AMQP and other solutions have latency issues.
Moreover, the receiving end of our application is a regular multicast
stream. I will implement the simple latency test I mentioned earlier,
and post some results soon.

Nir.
