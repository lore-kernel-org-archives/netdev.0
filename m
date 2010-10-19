From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [RFC 0/3] MPEG2/TS drop analyzer iptables match extension
Date: Tue, 19 Oct 2010 16:21:33 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1010191608080.18708@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: paulmck@linux.vnet.ibm.com, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Netfilter Developers <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is my iptables match module for analyzing IPTV MPEG2/TS streams.
Currently it only detects dropped packets, but I want to extend it for
analyzing jitter and bursts.

Jan Engelhardt convinced me that I should just send the module as-is
for review on the list.  I wrote the code in 2009, and have only done
some minor changes to make it work on kernel 2.6.35 since.

The code is running in our production environment, where it handles
approx 120 TV-channels which gives an approx 600 Mbit/s bandwidth
usage.  The production hardware are using an ATOM 330 CPU (1.6Ghz),
and a PCI-express attached NIC Intel 82576 (driver igb).

I take advantage of the multiqueue features in the 82576 Intel NIC.
This together with using RCU locking, makes the module scale very well
to several CPUs (the ATOM 330 has two cores with HyperTreading).
The total CPU load on production is only 10% CPU load (6-7% in softirq).

I do "deep-packet-inspection" of the IP packet in order to process the
7 internal TS (Transport Stream) packets.

I have placed the presentation I'm giving at Netfilter Workshop 2010 on 
the Wiki list of presentations:
  http://workshop.netfilter.org/2010/wiki/index.php/List_of_presentations
and a direct link here:
  http://workshop.netfilter.org/2010/presentations/IPTV-burst-issues-NFWS2010-JesperBrouer.odp

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
