From: Patrick McHardy <kaber@trash.net>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface
Date: Thu, 15 May 2008 20:14:39 +0200
Message-ID: <482C7D8F.3040401@trash.net>
References: <20080515091216.GA6550@ff.dom.local> <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk> <482C6040.9030808@trash.net> <20080515180914.GA2936@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kingsley Foreman <kingsley@internode.com.au>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49509 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbYEOSOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 14:14:42 -0400
In-Reply-To: <20080515180914.GA2936@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, May 15, 2008 at 06:09:36PM +0200, Patrick McHardy wrote:
>> Kingsley Foreman wrote:
>>> i just rolled back the kernel to 2.6.24 and im seeing the same thing,
>>>
>>> I was using 2.6.22 before and didn't see the problem, txqueuelen on the 
>>> bond0 interface is 0 (the default)
>> That might explain things, although it shouldn't have worked before
>> either.
>>
>> CBQ creates default pfifo qdiscs for its leaves, these use a limit
>> of txqueuelen or 1 if it is zero. So even small bursts will cause
>> drops. Do things improve if you set txqueuelen to a larger value
>> *before* configuring the qdiscs?
> 
> Kingsley wrote to me that even after changing txqueuelen to 1000 the
> "dropped" number didn't change much. A debugging patch with printks
> around all "sch->qstats.dropps++" showed only the end of cbq_enqueue().


Thats where packets dropped by default pfifo would be accounted.
Did you change txqueuelen before or after setting up the qdiscs?

> I've asked to check tomorrow "pfifo limit 1000" for these drops too.

That will clear it up.

>> Another thing is that CBQ on bond will probably not work properly
>> at all, it needs a real device since it measures the timing between
>> dequeue events for idle time estimation. On software devices this
>> doesn't work.
> 
> Right, but these drops without any sign of overactions or overlimits
> seem to show it's not about shaping (or it's not counted/documented
> enough).

Yes, these drops are probably unrelated, just thought I mention it.
