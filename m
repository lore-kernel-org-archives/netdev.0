From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] ipmr: delete redundant variable
Date: Wed, 23 Jul 2008 17:35:18 +0800
Message-ID: <4886FB56.20905@cn.fujitsu.com>
References: <48868D54.6050701@cn.fujitsu.com> <200807231003.05848.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63993 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752566AbYGWJg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 05:36:56 -0400
In-Reply-To: <200807231003.05848.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Oeser said the following on 2008-7-23 16:03:
> Hi Wang Chen,
> 
> Wang Chen schrieb:
>> *v can be removed as this patch showing.
> 
> You are right, but did you check the resulting asm?
>  
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>> ---
>> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
>> index c519b8d..6e715c7 100644
>> --- a/net/ipv4/ipmr.c
>> +++ b/net/ipv4/ipmr.c
>> @@ -1129,9 +1128,9 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
>>  
>>  	if (event != NETDEV_UNREGISTER)
>>  		return NOTIFY_DONE;
>> -	v=&vif_table[0];
>> -	for (ct=0;ct<maxvif;ct++,v++) {
>> -		if (v->dev==dev)
> 
> This is ptr += sizeof(vif_table[0])
> 
>> +
>> +	for (ct = 0; ct < maxvif; ct++) {
>> +		if (vif_table[ct].dev == dev)
> 
> This is ptr + ct * sizeof(vif_table[0])
> 
> On architectures, where the second address variant is
> not supported, it spills a register with the multiply/shift.
> 

But "accessing entry of table by index" is always allowed,
right?
If the complier makes such pointer which spills a register with
the multiply/shift, the simple code as following is bug too:
i = table[100].field;
But it shouldn't, right :)

> But the second variant could be easily auto vectorized, 
> if we had no if.
> 
> So just check the asm on a CISC and a RISC architecture 
> with a cross compile, before you transform these patterns.
> 
> Maybe GCC even transform one into the other these days :-)

