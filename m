From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Wed, 16 Dec 2009 09:58:29 +0800
Message-ID: <20091216015829.GB13068@gondor.apana.org.au>
References: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com> <20091213122512.GA17255@gondor.apana.org.au> <20091213234055.GA28340@redhat.com> <20091215144252.GA7465@gondor.apana.org.au> <20091215233226.GA27129@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57759 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933390AbZLPB6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 20:58:40 -0500
Content-Disposition: inline
In-Reply-To: <20091215233226.GA27129@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 01:32:27AM +0200, Michael S. Tsirkin wrote:
> 
> Right. Hmm. So for this to work we'll need to
> 1. Free skb upon interrupt instead of
>    waiting for the next xmit call

No the next xmit call can free the skbs.

> 2. Add API to query free ring capacity

This is all you need.

> We could also extend host to delay interrupt
> until there is sufficient TX capacity
> but of course we also need to support
> old hosts as well.

Yes that what real hardware does too.  They are able to delay
the interrupt until the number of free entries exceeds a minimum
threshold.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
