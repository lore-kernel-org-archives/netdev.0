From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Does ESP support 64 bit sequence numbering for authentication
	hash ?
Date: Thu, 15 Jan 2009 16:56:44 +1100
Message-ID: <20090115055644.GA30626@gondor.apana.org.au>
References: <1231943033.7937.120.camel@libdev3.mvista.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: djenkins@mvista.com
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1231943033.7937.120.camel@libdev3.mvista.co.uk>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dean Jenkins <djenkins@mvista.com> wrote:
> 
> Does ESP support 64 bit sequence numbering for use with the
> authentication HMAC ?

We don't support 64-bit sequence numbers yet.  If you look at
struct xfrm_replay_state which is where we store the sequence
number internally you'll find that it uses u32s.

Patches for 64-bit support are welcome of course.

> I've looked at struct aead_givcrypt_request and it has a u64 seq member.
> Does ESP populate this with a 64 bit sequence number ?

That's different.  That's a generic value used to construct the IV.

> If 32 bit sequence numbering negotiated then how does the HMAC routine
> know that it should not use the top 32 bits of seq ? Or is it simply
> that if the top 32 bits are zero then the HMAC just uses the lower 32
> bits ?

Because the value we start out with is a u32, the high bits are
never set for IPsec.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
