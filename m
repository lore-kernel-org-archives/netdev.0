From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Mon, 25 Aug 2014 10:54:41 +0800
Message-ID: <53FAA571.9020901@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>	 <1408608310-13579-2-git-send-email-jasowang@redhat.com>	 <1408683665.5648.69.camel@marge.simpson.net>	 <20140822073653.GA7372@gmail.com> <53F70887.8030602@redhat.com> <1408716976.5604.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, eliezer.tamir@linux.intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753767AbaHYCzj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2014 22:55:39 -0400
In-Reply-To: <1408716976.5604.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2014 10:16 PM, Eric Dumazet wrote:
> On Fri, 2014-08-22 at 17:08 +0800, Jason Wang wrote:
>
>> > But this is just for current process. We want to determine whether or
>> > not it was worth to loop busily in current process by checking if
>> > there's any another runnable processes or callbacks. And what we need
>> > here is just a simple and lockless hint which can't be wrong but may be
>> > inaccurate to exit the busy loop. The net code does not depends on this
>> > hint to do scheduling or yielding.
>> > 
>> > How about just introducing a boolean helper like current_can_busy_loop()
>> > and return true in one of the following conditions:
>> > 
>> > - Current task is SCHED_FIFO
>> > - Current task is neither SCHED_FIFO nor SCHED_IDLE and no other
>> > runnable processes or pending RCU callbacks in current cpu
>> > 
>> > And add warns to make sure it can only be called in process context.
> 1) Any reasons Eliezer Tamir is not included in the CC list ?
>
>    He is the busypoll author after all, and did nothing wrong to be
> banned from these patches ;)
CC Eliezer Tamir


No intentional, I just generate the CC list through get_maintainer.pl :(
>
> 2) It looks like sk_buy_loop() should not be inlined, its is already too
> big.
