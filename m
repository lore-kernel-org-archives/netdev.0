From: Ben Greear <greearb@candelatech.com>
Subject: Re: Is skb->queue_mapping valid for received packets?
Date: Mon, 13 Jun 2011 19:28:37 -0700
Message-ID: <4DF6C755.90402@candelatech.com>
References: <4DF6C091.5050301@candelatech.com> <4DF6C23D.9020704@candelatech.com> <20110614022159.GL21309@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47101 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349Ab1FNC2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 22:28:40 -0400
In-Reply-To: <20110614022159.GL21309@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2011 07:21 PM, Andy Gospodarek wrote:
> On Mon, Jun 13, 2011 at 07:06:53PM -0700, Ben Greear wrote:
>> On 06/13/2011 06:59 PM, Ben Greear wrote:
>>>
>>> Anyone know if skb->queue_mapping is set for incoming packets, ie to
>>> notify which queue they came in on? I can't find it set anywhere,
>>> and it appears it is sometimes set to 1 when it should be 0 in
>>> my system.
>>>
>>> Maybe it's never actually set, and I'm just reading some stale
>>> data?
>>
>> Bleh, found it the second I posted.
>>
>> Seems it's skb_record_rx_queue(), and funny enough, it seems to add +1,
>> so if you are trying to bridge pkts from eth0 to eth1 on the same queues,
>> looks like you need to subtract one on xmit before finding the txqueue.
>>
>> Or something like that.
>>
>
> Just saw your response after I replied. :-)
>
> The queue_mapping storage is a bit odd, but it generally works.  The
> value stored in queue_mapping should be decremented properly in
> dev_pick_tx and it should go out of your card with a tx queue that
> matches the rx queue.
>
> There were some issues discovered and fixed with bonding last week
> related to queue_mapping and I would not be surprised if another stacked
> interface like bridging had an issue.

I feel a bit better that I'm not the only one who got
confused on this :)

A quick grep didn't show any queue mgt in bridging code, but
I didn't look closely and might have grep'd the wrong thing.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
