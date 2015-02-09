From: Josh Hunt <johunt@akamai.com>
Subject: Re: nft hash set expansion problem
Date: Mon, 09 Feb 2015 08:44:32 -0600
Message-ID: <54D8C7D0.9030803@akamai.com>
References: <54D7BB53.2050203@akamai.com> <54D7E677.5050708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:60159 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750928AbbBIOoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 09:44:34 -0500
In-Reply-To: <54D7E677.5050708@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2015 04:43 PM, Daniel Borkmann wrote:
> On 02/08/2015 08:38 PM, Josh Hunt wrote:
>> Nft hash sets are unable to expand past the initial # of buckets. This
>> is b/c nft hash sets don't define the max_shift parameter and so
>> rht_grow_above_75():
> ...
>> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
>> index e96fc00..2c51617 100644
>> --- a/lib/rhashtable.c
>> +++ b/lib/rhashtable.c
>> @@ -250,7 +250,7 @@ bool rht_grow_above_75(const struct rhashtable
>> *ht, size_t new_size)
>>   {
>>          /* Expand table when exceeding 75% load */
>>          return atomic_read(&ht->nelems) > (new_size / 4 * 3) &&
>> -              (ht->p.max_shift && atomic_read(&ht->shift) <
>> ht->p.max_shift);
>> +              (ht->p.max_shift ? atomic_read(&ht->shift) <
>> ht->p.max_shift : 1);
>>   }
>>   EXPORT_SYMBOL_GPL(rht_grow_above_75);
>
> This seems not correct as we want to have an upper limit for
> rhashtable expansions. It's better to define a max_shift for
> nftables, instead.

Thanks Daniel that's what I wanted to know. I'll fix this on the 
nft_hash side.

Josh
