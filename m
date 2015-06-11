From: Chris Mason <clm@fb.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
Date: Thu, 11 Jun 2015 18:18:49 -0400
Message-ID: <557A0949.3020705@fb.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>	 <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>	 <5579FABE.4050505@fb.com> <1434057733.27504.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Shaohua Li <shli@fb.com>, <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <Kernel-team@fb.com>, Eric Dumazet <edumazet@google.com>,
        David Rientjes
	<rientjes@google.com>, <linux-mm@kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1434057733.27504.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 06/11/2015 05:22 PM, Eric Dumazet wrote:
> On Thu, 2015-06-11 at 17:16 -0400, Chris Mason wrote:
>> On 06/11/2015 04:48 PM, Eric Dumazet wrote:

>>
>> networking is asking for 32KB, and the MM layer is doing what it can to
>> provide it.  Are the gains from getting 32KB contig bigger than the cost
>> of moving pages around if the MM has to actually go into compaction?
>> Should we start disk IO to give back 32KB contig?
>>
>> I think we want to tell the MM to compact in the background and give
>> networking 32KB if it happens to have it available.  If not, fall back
>> to smaller allocations without doing anything expensive.
> 
> Exactly my point. (And I mentioned this about 4 months ago)

Sorry, reading this again I wasn't very clear.  I agree with Shaohua's
patch because it is telling the allocator that we don't want to wait for
reclaim or compaction to find contiguous pages.

But, is there any fallback to a single page allocation somewhere else?
If this is the only way to get memory, we might want to add a single
alloc_page path that won't trigger compaction but is at least able to
wait for kswapd to make progress.

-chris




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
