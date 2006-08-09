From: Philip Molter <philip@datafoundry.com>
Subject: Re: tg3: tg3_stop_block timed out
Date: Wed, 09 Aug 2006 09:44:59 -0500
Message-ID: <44D9F4EB.8050809@datafoundry.com>
References: <eb8fmt$6lf$1@sea.gmane.org> <1154992063.5328.3.camel@rh4> <200608080124.38823.bernd-schubert@gmx.de> <1154994410.5328.10.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bernd Schubert <bernd-schubert@gmx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailstar.maildev2.aus.datafoundry.com ([209.99.125.26]:30593
	"EHLO mailstar.maildev2.aus.datafoundry.com") by vger.kernel.org
	with ESMTP id S1750901AbWHIOp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 10:45:29 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1154994410.5328.10.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Tue, 2006-08-08 at 01:24 +0200, Bernd Schubert wrote:
> 
>> tg3.c:v3.49 (Feb 2, 2006)
>> acpi_bus-0201 [01] bus_set_power         : Device is not power manageable
>> eth1: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:e0:81:2b:aa:28
>> eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap[0]
>> eth1: dma_rwctrl[769f4000] dma_mask[64-bit]
>> eth2: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:e0:81:2b:aa:29
>> eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
>> eth2: dma_rwctrl[769f4000] dma_mask[64-bit]
>>
> 
> You have ASF enabled on eth1 but not on eth2 so I wonder if ASF is
> causing the problem.  Can you run the same traffic on eth2 and see if
> you get the same timeout problem?  Thanks.

I'm also having this same problem:

divert: allocating divert_blk for bond0
tg3.c:v3.14 (November 15, 2004)
divert: allocating divert_blk for eth0
eth0: Tigon3 [partno(BCM95704A7) rev 2003 PHY(5704)] 
(PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:e0:81:2e:82:1a
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] 
TSOcap[1]
divert: allocating divert_blk for eth1
eth1: Tigon3 [partno(BCM95704A7) rev 2003 PHY(5704)] 
(PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:e0:81:2e:82:1b
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] 
TSOcap[1]
divert: freeing divert_blk for bond0
divert: freeing divert_blk for eth0
divert: freeing divert_blk for eth1

02:09.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 
Gigabit Ethernet (rev 03)
         Subsystem: Broadcom Corporation: Unknown device 1644
         Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 161
         Memory at fc8c0000 (64-bit, non-prefetchable) [size=fc8a0000]
         Memory at fc8b0000 (64-bit, non-prefetchable) [size=64K]
         Expansion ROM at 00010000 [disabled]
         Capabilities: [40] PCI-X non-bridge device.
         Capabilities: [48] Power Management version 2
         Capabilities: [50] Vital Product Data
         Capabilities: [58] Message Signalled Interrupts: 64bit+ 
Queue=0/3 Enable-

02:09.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 
Gigabit Ethernet (rev 03)
         Subsystem: Broadcom Corporation: Unknown device 1644
         Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 169
         Memory at fc8f0000 (64-bit, non-prefetchable) [size=fc8d0000]
         Memory at fc8e0000 (64-bit, non-prefetchable) [size=64K]
         Expansion ROM at 00010000 [disabled]
         Capabilities: [40] PCI-X non-bridge device.
         Capabilities: [48] Power Management version 2
         Capabilities: [50] Vital Product Data
         Capabilities: [58] Message Signalled Interrupts: 64bit+ 
Queue=0/3 Enable-

I run these things with jumbo frames and bonding.  In the case last 
night, our machine completely locked up because both interfaces stopped 
working and the channel bond between them went down.  These guys are 
pushing a little over 1Gb/s total traffic between them (500Mb/s each) 
and one of them will take in about 300Mb/s.  Outgoing packets average 
20kpkts/s and incoming packets on the one interface average about 
45kpkts/s (most incoming traffic is not jumbo).

This was on console:

tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
tg3: eth1: transmit timed out, resetting
tg3: tg3_stop_block timed out, ofs=3400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=1800 enable_bit=2
tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
tg3: eth0: transmit timed out, resetting
tg3: tg3_stop_block timed out, ofs=3400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=1800 enable_bit=2
tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
tg3: eth1: transmit timed out, resetting
tg3: tg3_stop_block timed out, ofs=3400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=1800 enable_bit=2
tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
tg3: eth0: transmit timed out, resetting
tg3: tg3_stop_block timed out, ofs=3400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
tg3: tg3_stop_block timed out, ofs=1800 enable_bit=2
tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2

We tried restarting networking.  We tried unloading all network-related 
modules and reloading them.  We eventually had to reboot the box to get 
networking started again.  The kernel is 2.6.10, via FC2 
(2.6.10-2.3.legacy).  We've also had the problem with the latest FC4 kernel.

Any information would be greatly appreciated.

Philip
