From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Fri, 12 Sep 2008 18:48:00 -0700
Message-ID: <20080913014800.GA10611@gondor.apana.org.au>
References: <20080913011018.GA10242@gondor.apana.org.au> <20080912.182259.238925690.davem@davemloft.net> <20080913012758.GA10459@gondor.apana.org.au> <20080912.184008.74354363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38982 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753680AbYIMBsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 21:48:06 -0400
Content-Disposition: inline
In-Reply-To: <20080912.184008.74354363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2008 at 06:40:08PM -0700, David Miller wrote:
>
> My current opinion is that both operations are equally difficult.
> With the slight advantage for ->requeue() because all the complicated
> logic is already implemented :-)

I'd agree with you if you haven't written the peek stuff :)

Now that peek exists, the dequeue stuff would be a lot simpler
than requeue because the only non-trivial logic would be in the
leaf qdiscs.  All the complex/classful qdiscs would be trivial
as they'd just write down the child qdisc that was peeked and
then call dequeue on that child.

Compare that to requeue where the classful qdiscs have to do
loads of work to figure out which child the packet should be
sent to.

In fact it looks like CBQ has taken the easy way out by remembering
the class the last packet was dequeued from so it's essentially
doing what I'm proposing here :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
