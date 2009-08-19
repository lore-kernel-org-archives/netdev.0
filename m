From: Johannes Stezenbach <js@sig21.net>
Subject: 100Mbit ethernet performance on embedded devices
Date: Wed, 19 Aug 2009 16:50:57 +0200
Message-ID: <20090819145057.GA25400@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-embedded@vger.kernel.org
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

a while ago I was working on a SoC with 200MHz ARM926EJ-S CPU
and integrated 100Mbit ethernet core, connected on internal
(fast) memory bus, with DMA.  With iperf I measured:

  TCP RX ~70Mbit/sec  (iperf -s on SoC, iperf -c on destop PC)
  TCP TX ~56Mbit/sec  (iperf -s on destop PC, iperf -c o SoC)

The CPU load during the iperf test is around
1% user, 44% system, 4% irq, 48% softirq, with 7500 irqs/sec.

The kernel used in these measurements does not have iptables
support, I think packet filtering will slow it down noticably,
but I didn't actually try.  The ethernet driver uses NAPI,
but it doesn't seem to be a win judging from the irq/sec number.
The kernel was an ancient 2.6.20.

I tried hard, but I couldn't find any performance figures for
comparison.  (All performance figures I found refer to 1Gbit
or 10Gbit server type systems.)

What I'm interested in are some numbers for similar hardware,
to find out if my hardware and/or ethernet driver can be improved,
or if the CPU will always be the limiting factor.
I'd also be interested to know if hardware checksumming
support would improve throughput noticably in such a system,
or if it is only useful for 1Gbit and above.

Did anyone actually manage to get close to 100Mbit/sec
with similar CPU resources?


TIA,
Johannes
