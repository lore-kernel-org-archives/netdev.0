From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/4] net: bcmgenet: add support for ethtool tx-frames
Date: Mon, 21 Apr 2014 12:55:12 -0700
Message-ID: <CAGVrzcaKQdmfvjJdCeDpa17fTxLBE_i-rVtARP5-bSD6bXQv7g@mail.gmail.com>
References: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
 <1398095124-5411-3-git-send-email-f.fainelli@gmail.com> <20140421.151720.1704047020816170974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:41473 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaDUTzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 15:55:53 -0400
Received: by mail-qc0-f182.google.com with SMTP id e16so4482393qcx.27
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 12:55:52 -0700 (PDT)
In-Reply-To: <20140421.151720.1704047020816170974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-21 12:17 GMT-07:00 David Miller <davem@davemloft.net>:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Mon, 21 Apr 2014 08:45:22 -0700
>
>> Configuring the ethtool tx-frames property, which translates into N
>> packets before a TX interrupt is the simplest configuration scheme
>> because it requires no locking neither at the softare nor hardware
>> level, and is completely indepedent from the link speed. Since ethtool
>> does not allow per-tx queue coalescing parameters, we apply the same
>> setting to any transmit queue.
>>
>> We can no longer enable the BDONE/PDONE interrupts as those would fire
>> for each packet/buffer received, which would defeat the MBDONE interrupt
>> purpose. The MBDONE interrupt is guaranteed to correspond to a
>> PDONE/BDONE interrupt when the threshold is set to 1.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>
> Does the MBDONE scheme have a timeout?
>
> For example if you ask for a MBDONE setting where N=4, if only 2 packets
> arrive will you get an interrupt or will it wait for 2 more to arrive
> no matter what?

There is no configurable timeout for the transmit DMA engine (receive
does have one), but we do get a ring empty interrupt as soon as the
transmit path has completed the packets, so the MBDONE interrupt cause
always makes us run the TX reclaim logic.

>
> If a timeout doesn't exist, you cannot use this.
>
> I'm very pessimistic because I see no inspection of the timeout
> parameter passed into the ethtool commands.  And in fact if the
> timeout does exist, and is fixed, you should error on non-zero
> values specified in the timeout field(s).
>
> So no matter what the situation is wrt. timeouts, this series needs
> either change or be completely tossed.

I will rework it, thanks for your feedback.
-- 
Florian
