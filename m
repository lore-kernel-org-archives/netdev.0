From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH net-next 1/4] tipc: remove unnecessary variables and conditions
Date: Mon, 16 Dec 2013 22:16:12 +0800
Message-ID: <52AF0B2C.2080900@gmail.com>
References: <1387197631-17240-1-git-send-email-wangweidong1@huawei.com> <1387197631-17240-2-git-send-email-wangweidong1@huawei.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7496@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: erik.hugne@ericsson.com, maloy@donjonn.com, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:43927 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab3LPOPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 09:15:48 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so5528282pbb.2
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 06:15:48 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7496@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013/12/16 21:33, David Laight wrote:
>> From: Wang Weidong
>> Sent: 16 December 2013 12:40
>> We remove a number of unnecessary variables and branches
>> in TIPC. This patch is cosmetic and does not change the
>> operation of TIPC in any way.
>>
> ...
>>   int __tipc_disconnect(struct tipc_port *tp_ptr)
>>   {
>> -	int res;
>> -
>>   	if (tp_ptr->connected) {
>>   		tp_ptr->connected = 0;
>>   		/* let timer expire on it's own to avoid deadlock! */
>>   		tipc_nodesub_unsubscribe(&tp_ptr->subscription);
>> -		res = 0;
>> -	} else {
>> -		res = -ENOTCONN;
>> +		return 0;
>>   	}
>> -	return res;
>> +
>> +	return -ENOTCONN;
>>   }
>
> IMHO better coded as:
>
> 	if (!tp_ptr->connected)
> 		return -ENOTCON;
>
> 	tp_ptr->connected = 0;
> 	/* let timer expire on it's own to avoid deadlock! */
> 	tipc_nodesub_unsubscribe(&tp_ptr->subscription);
> 	return 0;
>
> 	David
>
>
Sure, I will fix it in v2.

Thanks.
	
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
