From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: Fri, 23 Jan 2004 21:10:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000001c3e238$62efbb30$0400a8c0@S2IOtech.com>
References: <1074914062.1036.39.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <hadi@cyberus.ca>
In-Reply-To: <1074914062.1036.39.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal, 
Please see answers below.
Thanks, Leonid

> Would be interesting to see performance numbers.

Your mileage will vary... Speaking of generic Linux and windows
platforms (that can't take advantage of many of the advanced features in
the ASIC yet), we have demonstrated 7.5 Gbps on Linux at SC2003, and 7.2
Gbps on Windows at the earlier Gartner show. These numbers are for a 1.5
GHz 2-way Itanium in one-to-many setup via 10GbE switch. Back-to-back
numbers between two systems are somewhat lower, pushing 6Gbps. Opteron
numbers are surprisingly close, 32-bit systems are slower since FSB is a
bottleneck. These numbers are with Jumbos and/or LSO, with 1500 bytes
frames performance is much lower... We have a complete matrix that
normally goes to customers, but it is not on a generic website yet. The
numbers are for TCP benchmarks - Chariot, nttcp, Iometer; raw
performance is higher and pushing pci-x 133 theoretical limit. PCI-X 133
bus is still a bottleneck for 10GbE for now, at least till PCI-X 266
systems show up. Hopefully, it will not be long...

In Linux, there are couple performance issues that we see
- transmit performance is noticeably worse than in Windows
- checksum in 2.4 seems to be calculated by the host even if the device
enables checksum offload
- Large Send Offload in 2.6 (no LSO in 2.4) give much smaller boost
comparing to Windows; on some systems there is no gain from LSO at all.

> BTW, your specs seem to indicate two interesting features:

There are several hw features and assists that current Linux driver
doesn't have since generic systems can't take advantage of yet.

> - Support for up to 32 concurrent PCI-X split transactions 

The device can match bridge split capabilities for up to 32 splits, for
better PCI-X bus utilization - the bus is a major bottleneck and we are
trying to utilize it very efficiently; splits just one part of this.
 
> - Adaptive Interrupt Coalescence

There are several interrupt schemes, in the utilization scheme the
device can be programmed to automatically adjust interrupt rate based
upon link utilization, independently for tx and rx interrupts. 
For instance, if the utilization is in single percentage digits then the
device can be programmed to get an interrupt per every packet since
interrupt rate doesn't matter much; If the utilization gets closer to
100%, it will probably make sense to program device for, say, one
interrupt per 200 packets - the number will somewhat vary for different
systems and packet sizes.

> 
> can you elaborate on these?
> 
> Also indent -kr -i8 may help.
> 
> cheers,
> jamal
> 
