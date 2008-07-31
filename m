From: Eduardo Habkost <ehabkost@redhat.com>
Subject: Re: [PATCH 2/2] xen-netfront: call netif_start_queue() on
	xennet_open()
Date: Thu, 31 Jul 2008 17:03:24 -0300
Message-ID: <20080731200323.GK7753@blackpad>
References: <1216912546-6971-1-git-send-email-ehabkost@redhat.com> <1216912546-6971-2-git-send-email-ehabkost@redhat.com> <4888A3B7.8060901@goop.org> <4888CA2A.1060509@garzik.org> <4888CC5D.9030800@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org, NetDev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316AbYGaUFU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 16:05:20 -0400
Content-Disposition: inline
In-Reply-To: <4888CC5D.9030800@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 11:39:25AM -0700, Jeremy Fitzhardinge wrote:
> Jeff Garzik wrote:
>> Jeremy Fitzhardinge wrote:
>>> Eduardo Habkost wrote:
>>>> xen-netfront was waking the queue before calling netif_start_queue(),
>>>> triggering the BUG_ON() on __netif_schedule().
>>>>
>>>> Signed-off-by: Eduardo Habkost <ehabkost@redhat.com>
>>>>   
>>> Ok,
>>> Acked-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
>>>
>>> but Ingo, do you want to pick this up?  You're gathering a collection of 
>>> these patches anyway, or should we kick it over to Dave/Jeff?
>>>
>>>    J
>>>
>>>> ---
>>>>  drivers/net/xen-netfront.c |    2 +-
>>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>>>> index 902bbe7..c749bdb 100644
>>>> --- a/drivers/net/xen-netfront.c
>>>> +++ b/drivers/net/xen-netfront.c
>>>> @@ -329,7 +329,7 @@ static int xennet_open(struct net_device *dev)
>>>>      }
>>>>      spin_unlock_bh(&np->rx_lock);
>>>>  -    xennet_maybe_wake_tx(dev);
>>>> +    netif_start_queue(dev);
>>
>> This is clearly a net driver change, it should go this way... 
>
> OK, all your's.

I didn't find it on any git repository. Is it queued somewhere? If not,
should I resend?

-- 
Eduardo
