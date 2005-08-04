From: Diego Beltrami <diego.beltrami@hiit.fi>
Subject: Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Thu, 04 Aug 2005 17:38:31 +0300
Message-ID: <42F22867.9050804@hiit.fi>
References: <1122984099.1214.142.camel@odysse> <Pine.GSO.4.58.0508032319000.3957@kekkonen.cs.hut.fi> <20050804131519.GB5831@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, netdev@oss.sgi.com, infrahip@hiit.fi,
        hipl-users@freelists.org, hipsec@ietf.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050804131519.GB5831@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Well to me it's more of an issue of maintainability.  BEET mode is
> more akin to transport/tunnel mode than AH/ESP/IPcomp.  As such its
> implementation would be most at home where the existing encapsulation
> and decapsulation for transport/tunnel mode is done.  That is, in
> xfrm[46]_input.c and xfrm[46]_output.c.
> 
> For instance, the reason the current patch has to touch esp4.c at
> all is really because the patch to xfrm4_output.c isn't right.
> It should do what the comment says and set skb->h to the start
> of the payload, not the start of the ESP header.  If it did that,
> then esp_output doesn't have to care about BEET at all.

This is totally true, and I agree with you but then this is somehow a 
controversial thing with respect to the esp6_output. In fact the 
esp6_output has the same purpose of esp_output, but it requires the 
skb->h to be set at the beginning of ESP header.

> 
> Also, the outer header generation should be done before
> x->type->output is called, not after.  That way, the AH
> semantics falls out quite naturally.

BEET has been designed to be compatible with HIP. This means that the 
ESP header should be computed with respect to the inner addresses.
In a very first implementation of BEET we were converting the inner 
addresses to the outer addresses before x->type->output, but we couldn't 
make interoperate BEET with HIP.
That's the reason why the outer header generation has been after 
x->type->output.

This is one of the reasons why the AH, as Pekka Nikader said, is a bit 
trickier with respect to ESP (the AH protocol protects the IP datagram 
including immutable parts of the IP header like the IP addresses whereas 
for ESP the IP header is not included in the calculation process).

--Diego
