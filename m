From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [6/6] [VIRTIO] net: Allow receiving SG packets
Date: Tue, 22 Apr 2008 09:13:55 +0800
Message-ID: <20080422011354.GB14994@gondor.apana.org.au>
References: <20080418032142.GD18071@gondor.apana.org.au> <20080418032427.GE18071@gondor.apana.org.au> <200804220506.16887.rusty@rustcorp.com.au> <20080421.130418.01258045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, virtualization@lists.linux-foundation.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54522 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932121AbYDVBOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 21:14:04 -0400
Content-Disposition: inline
In-Reply-To: <20080421.130418.01258045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2008 at 01:04:18PM -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Tue, 22 Apr 2008 05:06:16 +1000
> 
> > I'm not sure what the right number is here.  Say worst case is header which 
> > goes over a page boundary then MAX_SKB_FRAGS in the skb, but for some reason 
> > that already has a +2:

The +2 (i.e., extra +1) is for the virtio GSO header.
 
> skb->data is linear, therefore it's not possible to need
> more than one scatterlist entry for it.

Theoretically yes :) But for virtualisation the underlying transport
may present meta-physically contiguous memory that is physically
discrete.  So we may actually need to have multiple SG entries for
skb->data.  However, no current code path should generate packets
with both long skb->data areas *and* skb page frags so we could
just drop them if they show up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
