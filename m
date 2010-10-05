From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv4 net-next-2.6 1/5] XFRM,IPv6: Remove xfrm_spi_hash()
	dependency on destination address
Date: Tue, 5 Oct 2010 10:11:14 +0800
Message-ID: <20101005021114.GA25681@gondor.apana.org.au>
References: <cover.1286139128.git.arno@natisbad.org> <5a0e320544e253cc903cfd3292600b6bec044a5f.1286139129.git.arno@natisbad.org> <20101004083306.GA17939@gondor.apana.org.au> <8739sl8yw5.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39517 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244Ab0JECL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 22:11:29 -0400
Content-Disposition: inline
In-Reply-To: <8739sl8yw5.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 04, 2010 at 10:51:38PM +0200, Arnaud Ebalard wrote:
> 
> Herbert Xu <herbert@gondor.apana.org.au> writes:
>
> > I'm fine with doing this for inbound SAs.  However, I can't see
> > how we can do this for outbound SAs where the SPI is chosen by
> > the remote end.
> 
> The change *does not* make the lookup in the hash table rely only on the
> spi, i.e. __xfrm_state_lookup() is still passed the address. It only
> removes the destination address from the computation of the hash. This
> allows passing NULL to __xfrm_state_lookup() specifically for input path
> and make the lookup only based on the SPI. The destination address check
> is done later (possibly after IRO remapping).
> 
> Except if I really missed something, this has no impact on outbound SA
> (other hashtables are used in that case). 

I'm thinking about the case where each remote end (or one remote
end with many IP addresses) chooses to use a single SPI which then
all gets hashed to the same bucket.

Outbound SAs are hashed into the same SPI hash table as inbound SAs.

> > Incidentally, it appears that our hash could do with some
> > strengthening.
> 
> After the change, xfrm_spi_hash() would contain:
> 
>  	unsigned int h = (__force u32)spi ^ proto;
>         return  ((h ^ (h >> 10) ^ (h >> 20)) & hmask)
> 
> which seems to spread the bits h correctly into hmask bits (I mean for
> the effort ;-) ). Are you thinking about something like changing the
> shifts based on the length of the mask?

What I meant here is that even without your change, it is relatively
easy to cause many SAs to be hashed to the same bucket.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
