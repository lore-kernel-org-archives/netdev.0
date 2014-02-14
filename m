From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next 4/4] sch_netem: replace spin_(un)lock_bh with
 sch_tree_(un)lock
Date: Fri, 14 Feb 2014 09:32:24 +0800
Message-ID: <52FD7228.3010804@huawei.com>
References: <1392173895-5012-1-git-send-email-yangyingliang@huawei.com>	<1392173895-5012-5-git-send-email-yangyingliang@huawei.com> <20140213.174606.334208738068503053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:3595 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbaBNBcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 20:32:46 -0500
In-Reply-To: <20140213.174606.334208738068503053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/14 6:46, David Miller wrote:
> From: Yang Yingliang <yangyingliang@huawei.com>
> Date: Wed, 12 Feb 2014 10:58:15 +0800
> 
>> spin_(un)lock_bh(root_lock) is same as sch_tree_(un)lock.
>>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>  ...
>> @@ -684,11 +683,9 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
>>  	for (i = 0; i < n; i++)
>>  		d->table[i] = data[i];
>>  
>> -	root_lock = qdisc_root_sleeping_lock(sch);
>> -
>> -	spin_lock_bh(root_lock);
>> +	sch_tree_lock(sch);
>>  	swap(q->delay_dist, d);
>> -	spin_unlock_bh(root_lock);
>> +	sch_tree_unlock(sch);
>>  
>>  	dist_free(d);
>>  	return 0;
> 
> This is more expensive than the existing code.
> 
> We will now calculate qdisc_root_sleeping_lock() twice which is at
> least two pointer dereferences each.
> 
> Without explicitly open-coding this, the compiler cannot cache the
> result, because the spin lock operations have memory barriers (if
> implemented inline) or are considered to potentially modify all memory
> (if implemented as function calls).
> 
> 
OK, thanks!
I'll send v2 without this patch.
