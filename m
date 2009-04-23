From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 22:19:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>
References: <20090423082052.GA4243@ff.dom.local> <1240495002.6554.155.camel@blade.ines.ro>
 <20090423181936.GA2756@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Radu Rendec <radu.rendec@ines.ro>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:50348 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbZDWUTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 16:19:51 -0400
In-Reply-To: <20090423181936.GA2756@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Apr 2009, Jarek Poplawski wrote:

> On Thu, Apr 23, 2009 at 04:56:42PM +0300, Radu Rendec wrote:
>> On Thu, 2009-04-23 at 08:20 +0000, Jarek Poplawski wrote:
>>
>> I am aware of the thread and even tried out the author's patch (despite
>> the fact that David Miller suggested it was not sane). Under heavy
>> (simulated) traffic nothing was changed: only one ksoftirqd using 100%
>> CPU, one CPU in 100%, others idle. This only confirms what I've already
>> been told: htb is single threaded by design.

Its more general that just HTB.  We have general Qdisc serialization 
point in net/sched/sch_generic.c by the qdisc_lock(q).


>> It also proves that most of the packet processing work is actually in 
>> htb.

I'm not sure that statement is true.
Can you run Oprofile on the system?  That will tell us exactly where time 
is spend...


> ...
> I thought about using some trick with virtual devs instead, but maybe
> I'm totally wrong.

I like the idea with virtual devices, as each virtual device could be 
bound to a hardware tx-queue.

Then you just have to construct your HTB trees on each virtual 
device, and assign customers accordingly.

I just realized, you don't use a multi-queue capably NIC right?
Then it would be difficult to use the hardware tx-queue idea.
Have you though of using several physical NICs?

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
