From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] xen-netfront: call netif_start_queue() on xennet_open()
Date: Thu, 24 Jul 2008 14:30:02 -0400
Message-ID: <4888CA2A.1060509@garzik.org>
References: <1216912546-6971-1-git-send-email-ehabkost@redhat.com> <1216912546-6971-2-git-send-email-ehabkost@redhat.com> <4888A3B7.8060901@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eduardo Habkost <ehabkost@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org, NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754476AbYGXSay@vger.kernel.org>
In-Reply-To: <4888A3B7.8060901@goop.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> Eduardo Habkost wrote:
>> xen-netfront was waking the queue before calling netif_start_queue(),
>> triggering the BUG_ON() on __netif_schedule().
>>
>> Signed-off-by: Eduardo Habkost <ehabkost@redhat.com>
>>   
> Ok,
> Acked-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> 
> but Ingo, do you want to pick this up?  You're gathering a collection of 
> these patches anyway, or should we kick it over to Dave/Jeff?
> 
>    J
> 
>> ---
>>  drivers/net/xen-netfront.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>> index 902bbe7..c749bdb 100644
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -329,7 +329,7 @@ static int xennet_open(struct net_device *dev)
>>      }
>>      spin_unlock_bh(&np->rx_lock);
>>  
>> -    xennet_maybe_wake_tx(dev);
>> +    netif_start_queue(dev);

This is clearly a net driver change, it should go this way...

	Jeff
