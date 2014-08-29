From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next v2] lib/rhashtable: allow users to set the minimum
 shifts of shrinking
Date: Fri, 29 Aug 2014 18:08:09 +0800
Message-ID: <54005109.3070904@windriver.com>
References: <1409190324-27828-1-git-send-email-ying.xue@windriver.com> <20140829093107.GA3563@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43651 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaH2KIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 06:08:46 -0400
In-Reply-To: <20140829093107.GA3563@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2014 05:31 PM, Thomas Graf wrote:
> On 08/28/14 at 09:45am, Ying Xue wrote:
>> Now the resizeable hash table size is allowed to shrink a too smaller
>> size - HASH_MIN_SIZE(4) although users initially specify a rather big
>> size when table is created. Especially when the number of objects
>> saved in the table keeps a small value in comparison with the initial
>> setting of table size during a quite long time, lots of actions of
>> expanding and shrinking are involved with objects being inserted or
> 
> Can you work on this part of the commit message a bit? I know what
> you want to say but it's not very clear from the text.
> 

OK. I will revise it.

>> removed from table. However, as synchronize_rcu() has to be called
>> during expanding and shrinking, these unnecessary actions would
>> seriously hit users' performance.
>>
>> Therefore, we should permit users to set the minimum table size
>> through configuring the minimum of number of shifts when table is
>> created according to users specific requirement.
>>
>> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
>> index a2c7881..85a4ac2 100644
>> --- a/lib/rhashtable.c
>> +++ b/lib/rhashtable.c
>> @@ -566,8 +568,13 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
>>  	    (!params->key_len && !params->obj_hashfn))
>>  		return -EINVAL;
>>  
>> +	if (params->min_shift)
>> +		params->min_shift = max(params->min_shift, min_shift);
>> +	else
>> +		params->min_shift = min_shift;
>> +
> 
> You can simplify all of the above to just:
> 
>   params->min_shift = max(params->min_shift, ilog2(HASH_MIN_SIZE));
> 
> 

Oops! when I created the code, I wrongly deemed params->min_shift as a
pointer so that the code became so complex. Thanks, I will change it
with your good advice.

Regards,
Ying
