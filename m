From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Linux router performance (3c59x) (fwd)
Date: Tue, 18 Mar 2003 10:54:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15990.60648.230534.852040@robur.slu.se>
References: <Pine.LNX.4.51.0303172239390.30872@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0303172239390.30872@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ralph Doncaster writes:
 > I haven't heard from Jamal or Dave, so perhaps someone from this list has
 > some wisdom to impart.
 > Currently the box in question is running a 67% system load with ~40kpps.
 > Here's the switch port stats that the 2 3c905cx cards are plugged into:

 Hello!

 First we do a lot of testing with routing path but have no experience
 with the hardware you have 3c59x or duron. 

 In general it seems hard to extrapolate performance X1 % CPU at X2 pps.
 You don't see CPU used in IRQ context and not in some of softIRQ's.

 I think a better way for this tests is to input "overload" so your 
 system gets saturated. You get the DoS test for free... After getting
 the throughput you have figure out what's your bottleneck CPU, PCI etc.

 > This is a box doing straight routing (no firewalling), with a full bgp4
 > routing table (>100k routes).  Kernel advanced router config option as
 > well as fastroute was chosen.

 The size of routing table itself has no effect... The challenge comes 
 when there are a high number of new "flows" per second so garbage 
 collection gets active. This can be seen with a program rtstat in the
 iproute2 package.
 
 Currently there is no driver with FASTROUTE support in the kernel so this 
 will not do you any good now.
 
 But Linux routing (and packet overload) performance is still very good.

 You can see performance numbers as well as profiles for different setups
 
 http://robur.slu.se/Linux/net-development/experiments/router-profile.html

 As seen packet memory allocation is one of the CPU consumers. And also
 we see that slab is not not fully per CPU so we are spinning in case of
 SMP.

 And as seen UP gives about 345 kpps. With skb recycling bump this up to
 507 kpps. The challenge for now is to get aggregated performance with SMP.

 Also remember that network and routing in particular is very much data
 transport which is DMA transfers from and to memory and these has to 
 interact with CPU/driver arbitrating for the bus to manage this DMA's.
 Latencies and serializations are not obvious at this level.


 Cheers.
						--ro
