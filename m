From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Sun, 16 Jan 2005 13:32:49 +0100
Message-ID: <16874.24305.461492.48668@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<16871.60849.905998.527106@robur.slu.se>
	<200501141300.44347.jeremy.guthrie@berbee.com>
	<200501141326.29575.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501141326.29575.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > I actually upped the buffer count to 8192 buffers instead of 10k.  
 > Of the 74 samples I have thus far, 57 have been clean of errors.  
 > Most of the sample errors appear to be shortly after the cache flush.

 I don't really believe in increasing RX buffers to this extent. We verified
 that you have CPU available and the drops occur when the timer based GC
 happens. Increasing buffers decreases overall performance and adds jitter.

 We saw also the timed based GC were taking the dst-entries from about
 600k to 40k in one shot. I think this what we should look into. Just 
 GC is "work" also after GC a lot flows has to be recreated doing fib 
 lookup and creating new entries. We want to smoothen the GC process so 
 happen more frequent and does less work. 

 Some time ago an "in-flow" GC (as opposed to timer based) was added to
 the routing code look for cand in route.c. In setup like yours (and ours) 
 it would be better to relay on this process to a higher extent. Anyway
 in /proc/sys/net/ipv4/route/ you have the files.

 gc_elasticity, gc_interval, gc_thresh etc I would avoid gc_min_interval.

 And you can play with your running system and for drops without causing
 your users to much pain. 
 
 We save the patch for routing without route hash and GC until later,


					       --ro
