From: Bill Fink <billfink@mindspring.com>
Subject: Re: Achieved 10Gbit/s bidirectional routing
Date: Fri, 17 Jul 2009 19:38:02 -0400
Message-ID: <20090717193802.3cb36d9d.billfink@mindspring.com>
References: <1247676631.30876.29.camel@localhost.localdomain>
	<20090715232253.91d9f264.billfink@mindspring.com>
	<1247737144.30876.53.camel@localhost.localdomain>
	<20090716113827.19fbb379.billfink@mindspring.com>
	<20090717203546.GA31259@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	jesse.brandeburg@intel.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758051AbZGQXiK@vger.kernel.org>
In-Reply-To: <20090717203546.GA31259@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Jul 2009, Willy Tarreau wrote:

> On Thu, Jul 16, 2009 at 11:38:27AM -0400, Bill Fink wrote:
> 
> > We also achieved nearly 80 Gbps in bidirectional TCP tests (40 Gbps
> > simultaneously in each direction):
> > 
> > [root@i7raid-1 ~]# ./nuttcp-6.2.6 -In2 -xc0/0 -p5001 192.168.1.11 & ./nuttcp-6.2.6 -In3 -r -xc0/0 -p5002 192.168.2.11 & ./nuttcp-6.2.6 -In4 -xc1/1 -p5003 192.168.3.11 & ./nuttcp-6.2.6 -In5 -r -xc1/1 -p5004 192.168.4.11 & ./nuttcp-6.2.6 -In6 -xc2/2 -p5005 192.168.5.11 & ./nuttcp-6.2.6 -In7 -r -xc2/2 -p5006 192.168.6.11 & ./nuttcp-6.2.6 -In8 -xc3/3 -p5007 192.168.7.11 & ./nuttcp-6.2.6 -In9 -r -xc3/3 -p5008 192.168.8.11                                    
> > n2: 11542.6250 MB /  10.07 sec = 9619.9920 Mbps 44 %TX 51 %RX 0 retrans 0.12 msRTT                                                                      
> > n3: 11543.7143 MB /  10.06 sec = 9622.2153 Mbps 41 %TX 49 %RX 0 retrans 0.15 msRTT                                                   
> > n4: 11622.8125 MB /  10.05 sec = 9701.0296 Mbps 43 %TX 51 %RX 0 retrans 0.10 msRTT                                                                      
> > n5: 11523.6875 MB /  10.03 sec = 9638.8883 Mbps 43 %TX 50 %RX 0 retrans 0.15 msRTT                                                                      
> > n6: 11608.0141 MB /  10.04 sec = 9695.7388 Mbps 43 %TX 50 %RX 0 retrans 0.10 msRTT                                                                      
> > n7: 11580.1250 MB /  10.04 sec = 9679.3910 Mbps 43 %TX 50 %RX 0 retrans 0.13 msRTT                                                                      
> > n8: 11608.0000 MB /  10.06 sec = 9678.7596 Mbps 42 %TX 50 %RX 0 retrans 0.10 msRTT                                                                      
> > n9: 11553.3750 MB /  10.05 sec = 9643.7296 Mbps 45 %TX 50 %RX 0 retrans 0.11 msRTT                                                                      
> > 
> > This was using 2 dual-port 10-GigE NICs in the first two PCIe 2.0 slots.
> > We are using an Intel i7 965 quad-core 3.2 GHz Nehalem processor
> > (overclocked to 3.4 GHz) and 2000 MHz DDR3 memory.  Adding an additional
> > dual-port 10-GigE NIC on the Nvidia N200 chip does only marginally
> > better, as it appears we are basically CPU limited at this point for
> > this test (the sum of the TX and RX CPU utilization for each pair of
> > 10-GigE interfaces is about 93%).
> 
> Hey guys, those are really nice numbers. Since TCP splicing appeared in the
> kernel (once we got it fixed), I achieved 10 Gbps of HTTP proxying using
> haproxy with very low CPU usage (about 20% of a Core2Duo 2.66 GHz).
> 
> Before buying the machines, I had been wandering around with the NICs
> donated by Myricom in order to try to find a machine capable of supporting
> this. My conclusion was that a lot of machines had difficulties getting
> above 3.5, 4.7 and 6.5 Gbps of output traffic (those 3 numbers were always
> the same, depending on the chipsets). There clearly was a bandwidth
> limitation imposed by the chipset.
> 
> So I waited for the X38 and AM780FX chipsets to become available and
> bought 3 machines (1 C2D, 1 AMD X2, 1 AMD X4). Those ones have no problem
> with 10 Gbps of forwarded traffic (20 Gbps of total bus bandwidth), even
> with 1500 bytes frames, but I don't know how high they can go, maybe
> they will saturate slightly above.
> 
> Unfortunately, I only have 5 NICs in 3 machines and no switch (and CX4
> is hard to find these days), so I'm probably stuck at 10 Gbps max.
> 
> Interestingly, I had the impression that forwarding data with TCP
> splicing costs less CPU than IP forwarding, because the NICs can do
> LRO.
> 
> Also, I know a french service provider who uses haproxy on Core i7
> machines and who has already reached 5 Gbps of sustained traffic
> with recent intel dual-port NICs (though I'm not sure exactly which
> ones). This is with very little CPU usage too, less than 2-3% user
> and 15% system+softirq. On previous machines (quad core xeons), it
> was impossible to go beyond 3 Gbps, it looked like the chipset was
> the limitating factor too (though I don't precisely remember which
> one it was).
> 
> I really blamed the NICs because this guys machine was about 4 times
> more powerful than mine, but apparently it was just a chipset issue.
> 
> I also happen to have a customer who recently received a few Sun NXGE,
> mounted in Sun x2100-m2 using an nvidia chipset which I tested OK at
> 10 Gbps with my myri10GE NICs. I'll try to see if I can run some tests
> there, as Davem once said those NICs are really good too.
> 
> All in all, I find it really cool that our beloved OS scales that
> well with the hardware :-)

Yes, I am quite impressed that the Linux kernel and TCP/IP network
stack performs amazingly well at these multi-10-GigE speeds.  I was
especially interested in Jesper's IP forwarding results, as we haven't
tested that yet ourselves, and one of the intended applications of
these systems is as a multi-10-GigE firewall, so that's looking very
encouraging at this point.

						-Bill
