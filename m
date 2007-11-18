From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from
 softirq to workqueue
Date: Sat, 17 Nov 2007 18:13:13 -0800 (PST)
Message-ID: <20071117.181313.217111568.davem@davemloft.net>
References: <20071117162939.GA21563@gondor.apana.org.au>
	<20071117.164542.253082483.davem@davemloft.net>
	<20071118020737.GA24821@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51225
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753507AbXKRCNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 21:13:14 -0500
In-Reply-To: <20071118020737.GA24821@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 18 Nov 2007 10:07:37 +0800

> On Sat, Nov 17, 2007 at 04:45:42PM -0800, David Miller wrote:
> >
> > Herbert, you asked about just nop'ing out cond_resched() when we're
> > doing real preemption.
> > 
> > A lot of code goes:
> > 
> > 	if (need_resched()) {
> > 		/* drop some locks, etc. */
> > 		cond_resched();
> > 		/* reacquire locks, etc. */
> > 	}
> > 
> > So it has to do something even with real preemption enabled.
> 
> Actually that shouldn't be necessary.  Because things like spin_unlock
> does preempt_enable which in turn does:
> 
> #define preempt_enable() \
> do { \
>         preempt_enable_no_resched(); \
>         barrier(); \
>         preempt_check_resched(); \
> } while (0)
> 
> when CONFIG_PREEMPT is enabled.  So at least in this case the
> cond_resched call is superfluous.

I see what you mean, ok yes that would catch it.
