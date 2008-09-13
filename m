From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Fri, 12 Sep 2008 18:10:18 -0700
Message-ID: <20080913011018.GA10242@gondor.apana.org.au>
References: <20080911.044717.265303740.davem@davemloft.net> <20080911.214929.152271268.davem@davemloft.net> <20080912080249.GA3971@ff.dom.local> <20080912.161005.91061839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53179 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756562AbYIMBK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 21:10:26 -0400
Content-Disposition: inline
In-Reply-To: <20080912.161005.91061839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2008 at 04:10:05PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 12 Sep 2008 08:02:49 +0000
> 
> > Alas I'm still not sure how this whole peek idea is going to be
> > implemented (dequeuing after peeking doesn't have to give us the
> > same skb since in the meantime e.g. in HTB some other class with
> > higher prio can get enough tokens etc., and if there is a break
> > for transmit in the meantime with possible enqueuing, or we can
> > deal with something like sch_multiq, which depends on the current
> > state of the tx_queues, this all looks even more interesting).
> 
> That's a good point.
> 
> Well, once that is discussed and resolved, at least the patch I
> posted can be used as a base for implementation :-)

Well we should remember the skb returned by peek, and then return
it on the next dequeue.  If peek hasn't been called since the
last dequeue then it's equivalent to the current dequeue.

This works for the two scenarios where we're planning to use
peek since they'll both call dequeue immediately.

It'd even work if there was a large gap (i.e., a sleep) after
the peek since we'd just peek again after waking up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
