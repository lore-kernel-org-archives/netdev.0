From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from softirq to workqueue
Date: Sun, 18 Nov 2007 10:07:37 +0800
Message-ID: <20071118020737.GA24821@gondor.apana.org.au>
References: <20071117143622.GA20813@gondor.apana.org.au> <473F145B.5090303@cosmosbay.com> <20071117162939.GA21563@gondor.apana.org.au> <20071117.164542.253082483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3996 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751899AbXKRCIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 21:08:15 -0500
Content-Disposition: inline
In-Reply-To: <20071117.164542.253082483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 17, 2007 at 04:45:42PM -0800, David Miller wrote:
>
> Herbert, you asked about just nop'ing out cond_resched() when we're
> doing real preemption.
> 
> A lot of code goes:
> 
> 	if (need_resched()) {
> 		/* drop some locks, etc. */
> 		cond_resched();
> 		/* reacquire locks, etc. */
> 	}
> 
> So it has to do something even with real preemption enabled.

Actually that shouldn't be necessary.  Because things like spin_unlock
does preempt_enable which in turn does:

#define preempt_enable() \
do { \
        preempt_enable_no_resched(); \
        barrier(); \
        preempt_check_resched(); \
} while (0)

when CONFIG_PREEMPT is enabled.  So at least in this case the
cond_resched call is superfluous.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
