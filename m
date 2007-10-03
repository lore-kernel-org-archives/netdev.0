From: Bill Fink <billfink@mindspring.com>
Subject: Re: tcp bw in 2.6
Date: Wed, 3 Oct 2007 03:19:06 -0400
Message-ID: <20071003031906.5f0d7cfd.billfink@mindspring.com>
References: <20070929142517.EC6AB5FB21@work.bitmover.com>
	<alpine.LFD.0.999.0709290914410.3579@woody.linux-foundation.org>
	<20070929172639.GB7037@bitmover.com>
	<alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org>
	<20071002005917.GB5480@bitmover.com>
	<alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org>
	<20071002022059.GE7037@bitmover.com>
	<47027C63.803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Larry McVoy <lm@bitmover.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	davem@davemloft.net, wscott@bitmover.com, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:45668 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751452AbXJCHT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 03:19:26 -0400
In-Reply-To: <47027C63.803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tangential aside:

On Tue, 02 Oct 2007, Rick Jones wrote:

> *) depending on the quantity of CPU around, and the type of test one is running, 
> results can be better/worse depending on the CPU to which you bind the 
> application.  Latency tends to be best when running on the same core as takes 
> interrupts from the NIC, bulk transfer can be better when running on a different 
> core, although generally better when a different core on the same chip.  These
> days the throughput stuff is more easily seen on 10G, but the netperf service 
> demand changes are still visible on 1G.

Interesting.  I was going to say that I've generally had the opposite
experience when it comes to bulk data transfers, which is what I would
expect due to CPU caching effects, but that perhaps it's motherboard/NIC/
driver dependent.  But in testing I just did I discovered it's even
MTU dependent (most of my normal testing is always with 9000-byte
jumbo frames).

With Myricom 10-GigE NICs, NIC interrupts on CPU 0 and nuttcp app
running on CPU 1 (both transmit and receive sides), and using 9000-byte
jumbo frames:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
10078.5000 MB /  10.02 sec = 8437.5396 Mbps 100 %TX 99 %RX

With Myricom 10-GigE NICs, and both NIC interrupts and nuttcp app
on CPU 0 (both transmit and receive sides), again using 9000-byte
jumbo frames:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11817.8750 MB /  10.00 sec = 9909.7537 Mbps 100 %TX 74 %RX

Same tests repeated with standard 1500-byte Ethernet MTU:

With Myricom 10-GigE NICs, NIC interrupts on CPU 0 and nuttcp app
running on CPU 1 (both transmit and receive sides), and using
standard 1500-byte Ethernet MTU:

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5685.9375 MB /  10.00 sec = 4768.0951 Mbps 99 %TX 98 %RX

With Myricom 10-GigE NICs, and both NIC interrupts and nuttcp app
on CPU 0 (both transmit and receive sides), again using standard
1500-byte Ethernet MTU:

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4974.0625 MB /  10.03 sec = 4161.6015 Mbps 100 %TX 100 %RX

Now back to your regularly scheduled programming.  :-)

						-Bill
