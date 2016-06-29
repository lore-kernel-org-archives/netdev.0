From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Wed, 29 Jun 2016 23:02:57 +0800
Message-ID: <20160629150257.GA29490@gondor.apana.org.au>
References: <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
 <20160628034150.GA13953@gondor.apana.org.au>
 <CALCETrXOT-zaV8O1Yu4RGybGvPv5C7gr=7EWjTKvUQUaRxz1aQ@mail.gmail.com>
 <20160629022337.GB23390@gondor.apana.org.au>
 <CALCETrW3zzMRazohKfOh7PKb5jegJOmyrC7EiCEF0eQ5SArNyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:58730 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbcF2PEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 11:04:09 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrW3zzMRazohKfOh7PKb5jegJOmyrC7EiCEF0eQ5SArNyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016 at 07:59:22AM -0700, Andy Lutomirski wrote:
>> I suspect that, if you compare a synchronous implementation that can
> use virtual addresses to a DMA based implementation that can't, you'll
> find that, for short messages like tcp md5 uses, the synchronous
> implementation would win every time.  I'm wondering if shash should
> gain the ability to use scatterlists and, if it doesn't already have
> it, the ability to use synchronous hardware implementations (like
> SHA-NI, for example, although I don't think that's useful for MD5).

I don't understand, if you add SGs to shash you get ahash.  So
why wouldn't you just use ahash?

AFAICS tcp md5 already uses ahash in sync mode so there is nothing
asynchronous here at all.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
