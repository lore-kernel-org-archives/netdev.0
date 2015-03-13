From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/6] rhashtable: Move seed init into bucket_table_alloc
Date: Fri, 13 Mar 2015 22:40:18 +1100
Message-ID: <20150313114018.GA3439@gondor.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWMLA-0000Bg-H9@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAFE8C4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:58809 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbbCMLki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 07:40:38 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAFE8C4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 11:33:39AM +0000, David Laight wrote:
>
> If the decision to resize a hash table is based on the length
> of the hash chains, then changing the hash function might either
> make that unnecessary or make an immediate resize be needed.

My plan is to trigger a delayed resize (as we do now) if we're
over 75%.

If we get a chain length above 4 then we do an immediate resize
if we're already over 75% and the delayed resize hasn't started
yet, otherwise we do an immediate rehash with no change in the
hash table size.

Note that in my new scheme the rehash will contain two distinct
parts.  The first part that is executed immediately will only
involve allocating the hash table.

The hard work of movings across is always performed in the kernel
thread.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
