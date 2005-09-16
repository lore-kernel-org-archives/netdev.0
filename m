From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Fri, 16 Sep 2005 14:18:01 +0200
Message-ID: <17194.47097.607795.141059@robur.slu.se>
References: <20050825212211.GA23384@netnation.com>
	<20050826115520.GA12351@yakov.inr.ac.ru>
	<17167.29239.469711.847951@robur.slu.se>
	<20050906235700.GA31820@netnation.com>
	<17182.64751.340488.996748@robur.slu.se>
	<20050907162854.GB24735@netnation.com>
	<20050907195911.GA8382@yakov.inr.ac.ru>
	<20050913221448.GD15704@netnation.com>
	<20050915210432.GD28925@yakov.inr.ac.ru>
	<17193.59406.200787.819069@robur.slu.se>
	<20050915222102.GA30387@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Simon Kirby <sim@netnation.com>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050915222102.GA30387@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Alexey Kuznetsov writes:

 > Sender: 367 Mbps, 717883 pps valid src/dst, 64 byte (Ethernet) packets
 > 2.4.27-rc1: 297 Mbps forwarded (w/idle time?!)
 > So, his best number is (717883/367)*297 ~= 580kpps

Yes sounds famliar XEON with e1000... So why not for 2.6?


Below a very quick test from our 1.6 GHz Opteron. Latest GIT tree w. UP.

e1000 at PCI-X 133/100 MHz. 82546 GB dual NIC's Input 881 kpps.into eth0.
  
Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 6733009 3267274 6534548 3267274    180      0      0      0 BRU
eth1   1500   0      6      0      0      0 6732737      0      0      0 BRU

cat /proc/net/softnet_stat 
0066bd27 00000000 000057aa 00000000 00000000 00000000 00000000 00000000 00000000

cat /proc/interrupts 
           CPU0       
 16:        707   IO-APIC-level  eth0
 17:        293   IO-APIC-level  eth1
 18:        286   IO-APIC-level  eth2
 19:        286   IO-APIC-level  eth3

Total routed T-put of 590 Kpps 

 > >  Yes. I'll guess the thinking was that RCU is for read mostly
 > 
 > RCU should not add essential overhead to DoS, actually. The difference
 > between direct dst_free and RCU is strange as well.

 I think we saw this before. I proposed disabling deferred deletions
 as with the patch I sent for UP. 

 > >  Also interesing to get BSD numbers? Sounds like they use something like
 > >  old FASTROUTE.
 > 
 > Yes, it is quite funny. I guess it required irq protection to radix tree
 > manipulations, grr... Anyway, I would expect BSD with fastforwarding beat
 > NAPI.

 BSD uses fixed polling from what I understand so it should be pretty close
 NAPI. With Radix for FIB they need route even more than Linux. But code
 path might be more efficient have less hooks. Also I dunno about SMP/NUMA 
 for BSD we pay some price for it but hopefully we get something return.

 Cheers.
						--ro
