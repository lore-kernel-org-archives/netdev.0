From: David Miller <davem@davemloft.net>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 01:48:57 -0700 (PDT)
Message-ID: <20100415.014857.168270765.davem@davemloft.net>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271268242.16881.1719.camel@edumazet-laptop>
	<1271271222.4567.51.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, xiaosuo@gmail.com,
	andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757529Ab0DOIsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:48:54 -0400
In-Reply-To: <1271271222.4567.51.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 14 Apr 2010 14:53:42 -0400

> On Wed, 2010-04-14 at 20:04 +0200, Eric Dumazet wrote:
> 
>> Yes, multiqueue is far better of course, but in case of hardware lacking
>> multiqueue, RPS can help many workloads, where application has _some_
>> work to do, not only counting frames or so...
> 
> Agreed. So to enumerate, the benefits come in if:
> a) you have many processors
> b) you have single-queue nic
> c) at sub-threshold traffic you dont care about a little latency
> d) you have a specific cache hierachy
> e) app is working hard to process incoming messages

A single-queue NIC is actually not a requirement, RPS helps also in
cases where you have 'N' application threads and N is less than the
number of CPUs your multi-queue NIC is distributing traffic to.

Moving the bulk of the input packet processing to the cpus where
the applications actually sit had a non-trivial benefit.  RFS takes
this aspect to yet another level.

> I think the main challenge for my pedantic mind is missing details. Is
> there a paper on rps? Example for #d above, the commit log mentions that
> rps benefits if you have certain types of "cache hierachy". Probably
> some arch with large shared L2/3 (maybe inclusive) cache will benefit.
> example: it does well on Nehalem and probably opterons as long (as you
> dont start stacking these things on some interconnect like QPI or HT).
> But what happens when you have FSB sharing across cores (still a very
> common setup)? etc etc

I think for the case where application locality is important,
RPS/RFS can help regardless of cache details.
