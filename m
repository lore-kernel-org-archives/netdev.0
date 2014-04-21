From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] net: bcmgenet: add support for ethtool
 tx-frames
Date: Mon, 21 Apr 2014 15:59:52 -0400 (EDT)
Message-ID: <20140421.155952.1239791110163851437.davem@davemloft.net>
References: <1398095124-5411-3-git-send-email-f.fainelli@gmail.com>
	<20140421.151720.1704047020816170974.davem@davemloft.net>
	<CAGVrzcaKQdmfvjJdCeDpa17fTxLBE_i-rVtARP5-bSD6bXQv7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaDUT77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 15:59:59 -0400
In-Reply-To: <CAGVrzcaKQdmfvjJdCeDpa17fTxLBE_i-rVtARP5-bSD6bXQv7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 21 Apr 2014 12:55:12 -0700

> 2014-04-21 12:17 GMT-07:00 David Miller <davem@davemloft.net>:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Mon, 21 Apr 2014 08:45:22 -0700
>>
>>> Configuring the ethtool tx-frames property, which translates into N
>>> packets before a TX interrupt is the simplest configuration scheme
>>> because it requires no locking neither at the softare nor hardware
>>> level, and is completely indepedent from the link speed. Since ethtool
>>> does not allow per-tx queue coalescing parameters, we apply the same
>>> setting to any transmit queue.
>>>
>>> We can no longer enable the BDONE/PDONE interrupts as those would fire
>>> for each packet/buffer received, which would defeat the MBDONE interrupt
>>> purpose. The MBDONE interrupt is guaranteed to correspond to a
>>> PDONE/BDONE interrupt when the threshold is set to 1.
>>>
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>
>> Does the MBDONE scheme have a timeout?
>>
>> For example if you ask for a MBDONE setting where N=4, if only 2 packets
>> arrive will you get an interrupt or will it wait for 2 more to arrive
>> no matter what?
> 
> There is no configurable timeout for the transmit DMA engine (receive
> does have one), but we do get a ring empty interrupt as soon as the
> transmit path has completed the packets, so the MBDONE interrupt cause
> always makes us run the TX reclaim logic.

This latency may be too large for TCP.

In particular things like TCP Small Queues need timely feedback for
transmitted packets.
