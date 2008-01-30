From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 16:25:12 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
 <20080130.055333.192844925.davem@davemloft.net>
 <Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>
 <20080130082136.1017631d@deepthought>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:60763 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbYA3WZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 17:25:24 -0500
In-Reply-To: <20080130082136.1017631d@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Thanks for your helpful reply and especially for the literature pointers.

>> Indeed, we are not asking to see 1000 Mb/s.  We'd be happy to see 900
>> Mb/s.
>>
>> Netperf is trasmitting a large buffer in MTU-sized packets (min 1500
>> bytes).  Since the acks are only about 60 bytes in size, they should be
>> around 4% of the total traffic.  Hence we would not expect to see more
>> than 960 Mb/s.

> Don't forget the network overhead: http://sd.wareonearth.com/~phil/net/overhead/
> Max TCP Payload data rates over ethernet:
>  (1500-40)/(38+1500) = 94.9285 %  IPv4, minimal headers
>  (1500-52)/(38+1500) = 94.1482 %  IPv4, TCP timestamps

Yes.  If you look further down the page, you will see that with jumbo 
frames (which we have also tried) on Gb/s ethernet the maximum throughput 
is:

   (9000-20-20-12)/(9000+14+4+7+1+12)*1000000000/1000000 = 990.042 Mbps

We are very far from this number -- averaging perhaps 600 or 700 Mbps.

> I believe what you are seeing is an effect that occurs when using
> cubic on links with no other idle traffic. With two flows at high speed,
> the first flow consumes most of the router buffer and backs off gradually,
> and the second flow is not very aggressive.  It has been discussed
> back and forth between TCP researchers with no agreement, one side
> says that it is unfairness and the other side says it is not a problem in
> the real world because of the presence of background traffic.

At least in principle, we should have NO congestion here.  We have ports 
on two different machines wired with a crossover cable.  Box A can not 
transmit faster than 1 Gb/s.  Box B should be able to receive that data 
without dropping packets.  It's not doing anything else!

> See:
>  http://www.hamilton.ie/net/pfldnet2007_cubic_final.pdf
>  http://www.csc.ncsu.edu/faculty/rhee/Rebuttal-LSM-new.pdf

This is extremely helpful.  The typical oscillation (startup) period shown 
in the plots in these papers is of order 10 seconds, which is similar to 
the types of oscillation periods that we are seeing.

*However* we have also seen similar behavior with the Reno congestion 
control algorithm.  So this might not be due to cubic, or entirely due to 
cubic.

In our application (cluster computing) we use a very tightly coupled 
high-speed low-latency network.  There is no 'wide area traffic'.  So it's 
hard for me to understand why any networking components or software layers 
should take more than milliseconds to ramp up or back off in speed. 
Perhaps we should be asking for a TCP congestion avoidance algorithm which 
is designed for a data center environment where there are very few hops 
and typical packet delivery times are tens or hundreds of microseconds. 
It's very different than delivering data thousands of km across a WAN.

Cheers,
 	Bruce
