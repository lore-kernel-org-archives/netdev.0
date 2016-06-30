From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Thu, 30 Jun 2016 11:45:20 +0800
Message-ID: <20160630034520.GA2049@gondor.apana.org.au>
References: <20160628034150.GA13953@gondor.apana.org.au>
 <CALCETrXOT-zaV8O1Yu4RGybGvPv5C7gr=7EWjTKvUQUaRxz1aQ@mail.gmail.com>
 <20160629022337.GB23390@gondor.apana.org.au>
 <CALCETrW3zzMRazohKfOh7PKb5jegJOmyrC7EiCEF0eQ5SArNyg@mail.gmail.com>
 <20160629150257.GA29490@gondor.apana.org.au>
 <CALCETrVKjwKkzR+qwsC=DMvM9tR4beAtvw=LLjzsAyuztV4bWw@mail.gmail.com>
 <20160629153818.GA29838@gondor.apana.org.au>
 <CALCETrUR1+au2-11qSAT24832nZcTwjUj8UY09rCMisyHawnaA@mail.gmail.com>
 <1467236646.6369.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrWUOuwaUrwkU9ywcqTK6aqQn6yNESmR3fgz6VMhwAnQdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54307 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbcF3Dp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 23:45:29 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrWUOuwaUrwkU9ywcqTK6aqQn6yNESmR3fgz6VMhwAnQdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016 at 03:39:37PM -0700, Andy Lutomirski wrote:
>
> I don't care about TCP MD5 performance at all.  Ease of maintenance is
> nice, though, and maybe there are other places in the kernel where
> performance does matter.

TCP MD5 is using ahash because it touches SG lists.  Touching
SG lists is a pretty reliable indicator for hashing a large amount
of data.  In fact TCP MD5 hashes the entire packet content so we're
talking about ~1000 bytes, just like IPsec.

Therefore it is completely pointless to use something like shash
for it as shash is only meant to be used for those hashing less
one block of data or less.

If you're aware of any other user in the kernel that is using
ahash and is hashing a small amount of data in aggregate (not
per update) please let me know.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
