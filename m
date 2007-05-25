From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 8536] New: Kernel drops UDP packets silently when reading from certain proc file entries
Date: Fri, 25 May 2007 16:57:12 +1000
Message-ID: <20070525065712.GA26619@gondor.apana.org.au>
References: <E1HrTDQ-0006qu-00@gondolin.me.apana.org.au> <4656872C.9000701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	andsve@gmail.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2634 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751917AbXEYG5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 02:57:25 -0400
Content-Disposition: inline
In-Reply-To: <4656872C.9000701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 25, 2007 at 08:50:20AM +0200, Eric Dumazet wrote:
>
> If this patch really helps, this means cond_resched_softirq()
> doesnt work at all and should be fixed, or just zapped as it
> is seldom used.

cond_resched_softirq lets other threads run if they want to.
It doesn't run pending softirq's at all.  In fact, it doesn't
even wake up ksoftirqd.

So if the only work we get come from softirq's then we'll just
block them until we're done with /proc/net/tcp.

You can (correctly) argue that cond_resched_softirq is broken,
but it doesn't change the fact that we don't even need to call
it for /proc/net/tcp.

This patch simply changes /proc/net/tcp to be in line with the
behaviour of inet_diag.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
