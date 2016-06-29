From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Wed, 29 Jun 2016 23:38:18 +0800
Message-ID: <20160629153818.GA29838@gondor.apana.org.au>
References: <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
 <20160628034150.GA13953@gondor.apana.org.au>
 <CALCETrXOT-zaV8O1Yu4RGybGvPv5C7gr=7EWjTKvUQUaRxz1aQ@mail.gmail.com>
 <20160629022337.GB23390@gondor.apana.org.au>
 <CALCETrW3zzMRazohKfOh7PKb5jegJOmyrC7EiCEF0eQ5SArNyg@mail.gmail.com>
 <20160629150257.GA29490@gondor.apana.org.au>
 <CALCETrVKjwKkzR+qwsC=DMvM9tR4beAtvw=LLjzsAyuztV4bWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40610 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbcF2Pi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 11:38:26 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrVKjwKkzR+qwsC=DMvM9tR4beAtvw=LLjzsAyuztV4bWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016 at 08:26:43AM -0700, Andy Lutomirski wrote:
> 
> Two reasons:
> 
> 1. Code like tcp md5 would be simpler if it could pass a scatterlist
> to hash the skb but use a virtual address for the header.

True.  But I bet we can make it simpler in other ways without
creating special interfaces for it.  Look at how we do IPsec
encryption/hashing, this is what TCP md5 should look like.  But
nobody in their right mind would bother doing this because this
is dead code.

> 2. The actual calling sequence and the amount of indirection is much
> less for shash, so hashing short buffer is probably *much* faster.

Really?

Have you measured the speed difference between the ahash and shash
interfaces? Are you sure that this would matter when compared
against the speed of hashing a single MD5 block?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
