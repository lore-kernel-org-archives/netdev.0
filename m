From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next] 8139cp: remove a won't occurred BUG_ON
Date: Mon, 27 Jan 2014 09:14:49 +0800
Message-ID: <52E5B309.1080402@huawei.com>
References: <52E4C862.9050103@huawei.com> <1390778623.2735.69.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:44259 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121AbaA0BQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 20:16:29 -0500
In-Reply-To: <1390778623.2735.69.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/27 7:23, Ben Hutchings wrote:
> On Sun, 2014-01-26 at 16:33 +0800, Wang Weidong wrote:
>> when variable i go to the BUG_ON the value is equal to the CP_NUM_STATS,
>> so the BUG_ON won't occur, so remove it
> 
> We hope that every BUG_ON() does not occur, but that doesn't mean they
> should be removed.  This check is meant to catch mistakes when adding
> new statistics.
> 
> Ben.
> 
Hi, Ben.

Yeah, but I think If someone would add new statistics, he should take into account
it instead the BUG_ON helper.

And that, I found some other drivers' get_ethtool_stats no have BUG_ON. Should we
add the BUG_ON into them?

Regards,
Wang

>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>  drivers/net/ethernet/realtek/8139cp.c | 1 -
>>  1 file changed, 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
>> index 737c1a8..b70e184 100644
>> --- a/drivers/net/ethernet/realtek/8139cp.c
>> +++ b/drivers/net/ethernet/realtek/8139cp.c
>> @@ -1585,7 +1585,6 @@ static void cp_get_ethtool_stats (struct net_device *dev,
>>  	tmp_stats[i++] = le16_to_cpu(nic_stats->tx_abort);
>>  	tmp_stats[i++] = le16_to_cpu(nic_stats->tx_underrun);
>>  	tmp_stats[i++] = cp->cp_stats.rx_frags;
>> -	BUG_ON(i != CP_NUM_STATS);
>>  
>>  	dma_free_coherent(&cp->pdev->dev, sizeof(*nic_stats), nic_stats, dma);
>>  }
> 
