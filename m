From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
	hashing.
Date: Thu, 29 Jan 2009 15:41:48 +1100
Message-ID: <20090129044148.GA25131@gondor.apana.org.au>
References: <20090128213141.GD22141@gondor.apana.org.au> <20090128.164058.248259991.davem@davemloft.net> <20090129013403.GA24043@gondor.apana.org.au> <20090128.174522.208349319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33336 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751302AbZA2Elx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 23:41:53 -0500
Content-Disposition: inline
In-Reply-To: <20090128.174522.208349319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2009 at 05:45:22PM -0800, David Miller wrote:
> 
> This is already proven to be false :-)
> 
> Having more TX queues helps a lot.  Robert's testing confirms
> this even when the number of TX queues exceeds the number of
> cores.
> 
> When Robert directly maps RX queues to a single TX queue on NIU, we
> get drops at the qdisc level during his routing tests.  With the TX
> queue iterator which causes all of the TX queues to be utilizied there
> are no drops.

This could just mean that the hardware has underprovisioned each
individual TX queue.  Or is there some fundamental efficiency of
using multiple queues that I have missed?

But yeah if a single TX queue isn't big enough to take care of
the output from a single core then you will need multiple TX
queues.  Although from an system-wide point of view it would
seem to be more optimal to make that TX queue bigger rather than
forcing the software to use multiple queues (which may come with
a bigger overhead) to make up for it.

Of course for us software developers we don't really have a choice :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
