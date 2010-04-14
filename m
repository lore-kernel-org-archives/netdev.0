From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 14:53:42 -0400
Message-ID: <1271271222.4567.51.camel@bigi>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f227.google.com ([209.85.217.227]:61464 "EHLO
	mail-gx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756176Ab0DNSxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 14:53:45 -0400
Received: by gxk27 with SMTP id 27so299180gxk.1
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 11:53:44 -0700 (PDT)
In-Reply-To: <1271268242.16881.1719.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-14 at 20:04 +0200, Eric Dumazet wrote:

> Yes, multiqueue is far better of course, but in case of hardware lacking
> multiqueue, RPS can help many workloads, where application has _some_
> work to do, not only counting frames or so...

Agreed. So to enumerate, the benefits come in if:
a) you have many processors
b) you have single-queue nic
c) at sub-threshold traffic you dont care about a little latency
d) you have a specific cache hierachy
e) app is working hard to process incoming messages

> RPS overhead (IPI, cache misses, ...) must be amortized by
> parallelization or we lose.

Indeed. 
How well they can be amortized seems very cpu or board specific.

I think the main challenge for my pedantic mind is missing details. Is
there a paper on rps? Example for #d above, the commit log mentions that
rps benefits if you have certain types of "cache hierachy". Probably
some arch with large shared L2/3 (maybe inclusive) cache will benefit.
example: it does well on Nehalem and probably opterons as long (as you
dont start stacking these things on some interconnect like QPI or HT).
But what happens when you have FSB sharing across cores (still a very
common setup)? etc etc

Can I ask what hardware you run this on?

> A ping test is not an ideal candidate for RPS, since everything is done
> at softirq level, and should be faster without RPS...

ping wont do justice to the possible potential of rps mostly because it
generates very little traffic i.e the part #c above. But it helps me at
least boot a machine with proper setup - but it is not totally useless
because i think the cost of IPI can be deduced from the results.
I am going to put together some udp app with variable think-time to see
what happens. Would that be a reasonable thing to test on?

It would be valuable to have something like Documentation/networking/rps
to detail things a little more. 

cheers,
jamal

