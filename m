From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: TCP_NOTSENT_LOWAT socket option
Date: Tue, 23 Jul 2013 09:20:36 -0700
Message-ID: <51EEAD54.2040603@hp.com>
References: <1374550027.4990.141.camel@edumazet-glaptop> <51EEA089.3040904@hp.com> <1374594244.3449.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:1834 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932705Ab3GWQUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 12:20:50 -0400
In-Reply-To: <1374594244.3449.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/2013 08:44 AM, Eric Dumazet wrote:
> On Tue, 2013-07-23 at 08:26 -0700, Rick Jones wrote:
>
>> I see that now the service demand increase is more like 8%, though there
>> is no longer a throughput increase.  Whether an 8% increase is not a bad
>> effect on the CPU usage of a single flow is probably in the eye of the
>> beholder.
>
> Again, it seems you didn't understand the goal of this patch.
>
> It's not trying to get lower cpu usage, but lower memory usage, _and_
> proper logical splitting of the write queue.

Right - I am questioning whether it is worth the CPU increase.

> Heh, you are trying the old crap again ;)

Yes - why do you seem to be resisting?-)

> Why should we care of setting buffer sizes at all, when we have
> autotuning ;)

Because it keeps growing the buffer too large?-)

> RTT can vary from 50us to 200ms, rate can vary dynamically as well, some
> AQM can trigger with whatever policy, you can have sudden reorders
> because some router chose to apply per packet load balancing :
>
> - You do not want to hard code buffer sizes, but instead let TCP stack
> tune it properly.

I agree that is far nicer if it can be counted upon to work well.

> Sure, I can probably can find out what are the optimal settings for a
> given workload and given network to get minimal cpu usage.
>
> But the point is having the stack finds this automatically.
>
> Further tweaks can be done to avoid a context switch per TSO packet for
> example. If we allow 10 notsent packets, we can probably  wait to have 5
> packets before doing a wakeup.

Isn't this change really just trying to paper-over the autotuning's 
over-growing of the socket buffers?  Or are you considering it an 
extension of the auto-tuning heuristics?

If your 20Gbit test setup needed only 256KB socket buffers (figure 
pulled form the ether) to get to 17 Gbit/s, isn't the autotuning's 
growing them to several MB a bug in the autotuning?

rick
