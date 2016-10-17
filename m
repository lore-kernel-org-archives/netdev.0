From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] crypto: ccm - avoid scatterlist for MAC encryption
Date: Mon, 17 Oct 2016 09:28:30 +0200
Message-ID: <1476689310.19992.1.camel@sipsolutions.net>
References: <1476551776-8099-1-git-send-email-ard.biesheuvel@linaro.org>
         (sfid-20161015_191624_228877_FEFB7F65)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, luto@amacapital.net,
        sergey.senozhatsky.work@gmail.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, davem@davemloft.net,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        j@w1.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49035 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750752AbcJQH2j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 03:28:39 -0400
In-Reply-To: <1476551776-8099-1-git-send-email-ard.biesheuvel@linaro.org> (sfid-20161015_191624_228877_FEFB7F65)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-10-15 at 18:16 +0100, Ard Biesheuvel wrote:
> The CCM code goes out of its way to perform the CTR encryption of the
> MAC using the subordinate CTR driver. To this end, it tweaks the
> input and output scatterlists so the aead_req 'odata' and/or
> 'auth_tag' fields [which may live on the stack] are prepended to the
> CTR payload. This involves calling sg_set_buf() on addresses which
> are not direct mapped, which is not supported.

> Since the calculation of the MAC keystream involves a single call
> into the cipher, to which we have a handle already given that the
> CBC-MAC calculation uses it as well, just calculate the MAC keystream
> directly, and record it in the aead_req private context so we can
> apply it to the MAC in cypto_ccm_auth_mac(). This greatly simplifies
> the scatterlist manipulation, and no longer requires scatterlists to
> refer to buffers that may live on the stack.

No objection from me, Herbert?

I'm getting a bit nervous though - I'd rather have any fix first so
people get things working again - so maybe I'll apply your other patch
and mine first, and then we can replace yours by this later.

johannes
