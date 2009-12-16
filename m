From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Wed, 16 Dec 2009 09:21:21 +0800
Message-ID: <20091216012121.GA13068@gondor.apana.org.au>
References: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com> <20091213122512.GA17255@gondor.apana.org.au> <20091213234055.GA28340@redhat.com> <20091215144252.GA7465@gondor.apana.org.au> <1260894380.16865.13.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46223 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934381AbZLPBV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 20:21:29 -0500
Content-Disposition: inline
In-Reply-To: <1260894380.16865.13.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2009 at 08:26:20AM -0800, Sridhar Samudrala wrote:
> 
> Also, can we do free_old_xmit_skbs() to freeup any used descriptors in
> the callback(skb_xmit_done) context? I tried this, but hit a panic in
> free_old_xmit_skbs(__skb_unlink() trying to remove the skb from the vi->send queue).
> Looks like we need to add the skb to the vi->send queue before doing a kick.

No you can't free skbs from hard IRQ context.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
