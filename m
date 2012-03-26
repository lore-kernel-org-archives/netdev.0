From: Ben Greear <greearb@candelatech.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL dereferences
 in check_peer_redir)
Date: Mon, 26 Mar 2012 16:46:40 -0700
Message-ID: <4F70FFE0.7070204@candelatech.com>
References: <4F70E308.7070908@candelatech.com>  <20120326.174945.1186427809261872546.davem@davemloft.net>  <4F70E560.3020102@candelatech.com>  <4F70F688.6050108@candelatech.com> <1332805148.3547.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34333 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459Ab2CZXqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 19:46:46 -0400
In-Reply-To: <1332805148.3547.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2012 04:39 PM, Eric Dumazet wrote:
> On Mon, 2012-03-26 at 16:06 -0700, Ben Greear wrote:
>> On 03/26/2012 02:53 PM, Ben Greear wrote:
>>> On 03/26/2012 02:49 PM, David Miller wrote:
>>>>
>>>> Looks like all of those strange undiagnosable reported Dave Jones
>>>> has been feeding us. Something in one part of the kernel leaves
>>>> a lock held, and this shows up as a warning elsewhere.
>>>
>>> Every (initial) bug printout fingers ipv6 and the 'ip' tool on my system.
>>
>> I added a patch to convert rcu_read_lock/unlock to macros so
>> that I could automatically grab the call site (_THIS_IP_)
>> and pass it into the lockdep framework instead of the (useless)
>> _THIS_IP_ in the old rcu_read_lock method which at best seems to
>> only indicate which module the issue relates to...
>
> Hi Ben
>
> Is this problem also appears with current tree ?
> (This could be a problem with the backport, as it was full of
> dependencies)

I don't think so..but I will double check in a bit.

> Also, if you use a patch to better track rcu_read_lock()/unlock(), you
> could add new macros as well to track that a particular unlock() matches
> one given lock(). (maybe returning the rcu_preempt_depth at
> rcu_read_lock() time , but maybe a more absolute ref would be better)
>
> So we could have a warning if an unlock() doesnt match the lock()
>
> inet6_dump_fib () was already a suspect but we could not find why.

The 3.0.21 kernel doesn't appear to have a rcu_read_lock_return(),
so I can't use your patch below.

Thanks,
Ben



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
