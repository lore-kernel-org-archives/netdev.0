From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 07 Jan 2010 10:05:37 -0500
Message-ID: <4B45F841.8030407@majjas.com>
References: <20100106072208.GA6711@ff.dom.local> <4B44E952.5000804@majjas.com>
 <20100106131044.25b4e500@nehalam> <4B451C31.3000309@majjas.com>
 <4B454A16.3030909@majjas.com> <4B455C62.6030504@majjas.com>
 <20100106205343.5460d658@nehalam> <4B4571D5.30002@majjas.com>
 <4B457711.1040008@majjas.com> <4B458B36.6050509@majjas.com>
 <20100107074756.GB6258@ff.dom.local> <4B459368.2000503@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta3.srv.hcvlny.cv.net ([167.206.4.198]:49837 "EHLO
	mta3.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003Ab0AGPGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 10:06:14 -0500
In-reply-to: <4B459368.2000503@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/7/2010 2:55 AM, Michael Breuer wrote:
> On 1/7/2010 2:47 AM, Jarek Poplawski wrote:
>> On Thu, Jan 07, 2010 at 02:20:22AM -0500, Michael Breuer wrote:
>>> ...
>>> Reapplied a couple of earlier patches - still can't do jumbo frames, 
>>> but
>>> the rx errors are gone and speed has improved. Too early to assure that
>>> it's stable.
>>>
>>> Patches that seem to fix the rx drops (all from Stephen):
>>> 1) Patch change to tx_init
>>> 2) Patch to lock netif_device_detach
>>> 3) Patch to sky2_tx_complete to add netif_device_present test
>>> Also in the mix: Jarek's alternative 2
>> BTW, the main difference between alt. 1 and 2 is error notification:
>> alternative 2 doesn't hide some (most) of drops, so, dependending on
>> app, there might be more and faster retransmits. (I don't know what
>> apps used by you (other than dhcp) can depend so much on this.)
>>
> Unless I misread the code, I think that in some cases e skb is 
> actually freed if the cfq (among others perhaps) scheduler returns an 
> error on enqueue (flow control perhaps).  Thus with alternative 1, it 
> is possible that the skb is acted upon after being freed - this would 
> be consistent with the DMAR errors I saw.
>
>>> With this set and mtu=1500 all seems good - decent if not stellar
>>> throughput; no logged errors; no reported packet loss. As before, will
>>> leave running and see if anything falls apart.
>> Good news!
>>
>> Jarek P.
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe 
>> linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
Bad news - crashed about an hour after I wrote this email - under load - 
same crash as before. Network watchdog... lots of attempts to reset the 
adapter... then hw watchdog rebooted the system.
