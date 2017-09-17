From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: Page allocator bottleneck
Date: Sun, 17 Sep 2017 18:43:09 +0300
Message-ID: <acc7ed46-b5d4-dac5-1c9f-a5a9c454c4a7@mellanox.com>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <87vaklyqwq.fsf@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Mel Gorman <mgorman@techsingularity.net>,
 Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>,
 Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>,
 Linux Kernel Network Developers <netdev@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 linux-mm <linux-mm@kvack.org>
To: Andi Kleen <ak@linux.intel.com>, Tariq Toukan <tariqt@mellanox.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <87vaklyqwq.fsf@linux.intel.com>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org



On 14/09/2017 11:19 PM, Andi Kleen wrote:
> Tariq Toukan <tariqt@mellanox.com> writes:
>>
>> Congestion in this case is very clear.
>> When monitored in perf top:
>> 85.58% [kernel] [k] queued_spin_lock_slowpath
> 
> Please look at the callers. Spinlock profiles without callers
> are usually useless because it's just blaming the messenger.
> 
> Most likely the PCP lists are too small for your extreme allocation
> rate, so it goes back too often to the shared pool.
> 
> You can play with the vm.percpu_pagelist_fraction setting.

Thanks Andi.
That was my initial guess, but I wasn't familiar with these tunes in VM 
to verify that.
Indeed, bottleneck is released when increasing the PCP size, and BW 
becomes significantly better.

> 
> -Andi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
