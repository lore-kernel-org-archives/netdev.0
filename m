From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Wed, 19 Aug 2009 16:05:17 +0100
Message-ID: <1250694317.2874.4.camel@achroite>
References: <20090819145057.GA25400@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-embedded@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:45651 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752011AbZHSPFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 11:05:18 -0400
In-Reply-To: <20090819145057.GA25400@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-19 at 16:50 +0200, Johannes Stezenbach wrote:
> Hi,
> 
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
> The kernel was an ancient 2.6.20.

Which driver is this?  Is it possible that it does not use NAPI
correctly?

> I tried hard, but I couldn't find any performance figures for
> comparison.  (All performance figures I found refer to 1Gbit
> or 10Gbit server type systems.)
> 
> What I'm interested in are some numbers for similar hardware,
> to find out if my hardware and/or ethernet driver can be improved,
> or if the CPU will always be the limiting factor.
> I'd also be interested to know if hardware checksumming
> support would improve throughput noticably in such a system,
> or if it is only useful for 1Gbit and above.

I have no recent experience with this sort of system, but checksum
offload and scatter/gather DMA support should significantly reduce both
CPU and memory bus load.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

