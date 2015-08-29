From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by walking
 all the percpu data at once
Date: Sat, 29 Aug 2015 13:22:38 +0530
Message-ID: <55E164C6.3000702@linux.vnet.ibm.com>
References: <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20150827.113823.214019265460582055.davem@davemloft.net> <55E00238.10909@linux.vnet.ibm.com> <20150828.112413.424099339331017970.davem@davemloft.net> <20150829025715.GA5546@linux.vnet.ibm.com> <1440818791.8932.128.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:42424 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbbH2Hvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 03:51:35 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Sat, 29 Aug 2015 17:51:32 +1000
In-Reply-To: <1440818791.8932.128.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2015 08:56 AM, Eric Dumazet wrote:
> On Sat, 2015-08-29 at 08:27 +0530, Raghavendra K T wrote:
>>
>>   	/* Use put_unaligned() because stats may not be aligned for u64. */
>>   	put_unaligned(items, &stats[0]);
>
>
>>   	for (i = 1; i < items; i++)
>> -		put_unaligned(snmp_fold_field64(mib, i, syncpoff), &stats[i]);
>> +		put_unaligned(buff[i], &stats[i]);
>>
>
> I believe Joe suggested following code instead :
>
> buff[0] = items;
> memcpy(stats, buff, items * sizeof(u64));

Thanks. Sure, will use this.

(I missed that. I thought that it was applicable only when we have
aligned data,and for power, put_aunaligned was not a nop unlike intel).

>
> Also please move buff[] array into __snmp6_fill_stats64() to make it
> clear it is used in a 'leaf' function.

Correct.

>
> (even if calling memcpy()/memset() makes it not a leaf function)
>
