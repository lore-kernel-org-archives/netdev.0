From: "Denis V. Lunev" <den@parallels.com>
Subject: Re: [PATCH 1/1] ipv4: fix definition of FIB_TABLE_HASHSZ
Date: Wed, 13 Mar 2013 13:27:55 +0400
Message-ID: <5140469B.3050708@parallels.com>
References: <1363164218-16316-1-git-send-email-den@openvz.org> <514043CE.2080607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, Tingwei Liu <tingw.liu@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:43332 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab3CMJ2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 05:28:02 -0400
In-Reply-To: <514043CE.2080607@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/13 1:15 PM, Li Wei wrote:
> On 03/13/2013 04:43 PM, Denis V. Lunev wrote:
>> From: "Denis V. Lunev" <den@openvz.org>
>>
>> a long time ago by the commit
>>
>>    commit 93456b6d7753def8760b423ac6b986eb9d5a4a95
>>    Author: Denis V. Lunev <den@openvz.org>
>>    Date:   Thu Jan 10 03:23:38 2008 -0800
>>
>>      [IPV4]: Unify access to the routing tables.
>>
>> the defenition of FIB_HASH_TABLE size has obtained wrong dependency:
>> it should depend upon CONFIG_IP_MULTIPLE_TABLES (as was in the original
>> code) but it was depended from CONFIG_IP_ROUTE_MULTIPATH
>>
>> This patch returns the situation to the original state.
>>
>> The problem was spotted by Tingwei Liu.
>>
>> Signed-off-by: Denis V. Lunev <den@openvz.org>
>> CC: Tingwei Liu <tingw.liu@gmail.com>
>> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>> ---
>>   include/net/ip_fib.h |   12 +++++-------
>>   1 files changed, 5 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
>> index 9497be1..3b12d5c 100644
>> --- a/include/net/ip_fib.h
>> +++ b/include/net/ip_fib.h
>> @@ -152,18 +152,16 @@ struct fib_result_nl {
>>   };
>>   
>>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>> -
>>   #define FIB_RES_NH(res)		((res).fi->fib_nh[(res).nh_sel])
>> -
>> -#define FIB_TABLE_HASHSZ 2
>> -
>>   #else /* CONFIG_IP_ROUTE_MULTIPATH */
>> -
>>   #define FIB_RES_NH(res)		((res).fi->fib_nh[0])
>> +#endif /* CONFIG_IP_ROUTE_MULTIPATH */
>>   
>> +#ifdef CONFIG_IP_ROUTE_MULTIPLE_TABLES
>> +#define FIB_TABLE_HASHSZ 2
>> +#else
>>   #define FIB_TABLE_HASHSZ 256
>> -
>> -#endif /* CONFIG_IP_ROUTE_MULTIPATH */
>> +#endif
> With CONFIG_IP_ROUTE_MULTIPLE_TABLES defined we use a smaller FIB_TABLE_HASHSZ ?
>
> Thanks.
pfff :((( I have mistaken once again. Thank you for pointing this out. 
I'll resend the patch.


>>   
>>   extern __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
>>   
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
