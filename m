From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 03 Aug 2006 16:37:35 +0200
Message-ID: <44D20A2F.3090005@arndnet.de>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-2.rz.RWTH-Aachen.DE ([134.130.3.131]:38060 "EHLO
	ms-dienst.rz.rwth-aachen.de") by vger.kernel.org with ESMTP
	id S932526AbWHCOh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 10:37:29 -0400
Received: from circe (circe.rz.RWTH-Aachen.DE [134.130.3.36])
 by ms-dienst.rz.rwth-aachen.de
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0J3F00BB1FAEJ9@ms-dienst.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Aug 2006 16:37:26 +0200 (MEST)
Received: from dustpuppy.kawo2.rwth-aachen.de
 (dustpuppy.kawo2.RWTH-Aachen.DE [134.130.180.5])	by smarthost.rwth-aachen.de
 (8.13.7/8.13.1/1) with ESMTP id k73EbP1b007873	for <netdev@vger.kernel.org>;
 Thu, 03 Aug 2006 16:37:25 +0200
Received: from dustpuppy.kawo2.rwth-aachen.de (localhost [127.0.0.1])
	by dustpuppy.kawo2.rwth-aachen.de (Postfix) with ESMTP id ADB551FC2A3	for
 <netdev@vger.kernel.org>; Thu, 03 Aug 2006 16:37:25 +0200 (CEST)
In-reply-to: <20060803135925.GA28348@2ka.mipt.ru>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Evgeniy Polyakov wrote:
> On Thu, Aug 03, 2006 at 03:48:39PM +0200, Arnd Hannemann (arnd@arndnet.de) wrote:
>> Hi,
>>
>> im running vanilla 2.6.17.6 and if i try to set the mtu of my e1000 nic
>> to 9000 bytes, page allocation failures occur (see below).
>>
>> However the box is a VIA Epia MII12000 with 1 GB of Ram and 1 GB of swap
>> enabled, so there should be plenty of memory available. HIGHMEM support
>> is off. The e1000 nic seems to be an 82540EM, which to my knowledge
>> should support jumboframes.
> 
> But it does not support splitting them into page sized chunks, so it
> requires the whole jumbo frame allocation in one contiguous chunk, 9k
> will be transferred into 16k allocation (order 3), since SLAB uses
> power-of-2 allocation.

Hmm, ok, what is the meaning of this line then:
> Normal: 44578*4kB 11117*8kB 800*16kB 0*32kB 1*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 280240kB

Are this the allocations which already happend? I thought they would
represent the free memory, not the already used one?

>> However I can't always reproduce this on a freshly booted system, so
>> someone else may be the culprit and leaking pages?
> 
> You will almost 100% reproduce it after "find / > /dev/null".
> 
>> Any ideas how to debug this?
> 
> It can not be debugged - you have cought a memory fragmentation problem,
> which is quite common.

That's too bad :-(
However it seems hard for me to imagine why there is no contiguous chunk
of 16k when there are hundreds of Mbyte free. Can't those other pages be
moved by the kernel, if a higher order allocation is requested?

> 
>>> kswapd0: page allocation failure. order:3, mode:0x20
> 
> e1000 tries to allocate 3-order pages atomically?
> Well, that's wrong.
>  

Why? After your explanation that makes sense for me. The driver needs
one contiguous chunk for those 9k packet buffer and thus requests a
3-order page of 16k. Or do i still do not understand this?

> Evgeniy Polyakov

Thank you for your fast answer,
Arnd Hannemann



