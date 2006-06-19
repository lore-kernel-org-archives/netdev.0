From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Tue, 20 Jun 2006 00:29:28 +1000
Message-ID: <20060619142928.GA17191@gondor.apana.org.au>
References: <20060619121519.GA16031@gondor.apana.org.au> <1150724031.5815.39.camel@jzny2> <20060619134227.GA16662@gondor.apana.org.au> <1150727009.5815.72.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:6662 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932463AbWFSO3i
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 10:29:38 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1150727009.5815.72.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 19, 2006 at 10:23:29AM -0400, jamal wrote:
> 
> Ok, I am trying to visualize but having a hard time:
> Re-queueing is done at the front of the queue to maintain ordering
> whereas queueing is done at the front (i.e it is a FIFO). i,e
> even if p2 comes in and gets queued while p1 is being processed,
> requeueing of p1 will put it infront of p2.

Correct.  When qdisc_run happens we take an skb off the head of the
queue.  If it can't be transmitted right away, we try to put it back
in the same spot.

If you have two qdisc_run's happening at the same time then that spot
could be different.

> Your super-packet issue may be different though ..

The reordering issue is not related to super-packets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
