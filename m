From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH 05/15] RDS: increase size of hash-table to 8K
Date: Wed, 23 Sep 2015 11:06:16 -0700
Message-ID: <5602EA18.7080404@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
 <1442703892-26692-6-git-send-email-santosh.shilimkar@oracle.com>
 <20150921.160527.1218605543469993281.davem@davemloft.net>
 <560098ED.7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560098ED.7@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On 9/21/2015 4:55 PM, santosh shilimkar wrote:
> On 9/21/2015 4:05 PM, David Miller wrote:
>> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>> Date: Sat, 19 Sep 2015 19:04:42 -0400
>>
>>> Even with per bucket locking scheme, in a massive parallel
>>> system with active rds sockets which could be in excess of multiple
>>> of 10K, rds_bin_lookup() workload is siginificant because of smaller
>>> hashtable size.
>>>
>>> With some tests, it was found that we get modest but still nice
>>> reduction in rds_bind_lookup with bigger bucket.
>>>
>>>     Hashtable    Baseline(1k)    Delta
>>>     2048:        8.28%         -2.45%
>>>     4096:        8.28%        -4.60%
>>>     8192:        8.28%        -6.46%
>>>     16384:        8.28%        -6.75%
>>>
>>> Based on the data, we set 8K as the bind hash-table size.
>>>
>>> Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
>>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>>
>> Like others I would strongly prefer that you use a dynamically sized
>> hash table.
>>
>> Eating 8k just because a module just happened to get loaded is really
>> not appropriate.
>>
>> And there are many other places that use such a scheme, one example is
>> the AF_NETLINK socket hash table.
>
> OK. Thanks for AF_NETLINK pointer. I will look it up.
>
I will follow your advice on resizable hash table usage. It seems
to be neat and fits well. But I want to make sure that the
implementation works for all the workloads so it will take
some time. Hopefully I can get that ready with testing for 4.5.

So for now,lets just drop the $subject patch from this
series. Do you want me to resend the series with the $subject
patch dropped, or you can apply rest of the series except
this one.

Let me know. Thanks !!

Regards,
Santosh
