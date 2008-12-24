From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [IPSEC]: Change the ICV length of sha256 to 128 bits
Date: Wed, 24 Dec 2008 19:59:40 +1100
Message-ID: <20081224085940.GA24830@gondor.apana.org.au>
References: <20081224060225.GA26084@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60835 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751482AbYLXI7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 03:59:50 -0500
Content-Disposition: inline
In-Reply-To: <20081224060225.GA26084@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 23, 2008 at 11:02:25PM -0700, Jason Gunthorpe wrote:
> The existing setting is 96 bits which does not match the RFCs and is
> not negotiable via IKEv2. RFC 4868 says the ICV should be 128 bits,
> and IKEv2 uses AUTH_HMAC_SHA2_256_128 = 12 to identify it.
> 
> git blame says this setting was made before RFC 4868 was published,
> so I'm not sure that it was chosen with any standard in mind.
> 
> NOTE: This 'breaks' the user space API, however at least StrongSwan
> 4.2.9's charon already associates AUTH_HMAC_SHA2_256_128 with
> the transform name 'sha256'.
> 
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

The 96 bits is actually still correct for the auth algorithm IDs
5, 6, and 7.  The parameters in 4868 have been assigned new IDs
starting from 12.

So what we should do is support both.

This is easy to do for af_key as it uses IDs to identify the
algorithms.  To make this work for xfrm, we need to extend the
auth algorithm specification to include the truncation length,
just like AEAD.

So if you feel adventurous, please prepare a patch to create a
new xfrm attribute XFRMA_AUTH2 that uses xfrm_algo_aead instead
of xfrm_algo, and allow that in place of XFRMA_AUTH.

After that we can restructure the auth algorithm list to be like
AEAD and then you can add a new set of SHA algorithms for RFC 4868.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
