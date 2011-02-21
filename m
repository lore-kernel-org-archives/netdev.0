From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: Advice on network driver design
Date: Mon, 21 Feb 2011 18:25:43 +0200
Message-ID: <4D629207.9000905@embedded-sol.com>
References: <4D5FC7A7.5050704@embedded-sol.com> <201102202013.34994.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh78.surpasshosting.com ([72.29.64.142]:57204 "EHLO
	sh78.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754984Ab1BUQZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 11:25:28 -0500
In-Reply-To: <201102202013.34994.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anrd,

On 02/20/2011 09:13 PM, arnd@arndb.de wrote:
> On Saturday 19 February 2011 14:37:43 Felix Radensky wrote:
>> Hi,
>>
>> I'm in the process of designing a network driver for a custom
>> hardware and would like to get some advice from linux network
>> gurus.
>>
>> The host platform is Freescale P2020. The custom hardware is
>> FPGA with several TX FIFOs, single RX FIFO and a set of registers.
>> FPGA is connected to CPU via PCI-E. Host CPU DMA controller is used
>> to get packets to/from FIFOs. Each FIFO has its set of events,
>> generating interrupts, which can be enabled and disabled. Status
>> register reflects the current state of events, the bit in status
>> register is cleared by FPGA when event is handled. Reads or writes to
>> status register have no impact on its contents.
>>
>> The device driver should support 80Mbit/sec of traffic in each direction.
>>
>> So far I have TX side working. I'm using Linux dmaengine APIs to
>> transfer packets to FIFOs. The DMA completion interrupt is handled
>> by per-fifo work queue.
>>
>> My question is about RX. Would such design benefit from NAPI ?
>> If my understanding of NAPI is correct, it runs in softirq context,
>> so I cannot do any DMA work in dev->poll(). If I were to use NAPI,
>> I should probably disable RX interrupts, do all DMA work in some
>> work queue, keep RX packets in a list and only then call dev->poll().
>> Is that correct ?
>>
>> Any other advice and how to write an efficient driver for this
>> hardware is most welcome. I can influence FPGA design to some degree,
>> so if you think FPGA should be changed to improve things, please let
>> me know.
> There are currently discussions ongoing about using virtio for this
> kind of connection. See http://www.mail-archive.com/linuxppc-dev@lists.ozlabs.org/msg49294.html
> for an archive.
>
> When you use virtio as the base, you can use the regular virtio-net
> driver or any other virtio high-level driver on top.
>
> 	Arnd
>
Thanks, I'll take a look at virtio. Some people seem to think it's an 
overkill for this task.

Felix.
