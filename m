From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Performance problem with route cache ?
Date: Fri, 21 Nov 2003 10:37:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16317.56564.129747.186894@robur.slu.se>
References: <02da01c3af54$c1f37f20$890010ac@edumazet>
	<16316.46493.7576.116171@robur.slu.se>
	<037d01c3b004$86b78e00$890010ac@edumazet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Robert Olsson" <Robert.Olsson@data.slu.se>, <netdev@oss.sgi.com>,
        <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "dada1" <dada1@cosmosbay.com>
In-Reply-To: <037d01c3b004$86b78e00$890010ac@edumazet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


dada1 writes:

 > Instead of using 2K or 4K buffers to store the data into socket, we end up
 > using 64 bytes size buffers... quite a huge difference indeed.
 > In case of a spike in network, the machine no longer consume 200 MB of
 > lowmem and stay alive.

 Well have no experice here... but think e1000 was using 4k for 1500 MTU
 packets at least before.

 > In a router context, copybreak should not be used, because the extra copy is
 > CPU intensive, and the data should not live long enough on memory.

 It easy to try again. I'm playing with realtek r8169 driver and are filling
 the skb one-by-one now as they are passed onto the stack. Rather than doing
 the RX-batch refill. I need to collect some data...
 
 > The machine just receives a lot of frames from a lot of different IP. That
 > is not a DOS attack.

 > rtstat -i 1
 >  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
 > mc GC: tot ignored goal_miss ovrf HASH: in
 > _search out_search
 > 279536      1490   11719     0     0     0     0     0       231     843
 > 0   12562   12560         2    0

 Well not DoS? What is this? See you have almost 10 times more new entries
 per/sec then what hits your already huge dst-cache. (hit/total).

 Compare to a procduction router for 10:th of thousands of users at 55 kpps.

size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
21797     54543     529     0    49     0     0     0       137      12      0       0       0         0    0           28139         59

Cheers.
							--ro
