From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Ethernet bridge performance
Date: Sun, 10 Aug 2003 23:49:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16182.48631.720695.768876@robur.slu.se>
References: <3F3217E7.2080903@allot.com>
	<3F3284EA.5050406@candelatech.com>
	<3F328A0F.3040005@allot.com>
	<16178.41976.3643.584516@robur.slu.se>
	<3F3601F3.6000001@allot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com,
   "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Felix Radensky <felix@allot.com>
In-Reply-To: <3F3601F3.6000001@allot.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Felix Radensky writes:

 > Is slab good enough in 2.4 ? I was thinking that one of the goals
 > of skb-recycle patch was to avoid skb allocations and deallocations
 > which consume quite a lot of CPU time (as profile shows). Are you
 > saying that your patch is not hepling to reduce CPU load ?
 
 Try to understand why/where packets get dropped in your setup to start with.
 Bridging shouldn't be different from routing which I experiments with.

 Check /proc/interrupts, /proc/net/softnet_stat and check for drops at 
 qdisc ( "tc -s qdisc" you might have to readd the qdisc just get the stats)

 Possible your TX-side cannot keep up with RX. Often the TX ring is not
 cleard aggressivly enough at high rates due intr. mitigation etc or possibly
 HW_FLOWCTRL from sink device. Disable it in your for testing.

 When you cure the cause in-kernel-drop you should have packets drops
 on the DMA-ring (in the driver) with NAPI drivers and no unnecssary
 skb allocation/CPU use or DMA's.

 > echo 1 > /proc/irq/48/smp_affinity
 > to avoid this kind of problem, or something else is required ?

 If you have both both incoming and outgoing on same CPU there will
 be no cache bouncing of course and a UP kernel would be faster if this
 all your job.

 
 Cheers.
						--ro
