From: Cong Wang <amwang@redhat.com>
Subject: Re: TCP delayed ACK heuristic
Date: Thu, 20 Dec 2012 11:23:49 +0800
Message-ID: <1355973829.25310.5.camel@cr0>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com>
	 <1355900436.6665.16.camel@cr0> <50D209E9.2000504@hp.com>
	 <20121219.125939.1674292599518627751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org, greearb@candelatech.com,
	eric.dumazet@gmail.com, shemminger@vyatta.com, tgraf@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751397Ab2LTDYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 22:24:11 -0500
In-Reply-To: <20121219.125939.1674292599518627751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-19 at 12:59 -0800, David Miller wrote:
> 
> Yes, but RFC2525 makes it very clear why we should not even
> consider doing crap like this.
> 
> ACKs are the only information we have to detect loss.
> 
> And, for the same reasons that TCP VEGAS is fundamentally broken, we
> cannot measure the pipe or some other receiver-side-visible piece of
> information to determine when it's "safe" to stretch ACK.
> 
> And even if it's "safe", we should not do it so that losses are
> accurately detected and we don't spuriously retransmit.
> 
> The only way to know when the bandwidth increases is to "test" it, by
> sending more and more packets until drops happen.  That's why all
> successful congestion control algorithms must operate on explicited
> tested pieces of information.
> 
> Similarly, it's not really possible to universally know if it's safe
> to stretch ACK or not.

Sounds reasonable. Thanks for your explanation.

> 
> Can we please drop this idea?  It has zero value and all downside as
> far as I'm concerned.
> 

Yeah, I am just trying to see if there is any way to get a reasonable
heuristic.

So, can we at least have a sysctl to control the timeout of the delayed
ACK? I mean the minimum 40ms. TCP_QUICKACK can help too, but it requires
the receiver to modify the application and has to be set every time when
calling recv().

Thanks!
