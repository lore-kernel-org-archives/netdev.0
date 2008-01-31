From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 02:52:13 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801310240210.3240@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
 <20080130.055333.192844925.davem@davemloft.net>
 <Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>
 <20080130082136.1017631d@deepthought>  <Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>
 <649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: SANGTAE HA <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:40084 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762314AbYAaIwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 03:52:25 -0500
In-Reply-To: <649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sangtae,

Thanks for joining this discussion -- it's good to a CUBIC author and 
expert here!

>> In our application (cluster computing) we use a very tightly coupled 
>> high-speed low-latency network.  There is no 'wide area traffic'.  So 
>> it's hard for me to understand why any networking components or 
>> software layers should take more than milliseconds to ramp up or back 
>> off in speed. Perhaps we should be asking for a TCP congestion 
>> avoidance algorithm which is designed for a data center environment 
>> where there are very few hops and typical packet delivery times are 
>> tens or hundreds of microseconds. It's very different than delivering 
>> data thousands of km across a WAN.

> If your network latency is low, regardless of type of protocols should 
> give you more than 900Mbps.

Yes, this is also what I had thought.

In the graph that we posted, the two machines are connected by an ethernet 
crossover cable.  The total RTT of the two machines is probably AT MOST a 
couple of hundred microseconds.  Typically it takes 20 or 30 microseconds 
to get the first packet out the NIC.  Travel across the wire is a few 
nanoseconds.  Then getting the packet into the receiving NIC might be 
another 20 or 30 microseconds.  The ACK should fly back in about the same 
time.

> I can guess the RTT of two machines is less than 4ms in your case and I 
> remember the throughputs of all high-speed protocols (including 
> tcp-reno) were more than 900Mbps with 4ms RTT. So, my question which 
> kernel version did you use with your broadcomm NIC and got more than 
> 900Mbps?

We are going to double-check this (we did the broadcom testing about two 
months ago). Carsten is going to re-run the broadcomm experiments later 
today and will then post the results.

You can see results from some testing on crossover-cable wired systems 
with broadcomm NICs, that I did about 2 years ago, here:
http://www.lsc-group.phys.uwm.edu/beowulf/nemo/design/SMC_8508T_Performance.html
You'll notice that total TCP throughput on the crossover cable was about 
220 MB/sec.  With TCP overhead this is very close to 2Gb/s.

> I have two machines connected by a gig switch and I can see what happens 
> in my environment. Could you post what parameters did you use for 
> netperf testing?

Carsten will post these in the next few hours.  If you want to simplify 
further, you can even take away the gig switch and just use a crossover 
cable.

> and also if you set any parameters for your testing, please post them
> here so that I can see that happens to me as well.

Carsten will post all the sysctl and ethtool parameters shortly.

Thanks again for chiming in. I am sure that with help from you, Jesse, and 
Rick, we can figure out what is going on here, and get it fixed.

Cheers,
 	Bruce
