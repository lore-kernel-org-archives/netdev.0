From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/5] xfrm: Traffic Flow Confidentiality for IPv4 ESP
Date: Fri, 3 Dec 2010 16:39:08 +0800
Message-ID: <20101203083908.GA2940@gondor.apana.org.au>
References: <1291132155-31277-1-git-send-email-martin@strongswan.org> <1291132155-31277-4-git-send-email-martin@strongswan.org> <20101203073403.GA2292@gondor.apana.org.au> <1291365175.1997.34.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291365175.1997.34.camel@martin>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 03, 2010 at 09:32:55AM +0100, Martin Willi wrote:
> 
> > What is the basis of this random length padding?
> 
> Let assume a peer does not support ESPv3 padding, but we have to pad a
> small packet with more than 255 bytes. We can't, the ESP padding length
> field is limited to 255.
> We could add 255 fixed bytes, but an eavesdropper could just subtract
> the 255 bytes from all packets smaller than the boundary, rendering our
> TFC efforts useless.
> By inserting a random length padding in the range possible, the
> eavesdropper knows that the packet has a length between "length" and
> "length - 255", but can't estimated its exact size. I'm aware that this
> is not optimal, but probably the best we can do(?).

I know why you want to do this, what I'm asking is do you have any
research behind this with regards to security (e.g., you're using an
insecure RNG to generate a value that is then used as the basis
for concealment)?

Has this scheme been discussed on a public forum somewhere?

> > I know that your last patch allows the padto to be set by PMTU.
> > But why would we ever want to use a padto that isn't clamped by
> > PMTU?
> 
> Probably never, valid point.
> 
> I'll add PMTU clamping to the next revision. We probably can drop the
> PMTU flag then and just use USHRT_MAX instead. 

Sounds good.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
