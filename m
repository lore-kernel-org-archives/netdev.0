From: Martin Willi <martin@strongswan.org>
Subject: Re: [PATCH 3/5] xfrm: Traffic Flow Confidentiality for IPv4 ESP
Date: Mon, 06 Dec 2010 16:10:25 +0100
Message-ID: <1291648225.1954.179.camel@martin>
References: <1291132155-31277-1-git-send-email-martin@strongswan.org>
	 <1291132155-31277-4-git-send-email-martin@strongswan.org>
	 <20101203073403.GA2292@gondor.apana.org.au>
	 <1291365175.1997.34.camel@martin>
	 <20101203083908.GA2940@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20101203083908.GA2940@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

> I know why you want to do this, what I'm asking is do you have any
> research behind this with regards to security 
> 
> Has this scheme been discussed on a public forum somewhere?

No, sorry, I haven't found much valuable discussion about TFC padding.
Nothing at all how to overcome the ESPv2 padding limit.

> using an insecure RNG to generate a value that is then used as the
> basis for concealment

Using get_random_bytes() adds another ~10% processing overhead due to
the underlying sha_transform. But this is probably negligible, we add
much more with the additional padding to encrypt/MAC.

I'll re-spin the patchset with get_random_bytes(). Even if the ESPv2
padding fallback makes TFC in this case less efficient, it shouldn't
harm. Or do you see this differently?

Regards
Martin
