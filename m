From: Ben Greear <greearb@candelatech.com>
Subject: Re: question on pktgen shutdown logic.
Date: Wed, 22 May 2013 16:28:40 -0700
Message-ID: <519D54A8.4090707@candelatech.com>
References: <519D519B.8040406@candelatech.com> <1369264921.3301.370.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37216 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601Ab3EVX2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 19:28:41 -0400
In-Reply-To: <1369264921.3301.370.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2013 04:22 PM, Eric Dumazet wrote:
> On Wed, 2013-05-22 at 16:15 -0700, Ben Greear wrote:
>> While looking at pktgen.c in 3.9.3, I cannot explain how
>> it does not race on shutdown.
>>
>> The thread worker checks for pktgen_exiting, and will bail out
>> of it's main loop and initiate cleanup if this is true.
>>
>> The pg_net_exit sets the pktgen_exiting to true, and then
>> proceedes to call
>>
>> 		kthread_stop(t->tsk);
>> 		kfree(t);
>>
>> What I don't understand is what keeps the kfree(t) from happening
>> before the thread has noticed pktgen_exiting is set and properly
>> bailed out of it's loop and finished cleanup?
>
> kthread_stop() is synchronous.

Ahh, so it waits for the pktgen_thread_worker method to return?

Why do we bother with the pktgen_exiting flag at all...it
would seem that just checking kthread_should_stop() would
do the trick?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
