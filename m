From: robert@herjulf.net
Subject: Strange CPU load when flushing route cache (kernel 2.6.31.6)
Date: Mon, 23 Nov 2009 16:07:10 +0100
Message-ID: <19210.42270.233337.986217@gargle.gargle.HOWL>
References: <1258970332.29747.262.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Robert Olsson <robert@herjulf.net>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from klais.its.uu.se ([130.238.7.59]:56939 "EHLO klais.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756968AbZKWMz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 07:55:58 -0500
In-Reply-To: <1258970332.29747.262.camel@jdb-workstation>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jesper Dangaard Brouer writes:

 > I have observed a strange route cache behaviour when I upgraded some
 > of my production Linux routers (1Gbit/s tg3) to kernel 2.6.31.6 (from
 > kernel 2.6.25.7).
 > 
 > Every time the route cache is flushed I get a CPU spike (in softirq)
 > with a tail.  I have attached some graphs that illustrate the issue
 > (hope vger.kernel.org will allow these attachments...)


 Nice plots. Yes had the same problem long time. Packets were dropped on
 even moderately loaded machines and the network managers were complaining.

 Also the are some router benchmarks (RFC??) that estimates the forwarding 
 performance to the level when the first packet drop occurs. One can of course 
 discuss such test but it's there...

 IMO is best to have he GC "inlined" with the creation of new flows and avoid 
 periodic tasks in this aspect. 

 Also I tried with something I called "active" garbage collection. The idea 
 was to get hints from TCP-FIN etc when to remove stale entries to take a 
 more pro-active approach. I think this was mentioned in the TRASH-paper. 

 If you only do routing you might try to disable the route cache.

 Cheers
					--ro
