From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Fri, 12 Sep 2008 18:27:58 -0700
Message-ID: <20080913012758.GA10459@gondor.apana.org.au>
References: <20080912080249.GA3971@ff.dom.local> <20080912.161005.91061839.davem@davemloft.net> <20080913011018.GA10242@gondor.apana.org.au> <20080912.182259.238925690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54943 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755373AbYIMB2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 21:28:05 -0400
Content-Disposition: inline
In-Reply-To: <20080912.182259.238925690.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2008 at 06:22:59PM -0700, David Miller wrote:
> 
> This requires state, for the unlink.  And that unlink point could be
> several levels deep into the tree.
> 
> There is also currently no restriction on how a packet scheduler
> maintains it's queue of SKBs.
> 
> So, if the idea is to keep track of the skb_queue_head pointer to
> unlink from at the root, I don't think that's a good idea.

No non-leaf qdiscs would remember remember the child qdisc where
it peeked from.

> And then there are all of these complicated pieces of state the
> classful qdiscs modify when a SKB is removed from their visibility.
> So, the unlink isn't just a simple list delete operation.  There
> are queue lengths that need to be updated, watchdog timers to
> manage, etc.

The decision really comes down to whether it's harder to requeue
a seemingly arbitrary packet or whether it's harder to dequeue the
packet that was last peeked.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
