From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Wed, 16 Dec 2009 10:53:31 +0800
Message-ID: <20091216025331.GA13935@gondor.apana.org.au>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912161311.40644.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, mst@redhat.com,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43738 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751370AbZLPCxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 21:53:40 -0500
Content-Disposition: inline
In-Reply-To: <200912161311.40644.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 01:11:40PM +1030, Rusty Russell wrote:
> 
>    Thanks for the hint.  They seem to use NAPI for xmit cleanup, so that's
> what we should do?  I'll try, but such a rewrite doesn't belong in 2.6.32.

Well it depends.  Real drivers can't touch the hardware so they're
stuck with whatever the hardware does.  For virtio we do have the
flexibility of modifying the backend.

Having said that, for existing backends that will signal when there
is just a single free entry on the queue something like NAPI could
reduce the overhead associated with the IRQs.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
