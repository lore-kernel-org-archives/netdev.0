From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 5 Jan 2005 17:30:34 +0100
Message-ID: <16860.5674.612383.986202@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<200501031656.57041.jeremy.guthrie@berbee.com>
	<16859.59675.522262.418329@robur.slu.se>
	<200501050918.22472.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501050918.22472.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > Yeah, the load will be high.  I'm expecting this to be watching ~ 750 mbps by 
 > next December.  The app profiles all traffic going in and out of our data 
 > centers.

 BW itself or pps is that not much of challange as handling of concurrent 
 flows.

 > I'm not showing the /proc/net/rt_cache_stat file.  Was there a kernel 
 > option I need to recompile with for rt_cache_stat to show up in proc?


 No it's there without any options. Would be nice to the output from rtstat


 > >  Also check that the CPU shares the RX packet load. CPU0 affinty to eth0
 > >  and CPU1 to eth1 seems to be best. It gives cache bouncing at "TX" and
 > >  slab jobs but we have accept that for now.

 > How would I go about doing this?

 Assume you route packets between eth0 <-> eth1 
 Set eth0 irq to CPU0 and eth1 to CPU1 with /proc/irq/XX/smp_affinity
 Disable irqbalancer etc.

 > cat /proc/net/softnet_stat

 total    droppped tsquz    Throttl  FR_hit   FR_succe FR_defer FR_def_o 
 cpu_coll 

 > 5592c972 00000000 00001fc8 00000000 00000000 00000000 00000000 00000000 
 > 00391c3f
 > 000f1991 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
 > 001292ba

 See! One line per CPU. So CPU0 is handing almost all packets.

 > "%soft"
 > Show  the percentage of time spent by the CPU or CPUs to service
 > softirqs.  A softirq (software interrupt) is one  of  up  to  32
 > enumerated software interrupts which can run on multiple CPUs

 Well yes. I had a more specific question. I'll look into mpstat where do 
 find it? Kernel pacthes?

 Be also aware that packet forwarding with SMP/NUMA is very much research
 today it is not that easy or not even possible to get aggregated performance 
 from several CPU's. in any setup. Well anyway we are beginning to see some 
 benefits now as we better understand the problems.

      
						--ro

  
 
