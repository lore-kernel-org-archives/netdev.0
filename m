From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Tue, 20 Jun 2006 08:33:26 +1000
Message-ID: <20060619223326.GA20354@gondor.apana.org.au>
References: <20060619121519.GA16031@gondor.apana.org.au> <1150724031.5815.39.camel@jzny2> <20060619134227.GA16662@gondor.apana.org.au> <1150727009.5815.72.camel@jzny2> <20060619142928.GA17191@gondor.apana.org.au> <1150727810.5815.78.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:19216 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964955AbWFSWdn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 18:33:43 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1150727810.5815.78.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 19, 2006 at 10:36:50AM -0400, jamal wrote:
> 
> Ok, but:
> The queue lock will ensure only one of the qdisc runs (assuming
> different CPUs) will be able to dequeue at any one iota in time, no?
> And if you assume that the cpu that manages to get the tx lock as well
> is going to be contending for the qlock in ordewr to requeue, then the
> only scenario i can see the race happening is when you have one CPU
> faster than the other.
> Did i miss something?

First of all you could receive an IRQ in between dropping xmit_lock
and regaining the queue lock.  Secondly we now have lockless drivers
where this assumption also does not hold.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
