From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Fw: ksoftirqd causing severe network performance problems
Date: Sat, 13 Sep 2003 14:14:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16227.2601.742897.252057@robur.slu.se>
References: <20030905084825.4b60169f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: brendan@telegraafnet.nl
In-Reply-To: <20030905084825.4b60169f.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 > Hi,
 > 
 > More than a week ago we replaced our old linux core routers (in a
 > failover setup), with a new one. The old used 2 100 mbit NICs and worked
 > very well, however we needed more than a 100 mbit throughput, so we
 > replaced the setup with an almost identical setup based on two new
 > servers with 2 1g NICs. At peek time it processes about 70 Mbits/sec of
 > traffic and we use vlan's and use iptables, firewalling and DNAT of
 > almost all the connections, the same as in the old setup.               
 >                                                                                 
 > At the end of last week, the new setup had network problems and what we saw on
 > the linux router was that the kernel threads ksoftirqd_CPU1 and ksoftirqd_CPU0
 > were using almost 100% of system time and the network throughput collapsed.
 > This happens every day once or twice but the first one seems reasonably
 > predictable and happens when the network traffic raises from a constant
 > throughput from 3 Mbit/sec to 46 Mbit/sec in 3 hours. At a rough 40 Mbit/sec
 > the problem occures and a failover to the slave router solves the problem. On
 > the faulty server (previously master) the 100% CPU usage drops to almost 100%
 > idle. When the backup is working fine, we can't use the faulty server anymore
 > for routing/firewalling because failing back to it again results in an instant
 > 100% system time again. Rebooting the system helps.                             

 Hello!
 
 Some debug suggestions... 

 Look/compare /proc/slab for suspects in this state.

 Check where the packet drops occurs. NIC, backlog or qdisc (you might need to and
 an qdisc to be able to monitor).

 route cache can be monitored with rtstat in iproute2 package.

 > every 60 second. The kernel functions which use the most clockticks (top 10)
 > during the problem are:
 > 
 >     50 ip_route_input                             0.1238
 >    676 __write_lock_failed                       21.1250
 >   2928 __read_lock_failed                       146.4000

 You seem to hit some lock... If this the problem or just symptoms is to see
 set affinity so just one CPU is used or try a UP kernel.

 Cheers.

						--ro
