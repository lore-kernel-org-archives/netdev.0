From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
	low traffic rates
Date: Fri, 14 Sep 2007 09:14:30 -0400
Message-ID: <1189775670.4266.50.camel@localhost>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
	 <1189120020.4259.68.camel@localhost> <46E11A61.9030409@katalix.com>
	 <1189171370.4234.38.camel@localhost>
	 <20070912030428.16059af6.billfink@mindspring.com>
	 <1189599142.4326.38.camel@localhost>  <46E7EE89.9060006@katalix.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jeff@garzik.org, mandeep.baines@gmail.com,
	ossthema@de.ibm.com, Stephen Hemminger <shemminger@osdl.org>,
	Rick Jones <rick.jones2@hp.com>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:11171 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756768AbXINNOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 09:14:36 -0400
Received: by nz-out-0506.google.com with SMTP id s18so656293nze
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 06:14:35 -0700 (PDT)
In-Reply-To: <46E7EE89.9060006@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-12-09 at 14:50 +0100, James Chapman wrote:

> By low traffic, I assume you mean a rate at which the NAPI driver 
> doesn't stay in polled mode. 

i.e:
"one interupt per packet per napi poll" which cause about 1-2 more IOs
in comparison to the case where you didnt do NAPI.

> The problem is that that rate is getting 
> higher all the time, as interface and CPU speeds increase. 

indeed;
While i dont want to throw more work at you, with some of the things
that improve the IO cost like PCI express, MSI, and some of the
intelligent things the tg3 does, is this problem still rampant etc? I
think if you can find (seems you have) one "modern" machine (with MSI
and a tg3 etc) that has this problem circa 2007 that will be a good
start.

> This results 
> in too many interrupts and NAPI thrashing in/out of polled mode very 
> quickly.

indeed.

> Yes please. We need an analysis of what happens to cpu usage, latency, 
> pps etc when various factors are changed, e.g. input pps, NAPI busy-idle 
> delay etc. The main purpose of my RFC wasn't to push a patch into the 
> kernel right now, it was to highlight the issue and to find out if 
> others were already working on it. The feedback has been good so far. I 
> just need to find some time to do some testing. :)

I love your message. From a blackbox perspective, yes we have some
challenges for NAPI below certain thresholds of traffic. 
My claim (in the paper) was the discrepancy between the cost of IO
access vs cost of RAM vs cost of caches vs CPU speeds has gotten too
high.
CPU Vendors have been paying close attention to most but IO. So avoiding
IO when you can is a good thing.

> Jamal, do you have more details? Are people saying NAPI gets too much of 
> the CPU pie because they profiled it?

In the old days Manfred Spraul actually did profile.
Most of the other folks were running benchmarks which account for cpu
use in addition to resources like bandwidth and latency. And so while
bandwidth and latency didnt affect them that much, they observed their
benchmarks didnt look good at low rates (even when they looked excellent
at high rates) because of CPU.

>  Are they complaining that system 
> behavior degrades too much under certain network traffic conditions?

yes - Under low traffic, high speed cpu youd notice a slightly higher
cpu use.

>  
> Mouse cursor movement jittery? Real-time apps such as music/video 
> players starved of CPU? Is it possible they blame NAPI because they see 
> tangible effects on their system, not because measured CPU usage is 
> high? 

If i recall correctly transactional type benchmarks is where this was
observed. Some IBM and Intel people bring it up every few months and
maybe Rick Jones once in a while.
Rick, care to comment on the benchmarks?

> I say this because my music/video player and mouse cursor behave 
> _much_ better with my NAPI changes during general use, despite the 
> increase in measured cpu load. Even ftp can make my system's mouse 
> cursor jitter...

Like i told you in my other email - i did notice something similar, i
just couldnt put my finger to it and at some points thought i was
imagining it.

cheers,
jamal

