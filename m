From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Is skb->queue_mapping valid for received packets?
Date: Mon, 13 Jun 2011 22:21:59 -0400
Message-ID: <20110614022159.GL21309@gospo.rdu.redhat.com>
References: <4DF6C091.5050301@candelatech.com> <4DF6C23D.9020704@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753950Ab1FNCWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 22:22:01 -0400
Content-Disposition: inline
In-Reply-To: <4DF6C23D.9020704@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2011 at 07:06:53PM -0700, Ben Greear wrote:
> On 06/13/2011 06:59 PM, Ben Greear wrote:
>>
>> Anyone know if skb->queue_mapping is set for incoming packets, ie to
>> notify which queue they came in on? I can't find it set anywhere,
>> and it appears it is sometimes set to 1 when it should be 0 in
>> my system.
>>
>> Maybe it's never actually set, and I'm just reading some stale
>> data?
>
> Bleh, found it the second I posted.
>
> Seems it's skb_record_rx_queue(), and funny enough, it seems to add +1,
> so if you are trying to bridge pkts from eth0 to eth1 on the same queues,
> looks like you need to subtract one on xmit before finding the txqueue.
>
> Or something like that.
>

Just saw your response after I replied. :-)

The queue_mapping storage is a bit odd, but it generally works.  The
value stored in queue_mapping should be decremented properly in
dev_pick_tx and it should go out of your card with a tx queue that
matches the rx queue.

There were some issues discovered and fixed with bonding last week
related to queue_mapping and I would not be surprised if another stacked
interface like bridging had an issue.

