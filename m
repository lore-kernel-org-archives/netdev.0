From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 23:35:59 +0100
Message-ID: <16861.48463.770166.352726@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<200501061546.32116.jeremy.guthrie@berbee.com>
	<16861.46969.536236.11355@robur.slu.se>
	<200501061618.24465.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501061618.24465.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > You mentioned before that " The stats didn't show any numbers so we don't 
 > know your load."  Was there a command you wanted me to re-run?

 rtstat should show the routing/packet load.

 From a systems like yours 2*933 MHz PIII in production for tens of thoundans
 of users many filter and full BGP routing. Current (late here) use.


 ifstat2 eth*
             RX --------------------------   TX -------------------------
eth0          272.8 M bit/s       51 k pps    350.7 M bit/s       51 k pps 
eth1          371.9 M bit/s       55 k pps    293.6 M bit/s       55 k pps 
eth2            6.7 M bit/s     1348   pps      3.0 M bit/s      991   pps 
eth3            472   bit/s        0   pps      600   bit/s        0   pps 

rtstat
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
21007    114060     748     0     5     0     0     0        11       5      0       0       0         0    0           58280          4
22683    112556     827     0     6     0     0     0         5       5      0       0       0         0    0           60841          7
24230    111083     765     0     4     0     0     0        13       4      0       0       0         0    0           66628          7


Around 110 kpps hitting warm cache entries and ~800 new lookups/sec. I was
expecting so see something similar from your system. 


FYI.
 cat /proc/net/softnet_stat 
9ba490f3 00000000 01281572 00000000 00000000 00000000 00000000 00000000 002562c2
9939268d 00000000 010e42e9 00000000 00000000 00000000 00000000 00000000 0028fe72


Good Night.


						    --ro
