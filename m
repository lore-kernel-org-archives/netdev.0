From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 4/5] sunvnet: count multicast packets
Date: Thu, 16 Mar 2017 11:30:02 -0700 (PDT)
Message-ID: <20170316.113002.1116238459858653812.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6DCFFB12CF@AcuExch.aculab.com>
        <4ee0ac85-62a3-2cb2-0d5d-d17e4334bde8@oracle.com>
        <063D6719AE5E284EB5DD2968C1650D6DCFFB283F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@oracle.com, netdev@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFB283F@AcuExch.aculab.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 16 Mar 2017 12:12:06 +0000

> From: Shannon Nelson
>> Sent: 16 March 2017 00:18
>> To: David Laight; netdev@vger.kernel.org; davem@davemloft.net
>> On 3/15/2017 1:50 AM, David Laight wrote:
>> > From: Shannon Nelson
>> >> Sent: 14 March 2017 17:25
>> > ...
>> >> +	if (unlikely(is_multicast_ether_addr(eth_hdr(skb)->h_dest)))
>> >> +		dev->stats.multicast++;
>> >
>> > I'd guess that:
>> > 	dev->stats.multicast += is_multicast_ether_addr(eth_hdr(skb)->h_dest);
>> > generates faster code.
>> > Especially if is_multicast_ether_addr(x) is (*x >> 7).
> 
> I'd clearly got brain-fade there, mcast bit is the first transmitted bit
> (on ethernet) but the bytes are sent LSB first (like async).
>> > 	David
>> 
>> Hi David, thanks for the comment.  My local instruction level
>> performance guru is on vacation this week so I can't do a quick check
>> with him today on this.  However, I"m not too worried here since the
>> inline code for is_multicast_ether_addr() is simply
>> 
>> 	return 0x01 & addr[0];
>> 
>> and objdump tells me that on sparc it compiles down to a simple single
>> byte load and compare:
>> 
>>      325c:	c2 08 80 03 	ldub  [ %g2 + %g3 ], %g1
>>      3260:	80 88 60 01 	btst  1, %g1
>>      3264:	32 60 00 b3 	bne,a,pn   %xcc, 3530 <vnet_rx_one+0x430>
>>      3268:	c2 5c 61 68 	ldx  [ %l1 + 0x168 ], %g1
>> 		dev->stats.multicast++;
> 
> Followed by a branch that might be marked 'assume taken' so the
> normal path takes the branch.

The branch is predicted not taken, so the fallthrough happens most
often.  And this is optimal for most Niagara parts as taken branches
make the cpu thread yield whereas non-taken branches do not.

But this is such a petty thing to be discussing compared to the substance
of this person's changes.  David, I really wish you wouldn't waste people's
time with this stuff.

Maybe if you had to review hundreds of networking patches every day like
I do, you would start to understand the costs of the interference you
place into the review process when you bring up such small matters like
this all the time.

I'd much rather you review the substance of a person's changes,
because that actually helps things more forward.  If you want to micro
optimize then _do it on your own time_, submit patches that do the
micro optimization, and have it go through the review process like
everyone else's changes.

I very much appreciate your cooperation on this matter.

Thanks.
