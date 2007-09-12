From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Wed, 12 Sep 2007 14:50:01 +0100
Message-ID: <46E7EE89.9060006@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>	 <1189120020.4259.68.camel@localhost> <46E11A61.9030409@katalix.com>	 <1189171370.4234.38.camel@localhost>	 <20070912030428.16059af6.billfink@mindspring.com> <1189599142.4326.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com,
	Stephen Hemminger <shemminger@osdl.org>
To: hadi@cyberus.ca, Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:58757 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968206AbXILNuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 09:50:06 -0400
In-Reply-To: <1189599142.4326.38.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-12-09 at 03:04 -0400, Bill Fink wrote:
>> On Fri, 07 Sep 2007, jamal wrote:
> 
>>> I am going to be the devil's advocate[1]:
>> So let me be the angel's advocate.  :-)
> 
> I think this would make you God's advocate ;->
> (http://en.wikipedia.org/wiki/God%27s_advocate)
> 
>> I view his results much more favorably.  
> 
> The challenge is, under _low traffic_: bad bad CPU use.
> Thats what is at stake, correct?

By low traffic, I assume you mean a rate at which the NAPI driver 
doesn't stay in polled mode. The problem is that that rate is getting 
higher all the time, as interface and CPU speeds increase. This results 
in too many interrupts and NAPI thrashing in/out of polled mode very 
quickly.

> Lets bury the stats for a sec ...

Yes please. We need an analysis of what happens to cpu usage, latency, 
pps etc when various factors are changed, e.g. input pps, NAPI busy-idle 
delay etc. The main purpose of my RFC wasn't to push a patch into the 
kernel right now, it was to highlight the issue and to find out if 
others were already working on it. The feedback has been good so far. I 
just need to find some time to do some testing. :)

> People are bitching about NAPI abusing CPU, is the 
> answer to abuse more CPU than NAPI?;->

Jamal, do you have more details? Are people saying NAPI gets too much of 
the CPU pie because they profiled it? Are they complaining that system 
behavior degrades too much under certain network traffic conditions? 
Mouse cursor movement jittery? Real-time apps such as music/video 
players starved of CPU? Is it possible they blame NAPI because they see 
tangible effects on their system, not because measured CPU usage is 
high? I say this because my music/video player and mouse cursor behave 
_much_ better with my NAPI changes during general use, despite the 
increase in measured cpu load. Even ftp can make my system's mouse 
cursor jitter...

> The answer could be "I am not solving that problem anymore" - at least
> thats what James is saying;->

I'm investigating whether the symptoms I describe above can be reduced 
or eliminated without resorting to hardware interrupt mitigation. 
Specifically, I want to do more testing on the idle polling scheme which 
seems to improve system behavior in my tests. This will involve more 
than doing a flood ping or two. :)

>> Sometimes there
>> are tradeoffs to be made to be decided by the user based on what's most
>> important to that user and his specific workload.  And the suggested
>> ethtool option (defaulting to current behavior) would enable the user
>> to make that decision.
> 
> And the challenge is:
> What workload is willing to invest that much cpu for low traffic?
> Can you name one? One that may come close is database benchmarks for
> latency - but those folks wouldnt touch this with a mile-long pole if
> you told them their cpu use is going to get worse than what NAPI (that
> big bad CPU hog under low traffic) is giving them.

I agree with both of you. But we need more test results first to know 
whether it will be useful to offer NAPI idle polling as an _option_.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

