From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next v2 1/2] tipc: make the code look more better
Date: Wed, 25 Dec 2013 10:52:53 +0800
Message-ID: <52BA4885.8080900@huawei.com>
References: <1387937473-5804-1-git-send-email-wangweidong1@huawei.com> <1387937473-5804-2-git-send-email-wangweidong1@huawei.com> <52BA4622.3060702@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>
To: Ying Xue <ying.xue@windriver.com>,
	"Stephens, Allan" <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:54364 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab3LYCxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 21:53:10 -0500
In-Reply-To: <52BA4622.3060702@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/25 10:42, Ying Xue wrote:
> On 12/25/2013 10:11 AM, Wang Weidong wrote:
>> In commit 0cee6bbe06f ("tipc: remove unnecessary variables and conditions")
>> didn't make the code look best. So fix it. This patch is cosmetic
>> and does not change the operation of TIPC in any way.
>>
> 
> I cannot see what value the patch does provide.
> 
> Actually the original logic seems better understandable for us because
> it immediately lets us know how to do if "tp_ptr->connected" is true.
> Instead the patch has a little negative effect on performance because
> "tp_ptr->connected" is true in most time.
> 
Sure, You are right. So just ignore it.

Thanks,
Wang

> Regards,
> Ying
> 
>> Suggested-by: David Laight <David.Laight@ACULAB.COM>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>  net/tipc/port.c | 13 ++++++-------
>>  1 file changed, 6 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/tipc/port.c b/net/tipc/port.c
>> index 5fd4c8c..ee81be0 100644
>> --- a/net/tipc/port.c
>> +++ b/net/tipc/port.c
>> @@ -832,14 +832,13 @@ exit:
>>   */
>>  int __tipc_disconnect(struct tipc_port *tp_ptr)
>>  {
>> -	if (tp_ptr->connected) {
>> -		tp_ptr->connected = 0;
>> -		/* let timer expire on it's own to avoid deadlock! */
>> -		tipc_nodesub_unsubscribe(&tp_ptr->subscription);
>> -		return 0;
>> -	}
>> +	if (!tp_ptr->connected)
>> +		return -ENOTCONN;
>>  
>> -	return -ENOTCONN;
>> +	tp_ptr->connected = 0;
>> +	/* let timer expire on it's own to avoid deadlock! */
>> +	tipc_nodesub_unsubscribe(&tp_ptr->subscription);
>> +	return 0;
>>  }
>>  
>>  /*
>>
> 
> 
> .
> 
