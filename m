From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: arp_hash
Date: Mon, 23 Mar 2015 08:21:10 +1100
Message-ID: <20150322212110.GB7925@gondor.apana.org.au>
References: <20150322114204.GA5010@gondor.apana.org.au>
 <1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:49924 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbbCVVVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 17:21:13 -0400
Content-Disposition: inline
In-Reply-To: <1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 05:56:21AM -0700, Eric Dumazet wrote:
>
> On x86_64, hash32_ptr(ptr) is not (0xffffffff ^ ptr) please look again.

OK it's not 0xffffffff but it's just as easy to figure out, you
can just cat /proc/net/unix.  On my machine everything starts at
0xffff880X and you can be pretty sure that if device was allocated
at boot then it's 0xffff8800.

And in my git tree it says:

static inline u32 hash32_ptr(const void *ptr)
{
	unsigned long val = (unsigned long)ptr;

#if BITS_PER_LONG == 64
	val ^= (val >> 32);
#endif
	return (u32)val;
}

What am I missing?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
