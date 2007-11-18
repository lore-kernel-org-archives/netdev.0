From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from
 softirq to workqueue
Date: Sat, 17 Nov 2007 16:45:42 -0800 (PST)
Message-ID: <20071117.164542.253082483.davem@davemloft.net>
References: <20071117143622.GA20813@gondor.apana.org.au>
	<473F145B.5090303@cosmosbay.com>
	<20071117162939.GA21563@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43782
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753530AbXKRApm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 19:45:42 -0500
In-Reply-To: <20071117162939.GA21563@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 18 Nov 2007 00:29:39 +0800

> However, since you're already working on this as your next step
> I can wait :)

Me too.

Herbert, you asked about just nop'ing out cond_resched() when we're
doing real preemption.

A lot of code goes:

	if (need_resched()) {
		/* drop some locks, etc. */
		cond_resched();
		/* reacquire locks, etc. */
	}

So it has to do something even with real preemption enabled.
