From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Wed, 6 Nov 2002 20:47:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15817.29109.859144.565330@robur.slu.se>
References: <3DC8B85B.5050805@candelatech.com>
	<15817.21170.173913.829498@robur.slu.se>
	<3DC95631.6030001@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   Jeff Garzik <jgarzik@mandrakesoft.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DC95631.6030001@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ben Greear writes:

 > >  I see you increased the RX-ring to 1024 pkts. 
 > >  Did you really see any improvement with this?
 > 
 > It helped drop fewer packets when running 4 ports at 92Mbps+
 > However, the difference between that and 512 is not large.
 > I would really like to make that size adjustable at module load
 > time and/or runtime, but I'm not sure how easy that would be.
 > 
 > Imagine being able to crank up your receive buffers when running at
 > very high speeds (and/or when you start dropping packets).  At lower speeds,
 > shrink things down and free up resources....

 I still doubt ;-) 

 With e1000 I played with various settings for RX-buffers rather recently 
 when the 82544 increased the number of available buffers from 256 to 4096.

 And I guess my test looks a bit like yours... Injecting an "overload" of 
 packets. I found was 256 buffers was the optimum. Approximative of course.
 
 
 > Were you testing SMP or uni-processor?  I've been doing the tulip testing
 > on a single processor P-IV system.

 We tested both at that time but it's rewritten now... 

 And as you saw for SMP with recycle it is easy to feed the recycled skb 
 back to CPU were it was created/processed.

 So kfree/skb_headerinit "should" cause less cache bouncing. Still we need
 to pollute one cache line to find the CPU "owner". I posted some of 
 numbers here time ago but it would be nice to verify with CPU's performance 
 counters.


 Cheers.

						--ro
