From: Felix Radensky <felix@embedded-sol.com>
Subject: Advice on network driver design
Date: Sat, 19 Feb 2011 15:37:43 +0200
Message-ID: <4D5FC7A7.5050704@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh78.surpasshosting.com ([72.29.64.142]:45230 "EHLO
	sh78.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899Ab1BSOPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Feb 2011 09:15:13 -0500
Received: from [109.66.242.77] (port=38867 helo=felix.lan)
	by sh78.surpasshosting.com with esmtpa (Exim 4.69)
	(envelope-from <felix@embedded-sol.com>)
	id 1Pqn08-00069X-Ua
	for netdev@vger.kernel.org; Sat, 19 Feb 2011 08:37:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm in the process of designing a network driver for a custom
hardware and would like to get some advice from linux network
gurus.

The host platform is Freescale P2020. The custom hardware is
FPGA with several TX FIFOs, single RX FIFO and a set of registers.
FPGA is connected to CPU via PCI-E. Host CPU DMA controller is used
to get packets to/from FIFOs. Each FIFO has its set of events, 
generating interrupts, which can be enabled and disabled. Status 
register reflects the current state of events, the bit in status 
register is cleared by FPGA when event is handled. Reads or writes to 
status register have no impact on its contents.

The device driver should support 80Mbit/sec of traffic in each direction.

So far I have TX side working. I'm using Linux dmaengine APIs to
transfer packets to FIFOs. The DMA completion interrupt is handled
by per-fifo work queue.

My question is about RX. Would such design benefit from NAPI ?
If my understanding of NAPI is correct, it runs in softirq context,
so I cannot do any DMA work in dev->poll(). If I were to use NAPI,
I should probably disable RX interrupts, do all DMA work in some
work queue, keep RX packets in a list and only then call dev->poll().
Is that correct ?

Any other advice and how to write an efficient driver for this 
hardware is most welcome. I can influence FPGA design to some degree, 
so if you think FPGA should be changed to improve things, please let 
me know.

Thanks a lot in advance.

Felix.

