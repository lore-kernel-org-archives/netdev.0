From: arnd@arndb.de
Subject: Re: Advice on network driver design
Date: Sun, 20 Feb 2011 20:13:34 +0100
Message-ID: <201102202013.34994.arnd@arndb.de>
References: <4D5FC7A7.5050704@embedded-sol.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Felix Radensky <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:55603 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab1BTTNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 14:13:46 -0500
In-Reply-To: <4D5FC7A7.5050704@embedded-sol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 February 2011 14:37:43 Felix Radensky wrote:
> Hi,
> 
> I'm in the process of designing a network driver for a custom
> hardware and would like to get some advice from linux network
> gurus.
> 
> The host platform is Freescale P2020. The custom hardware is
> FPGA with several TX FIFOs, single RX FIFO and a set of registers.
> FPGA is connected to CPU via PCI-E. Host CPU DMA controller is used
> to get packets to/from FIFOs. Each FIFO has its set of events, 
> generating interrupts, which can be enabled and disabled. Status 
> register reflects the current state of events, the bit in status 
> register is cleared by FPGA when event is handled. Reads or writes to 
> status register have no impact on its contents.
> 
> The device driver should support 80Mbit/sec of traffic in each direction.
> 
> So far I have TX side working. I'm using Linux dmaengine APIs to
> transfer packets to FIFOs. The DMA completion interrupt is handled
> by per-fifo work queue.
> 
> My question is about RX. Would such design benefit from NAPI ?
> If my understanding of NAPI is correct, it runs in softirq context,
> so I cannot do any DMA work in dev->poll(). If I were to use NAPI,
> I should probably disable RX interrupts, do all DMA work in some
> work queue, keep RX packets in a list and only then call dev->poll().
> Is that correct ?
> 
> Any other advice and how to write an efficient driver for this 
> hardware is most welcome. I can influence FPGA design to some degree, 
> so if you think FPGA should be changed to improve things, please let 
> me know.

There are currently discussions ongoing about using virtio for this
kind of connection. See http://www.mail-archive.com/linuxppc-dev@lists.ozlabs.org/msg49294.html
for an archive.

When you use virtio as the base, you can use the regular virtio-net
driver or any other virtio high-level driver on top.

	Arnd
