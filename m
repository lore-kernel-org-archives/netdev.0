From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] tun: Allow GSO using virtio_net_hdr
Date: Thu, 24 Jul 2008 22:20:44 +0800
Message-ID: <20080724142044.GA8266@gondor.apana.org.au>
References: <200806260028.07883.rusty@rustcorp.com.au> <200806260029.40267.rusty@rustcorp.com.au> <200806260030.38293.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Max Krasnyansky <maxk@qualcomm.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, markmc@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46172 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751149AbYGXOU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 10:20:57 -0400
Content-Disposition: inline
In-Reply-To: <200806260030.38293.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2008 at 12:30:37AM +1000, Rusty Russell wrote:
> Add a IFF_VNET_HDR flag.  This uses the same ABI as virtio_net (ie. prepending
> struct virtio_net_hdr to packets) to indicate GSO and checksum information.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

I just noticed that we still allocate a linear skb even when GSO
is enabled.  Please fix this by allocating page frags where
necessary.  Otherwise GSO is only going to work before memory
fragmentation sets in.

IIRC I'd sent out a patch to the virt mailing list with code
that did this.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
