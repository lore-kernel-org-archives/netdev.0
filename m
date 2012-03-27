From: Ben Greear <greearb@candelatech.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL dereferences
 in check_peer_redir)
Date: Mon, 26 Mar 2012 22:30:52 -0700
Message-ID: <4F71508C.908@candelatech.com>
References: <4F70E308.7070908@candelatech.com> <20120326.174945.1186427809261872546.davem@davemloft.net> <4F70E560.3020102@candelatech.com> <4F70F688.6050108@candelatech.com> <1332805148.3547.14.camel@edumazet-glaptop> <4F70FFE0.7070204@candelatech.com> <1332806834.3547.16.camel@edumazet-glaptop> <20120327051120.GM2450@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44626 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab2C0FbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 01:31:00 -0400
In-Reply-To: <20120327051120.GM2450@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2012 10:11 PM, Paul E. McKenney wrote:
> On Tue, Mar 27, 2012 at 02:07:14AM +0200, Eric Dumazet wrote:
>> On Mon, 2012-03-26 at 16:46 -0700, Ben Greear wrote:
>>
>>> The 3.0.21 kernel doesn't appear to have a rcu_read_lock_return(),
>>> so I can't use your patch below.
>>
>> This patch was only to show the point (I also CCed Paul, he might have
>> some time to think about it, after he clears the inline stuff with
>> Linus)
>
> There is an rcu_preempt_depth() that returns rcu_read_lock() nesting
> level for CONFIG_PREEMPT_RCU=y on the one hand and returns zero
> for CONFIG_PREEMPT_RCU=n on the other.  So if you can reproduce
> with CONFIG_PREEMPT_RCU=y, you can substitute rcu_preempt_depth()
> rcu_read_lock_return() in Eric's earlier patch.

I'll try looking at that tomorrow.  I tried adding some code to check for
recursive calls to the fib-dump, and didn't see it ever hit, though
the bug continued to happen readily.

I just #if 0 the part between rcu-read-lock and read-unlock, and
the problem went away..but of course you can't dump ipv6
routes then...

The actual logic to dump the fib is quite complex, full of
opaque types and other stuff ripe for bugs.  But, I don't see
how it could cause the rcu splats in such a repeatable manner.

The bug is always reported as being in the same place, so if
there is any other debugging code you can think of to help
shed light on this, I'll be happy to add it and give it a try.
For instance, is there a way to dump (print) all current holders of
the rcu_read_lock?  I could call that before/during/after in that
method and maybe get a clue.

Thanks,
Ben

>
> 							Thanx, Paul
>
>> As I said, I was referreing to you adding stuff in rcu. ;)
>>
>> Unfortunately I wont have time in the near future to do so myself.
>>
>>
>>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
