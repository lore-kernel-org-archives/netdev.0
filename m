From: Jamie Lokier <jamie@shareable.org>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Wed, 19 Aug 2009 16:35:34 +0100
Message-ID: <20090819153534.GC30013@shareable.org>
References: <20090819145057.GA25400@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-embedded@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090819145057.GA25400@sig21.net>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Stezenbach wrote:
> a while ago I was working on a SoC with 200MHz ARM926EJ-S CPU
> and integrated 100Mbit ethernet core, connected on internal
> (fast) memory bus, with DMA.  With iperf I measured:
> 
>   TCP RX ~70Mbit/sec  (iperf -s on SoC, iperf -c on destop PC)
>   TCP TX ~56Mbit/sec  (iperf -s on destop PC, iperf -c o SoC)
> 
> The CPU load during the iperf test is around
> 1% user, 44% system, 4% irq, 48% softirq, with 7500 irqs/sec.
> 
> The kernel used in these measurements does not have iptables
> support, I think packet filtering will slow it down noticably,
> but I didn't actually try.  The ethernet driver uses NAPI,
> but it doesn't seem to be a win judging from the irq/sec number.

You should see far fewer interrupts if NAPI was working properly.
Rather than NAPI not being a win, it looks like it's not active at
all.

7500/sec is close to the packet rate, for sending TCP with
full-size ethernet packages over a 100Mbit ethernet link.

> What I'm interested in are some numbers for similar hardware,
> to find out if my hardware and/or ethernet driver can be improved,
> or if the CPU will always be the limiting factor.

I have a SoC with a 166MHz ARMv4 (ARM7TDMI I think, but I'm not sure),
and an external RTL8139 100Mbit ethernet chip over the SoC's PCI bus.

It gets a little over 80Mbit/s actual data throughput in both
directions, running a simple FTP client.

> I'd also be interested to know if hardware checksumming
> support would improve throughput noticably in such a system,
> or if it is only useful for 1Gbit and above.
> 
> Did anyone actually manage to get close to 100Mbit/sec
> with similar CPU resources?

Remember, the TCP throughput cannot reach 100Mbit/sec due to the
overhead of packet framing.  But it should be much closer to 100 than 70.

-- Jamie
