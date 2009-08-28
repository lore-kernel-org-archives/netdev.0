From: Johannes Stezenbach <js@sig21.net>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Fri, 28 Aug 2009 16:26:33 +0200
Message-ID: <20090828142633.GA7375@sig21.net>
References: <20090819145057.GA25400@sig21.net>
 <4A96A871.3090002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-embedded@vger.kernel.org, netdev@vger.kernel.org
To: H M Thalib <hmthalib@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:46298 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980AbZH1O0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2009 10:26:35 -0400
Content-Disposition: inline
In-Reply-To: <4A96A871.3090002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2009 at 09:08:25PM +0530, H M Thalib wrote:
> Johannes Stezenbach wrote:
> >
> >a while ago I was working on a SoC with 200MHz ARM926EJ-S CPU
> >and integrated 100Mbit ethernet core, connected on internal
> >(fast) memory bus, with DMA.  With iperf I measured:
> 
> Did you used Iperf it is not the correct tool to find the
> performance of ethernet. use tools like Smartbits or IXIA they are
> special hardware to measure the performance . They will give you
> better results

iperf is close to what the targeted application of this system
does -- receive a stream via TCP and process it.

Busybox wget e.g. is not good for benchmarking, it has a too small
receive buffer and adds a lot of syscall overhead.

> >  TCP RX ~70Mbit/sec  (iperf -s on SoC, iperf -c on destop PC)
> >  TCP TX ~56Mbit/sec  (iperf -s on destop PC, iperf -c o SoC)
> 
> Did you stopped unwanted process in both PC as well as processor,
> make sure PC has a bottle neck. Does it gives a through put of at
> least 95MBps. Is you system connected directly with crossover
> cables.

They are usually cpnnected via a 100Mbit switch, direct connection
yields no measurable improvement, and the PC can RX/TX ~95Mbit/sec
at close to 0% CPI load.

> >The CPU load during the iperf test is around
> >1% user, 44% system, 4% irq, 48% softirq, with 7500 irqs/sec.
> 
> Did you used vmast -- it is not the correct way to measure the cpu load
> or do you use top -- it takes lots of you system resource .. this
> can affect ehternet performance

I used a small tool similar to busybox nmeter (except that
it prints numbers instead of a bar). When this tool alone
runs the system is 100% idle.

> >I tried hard, but I couldn't find any performance figures for
> >comparison.  (All performance figures I found refer to 1Gbit
> >or 10Gbit server type systems.)
> 
> surely you will not find the perf data for small low end processor
> because they are not made fro that. and also this data is not some
> thing sharable .they are the benchmark about their product.

I wouldn't trust manufacturer benchmakrs anyway.  But I was
hoping to get some numbers from people working on similar
networked embedded hsystems.  E.g. it is hard to believe
that wireless routers running OpenWRT have trouble handling
54Mbit on the *wired* interface with a few iptables rules
enabled.


Thanks,
Johannes
