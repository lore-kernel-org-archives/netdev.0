From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 09:58:46 -0400
Message-ID: <1271426326.4606.83.camel@bigi>
References: <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi> <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <o2v412e6f7f1004152302j1aca5edam9d53d01781ddbe9d@mail.gmail.com>
	 <20100416071522.GY18855@one.firstfloor.org> <1271424455.4606.39.camel@bigi>
	 <20100416133707.GZ18855@one.firstfloor.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:31501 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932207Ab0DPN6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 09:58:48 -0400
Received: by qw-out-2122.google.com with SMTP id 8so832763qwh.37
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 06:58:47 -0700 (PDT)
In-Reply-To: <20100416133707.GZ18855@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-16 at 15:37 +0200, Andi Kleen wrote:
> On Fri, Apr 16, 2010 at 09:27:35AM -0400, jamal wrote:

> > So you are saying that the old implementation of IPI (likely what i
> > tried pre-napi and as recent as 2-3 years ago) was bad because of a
> > single lock?
> 
> Yes.

> The old implementation of smp_call_function. Also in the really old
> days there was no smp_call_function_single() so you tended to broadcast.
> 
> Jens did a lot of work on this for his block device work IPI implementation.

Nice - thanks for that info! So not only has h/ware improved, but
implementation as well..

> > On IPIs:
> > Is anyone familiar with what is going on with Nehalem? Why is it this
> > good? I expect things will get a lot nastier with other hardware like
> > xeon based or even Nehalem with rps going across QPI.
> 
> Nehalem is just fast. I don't know why it's fast in your specific
> case. It might be simply because it has lots of bandwidth everywhere.
> Atomic operations are also faster than on previous Intel CPUs.

Well, the cache architecture is nicer. The on-die MC is nice. No more
shared MC hub/FSB. The 3 MC channels are nice. Intel finally beating
AMD ;-> someone did a measurement of the memory timings (L1, L2, L3, MM
and the results were impressive; i have the numbers somewhere).

> 
> > Here's why i think IPIs are bad, please correct me if i am wrong:
> > - they are synchronous. i.e an IPI issuer has to wait for an ACK (which
> > is in the form of an IPI).
> 
> In the hardware there's no ack, but in the Linux implementation there
> is usually (because need to know when to free the stack state used
> to pass information)
>
> However there's also now support for queued IPI
> with a special API (I believe Tom is using that)
> 

Which is the non-queued-IPI call?

> > - data cache has to be synced to main memory
> > - the instruction pipeline is flushed
> 
> At least on Nehalem data transfer can be often through the cache.

I thought you have to go all the way to MM in case of IPIs.

> IPIs involve APIC accesses which are not very fast (so overall
> it's far more than a pipeline worth of work), but it's still
> not a incredible expensive operation.
> 
> There's also X2APIC now which should be slightly faster, but it's 
> likely not in your Nehalem (this is only in the highend Xeon versions)
> 

Ok, true - forgot about the APIC as well...

> > Do you know any specs i could read up which will tell me a little more?
> 
> If you're just interested in IPI and cache line transfer performance it's
> probably best to just measure it.

There are tools like benchit which would give me L1,2,3,MM measurements;
for IPI the ping + rps test i did maybe sufficient.

> Some general information is always in the Intel optimization guide.

Thanks Andi!

cheers,
jamal

