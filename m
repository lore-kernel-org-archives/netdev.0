From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [PATCH] net/usb: rtl8150: allocate URB transfer_buffer and setup_packet
 separately
Date: Sat, 10 Aug 2013 10:38:19 +0300
Message-ID: <5205EDEB.3010707@iki.fi>
References: <20130807133653.15587.35442.stgit@localhost6.localdomain6> <alpine.DEB.2.10.1308081809120.4258@fry.nucleusys.com> <5203F4D4.8090609@iki.fi> <alpine.DEB.2.10.1308092149270.3114@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from saarni.dnainternet.net ([83.102.40.136]:38398 "EHLO
	saarni.dnainternet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965460Ab3HJHi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 03:38:27 -0400
In-Reply-To: <alpine.DEB.2.10.1308092149270.3114@fry.nucleusys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.08.2013 21:50, Petko Manolov wrote:
> On Thu, 8 Aug 2013, Jussi Kivilinna wrote:
> 
>> On 08.08.2013 18:14, Petko Manolov wrote:
>>> On Wed, 7 Aug 2013, Jussi Kivilinna wrote:
>>>
>>>> rtl8150 allocates URB transfer_buffer and setup_packet as part of same 
>>>> structure 'struct async_req'. This can cause same cacheline to be 
>>>> DMA-mapped twice with same URB. This can lead to memory corruption on 
>>>> some systems.
>>>
>>> I can see performance impact due to the double mapping.  However, memory 
>>> corruption seems a bit too much for sane cache and DMA controllers.  Out 
>>> of interest - which is the architecture that will potentially corrupt the 
>>> memory.
>>
>> rtlwifi driver had similar structure to allocate both setup_packet and 
>> transfer_buffer in single go (overlapping dma-mapping cachelines) and 
>> this caused problems on ARM/sunxi. Problems means: memory corruptions at 
>> random locations, device freezes and lock-ups.
> 
> Broken controllers?..
> 

At first I thought so too, but I discussed about this at linux-usb, and answer
was that driver which uses same (dma/-)cacheline for multiple buffers is buggy..
  http://marc.info/?l=linux-usb&m=137130407121137&w=2 (at end)
  http://marc.info/?l=linux-usb&m=137137080902265&w=2
  http://marc.info/?l=linux-usb&m=137242422120782&w=2

-Jussi
