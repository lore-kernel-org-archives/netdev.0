From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Subject: Re: [PATCH 0/4] crypto: CRYPTO_MAX_ALG_NAME is too low
Date: Thu, 6 Apr 2017 17:10:16 +0200
Message-ID: <83468dbd-08a8-0014-3d01-08ea3693393c@nokia.com>
References: <e96825bd-4e1d-c6c1-160e-0dc10f7f3981@nokia.com>
 <367298c5-aa5d-3708-72d0-8a44702d0caa@nokia.com>
 <20170406081509.GB30557@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        <linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170406081509.GB30557@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

On 06/04/17 10:15, Herbert Xu wrote:
> On Thu, Mar 16, 2017 at 03:16:29PM +0100, Alexander Sverdlin wrote:
>> This is a regression caused by 856e3f4092
>> ("crypto: seqiv - Add support for new AEAD interface")
>>
>> As I've said above, I can offer one of the two solutions, which patch should I send?
>> Or do you see any better alternatives?
> Here is a series of patches which should fix the problem.
> 
> The first three patches prepare the user-space interfaces to deal
> with longer names.  The final patch extends it.
> 
> Note that with crypto_user I haven't actually extended it to
> configure longer names.  It'll only be able to configure names
> less than 64 bytes.  However, it should be able to dump/read
> algorithms with longer names, albeit the name will be truncated
> to 64 bytes length.
> 
> Steffen, when convenient could you look into extending the crypto
> user interface to handle longer names (preferably arbitraty length
> since netlink should be able to deal with that)?
> 
> Likewise xfrm is still fixed to 64 bytes long.  But this should
> be OK as the problematic case only arises with IV generators for
> now and we do not allow IV generators to be specified through xfrm.
> 
> af_alg on the other hand now allows arbitrarily long names.

I'm not sure about patch 2 (as I've replied separately), but I've applied
and tested the whole series and it at least solves the original problem
with long algorithm name.

> As the final patch depends on all three it would be easiest if
> we pushed the xfrm patch through the crypto tree.  Steffen/David?

-- 
Best regards,
Alexander Sverdlin.
