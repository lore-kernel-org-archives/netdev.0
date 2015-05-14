From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: fix a neigh entry leak issue
Date: Thu, 14 May 2015 12:17:51 -0400 (EDT)
Message-ID: <20150514.121751.1894390478989103661.davem@davemloft.net>
References: <1431587190-28901-1-git-send-email-ying.xue@windriver.com>
	<1431612382.27831.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, jiri@resnulli.us, sfeldma@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933239AbbENQR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 12:17:56 -0400
In-Reply-To: <1431612382.27831.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 May 2015 07:06:22 -0700

> On Thu, 2015-05-14 at 15:06 +0800, Ying Xue wrote:
>> Once we get a neighbour through looking up arp cache or creating a
>> new one in rocker_port_ipv4_resolve(), the neighbour's refcount is
>> already taken. But we don't put the refcount again after it's used,
>> which make the neighbour entry leaked.
>> 
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> ---
>>  drivers/net/ethernet/rocker/rocker.c |    1 +
>>  1 file changed, 1 insertion(+)
>> 
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> index 1fc006b..7504540 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -3053,6 +3053,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
>>  	else
>>  		neigh_event_send(n, NULL);
>>  
>> +	neigh_release(n);
>>  	return err;
>>  }
>>  
> 
> I do not think this fix is complete.
> 
> neigh_create() can return an error, and we'll crash.

Correct, neigh_create() return values must be checked with IS_ERR().
