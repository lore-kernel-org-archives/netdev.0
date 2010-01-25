From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH] ixgbe: only process one ixgbe_watchdog_task
 at a time.
Date: Sun, 24 Jan 2010 22:24:18 -0800
Message-ID: <4B5D3912.9030802@intel.com>
References: <20100123101644.12479.40925.stgit@localhost.localdomain> <20100123.021941.134608202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:50327 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193Ab0AYGYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 01:24:20 -0500
In-Reply-To: <20100123.021941.134608202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat, 23 Jan 2010 02:17:31 -0800
>
>   
>> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
>> index 8d206f7..cbc62db 100644
>> --- a/drivers/net/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>> @@ -5013,7 +5013,8 @@ static void ixgbe_watchdog_task(struct work_struct *work)
>>  	struct ixgbe_ring *tx_ring;
>>  	int some_tx_pending = 0;
>>  
>> -	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
>> +	while (test_and_set_bit(__IXGBE_IN_WATCHDOG_TASK, &adapter->state))
>> +		msleep(1);
>>  
>>     
>
> I think using a mutex() would better serve you here.
>   
I'll make this change and resubmit. Thanks.
