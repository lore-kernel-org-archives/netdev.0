From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 03 Aug 2006 23:40:27 +0200
Message-ID: <44D26D4B.4090609@arndnet.de>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru>
 <44D20A2F.3090005@arndnet.de> <20060803150330.GB12915@2ka.mipt.ru>
 <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl>
 <20060803151631.GA14774@2ka.mipt.ru> <20060803154125.GA9745@2ka.mipt.ru>
 <44D23BC3.7040707@arndnet.de> <20060803182911.GA8692@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-2.rz.RWTH-Aachen.DE ([134.130.3.131]:11514 "EHLO
	ms-dienst.rz.rwth-aachen.de") by vger.kernel.org with ESMTP
	id S932581AbWHCVkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 17:40:19 -0400
Received: from circe (circe.rz.RWTH-Aachen.DE [134.130.3.36])
 by ms-dienst.rz.rwth-aachen.de
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0J3F00LZCYV58O@ms-dienst.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Aug 2006 23:40:18 +0200 (MEST)
Received: from dustpuppy.kawo2.rwth-aachen.de
 (dustpuppy.kawo2.RWTH-Aachen.DE [134.130.180.5])	by smarthost.rwth-aachen.de
 (8.13.7/8.13.1/1) with ESMTP id k73LeHWE021215	for <netdev@vger.kernel.org>;
 Thu, 03 Aug 2006 23:40:17 +0200
Received: from dustpuppy.kawo2.rwth-aachen.de (localhost [127.0.0.1])
	by dustpuppy.kawo2.rwth-aachen.de (Postfix) with ESMTP id 4620F1FC29E	for
 <netdev@vger.kernel.org>; Thu, 03 Aug 2006 23:40:17 +0200 (CEST)
In-reply-to: <20060803182911.GA8692@2ka.mipt.ru>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Aug 03, 2006 at 08:09:07PM +0200, Arnd Hannemann (arnd@arndnet.de) wrote:
>> Evgeniy Polyakov schrieb:
>>> On Thu, Aug 03, 2006 at 07:16:31PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
>>>>>> then skb_alloc adds a little
>>>>>> (sizeof(struct skb_shared_info)) at the end, and this ends up
>>>>>> in 32k request just for 9k jumbo frame.
>>>>> Strange, why this skb_shared_info cannon be added before first alignment? 
>>>>> And what about smaller frames like 1500, does this driver behave similar 
>>>>> (first align then add)?
>>>> It can be.
>>>> Could attached  (completely untested) patch help?
>>> Actually this patch will not help, this new one could.
>>>
>> I applied the attached pachted. And got this output:
>>
>>> Intel(R) PRO/1000 Network Driver - bufsz 13762
>>> ...

>> I'm a bit puzzled that there are so much allocations. However the patch
>> seems to work. (at least not obviously breaks things for me yet)
> 
> Very strange output actually - comments in the code say that frame size
> can not exceed 0x3f00, but in this log it is much more than 16128 and
> that is after sizeof(struct skb_shared_info) has been removed...
> Could you please remove debug output and run some network stress test in
> parallel with high disk/memory activity to check if that does not break
> your system and watch /proc/slabinfo for 16k and 32k sized pools.

The system seems to be still stable.

>From /proc/slabinfo during netio test:
> size-32768(DMA)        0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
> size-32768            84     89  32768    1    8 : tunables    8    4    0 : slabdata     84     89      0
> size-16384(DMA)        0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0      0
> size-16384           184    188  16384    1    4 : tunables    8    4    0 : slabdata    184    188      0

Netio results:

NETIO - Network Throughput Benchmark, Version 1.26
(C) 1997-2005 Kai Uwe Rommel

TCP connection established.
Packet size  1k bytes:  72320 KByte/s Tx,  86656 KByte/s Rx.
Packet size  2k bytes:  71400 KByte/s Tx,  94703 KByte/s Rx.
Packet size  4k bytes:  71544 KByte/s Tx,  88463 KByte/s Rx.
Packet size  8k bytes:  70392 KByte/s Tx,  92127 KByte/s Rx.
Packet size 16k bytes:  70512 KByte/s Tx,  102607 KByte/s Rx.
Packet size 32k bytes:  71705 KByte/s Tx,  101083 KByte/s Rx.
Done.

Strange ist that receiving seems to be much faster than transmitting.


> -- 
> 	Evgeniy Polyakov

Thanks,
Arnd



