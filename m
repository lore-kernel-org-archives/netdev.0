From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 1/2] drop_monitor: fix sleeping in invalid context
 warning
Date: Sat, 28 Apr 2012 10:30:22 -0400
Message-ID: <20120428143022.GA5944@hmsreliant.think-freely.org>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
 <1335557509-32726-1-git-send-email-nhorman@tuxdriver.com>
 <1335557509-32726-2-git-send-email-nhorman@tuxdriver.com>
 <1335593473.2900.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50751 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab2D1Oa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 10:30:29 -0400
Content-Disposition: inline
In-Reply-To: <1335593473.2900.0.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 28, 2012 at 08:11:13AM +0200, Eric Dumazet wrote:
> On Fri, 2012-04-27 at 16:11 -0400, Neil Horman wrote:
> > Eric Dumazet pointed out this warning in the drop_monitor protocol to me:
> > 
> 
> > It stems from holding a spinlock (trace_state_lock) while attempting to register
> > or unregister tracepoint hooks, making in_atomic() true in this context, leading
> > to the warning when the tracepoint calls might_sleep() while its taking a mutex.
> > Since we only use the trace_state_lock to prevent trace protocol state races, as
> > well as hardware stat list updates on an rcu write side, we can just convert the
> > spinlock to a mutex to avoid this problem.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: David Miller <davem@davemloft.net>
> > ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Thanks Neil
> 
Anytmie, thanks for reporting it.
Neil

> 
> 
> 
