From: David Miller <davem@davemloft.net>
Subject: Re: net: Generalise wq_has_sleeper helper
Date: Wed, 25 Nov 2015 11:37:29 -0500 (EST)
Message-ID: <20151125.113729.987827630302526646.davem@davemloft.net>
References: <20151111094829.GA23202@gondor.apana.org.au>
	<20151124055423.GA31611@gondor.apana.org.au>
	<20151125091533.GX17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tatsu@ab.jp.nec.com, mingo@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jolsa@redhat.com, eric.dumazet@gmail.com
To: peterz@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151125091533.GX17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 25 Nov 2015 10:15:33 +0100

> On Tue, Nov 24, 2015 at 01:54:23PM +0800, Herbert Xu wrote:
>> + * The race for tcp fires when the __add_wait_queue changes done by CPU1 stay
>> + * in its cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1
>> + * could then endup calling schedule and sleep forever if there are no more
>> + * data on the socket.
>> + *
> 
> Would be easier to refer to the comment that now adorns
> waitqueue_active().

Yeah, that might be a good idea.  Herbert can you adjust this?

>> + */
>> +static inline bool wq_has_sleeper(wait_queue_head_t *wq)
>> +{
>> +	/* We need to be sure we are in sync with the
> 
> broken comment style.

This is how we do it in the networking, so that's why it's formatted
this way, but yes he will need to fix it up.
