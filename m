From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/4] crypto: CRYPTO_MAX_ALG_NAME is too low
Date: Thu, 6 Apr 2017 16:15:09 +0800
Message-ID: <20170406081509.GB30557@gondor.apana.org.au>
References: <e96825bd-4e1d-c6c1-160e-0dc10f7f3981@nokia.com>
 <367298c5-aa5d-3708-72d0-8a44702d0caa@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <367298c5-aa5d-3708-72d0-8a44702d0caa@nokia.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 16, 2017 at 03:16:29PM +0100, Alexander Sverdlin wrote:
>
> This is a regression caused by 856e3f4092
> ("crypto: seqiv - Add support for new AEAD interface")
> 
> As I've said above, I can offer one of the two solutions, which patch should I send?
> Or do you see any better alternatives?

Here is a series of patches which should fix the problem.

The first three patches prepare the user-space interfaces to deal
with longer names.  The final patch extends it.

Note that with crypto_user I haven't actually extended it to
configure longer names.  It'll only be able to configure names
less than 64 bytes.  However, it should be able to dump/read
algorithms with longer names, albeit the name will be truncated
to 64 bytes length.

Steffen, when convenient could you look into extending the crypto
user interface to handle longer names (preferably arbitraty length
since netlink should be able to deal with that)?

Likewise xfrm is still fixed to 64 bytes long.  But this should
be OK as the problematic case only arises with IV generators for
now and we do not allow IV generators to be specified through xfrm.

af_alg on the other hand now allows arbitrarily long names.

As the final patch depends on all three it would be easiest if
we pushed the xfrm patch through the crypto tree.  Steffen/David?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
