From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 6688] Memory allocation problem
Date: Wed, 12 Jul 2006 21:44:46 +1000
Message-ID: <E1G0d94-0004My-00@gondolin.me.apana.org.au>
References: <20060620002433.28115714.akpm@osdl.org>
Cc: netdev@vger.kernel.org, pstaszewski@artcom.pl,
	Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49937 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751266AbWGLLpL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 07:45:11 -0400
To: davem@davemloft.net, akpm@osdl.org (Andrew Morton)
In-Reply-To: <20060620002433.28115714.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> On Mon, 19 Jun 2006 23:46:08 -0700
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=6688
> 
> This is looking like a net memory leak in 2.6.16.  1/3rd is in ip_fib_alias
> and 2/3rds is in size-64.  I've asked the reporter to apply the leak
> detector patch so we can find out who is using the size-64 part.

I had a look at fib_trie.c and found a bug.  This is probably not the
cause of the leak since it looks more likely to cause a crash than
anything.  However, please retest with this applied just to be sure.

[IPV4]: Fix error handling for fib_insert_node call

The error handling around fib_insert_node was broken because we always
zeroed the error before checking it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
