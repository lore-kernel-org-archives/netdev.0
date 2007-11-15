From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH, take2] netfilter : struct xt_table_info diet
Date: Thu, 15 Nov 2007 16:58:43 +0100
Message-ID: <473C6CB3.6040803@trash.net>
References: <473B6D88.4010701@cosmosbay.com>	<473C3E92.30004@trash.net> <20071115164516.ced96a9e.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48866 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758062AbXKOP6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 10:58:47 -0500
In-Reply-To: <20071115164516.ced96a9e.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Thu, 15 Nov 2007 13:41:54 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>> +#define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
>>> +			  + nr_cpu_ids * sizeof(char *))
>>
>>>  	/* overflow check */
>>> -	if (tmp.size >= (INT_MAX - sizeof(struct xt_table_info)) / NR_CPUS -
>>> -			SMP_CACHE_BYTES)
>>> +	if (tmp.size >= INT_MAX / num_possible_cpus())
>>>  		return -ENOMEM;
>> We need to make sure offsetof(struct xt_table_info, entries) +
>> nr_cpu_ids * sizeof(char *) doesn't overflow, so why doesn't it
>> use nr_cpu_ids here as well?
>>
> 
> nr_cpu_ids is <= NR_CPUS, so XT_TABLE_INFO_SZ cannot overflow


Yes, but nr_cpu_ids is >= num_possible_cpus, which is what we're
using with your patch.

> The 'overflow check' we do here is in fact not very usefull now
> that we dont need to multiply tmp.size by NR_CPUS and potentially
> overflow the result.
> 
> We can delete the test, because kmalloc()/vmalloc() will probably
> fail gracefully if we ask too much memory.


You're right, I'll remove it. Thanks.
