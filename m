From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Tue, 4 Aug 2009 11:49:10 +0800
Message-ID: <20090804034910.GA30871@gondor.apana.org.au>
References: <20090728155055.2266.41649.sendpatchset@localhost.localdomain> <OF4A7A6701.1BD183E8-ON65257604.0024A9E1-65257606.0030A90D@in.ibm.com> <20090803.202935.221338243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50147 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751039AbZHDDt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 23:49:26 -0400
Content-Disposition: inline
In-Reply-To: <20090803.202935.221338243.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 03, 2009 at 08:29:35PM -0700, David Miller wrote:
>
> Although PFIFO is not work-conserving, isn't it important to retain
> ordering?  What if higher priority packets are in the queue when we
> enqueue?  This new bypass will send the wrong packet, won't it?

The bypass only kicks in if the queue length is zero.

> I'm beginning to think, if we want to make the default case go as fast
> as possible, we should just bypass everything altogether.  The entire
> qdisc layer, all of it.

Can you be more specific? AFAICS he's already bypassing the qdisc
layer when it can be done safely.

> Special casing something that essentially is unused, is in a way
> a waste of time.  If this bypass could be applied to some of the
> complicated qdiscs, then it'd be worthwhile, but just for the
> default which effectively makes it do nothing, I don't see that
> value in it.

I agree with this sentiment.  Essentially what this bypass does
is to eliminate the enqueue + qdisc_restart + dequeue in the
cases where it is safe.  So its value is entirely dependent on
the cost of the code that is eliminated, which may not be that
large for the default qdisc.

Krishna, those netperf tests that you performed, were they done
with a single TX queue or multiple TX queues? If the latter did
you tune the system so that each netperf was bound to a single
core which had its own dedicated TX queue?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
