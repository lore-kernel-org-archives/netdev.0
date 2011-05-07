From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 19:51:01 +0100
Message-ID: <270382A9E068495F7E8A14CC@Ximines.local>
References: <891B02256A0667292521A4BF@Ximines.local>	
 <1304770926.2821.1157.camel@edumazet-laptop>	
 <0F4A638C2A523577CDBC295E@Ximines.local>	
 <1304785589.3207.5.camel@edumazet-laptop>	
 <178E8895FB84C07251538EF7@Ximines.local>
 <1304793174.3207.22.camel@edumazet-laptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:55314 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755955Ab1EGSvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 14:51:04 -0400
In-Reply-To: <1304793174.3207.22.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 7 May 2011 20:32:54 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Well, there is also one rcu_barrier() call that is expensive.
> (It was changed from one synchronize_rcu() to one rcu_barrier() lately
> in commit ef885afb , in 2.6.36 kernel)

I think you are saying it may be waiting in rcu_barrier(). I'll
instrument that later plus synchronize_sched().

> http://git2.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commi
> tdiff;h=ef885afbf8a37689afc1d9d545e2f3e7a8276c17

OK, so in head, which I am using, rollback_registered_many which
previously had 2 calls to synchronize_net(), now has one, followed
by a call to rc_barrier() at the bottom.

> netdev_wait_allrefs() waits that all references to a device vanishes.
>
> It currently uses a _very_ pessimistic 250 ms delay between each probe.
> Some users reported that no more than 4 devices can be dismantled per
> second, this is a pretty serious problem for some setups.

Right, that's what I patched before (see patch attached to
message from earlier today) to do an exponential backoff (see
previous entry), i.e. do a 5ms sleep, then a 10ms, then a 20ms, but
never more than 250ms. It made no difference.

> time to remove 50 ipip tunnels on a UP machine :
>
> before patch : real 11.910s
> after patch : real 1.250s

Sadly I don't see that improvement!

-- 
Alex Bligh
