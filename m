From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 21:40:53 +0800
Message-ID: <20091217134053.GA31964@gondor.apana.org.au>
References: <20091217111219.9809.27432.sendpatchset@krkumar2.in.ibm.com> <20091217123153.GA31131@gondor.apana.org.au> <OF5A62ABA0.8A2B2426-ON6525768F.0044F439-6525768F.004611D6@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44454 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935383AbZLQNlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 08:41:01 -0500
Content-Disposition: inline
In-Reply-To: <OF5A62ABA0.8A2B2426-ON6525768F.0044F439-6525768F.004611D6@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 06:26:33PM +0530, Krishna Kumar2 wrote:
>
> Since dequeue_skb finds the first skb that was cached in gso_skb,
> handles the stopped txq and returns NULL for all subsequent skbs.
> And qdisc_restart bails out immediately. Only the first skb will
> get requeue'd, and no more skbs are taken out of the queue -
> either dequeue or gso_skb, till the driver restarts the queue.

But dev_requeue_skb immediately reschedules a new TX softirq
so this will keep going until the hardware wakes up the queue.

That is, we have an infinite loop consuming CPU that could otherwise
be spent doing useful work, such as generating new packets.

Note that this is not new in 2.6.32.  It has been this way since
2008 at least.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
