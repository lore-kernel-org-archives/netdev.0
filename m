From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: RE: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 02:31:25 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
 <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
 <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>
 <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:58882 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbYAaIbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 03:31:39 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

>> It's good to be talking directly to one of the e1000 developers and
>> maintainers.  Although at this point I am starting to think that the
>> issue may be TCP stack related and nothing to do with the NIC.  Am I
>> correct that these are quite distinct parts of the kernel?
>
> Yes, quite.

OK.  I hope that there is also someone knowledgable about the TCP stack 
who is following this thread. (Perhaps you also know this part of the 
kernel, but I am assuming that your expertise is on the e1000/NIC bits.)

>> Important note: we ARE able to get full duplex wire speed (over 900
>> Mb/s simulaneously in both directions) using UDP.  The problems occur
>> only with TCP connections.
>
> That eliminates bus bandwidth issues, probably, but small packets take
> up a lot of extra descriptors, bus bandwidth, CPU, and cache resources.

I see.  Your concern is the extra ACK packets associated with TCP.  Even 
those these represent a small volume of data (around 5% with MTU=1500, and 
less at larger MTU) they double the number of packets that must be handled 
by the system compared to UDP transmission at the same data rate. Is that 
correct?

>> I have to wait until Carsten or Henning wake up tomorrow (now 23:38 in
>> Germany).  So we'll provide this info in ~10 hours.
>
> I would suggest you try TCP_RR with a command line something like this:
> netperf -t TCP_RR -H <hostname> -C -c -- -b 4 -r 64K
>
> I think you'll have to compile netperf with burst mode support enabled.

I just saw Carsten a few minutes ago.  He has to take part in a 
'Baubesprechung' meeting this morning, after which he will start answering 
the technical questions and doing additional testing as suggested by you 
and others.  If you are on the US west coast, he should have some answers 
and results posted by Thursday morning Pacific time.

>> I assume that the interrupt load is distributed among all four cores
>> -- the default affinity is 0xff, and I also assume that there is some
>> type of interrupt aggregation taking place in the driver.  If the
>> CPUs were not able to service the interrupts fast enough, I assume
>> that we would also see loss of performance with UDP testing.
>>
>>> One other thing you can try with e1000 is disabling the dynamic
>>> interrupt moderation by loading the driver with
>>> InterruptThrottleRate=8000,8000,... (the number of commas depends on
>>> your number of ports) which might help in your particular benchmark.
>>
>> OK.  Is 'dynamic interrupt moderation' another name for 'interrupt
>> aggregation'?  Meaning that if more than one interrupt is generated
>> in a given time interval, then they are replaced by a single
>> interrupt?
>
> Yes, InterruptThrottleRate=8000 means there will be no more than 8000
> ints/second from that adapter, and if interrupts are generated faster
> than that they are "aggregated."
>
> Interestingly since you are interested in ultra low latency, and may be
> willing to give up some cpu for it during bulk transfers you should try
> InterruptThrottleRate=1 (can generate up to 70000 ints/s)

I'm not sure it's quite right to say that we are interested in ultra low 
latency. Most of our network transfers involve bulk data movement (a few 
MB or more).  We don't care so much about low latency (meaning how long it 
takes the FIRST byte of data to travel from sender to receiver).  We care 
about aggregate bandwidth: once the pipe is full, how fast can data be 
moved through it. Sow we don't care so much if getting the pipe full takes 
20 us or 50 us.  We just want the data to flow fast once the pipe IS full.

> Welcome, its an interesting discussion.  Hope we can come to a good
> conclusion.

Thank you. Carsten will post more info and answers later today.

Cheers,
 	Bruce
