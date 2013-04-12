From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tuntap: fix error return code in tun_set_iff()
Date: Fri, 12 Apr 2013 15:00:36 -0400 (EDT)
Message-ID: <20130412.150036.858312621256997624.davem@davemloft.net>
References: <CAPgLHd9WrbgeYH9pw81kQn9sv=On8e399qAOth6MWprF6PS5pg@mail.gmail.com>
	<1365774560.4459.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, jasowang@redhat.com, mst@redhat.com,
	edumazet@google.com, nhorman@tuxdriver.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3DLTAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 15:00:38 -0400
In-Reply-To: <1365774560.4459.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Apr 2013 06:49:20 -0700

> On Fri, 2013-04-12 at 21:17 +0800, Wei Yongjun wrote:
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> 
>> Fix to return a negative error code from the error handling
>> case instead of 0, as returned elsewhere in this function.
>> 
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> ---
>>  drivers/net/tun.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index b7c457a..729ed53 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1594,7 +1594,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>  
>>  		if (tun->flags & TUN_TAP_MQ &&
>>  		    (tun->numqueues + tun->numdisabled > 1))
>> -			return err;
>> +			return -EBUSY;
>>  	}
>>  	else {
>>  		char *name;
> 
> Bug added in linux-3.8 , commit 4008e97f866db665 
> ("tuntap: fix ambigious multiqueue API")
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
