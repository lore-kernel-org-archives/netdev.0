From: Martin Willi <martin@strongswan.org>
Subject: Re: [PATCH 3/5] xfrm: Traffic Flow Confidentiality for IPv4 ESP
Date: Fri, 03 Dec 2010 09:32:55 +0100
Message-ID: <1291365175.1997.34.camel@martin>
References: <1291132155-31277-1-git-send-email-martin@strongswan.org>
	 <1291132155-31277-4-git-send-email-martin@strongswan.org>
	 <20101203073403.GA2292@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20101203073403.GA2292@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> What is the basis of this random length padding?

Let assume a peer does not support ESPv3 padding, but we have to pad a
small packet with more than 255 bytes. We can't, the ESP padding length
field is limited to 255.
We could add 255 fixed bytes, but an eavesdropper could just subtract
the 255 bytes from all packets smaller than the boundary, rendering our
TFC efforts useless.
By inserting a random length padding in the range possible, the
eavesdropper knows that the packet has a length between "length" and
"length - 255", but can't estimated its exact size. I'm aware that this
is not optimal, but probably the best we can do(?).

> Also, what happens when padto exceeds the MTU? Doesn't this
> effectively disable PMTU-discovery?

Yes. An administrator setting a padto value larger than PMTU can
currently break PMTU discovery.

> I know that your last patch allows the padto to be set by PMTU.
> But why would we ever want to use a padto that isn't clamped by
> PMTU?

Probably never, valid point.

I'll add PMTU clamping to the next revision. We probably can drop the
PMTU flag then and just use USHRT_MAX instead. 

Thanks!
Martin
