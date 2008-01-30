From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 09:36:53 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Carsten Aulbert" <carsten.aulbert@aei.mpg.de>,
	"Henning Fehrmann" <henning.fehrmann@aei.mpg.de>,
	"Bruce Allen" <bruce.allen@aei.mpg.de>
To: "Bruce Allen" <ballen@gravity.phys.uwm.edu>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34591 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763871AbYA3Rgz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 12:36:55 -0500
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bruce Allen wrote:
> Details:
> Kernel version: 2.6.23.12
> ethernet NIC: Intel 82573L
> ethernet driver: e1000 version 7.3.20-k2
> motherboard: Supermicro PDSML-LN2+ (one quad core Intel Xeon X3220,
> Intel 3000 chipset, 8GB memory)

Hi Bruce,
The 82573L (a client NIC, regardless of the class of machine it is in)
only has a x1 connection which does introduce some latency since the
slot is only capable of about 2Gb/s data total, which includes overhead
of descriptors and other transactions.  As you approach the maximum of
the slot it gets more and more difficult to get wire speed in a
bidirectional test.
 
> The test was done with various mtu sizes ranging from 1500 to 9000,
> with ethernet flow control switched on and off, and using reno and
> cubic as a TCP congestion control.

As asked in LKML thread, please post the exact netperf command used to
start the client/server, whether or not you're using irqbalanced (aka
irqbalance) and what cat /proc/interrupts looks like (you ARE using MSI,
right?)

I've recently discovered that particularly with the most recent kernels
if you specify any socket options (-- -SX -sY) to netperf it does worse
than if it just lets the kernel auto-tune.
 
> The behavior depends on the setup. In one test we used cubic
> congestion control, flow control off. The transfer rate in one
> direction was above 0.9Gb/s while in the other direction it was 0.6
> to 0.8 Gb/s. After 15-20s the rates flipped. Perhaps the two steams
> are fighting for resources. (The performance of a full duplex stream
> should be close to 1Gb/s in both directions.)  A graph of the
> transfer speed as a function of time is here:
> https://n0.aei.uni-hannover.de/networktest/node19-new20-noflow.jpg 
> Red shows transmit and green shows receive (please ignore other
> plots): 

One other thing you can try with e1000 is disabling the dynamic
interrupt moderation by loading the driver with
InterruptThrottleRate=8000,8000,... (the number of commas depends on
your number of ports) which might help in your particular benchmark.

just for completeness can you post the dump of ethtool -e eth0 and lspci
-vvv?

Thanks,
  Jesse
