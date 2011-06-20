From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 10/11] mv643xx_eth: enable transmit time stamping.
Date: Mon, 20 Jun 2011 13:55:12 -0700 (PDT)
Message-ID: <20110620.135512.26659219089505445.davem@davemloft.net>
References: <cover.1308556146.git.richard.cochran@omicron.at>
	<96e6a2899b55ac1272cee8ce63e2549e24a10386.1308556146.git.richard.cochran@omicron.at>
	<20110620163524.GD994@wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284Ab1FTUzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:55:15 -0400
In-Reply-To: <20110620163524.GD994@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 20 Jun 2011 18:35:24 +0200

> On Mon, Jun 20, 2011 at 09:51:32AM +0200, Richard Cochran wrote:
> 
>> This patch enables software (and phy device) transmit time stamping.
>> Compile tested only.
>> 
>> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
>> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
>> ---
>>  drivers/net/mv643xx_eth.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>> 
>> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
>> index 1b7d2c1..3671714 100644
>> --- a/drivers/net/mv643xx_eth.c
>> +++ b/drivers/net/mv643xx_eth.c
>> @@ -847,6 +847,8 @@ no_csum:
>>  	/* clear TX_END status */
>>  	mp->work_tx_end &= ~(1 << txq->index);
>>  
>> +	skb_tx_timestamp(skb);
>> +
>>  	/* ensure all descriptors are written before poking hardware */
>>  	wmb();
>>  	txq_enable(txq);
> 
> This only timestamps the skb _after_ writing the final (cmd_sts) HW TX
> descriptor word, and so if your previous patch is correct (which I don't
> think it is), this would be buggy as well.

Agreed.

I'll apply the other patches and leave this one for now.
