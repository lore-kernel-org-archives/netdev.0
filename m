From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Wed, 16 Jan 2008 12:19:51 +0900
Message-ID: <478D77D7.60703@miraclelinux.com>
References: <20080115090532.GB1696@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:48845 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754293AbYAPDVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 22:21:48 -0500
In-Reply-To: <20080115090532.GB1696@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is supposing a case that bond_mii_monitor() is invoked in 
bond_open(), and after that, 0 is set to miimon via sysfs (see same place on 
other monitors).
Though message in bonding_store_miimon() says miimon value 1-INT_MAX rejected, 
but it looks like 0 can be accepted and monitor must be stopped in that case.

>> Change code not to rearm bond_mii_monitor() when value 0 is set for miimon.
>>
>> Signed-off-by: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
>> ---
>>  drivers/net/bonding/bond_main.c |    3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2388,7 +2388,8 @@ void bond_mii_monitor(struct work_struct
>>  
>>  	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
>>  	read_unlock(&bond->lock);
>> -	queue_delayed_work(bond->wq, &bond->mii_work, delay);
>> +	if (bond->params.miimon)
>> +		queue_delayed_work(bond->wq, &bond->mii_work, delay);
>>  }
> 
> Maybe I miss something, but is this bond_mii_monitor() function
> supposed to be ever started if (!bond->params.miimon)? (IOW: isn't
> it enough to control this where the parameter is changed only?)
> 
> Regards,
> Jarek P.

--
Makito SHIOKAWA
MIRACLE LINUX CORPORATION
