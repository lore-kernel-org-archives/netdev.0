From: Nir Tzachar <nir.tzachar@gmail.com>
Subject: Re: Fwd: [RFC v3] net: Introduce recvmmsg socket syscall
Date: Tue, 15 Sep 2009 11:37:36 +0300
Message-ID: <9b2db90b0909150137j16c46340o89b55af62f7b613e@mail.gmail.com>
References: <9b2db90b0908060014r6a1763e8t1b3ee9310e012c25@mail.gmail.com>
	 <9b2db90b0908060015v45d31060me94cf436f4a25e42@mail.gmail.com>
	 <20090914230902.GC22743@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, Ziv Ayalon <ziv@final.co.il>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:44913 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbZIOIhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 04:37:34 -0400
Received: by fxm17 with SMTP id 17so1385771fxm.37
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 01:37:36 -0700 (PDT)
In-Reply-To: <20090914230902.GC22743@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2009 at 2:09 AM, Arnaldo Carvalho de
Melo<acme@ghostprotocols.net> wrote:
> Em Thu, Aug 06, 2009 at 10:15:26AM +0300, Nir Tzachar escreveu:
>> Hello.
>>
>> Is there anything new with this patch? What are the plans for merging
>> it upstream?
>
> I'm doing perf runs using a test app using recvmsg, then with the first
> patch, that introduces recvmmsg, then with the second, that locks the
> series of unlocked_recvmmsg calls just once, will try to get this posted
> here soon.
>
> I'd really appreciate if the people interested in this could try it and
> post numbers too, to get this ball rolling again.
>
> As for getting it upstream, well, posting numbers here would definetely
> help with that :-)

Ok, here are some crude results:

Setup:
linux 2.6.29.2 with the third version of the patch, running on an
Intel Xeon X3220 2.4GHz quad core, with 4Gbyte of ram, running Ubuntu
9.04

Application:
A financial application, subscribing to quotes from a stock exchange.
Typical traffic is small (around 50-100 bytes) multicast packets in
large volumes. The application just receives  the quotes and pass them
along.

The test:
Run two version of the application, head to head. one version using
recvmsg and the other recvmmsg. The data is passed to a third
application measuring the latency of the data.

Results:
On general, the recvmmsg beats the pants off the regular recvmsg by a
whole millisecond (which might not sound much, but is _really_ a lot
for us ;). The exact distribution fluctuates between half a milli and
2 millis, but the average is 1 milli.

Conclusions:
We would _really_ like to see this patch go upstream. It gives an
important performance boost in out use cases.

We are willing to perform more accurate tests if needed, and would
appreciate the feedback on how to conduct them.

Cheers,
Nir.
