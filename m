From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: packet forward tests w. 2.5.46
Date: Tue, 12 Nov 2002 16:15:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15825.6934.241737.714418@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

Here are some the of the packet forwarding tests we did before. Now moved to 
recent 2.5.46 w. XEON 1.8 GHz, SeverWorks, e1000 dual-port w. 82546. and 4.4.12-k1 
from kernel tree. 10 Mpkts at rate of 817 kpps (64 bytes pkts) injected into 
eth0 and forwarded to eth1. TX-OK on eth1 gives the throughput.

Vanlilla NAPI
=============

netstat -i
eth0   1500   0 4488490 7703683 7703683 5511514     22      0      0      0 BRU
eth1   1500   0     22      0      0      0 4488490      0      0      0 BRU

irq's
 24:         47   IO-APIC-level  eth0
 25:      39744   IO-APIC-level  eth1

softnet_stat
00447d48 00000000 00003af5 00000000 00000000 00000000 00000000 00000000 00000000

Vanilla kernel (w. NAPI) has now a very decent performance of 367 kpps.


Vanilla above plus exerimental skb-recycling.
=============================================
robur.slu.se:/pub/Linux/net-development/skb_recycling/ 
recycle14.pat and e1000-RC-021112.pat

eth0   1500   0 5635546 6762949 6762949 4364460     26      0      0      0 BRU
eth1   1500   0     26      0      0      0 5635550      0      0      0 BRU

 24:         56   IO-APIC-level  eth0
 25:      68406   IO-APIC-level  eth1

0055fdfc 00000000 00004a44 00000000 00000000 00000000 00000000 00000000 00000000

We improve to 460 kpps which is about 25% increase in packet budget.


Vanilla without NAPI and RC.
============================
eth0   1500   0 7512826 5116105 5116105 2487178      9      0      0      0 BRU
eth1   1500   0     11      0      0      0    305      0      0      0 BRU

 24:      11803   IO-APIC-level  eth0
 25:         68   IO-APIC-level  eth1
 
0072a447 0072a1cb 00000002 00000001 00000000 00000000 00000000 00000000 00000000

0 pps :-) Enabling link-flowcontol would proably have helped. But there are
equipment around that misses it... 

SMP next...

Cheers.
						--ro

PS!
Note interface counters RX-ERR, RX-DRP get screwed up in this tests. But RX-OK+
RX-OVR counts the RX-pkts.
