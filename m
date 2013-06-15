From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [RFC PATCH] usb: hcd: warn about URB buffers that are not DMA
 aligned and are about to be DMA mapped
Date: Sat, 15 Jun 2013 16:22:30 +0300
Message-ID: <51BC6A96.7030707@iki.fi>
References: <20130614133803.25747.98705.stgit@localhost6.localdomain6> <CACVXFVM4TsS-_qK_w01oajV1XcA_+OF8xdTX2xjjxOTFNAo6Sw@mail.gmail.com> <51BC3F9E.3010605@iki.fi> <CACVXFVMe9fgdiDTRC0rWvwZJM8aT7AZY8Q1MwiOTc4ks0PQPOg@mail.gmail.com> <51BC67D7.90006@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Network Development <netdev@vger.kernel.org>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirokuusama.dnainternet.net ([83.102.40.133]:42749 "EHLO
	sirokuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754396Ab3FONWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 09:22:37 -0400
In-Reply-To: <51BC67D7.90006@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.06.2013 16:10, Jussi Kivilinna wrote:
[...]
>>
>>>
>>>>
>>>>>
>>>>> Instead of fixing host drivers, users end up posting bug reports against
>>>>> those USB device drivers that use unaligned buffers for URB; such as with
>>>>> rtl8192cu (http://thread.gmane.org/gmane.linux.kernel.wireless.general/105631).
>>>>
>>>> Not only rtl8192cu driver, all USB network device drivers have the problem.
>>>>
>>>>>
>>>>> Patch makes this issue more visible at core level, and hopefully gives hint
>>>>> for future hcd driver implementors about this problem.
>>>>
>>>> So please find the root cause first, and don't add the noise now.
>>>
>>> I think the root cause is that host driver is letting pass non-aligned buffers
>>> to core on archs that have ARCH_DMA_MINALIGN set.
>>
>> No, I don't think so, about the problem, the dma alignment requirement should
>> be from your host controller.
>>
>> As I said above, dma mapping/unmapping should be capable of dealing with
>> the unaligned buffer if no one touches memory which shares cacheline with
>> URB->transfer_buffer during URB transfer.
> 
> How can you guarantee that when you allow unaligned URB buffers?
> 
> You can have the buffer as part of some larger structure and send out async URB.
> Then while buffer is DMA mapped and send async to hw, you use other parts of
> that structure even if it shares cacheline with the buffer. You might issue
> multiple URBs with transfer buffers within same cacheline. I would expect that
> to be acceptable or URB documentation should say something against such.
> 

Hm.. rethink this a bit.

Transfer buffer might be dma aligned but shorter than cacheline and end of cacheline
used as something else. Manual alignment by host driver does not catch that
or fix that.
So, yes.. dma mapping should work with unaligned buffers, but maybe the actual
problem is multiple buffers from same cacheline.

-Jussi
