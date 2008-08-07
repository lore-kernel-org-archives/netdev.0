From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 7 Aug 2008 14:15:35 +0800
Message-ID: <20080807061535.GA7591@gondor.apana.org.au>
References: <20080731132735.GA9085@gondor.apana.org.au> <20080803.011945.249059359.davem@davemloft.net> <20080803085553.GA1512@gondor.apana.org.au> <20080806.230741.137564172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, buytenh@wantstofly.org,
	netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	dale@farnsworth.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46278 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751861AbYHGGPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 02:15:48 -0400
Content-Disposition: inline
In-Reply-To: <20080806.230741.137564172.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2008 at 11:07:41PM -0700, David Miller wrote:
>
> We don't touch anything in the original TSO skb.  However we expand
> the headroom (if necessary) and in the area in front of skb->data we
> build the header areas for the sub-TSO frames, one by one.

Or we could just allocate them beforehand, either way, it's one
operation per superpacket so it's cheap.
 
> This might be where we get pushed over the edge and have to add a
> dma_addr_t to sk_buff and skb_frag_struct.  And that might not
> be such a bad thing because it will allow other things that
> we've always wanted to do.

Since the skb_frag struct is in the shared area where we have
to pad up to a power-of-two for kmalloc we usually have plenty
of free space anyway.

> Another nice aspect of this idea is that we can make the existing GSO
> code just build this funny "TSO plus hidden headers" SKB, and then do
> the by-hand unpacking into new SKB chunks that we will let smart
> drivers do directly into their TX rings.
> 
> Herbert what do you think?

Yes this idea sounds perfect :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
